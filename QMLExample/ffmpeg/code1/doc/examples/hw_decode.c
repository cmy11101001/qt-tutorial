/*
 * Copyright (c) 2017 Jun Zhao
 * Copyright (c) 2017 Kaixuan Liu
 *
 * HW Acceleration API (video decoding) decode sample
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
 * @file HW-accelerated decoding API usage.example
 * @example hw_decode.c
 *
 * Perform HW-accelerated decoding with output frames from HW video
 * surfaces.
 */

#include <stdio.h>

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/pixdesc.h>
#include <libavutil/hwcontext.h>
#include <libavutil/opt.h>
#include <libavutil/avassert.h>
#include <libavutil/imgutils.h>

// 定义硬件设备上下文和硬件像素格式
static AVBufferRef *hw_device_ctx = NULL;
static enum AVPixelFormat hw_pix_fmt;
static FILE *output_file = NULL;

// 初始化硬件解码器
static int hw_decoder_init(AVCodecContext *ctx, const enum AVHWDeviceType type)
{
    int err = 0;

    // 创建指定的硬件设备
    if ((err = av_hwdevice_ctx_create(&hw_device_ctx, type,
                                      NULL, NULL, 0)) < 0) {
        fprintf(stderr, "Failed to create specified HW device.\n");
        return err;
    }
    // 将硬件设备上下文引用到解码器上下文中
    ctx->hw_device_ctx = av_buffer_ref(hw_device_ctx);

    return err;
}

// 获取硬件表面格式
static enum AVPixelFormat get_hw_format(AVCodecContext *ctx,
                                        const enum AVPixelFormat *pix_fmts)
{
    const enum AVPixelFormat *p;

    // 遍历像素格式
    for (p = pix_fmts; *p != -1; p++) {
        // 如果找到硬件像素格式，则返回
        if (*p == hw_pix_fmt)
            return *p;
    }

    fprintf(stderr, "Failed to get HW surface format.\n");
    return AV_PIX_FMT_NONE;
}

// 解码并写入数据
static int decode_write(AVCodecContext *avctx, AVPacket *packet)
{
    AVFrame *frame = NULL, *sw_frame = NULL;
    AVFrame *tmp_frame = NULL;
    uint8_t *buffer = NULL;
    int size;
    int ret = 0;

    // 发送数据包到解码器
    ret = avcodec_send_packet(avctx, packet);
    if (ret < 0) {
        fprintf(stderr, "Error during decoding\n");
        return ret;
    }

    // 循环接收解码后的帧
    while (1) {
        // 分配帧
        if (!(frame = av_frame_alloc()) || !(sw_frame = av_frame_alloc())) {
            fprintf(stderr, "Can not alloc frame\n");
            ret = AVERROR(ENOMEM);
            goto fail;
        }

        // 接收解码后的帧
        ret = avcodec_receive_frame(avctx, frame);
        // 如果没有更多的帧，则返回
        if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
            av_frame_free(&frame);
            av_frame_free(&sw_frame);
            return 0;
        } else if (ret < 0) {
            fprintf(stderr, "Error while decoding\n");
            goto fail;
        }

        // 如果帧的格式是硬件像素格式，则从GPU传输数据到CPU
        if (frame->format == hw_pix_fmt) {
            if ((ret = av_hwframe_transfer_data(sw_frame, frame, 0)) < 0) {
                fprintf(stderr, "Error transferring the data to system memory\n");
                goto fail;
            }
            tmp_frame = sw_frame;
        } else
            tmp_frame = frame;

        // 获取帧的大小
        size = av_image_get_buffer_size(tmp_frame->format, tmp_frame->width,
                                        tmp_frame->height, 1);
        // 分配缓冲区
        buffer = av_malloc(size);
        if (!buffer) {
            fprintf(stderr, "Can not alloc buffer\n");
            ret = AVERROR(ENOMEM);
            goto fail;
        }
        // 将图像数据复制到缓冲区
        ret = av_image_copy_to_buffer(buffer, size,
                                      (const uint8_t * const *)tmp_frame->data,
                                      (const int *)tmp_frame->linesize, tmp_frame->format,
                                      tmp_frame->width, tmp_frame->height, 1);
        if (ret < 0) {
            fprintf(stderr, "Can not copy image to buffer\n");
            goto fail;
        }

        // 将缓冲区数据写入文件
        if ((ret = fwrite(buffer, 1, size, output_file)) < 0) {
            fprintf(stderr, "Failed to dump raw data.\n");
            goto fail;
        }

    fail:
        av_frame_free(&frame);
        av_frame_free(&sw_frame);
        av_freep(&buffer);
        if (ret < 0)
            return ret;
    }
}

