/*
 * copyright (c) 2013 Andrew Kelley
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/**
 * @file libavfilter audio filtering API usage example
 * @example filter_audio.c
 *
 * This example will generate a sine wave audio, pass it through a simple filter
 * chain, and then compute the MD5 checksum of the output data.
 *
 * The filter chain it uses is:
 * (input) -> abuffer -> volume -> aformat -> abuffersink -> (output)
 *
 * abuffer: This provides the endpoint where you can feed the decoded samples.
 * volume: In this example we hardcode it to 0.90.
 * aformat: This converts the samples to the samplefreq, channel layout,
 *          and sample format required by the audio device.
 * abuffersink: This provides the endpoint where you can read the samples after
 *              they have passed through the filter chain.
 */

#include <inttypes.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "libavutil/channel_layout.h"
#include "libavutil/md5.h"
#include "libavutil/mem.h"
#include "libavutil/opt.h"
#include "libavutil/samplefmt.h"

#include "libavfilter/avfilter.h"
#include "libavfilter/buffersink.h"
#include "libavfilter/buffersrc.h"

#define INPUT_SAMPLERATE     48000
#define INPUT_FORMAT         AV_SAMPLE_FMT_FLTP
#define INPUT_CHANNEL_LAYOUT (AVChannelLayout)AV_CHANNEL_LAYOUT_5POINT0

#define VOLUME_VAL 0.90

