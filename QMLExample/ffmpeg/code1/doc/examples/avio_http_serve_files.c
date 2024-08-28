/*
 * Copyright (c) 2015 Stephan Holljes
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/**
 * @file libavformat multi-client network API usage example
 * @example avio_http_serve_files.c
 *
 * Serve a file without decoding or demuxing it over the HTTP protocol. Multiple
 * clients can connect and will receive the same file.
 */

#include <libavformat/avformat.h>
#include <libavutil/opt.h>
#include <unistd.h>

// 处理客户端连接
static void process_client(AVIOContext *client, const char *in_uri)
{
    AVIOContext *input = NULL;
    uint8_t buf[1024];
    int ret, n, reply_code;
    uint8_t *resource = NULL;
    // 进行握手
    while ((ret = avio_handshake(client)) > 0) {
        av_opt_get(client, "resource", AV_OPT_SEARCH_CHILDREN, &resource);
        // 检查resource的长度，因为av_opt_get()可能返回空字符串。
        if (resource && strlen(resource))
            break;
        av_freep(&resource);
    }
    if (ret < 0)
        goto end;
    av_log(client, AV_LOG_TRACE, "resource=%p\n", resource);
    // 检查资源是否匹配
    if (resource && resource[0] == '/' && !strcmp((resource + 1), in_uri)) {
        reply_code = 200;
    } else {
        reply_code = AVERROR_HTTP_NOT_FOUND;
    }
    // 设置回复代码
    if ((ret = av_opt_set_int(client, "reply_code", reply_code, AV_OPT_SEARCH_CHILDREN)) < 0) {
        av_log(client, AV_LOG_ERROR, "Failed to set reply_code: %s.\n", av_err2str(ret));
        goto end;
    }
    av_log(client, AV_LOG_TRACE, "Set reply code to %d\n", reply_code);

    // 再次进行握手
    while ((ret = avio_handshake(client)) > 0);

    if (ret < 0)
        goto end;

    fprintf(stderr, "Handshake performed.\n");
    // 检查回复代码
    if (reply_code != 200)
        goto end;
    fprintf(stderr, "Opening input file.\n");
    // 打开输入文件
    if ((ret = avio_open2(&input, in_uri, AVIO_FLAG_READ, NULL, NULL)) < 0) {
        av_log(input, AV_LOG_ERROR, "Failed to open input: %s: %s.\n", in_uri,
               av_err2str(ret));
        goto end;
    }
    // 读取输入文件并写入客户端
    for(;;) {
        n = avio_read(input, buf, sizeof(buf));
        if (n < 0) {
            if (n == AVERROR_EOF)
                break;
            av_log(input, AV_LOG_ERROR, "Error reading from input: %s.\n",
                   av_err2str(n));
            break;
        }
        avio_write(client, buf, n);
        avio_flush(client);
    }
end:
    fprintf(stderr, "Flushing client\n");
    avio_flush(client);
    fprintf(stderr, "Closing client\n");
    avio_close(client);
    fprintf(stderr, "Closing input\n");
    avio_close(input);
    av_freep(&resource);
}

int main(int argc, char **argv)
{
    AVDictionary *options = NULL;
    AVIOContext *client = NULL, *server = NULL;
    const char *in_uri, *out_uri;
    int ret, pid;
    // 设置日志级别
    av_log_set_level(AV_LOG_TRACE);
    // 检查参数数量
    if (argc < 3) {
        printf("usage: %s input http://hostname[:port]\n"
               "API example program to serve http to multiple clients.\n"
               "\n", argv[0]);
        return 1;
    }

    in_uri = argv[1];
    out_uri = argv[2];

    // 初始化网络
    avformat_network_init();

    // 设置服务器监听模式
    if ((ret = av_dict_set(&options, "listen", "2", 0)) < 0) {
        fprintf(stderr, "Failed to set listen mode for server: %s\n", av_err2str(ret));
        return ret;
    }
    // 打开服务器
    if ((ret = avio_open2(&server, out_uri, AVIO_FLAG_WRITE, NULL, &options)) < 0) {
        fprintf(stderr, "Failed to open server: %s\n", av_err2str(ret));
        return ret;
    }
    fprintf(stderr, "Entering main loop.\n");
    // 主循环
    for(;;) {
        // 接受客户端连接
        if ((ret = avio_accept(server, &client)) < 0)
            goto end;
        fprintf(stderr, "Accepted client, forking process.\n");
        // XXX: Since we don't reap our children and don't ignore signals
        //      this produces zombie processes.
        pid = fork();
        if (pid < 0) {
            perror("Fork failed");
            ret = AVERROR(errno);
            goto end;
        }
        if (pid == 0) {
            fprintf(stderr, "In child.\n");
            // 处理客户端连接
            process_client(client, in_uri);
            avio_close(server);
            exit(0);
        }
        if (pid > 0)
            avio_close(client);
    }
end:
    avio_close(server);
    if (ret < 0 && ret != AVERROR_EOF) {
        fprintf(stderr, "Some errors occurred: %s\n", av_err2str(ret));
        return 1;
    }
    return 0;
}