int main(int argc, char *argv[])
{
    AVFormatContext *input_ctx = NULL;
    int video_stream, ret;
    AVStream *video = NULL;
    AVCodecContext *decoder_ctx = NULL;
    const AVCodec *decoder = NULL;
    AVPacket *packet = NULL;
    enum AVHWDeviceType type;
    int i;

    // 检查参数数量
    if (argc < 4) {
        fprintf(stderr, "Usage: %s <device type> <input file> <output file>\n", argv[0]);
        return -1;
    }

    // 获取硬件设备类型
    type = av_hwdevice_find_type_by_name(argv[1]);
    if (type == AV_HWDEVICE_TYPE_NONE) {
        fprintf(stderr, "Device type %s is not supported.\n", argv[1]);
        fprintf(stderr, "Available device types:");
        // 遍历所有支持的硬件设备类型
        while((type = av_hwdevice_iterate_types(type)) != AV_HWDEVICE_TYPE_NONE)
            fprintf(stderr, " %s", av_hwdevice_get_type_name(type));
        fprintf(stderr, "\n");
        return -1;
    }

    // 分配数据包
    packet = av_packet_alloc();
    if (!packet) {
        fprintf(stderr, "Failed to allocate AVPacket\n");
        return -1;
    }

    // 打开输入文件
    if (avformat_open_input(&input_ctx, argv[2], NULL, NULL) != 0) {
        fprintf(stderr, "Cannot open input file '%s'\n", argv[2]);
        return -1;
    }

    // 获取输入流信息
    if (avformat_find_stream_info(input_ctx, NULL) < 0) {
        fprintf(stderr, "Cannot find input stream information.\n");
        return -1;
    }

    // 查找视频流信息
    ret = av_find_best_stream(input_ctx, AVMEDIA_TYPE_VIDEO, -1, -1, &decoder, 0);
    if (ret < 0) {
        fprintf(stderr, "Cannot find a video stream in the input file\n");
        return -1;
    }
    video_stream = ret;

    // 遍历解码器配置
    for (i = 0;; i++) {
        const AVCodecHWConfig *config = avcodec_get_hw_config(decoder, i);
        if (!config) {
            fprintf(stderr, "Decoder %s does not support device type %s.\n",
                    decoder->name, av_hwdevice_get_type_name(type));
            return -1;
        }
        // 如果解码器支持硬件设备上下文和设备类型，则获取硬件像素格式
        if (config->methods & AV_CODEC_HW_CONFIG_METHOD_HW_DEVICE_CTX &&
            config->device_type == type) {
            hw_pix_fmt = config->pix_fmt;
            break;
        }
    }

    // 分配解码器上下文
    if (!(decoder_ctx = avcodec_alloc_context3(decoder)))
        return AVERROR(ENOMEM);

    // 获取视频流
    video = input_ctx->streams[video_stream];
    // 将视频流参数复制到解码器上下文中
    if (avcodec_parameters_to_context(decoder_ctx, video->codecpar) < 0)
        return -1;

    // 设置解码器获取格式函数
    decoder_ctx->get_format  = get_hw_format;

    // 初始化硬件解码器
    if (hw_decoder_init(decoder_ctx, type) < 0)
        return -1;

    // 打开解码器
    if ((ret = avcodec_open2(decoder_ctx, decoder, NULL)) < 0) {
        fprintf(stderr, "Failed to open codec for stream #%u\n", video_stream);
        return -1;
    }

    // 打开输出文件
    output_file = fopen(argv[3], "w+b");

    // 实际解码并写入数据
    while (ret >= 0) {
        // 读取数据包
        if ((ret = av_read_frame(input_ctx, packet)) < 0)
            break;

        // 如果是视频流，则解码并写入数据
        if (video_stream == packet->stream_index)
            ret = decode_write(decoder_ctx, packet);

        // 释放数据包
        av_packet_unref(packet);
    }

    // 刷新解码器
    ret = decode_write(decoder_ctx, NULL);

    // 关闭输出文件
    if (output_file)
        fclose(output_file);
    // 释放数据包
    av_packet_free(&packet);
    // 释放解码器上下文
    avcodec_free_context(&decoder_ctx);
    // 关闭输入文件
    avformat_close_input(&input_ctx);
    // 释放硬件设备上下文
    av_buffer_unref(&hw_device_ctx);

    return 0;
}