// 初始化过滤器图
static int init_filter_graph(AVFilterGraph **graph, AVFilterContext **src,
                             AVFilterContext **sink)
{
    AVFilterGraph *filter_graph;
    AVFilterContext *abuffer_ctx;
    const AVFilter  *abuffer;
    AVFilterContext *volume_ctx;
    const AVFilter  *volume;
    AVFilterContext *aformat_ctx;
    const AVFilter  *aformat;
    AVFilterContext *abuffersink_ctx;
    const AVFilter  *abuffersink;

    AVDictionary *options_dict = NULL;
    uint8_t options_str[1024];
    uint8_t ch_layout[64];

    int err;

    // 创建一个新的过滤器图，它将包含所有的过滤器
    filter_graph = avfilter_graph_alloc();
    if (!filter_graph) {
        fprintf(stderr, "Unable to create filter graph.\n");
        return AVERROR(ENOMEM);
    }

    // 创建abuffer过滤器；它将用于将解码后的样本输入到图中
    abuffer = avfilter_get_by_name("abuffer");
    if (!abuffer) {
        fprintf(stderr, "Could not find the abuffer filter.\n");
        return AVERROR_FILTER_NOT_FOUND;
    }

    abuffer_ctx = avfilter_graph_alloc_filter(filter_graph, abuffer, "src");
    if (!abuffer_ctx) {
        fprintf(stderr, "Could not allocate the abuffer instance.\n");
        return AVERROR(ENOMEM);
    }

    // 通过AVOptions API设置过滤器的选项
    av_channel_layout_describe(&INPUT_CHANNEL_LAYOUT, ch_layout, sizeof(ch_layout));
    av_opt_set    (abuffer_ctx, "channel_layout", ch_layout,                            AV_OPT_SEARCH_CHILDREN);
    av_opt_set    (abuffer_ctx, "sample_fmt",     av_get_sample_fmt_name(INPUT_FORMAT), AV_OPT_SEARCH_CHILDREN);
    av_opt_set_q  (abuffer_ctx, "time_base",      (AVRational){ 1, INPUT_SAMPLERATE },  AV_OPT_SEARCH_CHILDREN);
    av_opt_set_int(abuffer_ctx, "sample_rate",    INPUT_SAMPLERATE,                     AV_OPT_SEARCH_CHILDREN);

    // 初始化过滤器；我们传递NULL选项，因为我们已经在上面的选项中设置了所有选项
    err = avfilter_init_str(abuffer_ctx, NULL);
    if (err < 0) {
        fprintf(stderr, "Could not initialize the abuffer filter.\n");
        return err;
    }

    // 创建volume过滤器。
    volume = avfilter_get_by_name("volume");
    if (!volume) {
        fprintf(stderr, "Could not find the volume filter.\n");
        return AVERROR_FILTER_NOT_FOUND;
    }

    volume_ctx = avfilter_graph_alloc_filter(filter_graph, volume, "volume");
    if (!volume_ctx) {
        fprintf(stderr, "Could not allocate the volume instance.\n");
        return AVERROR(ENOMEM);
    }

    // 通过字典的方式传递选项
    av_dict_set(&options_dict, "volume", AV_STRINGIFY(VOLUME_VAL), 0);
    err = avfilter_init_dict(volume_ctx, &options_dict);
    av_dict_free(&options_dict);
    if (err < 0) {
        fprintf(stderr, "Could not initialize the volume filter.\n");
        return err;
    }

    // 创建aformat过滤器；
    // 它确保输出是所需的格式
    aformat = avfilter_get_by_name("aformat");
    if (!aformat) {
        fprintf(stderr, "Could not find the aformat filter.\n");
        return AVERROR_FILTER_NOT_FOUND;
    }

    aformat_ctx = avfilter_graph_alloc_filter(filter_graph, aformat, "aformat");
    if (!aformat_ctx) {
        fprintf(stderr, "Could not allocate the aformat instance.\n");
        return AVERROR(ENOMEM);
    }

    // 通过字符串的方式传递选项
    snprintf(options_str, sizeof(options_str),
             "sample_fmts=%s:sample_rates=%d:channel_layouts=stereo",
             av_get_sample_fmt_name(AV_SAMPLE_FMT_S16), 44100);
    err = avfilter_init_str(aformat_ctx, options_str);
    if (err < 0) {
        av_log(NULL, AV_LOG_ERROR, "Could not initialize the aformat filter.\n");
        return err;
    }

    // 最后创建abuffersink过滤器；
    // 它将用于从图中获取过滤后的数据
    abuffersink = avfilter_get_by_name("abuffersink");
    if (!abuffersink) {
        fprintf(stderr, "Could not find the abuffersink filter.\n");
        return AVERROR_FILTER_NOT_FOUND;
    }

    abuffersink_ctx = avfilter_graph_alloc_filter(filter_graph, abuffersink, "sink");
    if (!abuffersink_ctx) {
        fprintf(stderr, "Could not allocate the abuffersink instance.\n");
        return AVERROR(ENOMEM);
    }

    // 这个过滤器不需要选项
    err = avfilter_init_str(abuffersink_ctx, NULL);
    if (err < 0) {
        fprintf(stderr, "Could not initialize the abuffersink instance.\n");
        return err;
    }

    // 连接过滤器；
    // 在这个简单的情况下，过滤器只是形成了一个线性链
    err = avfilter_link(abuffer_ctx, 0, volume_ctx, 0);
    if (err >= 0)
        err = avfilter_link(volume_ctx, 0, aformat_ctx, 0);
    if (err >= 0)
        err = avfilter_link(aformat_ctx, 0, abuffersink_ctx, 0);
    if (err < 0) {
        fprintf(stderr, "Error connecting filters\n");
        return err;
    }

    // 配置过滤器图
    err = avfilter_graph_config(filter_graph, NULL);
    if (err < 0) {
        av_log(NULL, AV_LOG_ERROR, "Error configuring the filter graph\n");
        return err;
    }

    *graph = filter_graph;
    *src   = abuffer_ctx;
    *sink  = abuffersink_ctx;

    return 0;
}

// 对过滤后的数据进行有用的操作：这个简单的例子只是打印每个平面的MD5校验和到stdout
static int process_output(struct AVMD5 *md5, AVFrame *frame)
{
    int planar     = av_sample_fmt_is_planar(frame->format);
    int channels   = frame->ch_layout.nb_channels;
    int planes     = planar ? channels : 1;
    int bps        = av_get_bytes_per_sample(frame->format);
    int plane_size = bps * frame->nb_samples * (planar ? 1 : channels);
    int i, j;

    for (i = 0; i < planes; i++) {
        uint8_t checksum[16];

        av_md5_init(md5);
        av_md5_sum(checksum, frame->extended_data[i], plane_size);

        fprintf(stdout, "plane %d: 0x", i);
        for (j = 0; j < sizeof(checksum); j++)
            fprintf(stdout, "%02X", checksum[j]);
        fprintf(stdout, "\n");
    }
    fprintf(stdout, "\n");

    return 0;
}

// 构造一个要过滤的音频数据帧；
// 这个简单的例子只是合成一个正弦波
static int get_input(AVFrame *frame, int frame_num)
{
    int err, i, j;

#define FRAME_SIZE 1024

    // 设置帧属性并分配数据缓冲区
    frame->sample_rate    = INPUT_SAMPLERATE;
    frame->format         = INPUT_FORMAT;
    av_channel_layout_copy(&frame->ch_layout, &INPUT_CHANNEL_LAYOUT);
    frame->nb_samples     = FRAME_SIZE;
    frame->pts            = frame_num * FRAME_SIZE;

    err = av_frame_get_buffer(frame, 0);
    if (err < 0)
        return err;

    // 为每个通道填充数据
    for (i = 0; i < 5; i++) {
        float *data = (float*)frame->extended_data[i];

        for (j = 0; j < frame->nb_samples; j++)
            data[j] = sin(2 * M_PI * (frame_num + j) * (i + 1) / FRAME_SIZE);
    }

    return 0;
}

int main(int argc, char *argv[])
{
    struct AVMD5 *md5;
    AVFilterGraph *graph;
    AVFilterContext *src, *sink;
    AVFrame *frame;
    uint8_t errstr[1024];
    float duration;
    int err, nb_frames, i;

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <duration>\n", argv[0]);
        return 1;
    }

    duration  = atof(argv[1]);
    nb_frames = duration * INPUT_SAMPLERATE / FRAME_SIZE;
    if (nb_frames <= 0) {
        fprintf(stderr, "Invalid duration: %s\n", argv[1]);
        return 1;
    }

    // 分配我们将使用的帧
    frame  = av_frame_alloc();
    if (!frame) {
        fprintf(stderr, "Error allocating the frame\n");
        return 1;
    }

    md5 = av_md5_alloc();
    if (!md5) {
        fprintf(stderr, "Error allocating the MD5 context\n");
        return 1;
    }

    // 设置过滤器图
    err = init_filter_graph(&graph, &src, &sink);
    if (err < 0) {
        fprintf(stderr, "Unable to init filter graph:");
        goto fail;
    }

    // 主过滤循环
    for (i = 0; i < nb_frames; i++) {
        // 获取要过滤的输入帧
        err = get_input(frame, i);
        if (err < 0) {
            fprintf(stderr, "Error generating input frame:");
            goto fail;
        }

        // 将帧发送到过滤图的输入
        err = av_buffersrc_add_frame(src, frame);
        if (err < 0) {
            av_frame_unref(frame);
            fprintf(stderr, "Error submitting the frame to the filtergraph:");
            goto fail;
        }

        // 获取所有可用的过滤输出
        while ((err = av_buffersink_get_frame(sink, frame)) >= 0) {
            // 现在做一些有用的事情
            err = process_output(md5, frame);
            if (err < 0) {
                fprintf(stderr, "Error processing the filtered frame:");
                goto fail;
            }
            av_frame_unref(frame);
        }

        if (err == AVERROR(EAGAIN)) {
            // 需要输入更多的帧
            continue;
        } else if (err == AVERROR_EOF) {
            // 没有更多要做的，完成
            break;
        } else if (err < 0) {
            // 发生错误
            fprintf(stderr, "Error filtering the data:");
            goto fail;
        }
    }

    avfilter_graph_free(&graph);
    av_frame_free(&frame);
    av_freep(&md5);

    return 0;

fail:
    av_strerror(err, errstr, sizeof(errstr));
    fprintf(stderr, "%s\n", errstr);
    return 1;
}