#include "exampleffmpeg.h"
//引入ffmpeg头文件
#include "ffmpeginclude.h"

ExampleFFMPEG::ExampleFFMPEG(QObject *parent)
    : QObject{parent}
{

}

//! --------------------- encode_audio ---------------------
/** 检查编码器是否支持给定的示例格式 */
static int check_sample_fmt(const AVCodec *codec, enum AVSampleFormat sample_fmt)
{
    const enum AVSampleFormat *p = codec->sample_fmts;

    while (*p != AV_SAMPLE_FMT_NONE) {
        if (*p == sample_fmt)
            return 1;
        p++;
    }
    return 0;
}

/** 就选择支持的最高采样率 */
static int select_sample_rate(const AVCodec *codec)
{
    const int *p;
    int best_samplerate = 0;

    if (!codec->supported_samplerates)
        return 44100;

    p = codec->supported_samplerates;
    while (*p) {
        if (!best_samplerate || abs(44100 - *p) < abs(44100 - best_samplerate))
            best_samplerate = *p;
        p++;
    }
    return best_samplerate;
}

/** 选择具有最高通道数的布局 */
static int select_channel_layout(const AVCodec *codec, AVChannelLayout *dst)
{
    const AVChannelLayout *p, *best_ch_layout;
    int best_nb_channels   = 0;

    if (!codec->ch_layouts) {
        AVChannelLayout layout = AV_CHANNEL_LAYOUT_STEREO;
        return av_channel_layout_copy(dst, &layout);
    }

    p = codec->ch_layouts;
    while (p->nb_channels) {
        int nb_channels = p->nb_channels;

        if (nb_channels > best_nb_channels) {
            best_ch_layout   = p;
            best_nb_channels = nb_channels;
        }
        p++;
    }
    return av_channel_layout_copy(dst, best_ch_layout);
}

/** 编码音频帧 */
static void _encode_audio(AVCodecContext *ctx, AVFrame *frame, AVPacket *pkt,
                   FILE *output)
{
    int ret;

    /* 发送帧进行编码 */
    ret = avcodec_send_frame(ctx, frame);
    if (ret < 0) {
        fprintf(stderr, "将帧发送至编码器时出错\n");
        exit(1);
    }

    /* 读取所有可用的输出数据包（它们通常可能有任意数量） */
    while (ret >= 0) {
        ret = avcodec_receive_packet(ctx, pkt);
        if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF)
            return;
        else if (ret < 0) {
            fprintf(stderr, "错误编码音频帧\n");
            exit(1);
        }

        fwrite(pkt->data, 1, pkt->size, output);
        av_packet_unref(pkt);
    }
}

/** 编码：生成一段音频 */
void ExampleFFMPEG::encode_audio(const char *filename)
{
    const AVCodec *codec;
    AVCodecContext *c= NULL;
    AVFrame *frame;
    AVPacket *pkt;
    int i, j, k, ret;
    FILE *f;
    uint16_t *samples;
    float t, tincr;

    /* 找到MP2编码器 */
    codec = avcodec_find_encoder(AV_CODEC_ID_MP2);
    if (!codec) {
        fprintf(stderr, "编解码器未找到\n");
        exit(1);
    }

    /* 创建MP2编码器实例 */
    c = avcodec_alloc_context3(codec);
    if (!c) {
        fprintf(stderr, "无法分配音频编解码器上下文\n");
        exit(1);
    }

    /* 设置比特率参数 */
    c->bit_rate = 64000;

    /* 检查编码器是否支持s16 PCM输入 */
    c->sample_fmt = AV_SAMPLE_FMT_S16;
    if (!check_sample_fmt(codec, c->sample_fmt)) {
        fprintf(stderr, "编码器不支持样本格式 %s",
                av_get_sample_fmt_name(c->sample_fmt));
        exit(1);
    }

    /* 选择编码器支持的其他音频参数 */
    c->sample_rate    = select_sample_rate(codec);
    ret = select_channel_layout(codec, &c->ch_layout);
    if (ret < 0)
        exit(1);

    /* 打开它 */
    if (avcodec_open2(c, codec, NULL) < 0) {
        fprintf(stderr, "无法打开编解码器\n");
        exit(1);
    }

    f = fopen(filename, "wb");
    if (!f) {
        fprintf(stderr, "无法打开 %s\n", filename);
        exit(1);
    }

    /* 用于存放编码输出的数据包 */
    pkt = av_packet_alloc();
    if (!pkt) {
        fprintf(stderr, "无法分配该数据包\n");
        exit(1);
    }

    /* 包含输入原始音频的帧 */
    frame = av_frame_alloc();
    if (!frame) {
        fprintf(stderr, "无法分配音频帧\n");
        exit(1);
    }

    frame->nb_samples     = c->frame_size;
    frame->format         = c->sample_fmt;
    ret = av_channel_layout_copy(&frame->ch_layout, &c->ch_layout);
    if (ret < 0)
        exit(1);

    /* 分配数据缓存 */
    ret = av_frame_get_buffer(frame, 0);
    if (ret < 0) {
        fprintf(stderr, "无法分配音频数据缓存\n");
        exit(1);
    }

    /* 编码一个单音音调 */
    t = 0;
    tincr = 2 * M_PI * 440.0 / c->sample_rate;
    for (i = 0; i < 200; i++) {
        /* 检查并确保数据帧（frame）是可被写入的。
         * 如果编码器（encoder）内部保留了对这个数据帧的引用，
         * 那么为了不修改到原引用的数据，会创建这个数据帧的一个副本进行操作 */
        ret = av_frame_make_writable(frame);
        if (ret < 0)
            exit(1);
        samples = (uint16_t*)frame->data[0];

        for (j = 0; j < c->frame_size; j++) {
            samples[2*j] = (int)(sin(t) * 10000);

            for (k = 1; k < c->ch_layout.nb_channels; k++)
                samples[2*j + k] = samples[2*j];
            t += tincr;
        }
        _encode_audio(c, frame, pkt, f);
    }

    /* 刷新编码器 */
    _encode_audio(c, NULL, pkt, f);

    fclose(f);

    av_frame_free(&frame);
    av_packet_free(&pkt);
    avcodec_free_context(&c);
}

//! --------------------- encode_video ---------------------
/** 编码视频帧 */
static void _encode_video(AVCodecContext *enc_ctx, AVFrame *frame, AVPacket *pkt,
                   FILE *outfile)
{
    int ret;

    // 将帧发送到编码器
    if (frame) {
        qDebug("发送帧 %lld", frame->pts);
    }

    // 发送帧到编码器
    ret = avcodec_send_frame(enc_ctx, frame);
    if (ret < 0) {
        fprintf(stderr, "发送用于编码的帧错误\n");
        exit(1);
    }

    // 接收编码后的数据包
    while (ret >= 0) {
        ret = avcodec_receive_packet(enc_ctx, pkt);
        if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF)
            return;
        else if (ret < 0) {
            fprintf(stderr, "编码过程中出现错误\n");
            exit(1);
        }

        qDebug("写包 %lld (size=%5d)", pkt->pts, pkt->size);
        fwrite(pkt->data, 1, pkt->size, outfile);
        av_packet_unref(pkt);
    }
}

/** 编码：生成1秒的视频 */
void ExampleFFMPEG::encode_video(const char *filename, const char *codec_name)
{
    const AVCodec *codec;
    AVCodecContext *c= NULL;
    int i, ret, x, y;
    FILE *f;
    AVFrame *frame;
    AVPacket *pkt;
    uint8_t endcode[] = { 0, 0, 1, 0xb7 };

    // 查找编码器
    codec = avcodec_find_encoder_by_name(codec_name);
    if (!codec) {
        fprintf(stderr, "编解码器 '%s' 未发现\n", codec_name);
        exit(1);
    }

    // 分配编码器上下文
    c = avcodec_alloc_context3(codec);
    if (!c) {
        fprintf(stderr, "无法分配视频编解码器上下文\n");
        exit(1);
    }

    // 分配数据包
    pkt = av_packet_alloc();
    if (!pkt)
        exit(1);

    // 设置采样参数
    c->bit_rate = 400000;
    // 分辨率必须是2的倍数
    c->width = 352;
    c->height = 288;
    // 每秒帧数
    c->time_base = (AVRational){1, 25};
    c->framerate = (AVRational){25, 1};

    // 每10帧发出一个I帧
    c->gop_size = 10;
    c->max_b_frames = 1;
    c->pix_fmt = AV_PIX_FMT_YUV420P;

    // 如果是H264编码器，设置预设值
    if (codec->id == AV_CODEC_ID_H264)
        av_opt_set(c->priv_data, "preset", "slow", 0);

    // 打开编码器
    ret = avcodec_open2(c, codec, NULL);
    if (ret < 0) {
        qDebug("无法打开编解码器: %d", ret);
//        fprintf(stderr, "Could not open codec: %s\n", av_err2str(ret));
        exit(1);
    }

    // 打开输出文件
    f = fopen(filename, "wb");
    if (!f) {
        fprintf(stderr, "打不开 %s\n", filename);
        exit(1);
    }

    // 分配帧
    frame = av_frame_alloc();
    if (!frame) {
        fprintf(stderr, "无法分配视频帧\n");
        exit(1);
    }
    frame->format = c->pix_fmt;
    frame->width  = c->width;
    frame->height = c->height;

    // 分配帧数据
    ret = av_frame_get_buffer(frame, 0);
    if (ret < 0) {
        fprintf(stderr, "无法分配视频帧数据\n");
        exit(1);
    }

    // 编码1秒的视频
    for (i = 0; i < 25; i++) {
        fflush(stdout);

        // 确保帧数据可写
        ret = av_frame_make_writable(frame);
        if (ret < 0)
            exit(1);

        // 准备一个虚拟图像
        // 在实际代码中，这是你自己的逻辑，用于填充帧
        // FFmpeg不关心你放入帧的内容
        // Y
        for (y = 0; y < c->height; y++) {
            for (x = 0; x < c->width; x++) {
                frame->data[0][y * frame->linesize[0] + x] = x + y + i * 3;
            }
        }

        // Cb和Cr
        for (y = 0; y < c->height/2; y++) {
            for (x = 0; x < c->width/2; x++) {
                frame->data[1][y * frame->linesize[1] + x] = 128 + y + i * 2;
                frame->data[2][y * frame->linesize[2] + x] = 64 + x + i * 5;
            }
        }

        frame->pts = i;

        // 编码图像
        _encode_video(c, frame, pkt, f);
    }

    // 刷新编码器
    _encode_video(c, NULL, pkt, f);

    // 添加序列结束码，以生成一个真实的MPEG文件
    // 这只对一些编码器有效
    // 在这个小例子中，我们直接写入数据包
    // 要创建一个有效的文件，你通常需要将数据包写入适当的文件格式或协议
    if (codec->id == AV_CODEC_ID_MPEG1VIDEO || codec->id == AV_CODEC_ID_MPEG2VIDEO)
        fwrite(endcode, 1, sizeof(endcode), f);
    fclose(f);

    // 释放资源
    avcodec_free_context(&c);
    av_frame_free(&frame);
    av_packet_free(&pkt);
}

//! --------------------- mux ---------------------
#define STREAM_DURATION   10.0
#define STREAM_FRAME_RATE 25 /* 25帧 */
#define STREAM_PIX_FMT    AV_PIX_FMT_YUV420P /* 视频像素格式 */

#define SCALE_FLAGS SWS_BICUBIC

/** 围绕单个输出AVStream（音视频输出流）的封装 */
typedef struct OutputStream {
    AVStream *st;
    AVCodecContext *enc;

    /* 将要生成的下一帧的pts（时间戳） */
    int64_t next_pts;
    int samples_count;

    AVFrame *frame;
    AVFrame *tmp_frame;

    AVPacket *tmp_pkt;

    float t, tincr, tincr2;

    struct SwsContext *sws_ctx;
    struct SwrContext *swr_ctx;
} OutputStream;

/** 输出信息（未使用）*/
static void log_packet(const AVFormatContext *fmt_ctx, const AVPacket *pkt)
{
//    AVRational *time_base = &fmt_ctx->streams[pkt->stream_index]->time_base;

//    printf("pts:%s pts_time:%s dts:%s dts_time:%s duration:%s duration_time:%s stream_index:%d\n",
//           av_ts2str(pkt->pts), av_ts2timestr(pkt->pts, time_base),
//           av_ts2str(pkt->dts), av_ts2timestr(pkt->dts, time_base),
//           av_ts2str(pkt->duration), av_ts2timestr(pkt->duration, time_base),
//           pkt->stream_index);
}

/** 写入一帧数据（音频或视频） */
static int write_frame(AVFormatContext *fmt_ctx, AVCodecContext *c,
                       AVStream *st, AVFrame *frame, AVPacket *pkt)
{
    int ret;

    // 将帧发送到编码器
    ret = avcodec_send_frame(c, frame);
    if (ret < 0) {
        qDebug("向编码器发送帧时出错: %d\n", ret);
        exit(1);
    }

    while (ret >= 0) {
        ret = avcodec_receive_packet(c, pkt);
        if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF)
            break;
        else if (ret < 0) {
            qDebug("编码一帧时出错: %d\n", ret);
            exit(1);
        }

        /* 这里进行的是一种时间戳单位的转换，
         * 从编解码器内部的时间基准转换到输出流的时间基准，
         * 以确保时间戳在不同上下文中的一致性和准确性 */
        av_packet_rescale_ts(pkt, c->time_base, st->time_base);
        pkt->stream_index = st->index;

        /* 将压缩后的帧写入媒体文件 */
        log_packet(fmt_ctx, pkt);
        ret = av_interleaved_write_frame(fmt_ctx, pkt);
        /* pkt此时已清空（av_interleaved_write_frame()函数会接收
         * 其原有内容并将其重置，故pkt无需再进行取消引用操作）
         * 若使用av_write_frame()，处理方式则会有所不同 */
        if (ret < 0) {
//            fprintf(stderr, "Error while writing output packet: %s\n", av_err2str(ret));
            exit(1);
        }
    }

    return ret == AVERROR_EOF ? 1 : 0;
}

/** 添加一个输出流 */
static void add_stream(OutputStream *ost, AVFormatContext *oc,
                       const AVCodec **codec,
                       enum AVCodecID codec_id)
{
    AVCodecContext *c;
    int i;

    /* 找到编解码器 */
    *codec = avcodec_find_encoder(codec_id);
    if (!(*codec)) {
        fprintf(stderr, "无法找到 '%s' 的编码器\n",
                avcodec_get_name(codec_id));
        exit(1);
    }

    ost->tmp_pkt = av_packet_alloc();
    if (!ost->tmp_pkt) {
        fprintf(stderr, "Could not allocate AVPacket\n");
        exit(1);
    }

    ost->st = avformat_new_stream(oc, NULL);
    if (!ost->st) {
        fprintf(stderr, "无法分配流\n");
        exit(1);
    }
    ost->st->id = oc->nb_streams-1;
    c = avcodec_alloc_context3(*codec);
    if (!c) {
        fprintf(stderr, "无法分配编码上下文\n");
        exit(1);
    }
    ost->enc = c;

    AVChannelLayout layout = AV_CHANNEL_LAYOUT_STEREO;
    switch ((*codec)->type) {
    case AVMEDIA_TYPE_AUDIO:
        c->sample_fmt  = (*codec)->sample_fmts ?
            (*codec)->sample_fmts[0] : AV_SAMPLE_FMT_FLTP;
        c->bit_rate    = 64000;
        c->sample_rate = 44100;
        if ((*codec)->supported_samplerates) {
            c->sample_rate = (*codec)->supported_samplerates[0];
            for (i = 0; (*codec)->supported_samplerates[i]; i++) {
                if ((*codec)->supported_samplerates[i] == 44100)
                    c->sample_rate = 44100;
            }
        }
        av_channel_layout_copy(&c->ch_layout, &layout);
        ost->st->time_base = (AVRational){ 1, c->sample_rate };
        break;

    case AVMEDIA_TYPE_VIDEO:
        c->codec_id = codec_id;

        c->bit_rate = 400000;
        /* 分辨率必须是二的倍数. */
        c->width    = 352;
        c->height   = 288;
        /* 时间基准：这是帧时间戳表示的基本时间单位（以秒为单位）。
         * 对于固定帧率的内容，时间基准应该是1/帧率，且时间戳的增量应与1相同
         * 1. 时间基准（timebase）：在视频编码中，时间基准是用于表示视频帧时间戳的基本单位
         * 2. 固定帧率（fixed-fps）：指视频帧率保持恒定
         * 3. 时间基准与帧率的关系：时间基准等于1除以帧率
         * 4. 时间戳增量：在固定帧率下，相邻帧之间的时间戳增量应为1个时间基准单位 */
        ost->st->time_base = (AVRational){ 1, STREAM_FRAME_RATE };
        c->time_base       = ost->st->time_base;

        /* 每隔最多十二帧，发射一帧帧内编码帧。
         * 这里的“emit”指的是在视频编码过程中输出或生成帧，
         * “intra frame”指的是帧内编码帧，即只使用当前帧信息进行编码而不参考其他帧的视频帧，
         * “every twelve frames”表示每十二帧，
         * 而“at most”则强调了这是一个最大间隔，
         * 也就是说，在视频流中，帧内编码帧会以不超过十二帧的间隔出现一次 */
        c->gop_size      = 12;
        c->pix_fmt       = STREAM_PIX_FMT;
        if (c->codec_id == AV_CODEC_ID_MPEG2VIDEO) {
            /* “仅为测试目的，我们还添加了B帧。”
             * 这里的B帧通常指的是视频编码中的一种帧类型，
             * 它能利用前后帧进行双向预测，以达到压缩视频数据的目的 */
            c->max_b_frames = 2;
        }
        if (c->codec_id == AV_CODEC_ID_MPEG1VIDEO) {
            /* 所需的处理以防止在某些系数溢出的宏块中使用
             * 这种情况不会出现在正常视频中，它仅在此处发生
             * 原因在于色度平面（chroma plane）的运动与亮度平面（luma plane）的运动不相匹配 */
            c->mb_decision = 2;
        }
        break;

    default:
        break;
    }

    /* 某些格式希望流头部信息是独立的 */
    if (oc->oformat->flags & AVFMT_GLOBALHEADER)
        c->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;
}

/**************************************************************/
/* 音频输出 */
/** 分配音频帧 */
static AVFrame *alloc_audio_frame(enum AVSampleFormat sample_fmt,
                                  const AVChannelLayout *channel_layout,
                                  int sample_rate, int nb_samples)
{
    AVFrame *frame = av_frame_alloc();
    if (!frame) {
        fprintf(stderr, "分配音频帧时出现错误\n");
        exit(1);
    }

    frame->format = sample_fmt;
    av_channel_layout_copy(&frame->ch_layout, channel_layout);
    frame->sample_rate = sample_rate;
    frame->nb_samples = nb_samples;

    if (nb_samples) {
        if (av_frame_get_buffer(frame, 0) < 0) {
            fprintf(stderr, "分配音频缓冲区时出错\n");
            exit(1);
        }
    }

    return frame;
}

/** 打开音频编解码器，并初始化相关的音频处理参数和上下文 */
static void open_audio(AVFormatContext *oc, const AVCodec *codec,
                       OutputStream *ost, AVDictionary *opt_arg)
{
    AVCodecContext *c;
    int nb_samples;
    int ret;
    AVDictionary *opt = NULL;

    c = ost->enc;

    /* 打开它 */
    av_dict_copy(&opt, opt_arg, 0);
    ret = avcodec_open2(c, codec, &opt);
    av_dict_free(&opt);
    if (ret < 0) {
//        fprintf(stderr, "无法打开音频编解码器: %s\n", av_err2str(ret));
        exit(1);
    }

    /* 初始化信号发生器 */
    ost->t     = 0;
    ost->tincr = 2 * M_PI * 110.0 / c->sample_rate;
    /* 每秒将频率增加110赫兹 */
    ost->tincr2 = 2 * M_PI * 110.0 / c->sample_rate / c->sample_rate;

    if (c->codec->capabilities & AV_CODEC_CAP_VARIABLE_FRAME_SIZE)
        nb_samples = 10000;
    else
        nb_samples = c->frame_size;

    ost->frame     = alloc_audio_frame(c->sample_fmt, &c->ch_layout,
                                       c->sample_rate, nb_samples);
    ost->tmp_frame = alloc_audio_frame(AV_SAMPLE_FMT_S16, &c->ch_layout,
                                       c->sample_rate, nb_samples);

    /* 将流参数复制到复用器中 */
    ret = avcodec_parameters_from_context(ost->st->codecpar, c);
    if (ret < 0) {
        fprintf(stderr, "无法复制流参数\n");
        exit(1);
    }

    /* 创建重采样上下文 */
    ost->swr_ctx = swr_alloc();
    if (!ost->swr_ctx) {
        fprintf(stderr, "无法创建重采样上下文\n");
        exit(1);
    }

    /* 设置选项 */
    av_opt_set_chlayout  (ost->swr_ctx, "in_chlayout",       &c->ch_layout,      0);
    av_opt_set_int       (ost->swr_ctx, "in_sample_rate",     c->sample_rate,    0);
    av_opt_set_sample_fmt(ost->swr_ctx, "in_sample_fmt",      AV_SAMPLE_FMT_S16, 0);
    av_opt_set_chlayout  (ost->swr_ctx, "out_chlayout",      &c->ch_layout,      0);
    av_opt_set_int       (ost->swr_ctx, "out_sample_rate",    c->sample_rate,    0);
    av_opt_set_sample_fmt(ost->swr_ctx, "out_sample_fmt",     c->sample_fmt,     0);

    /* 初始化重采样上下文 */
    if ((ret = swr_init(ost->swr_ctx)) < 0) {
        fprintf(stderr, "初始化重采样上下文失败\n");
        exit(1);
    }
}

/** 准备一个16位的虚拟音频帧，该帧包含'frame_size'个样本和'nb_channels'个通道 */
static AVFrame *get_audio_frame(OutputStream *ost)
{
    AVFrame *frame = ost->tmp_frame;
    int j, i, v;
    int16_t *q = (int16_t*)frame->data[0];

    /* 检查我们是否想要生成更多的帧 */
    if (av_compare_ts(ost->next_pts, ost->enc->time_base,
                      STREAM_DURATION, (AVRational){ 1, 1 }) > 0)
        return NULL;

    for (j = 0; j <frame->nb_samples; j++) {
        v = (int)(sin(ost->t) * 10000);
        for (i = 0; i < ost->enc->ch_layout.nb_channels; i++)
            *q++ = v;
        ost->t     += ost->tincr;
        ost->tincr += ost->tincr2;
    }

    frame->pts = ost->next_pts;
    ost->next_pts  += frame->nb_samples;

    return frame;
}

/**
 * 编码一个音频帧并将其发送给复用器
 * 如果编码完成则返回1，否则返回0
 */
static int write_audio_frame(AVFormatContext *oc, OutputStream *ost)
{
    AVCodecContext *c;
    AVFrame *frame;
    int ret;
    int dst_nb_samples;

    c = ost->enc;

    frame = get_audio_frame(ost);

    if (frame) {
        /* 使用重采样器将样本从本机格式转换为目标编解码器格式 */
        /* 计算目标样本的数量 */
        dst_nb_samples = swr_get_delay(ost->swr_ctx, c->sample_rate) + frame->nb_samples;
        av_assert0(dst_nb_samples == frame->nb_samples);

        /* 当我们向编码器传递一帧数据时，编码器可能会在其内部保留对该帧的引用
         * 确保我们在这里不会覆盖它
         */
        ret = av_frame_make_writable(ost->frame);
        if (ret < 0)
            exit(1);

        /* 转换为目标格式 */
        ret = swr_convert(ost->swr_ctx,
                          ost->frame->data, dst_nb_samples,
                          (const uint8_t **)frame->data, frame->nb_samples);
        if (ret < 0) {
            fprintf(stderr, "在转换过程中发生了错误\n");
            exit(1);
        }
        frame = ost->frame;

        frame->pts = av_rescale_q(ost->samples_count, (AVRational){1, c->sample_rate}, c->time_base);
        ost->samples_count += dst_nb_samples;
    }

    return write_frame(oc, c, ost->st, frame, ost->tmp_pkt);
}

/**************************************************************/
/* 视频输出 */
/** 分配视频帧 */
static AVFrame *alloc_frame(enum AVPixelFormat pix_fmt, int width, int height)
{
    AVFrame *frame;
    int ret;

    frame = av_frame_alloc();
    if (!frame)
        return NULL;

    frame->format = pix_fmt;
    frame->width  = width;
    frame->height = height;

    /* 为帧数据分配缓冲区 */
    ret = av_frame_get_buffer(frame, 0);
    if (ret < 0) {
        fprintf(stderr, "无法分配帧数据\n");
        exit(1);
    }

    return frame;
}

/** 打开视频编解码器 */
static void open_video(AVFormatContext *oc, const AVCodec *codec,
                       OutputStream *ost, AVDictionary *opt_arg)
{
    int ret;
    AVCodecContext *c = ost->enc;
    AVDictionary *opt = NULL;

    av_dict_copy(&opt, opt_arg, 0);

    /* 打开编解码器 */
    ret = avcodec_open2(c, codec, &opt);
    av_dict_free(&opt);
    if (ret < 0) {
//        fprintf(stderr, "无法打开视频编解码器: %s\n", av_err2str(ret));
        exit(1);
    }

    /* 分配并初始化一个可重复使用的帧 */
    ost->frame = alloc_frame(c->pix_fmt, c->width, c->height);
    if (!ost->frame) {
        fprintf(stderr, "无法分配视频帧\n");
        exit(1);
    }

    /* 如果输出格式不是YUV420P，那么也需要一个临时的YUV420P图像
     * 然后，它会被转换成所需的输出格式
     */
    ost->tmp_frame = NULL;
    if (c->pix_fmt != AV_PIX_FMT_YUV420P) {
        ost->tmp_frame = alloc_frame(AV_PIX_FMT_YUV420P, c->width, c->height);
        if (!ost->tmp_frame) {
            fprintf(stderr, "无法分配临时视频帧\n");
            exit(1);
        }
    }

    /* 将流参数复制到复用器 */
    ret = avcodec_parameters_from_context(ost->st->codecpar, c);
    if (ret < 0) {
        fprintf(stderr, "无法复制流参数\n");
        exit(1);
    }
}

/** 准备一个占位图像. */
static void fill_yuv_image(AVFrame *pict, int frame_index,
                           int width, int height)
{
    int x, y, i;

    i = frame_index;

    /* Y */
    for (y = 0; y < height; y++)
        for (x = 0; x < width; x++)
            pict->data[0][y * pict->linesize[0] + x] = x + y + i * 3;

    /* Cb and Cr */
    for (y = 0; y < height / 2; y++) {
        for (x = 0; x < width / 2; x++) {
            pict->data[1][y * pict->linesize[1] + x] = 128 + y + i * 2;
            pict->data[2][y * pict->linesize[2] + x] = 64 + x + i * 5;
        }
    }
}

/** 获取视频帧 */
static AVFrame *get_video_frame(OutputStream *ost)
{
    AVCodecContext *c = ost->enc;

    /* 检查我们是否想要生成更多的帧 */
    if (av_compare_ts(ost->next_pts, c->time_base,
                      STREAM_DURATION, (AVRational){ 1, 1 }) > 0)
        return NULL;

    /* 当我们将一帧画面传递给编码器时，编码器可能会在内部保留对该帧的引用
     * 确保我们在这里不会覆写它 */
    if (av_frame_make_writable(ost->frame) < 0)
        exit(1);

    if (c->pix_fmt != AV_PIX_FMT_YUV420P) {
        /* 因为我们仅生成 YUV420P 格式的图像，如果需要的话
         * 必须将其转换为编码器所需的像素格式 */
        if (!ost->sws_ctx) {
            ost->sws_ctx = sws_getContext(c->width, c->height,
                                          AV_PIX_FMT_YUV420P,
                                          c->width, c->height,
                                          c->pix_fmt,
                                          SCALE_FLAGS, NULL, NULL, NULL);
            if (!ost->sws_ctx) {
                fprintf(stderr,
                        "无法初始化转换上下文\n");
                exit(1);
            }
        }
        fill_yuv_image(ost->tmp_frame, ost->next_pts, c->width, c->height);
        sws_scale(ost->sws_ctx, (const uint8_t * const *) ost->tmp_frame->data,
                  ost->tmp_frame->linesize, 0, c->height, ost->frame->data,
                  ost->frame->linesize);
    } else {
        fill_yuv_image(ost->frame, ost->next_pts, c->width, c->height);
    }

    ost->frame->pts = ost->next_pts++;

    return ost->frame;
}

/**
 * 编码一个视频帧并将其发送给复用器
 * 当编码完成时返回1，否则返回0
 */
static int write_video_frame(AVFormatContext *oc, OutputStream *ost)
{
    return write_frame(oc, ost->enc, ost->st, get_video_frame(ost), ost->tmp_pkt);
}

/** 关闭输出流，释放资源 */
static void close_stream(AVFormatContext *oc, OutputStream *ost)
{
    avcodec_free_context(&ost->enc);
    av_frame_free(&ost->frame);
    av_frame_free(&ost->tmp_frame);
    av_packet_free(&ost->tmp_pkt);
    sws_freeContext(ost->sws_ctx);
    swr_free(&ost->swr_ctx);
}

/**************************************************************/
/* 媒体文件输出 */

/** 编码：生成一个音视频文件 */
void ExampleFFMPEG::mux(const char *filename)
{
    OutputStream video_st = { 0 }, audio_st = { 0 };
    const AVOutputFormat *fmt;
    AVFormatContext *oc;
    const AVCodec *audio_codec, *video_codec;
    int ret;
    int have_video = 0, have_audio = 0;
    int encode_video = 0, encode_audio = 0;
    AVDictionary *opt = NULL;
    int i;

    /* 分配输出媒体上下文 */
    avformat_alloc_output_context2(&oc, NULL, NULL, filename);
    if (!oc) {
        qDebug("无法从文件扩展名推断输出格式：正在使用MPEG\n");
        avformat_alloc_output_context2(&oc, NULL, "mpeg", filename);
    }
    if (!oc)
        return;

    fmt = oc->oformat;

    /* 使用默认格式编解码器添加音频和视频流
     * 并初始化编解码器 */
    if (fmt->video_codec != AV_CODEC_ID_NONE) {
        add_stream(&video_st, oc, &video_codec, fmt->video_codec);
        have_video = 1;
        encode_video = 1;
    }
    if (fmt->audio_codec != AV_CODEC_ID_NONE) {
        add_stream(&audio_st, oc, &audio_codec, fmt->audio_codec);
        have_audio = 1;
        encode_audio = 1;
    }

    /* 现在所有参数都已设置
     * 我们可以打开音频和视频编解码器并分配必要的编码缓冲区 */
    if (have_video)
        open_video(oc, video_codec, &video_st, opt);

    if (have_audio)
        open_audio(oc, audio_codec, &audio_st, opt);

    av_dump_format(oc, 0, filename, 1);

    /* 如果需要，打开输出文件 */
    if (!(fmt->flags & AVFMT_NOFILE)) {
        ret = avio_open(&oc->pb, filename, AVIO_FLAG_WRITE);
        if (ret < 0) {
//            fprintf(stderr, "无法打开 '%s': %s\n", filename,
//                    av_err2str(ret));
            return;
        }
    }

    /* 如果有的话，写入流的头部信息 */
    ret = avformat_write_header(oc, &opt);
    if (ret < 0) {
//        fprintf(stderr, "在打开输出文件时发生了错误: %s\n",
//                av_err2str(ret));
        return;
    }

    while (encode_video || encode_audio) {
        /* 选择要编码的流 */
        if (encode_video &&
            (!encode_audio || av_compare_ts(video_st.next_pts, video_st.enc->time_base,
                                            audio_st.next_pts, audio_st.enc->time_base) <= 0)) {
            encode_video = !write_video_frame(oc, &video_st);
        } else {
            encode_audio = !write_audio_frame(oc, &audio_st);
        }
    }

    av_write_trailer(oc);

    /* 关闭每个编解码器 */
    if (have_video)
        close_stream(oc, &video_st);
    if (have_audio)
        close_stream(oc, &audio_st);

    if (!(fmt->flags & AVFMT_NOFILE))
        /* 关闭输出文件 */
        avio_closep(&oc->pb);

    /* 释放流 */
    avformat_free_context(oc);
}

//! --------------------- decode_audio ---------------------
#define AUDIO_INBUF_SIZE 20480
#define AUDIO_REFILL_THRESH 4096

/** 根据采样格式获取格式字符串 */
static int get_format_from_sample_fmt(const char **fmt,
                                      enum AVSampleFormat sample_fmt)
{
    int i;
    struct sample_fmt_entry {
        enum AVSampleFormat sample_fmt; const char *fmt_be, *fmt_le;
    } sample_fmt_entries[] = {
        { AV_SAMPLE_FMT_U8,  "u8",    "u8"    },
        { AV_SAMPLE_FMT_S16, "s16be", "s16le" },
        { AV_SAMPLE_FMT_S32, "s32be", "s32le" },
        { AV_SAMPLE_FMT_FLT, "f32be", "f32le" },
        { AV_SAMPLE_FMT_DBL, "f64be", "f64le" },
    };
    *fmt = NULL;

    for (i = 0; i < FF_ARRAY_ELEMS(sample_fmt_entries); i++) {
        struct sample_fmt_entry *entry = &sample_fmt_entries[i];
        if (sample_fmt == entry->sample_fmt) {
            *fmt = AV_NE(entry->fmt_be, entry->fmt_le);
            return 0;
        }
    }

    fprintf(stderr,
            "样本格式 %s 不被支持作为输出格式\n",
            av_get_sample_fmt_name(sample_fmt));
    return -1;
}

/** 解码音频数据，并写入文件 */
static void _decode_audio(AVCodecContext *dec_ctx, AVPacket *pkt, AVFrame *frame,
                   FILE *outfile)
{
    int i, ch;
    int ret, data_size;

    // 将压缩数据包发送到解码器
    ret = avcodec_send_packet(dec_ctx, pkt);
    if (ret < 0) {
        fprintf(stderr, "将数据包提交给解码器时出现错误\n");
        exit(1);
    }

    // 读取所有输出帧（通常可能有任意数量的帧）
    while (ret >= 0) {
        ret = avcodec_receive_frame(dec_ctx, frame);
        if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF)
            return;
        else if (ret < 0) {
            fprintf(stderr, "在解码过程中出现了错误\n");
            exit(1);
        }
        data_size = av_get_bytes_per_sample(dec_ctx->sample_fmt);
        if (data_size < 0) {
            // 这不应该发生，只是出于谨慎
            fprintf(stderr, "未能计算数据大小\n");
            exit(1);
        }
        for (i = 0; i < frame->nb_samples; i++)
            for (ch = 0; ch < dec_ctx->ch_layout.nb_channels; ch++)
                fwrite(frame->data[ch] + data_size*i, 1, data_size, outfile);
    }
}

/** 解码：一段音频输出原始PCM数据 */
void ExampleFFMPEG::decode_audio(const char *filename, const char *outfilename)
{
    const AVCodec *codec;
    AVCodecContext *c= NULL;
    AVCodecParserContext *parser = NULL;
    int len, ret;
    FILE *f, *outfile;
    uint8_t inbuf[AUDIO_INBUF_SIZE + AV_INPUT_BUFFER_PADDING_SIZE];
    uint8_t *data;
    size_t   data_size;
    AVPacket *pkt;
    AVFrame *decoded_frame = NULL;
    enum AVSampleFormat sfmt;
    int n_channels = 0;
    const char *fmt;

    // 分配AVPacket
    pkt = av_packet_alloc();

    // 查找MPEG音频解码器
    codec = avcodec_find_decoder(AV_CODEC_ID_MP2);
    if (!codec) {
        fprintf(stderr, "未找到编解码器\n");
        exit(1);
    }

    // 初始化解析器
    parser = av_parser_init(codec->id);
    if (!parser) {
        fprintf(stderr, "未发现解析器\n");
        exit(1);
    }

    // 分配AVCodecContext
    c = avcodec_alloc_context3(codec);
    if (!c) {
        fprintf(stderr, "无法分配音频编解码器上下文\n");
        exit(1);
    }

    // 打开解码器
    if (avcodec_open2(c, codec, NULL) < 0) {
        fprintf(stderr, "未能打开编解码器\n");
        exit(1);
    }

    // 打开输入文件
    f = fopen(filename, "rb");
    if (!f) {
        fprintf(stderr, "未能打开 %s\n", filename);
        exit(1);
    }
    // 打开输出文件
    outfile = fopen(outfilename, "wb");
    if (!outfile) {
        av_free(c);
        exit(1);
    }

    // 解码直到文件结束
    data      = inbuf;
    data_size = fread(inbuf, 1, AUDIO_INBUF_SIZE, f);

    while (data_size > 0) {
        // 分配AVFrame
        if (!decoded_frame) {
            if (!(decoded_frame = av_frame_alloc())) {
                fprintf(stderr, "无法分配音频帧\n");
                exit(1);
            }
        }

        // 解析数据包
        ret = av_parser_parse2(parser, c, &pkt->data, &pkt->size,
                               data, data_size,
                               AV_NOPTS_VALUE, AV_NOPTS_VALUE, 0);
        if (ret < 0) {
            fprintf(stderr, "在解析过程中出现了错误\n");
            exit(1);
        }
        data      += ret;
        data_size -= ret;

        // 解码数据包
        if (pkt->size)
            _decode_audio(c, pkt, decoded_frame, outfile);

        // 如果数据不足，则填充数据
        if (data_size < AUDIO_REFILL_THRESH) {
            memmove(inbuf, data, data_size);
            data = inbuf;
            len = fread(data + data_size, 1,
                        AUDIO_INBUF_SIZE - data_size, f);
            if (len > 0)
                data_size += len;
        }
    }

    // 刷新解码器
    pkt->data = NULL;
    pkt->size = 0;
    _decode_audio(c, pkt, decoded_frame, outfile);

    // 打印输出pcm信息，因为没有pcm的元数据
    sfmt = c->sample_fmt;

    // 如果是平面格式，则转换为打包格式
    if (av_sample_fmt_is_planar(sfmt)) {
        const char *packed = av_get_sample_fmt_name(sfmt);
        qDebug("警告：解码器产生的样本格式是平面的 "
               "(%s). 本示例将仅输出第一个声道\n",
               packed ? packed : "?");
        sfmt = av_get_packed_sample_fmt(sfmt);
    }

    // 获取通道数
    n_channels = c->ch_layout.nb_channels;
    // 获取格式字符串
    if ((ret = get_format_from_sample_fmt(&fmt, sfmt)) < 0)
        goto end;

    // 打印播放命令
    qDebug("使用该命令来播放输出的音频文件:\n"
           "ffplay -f %s -ac %d -ar %d %s\n",
           fmt, n_channels, c->sample_rate,
           outfilename);
end:
    // 关闭文件
    fclose(outfile);
    fclose(f);

    // 释放资源
    avcodec_free_context(&c);
    av_parser_close(parser);
    av_frame_free(&decoded_frame);
    av_packet_free(&pkt);
}

//! --------------------- decode_video ---------------------
#define INBUF_SIZE 4096
/** 保存PGM图像的函数 */
static void pgm_save(unsigned char *buf, int wrap, int xsize, int ysize,
                     char *filename)
{
    FILE *f;
    int i;

    f = fopen(filename,"wb");
    fprintf(f, "P5\n%d %d\n%d\n", xsize, ysize, 255);
    for (i = 0; i < ysize; i++)
        fwrite(buf + i * wrap, 1, xsize, f);
    fclose(f);
}

/** 解码视频帧 */
static void _decode_video(AVCodecContext *dec_ctx, AVFrame *frame, AVPacket *pkt,
                   const char *filename)
{
    char buf[1024];
    int ret;

    ret = avcodec_send_packet(dec_ctx, pkt);
    if (ret < 0) {
        fprintf(stderr, "在发送一个数据包进行解码时发生错误\n");
        exit(1);
    }

    while (ret >= 0) {
        ret = avcodec_receive_frame(dec_ctx, frame);
        if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF)
            return;
        else if (ret < 0) {
            fprintf(stderr, "在解码过程中出现了错误\n");
            exit(1);
        }

        qDebug("保存帧 %3lld\n", dec_ctx->frame_num);
        fflush(stdout);

        /* 图片由解码器分配，无需释放它 */
        snprintf(buf, sizeof(buf), "%s-%lld", filename, dec_ctx->frame_num);
        pgm_save(frame->data[0], frame->linesize[0],
                 frame->width, frame->height, buf);
    }
}

/** 解码：一段视频输出所有帧图片 */
void ExampleFFMPEG::decode_video(const char *filename, const char *outfilename)
{
    const AVCodec *codec;
    AVCodecParserContext *parser;
    AVCodecContext *c= NULL;
    FILE *f;
    AVFrame *frame;
    uint8_t inbuf[INBUF_SIZE + AV_INPUT_BUFFER_PADDING_SIZE];
    uint8_t *data;
    size_t   data_size;
    int ret;
    int eof;
    AVPacket *pkt;

    pkt = av_packet_alloc();
    if (!pkt)
        exit(1);

    /* 将缓冲区末尾设置为0（这确保了对于损坏的MPEG流不会发生越界读取） */
    memset(inbuf + INBUF_SIZE, 0, AV_INPUT_BUFFER_PADDING_SIZE);

    /* 找到MPEG-1视频解码器 */
    codec = avcodec_find_decoder(AV_CODEC_ID_H264); // AV_CODEC_ID_MPEG1VIDEO
    if (!codec) {
        fprintf(stderr, "编解码器未找到\n");
        exit(1);
    }

    parser = av_parser_init(codec->id);
    if (!parser) {
        fprintf(stderr, "解析器未找到\n");
        exit(1);
    }

    c = avcodec_alloc_context3(codec);
    if (!c) {
        fprintf(stderr, "无法分配视频编解码器上下文\n");
        exit(1);
    }

    /*
     *  1. 编解码器：msmpeg4和mpeg4。
     *  2. 必须初始化的参数：宽度和高度。
     *  3. 原因：这些信息在比特流中不可用 */

    /* 打开它 */
    if (avcodec_open2(c, codec, NULL) < 0) {
        fprintf(stderr, "打不开编解码器\n");
        exit(1);
    }

    f = fopen(filename, "rb");
    if (!f) {
        fprintf(stderr, "打不开 %s\n", filename);
        exit(1);
    }

    frame = av_frame_alloc();
    if (!frame) {
        fprintf(stderr, "无法分配视频帧\n");
        exit(1);
    }

    do {
        /* 从输入文件中读取原始数据 */
        data_size = fread(inbuf, 1, INBUF_SIZE, f);
        if (ferror(f))
            break;
        eof = !data_size;

        /* 使用解析器将数据分割成帧 */
        data = inbuf;
        while (data_size > 0 || eof) {
            ret = av_parser_parse2(parser, c, &pkt->data, &pkt->size,
                                   data, data_size, AV_NOPTS_VALUE, AV_NOPTS_VALUE, 0);
            if (ret < 0) {
                fprintf(stderr, "在解析过程中出现了错误\n");
                exit(1);
            }
            data      += ret;
            data_size -= ret;

            if (pkt->size)
                _decode_video(c, frame, pkt, outfilename);
            else if (eof)
                break;
        }
    } while (!eof);

    /* 刷新编码器 */
    _decode_video(c, frame, NULL, outfilename);

    fclose(f);

    av_parser_close(parser);
    avcodec_free_context(&c);
    av_frame_free(&frame);
    av_packet_free(&pkt);
}

//! --------------------- demux_decode ---------------------
// 定义全局变量
static AVFormatContext *fmt_ctx = NULL;
static AVCodecContext *video_dec_ctx = NULL, *audio_dec_ctx;
static int width, height;
static enum AVPixelFormat pix_fmt;
static AVStream *video_stream = NULL, *audio_stream = NULL;
static FILE *video_dst_file = NULL;
static FILE *audio_dst_file = NULL;

// 定义视频帧缓冲区
static uint8_t *video_dst_data[4] = {NULL};
static int      video_dst_linesize[4];
static int video_dst_bufsize;

// 定义视频和音频流索引
static int video_stream_idx = -1, audio_stream_idx = -1;
static AVFrame *frame = NULL;
static AVPacket *pkt = NULL;
static int video_frame_count = 0;
static int audio_frame_count = 0;

/** 输出视频帧 */
static int output_video_frame(AVFrame *frame)
{
    // 检查视频帧的宽、高和像素格式是否发生变化
    if (frame->width != width || frame->height != height ||
        frame->format != pix_fmt) {
        /* 为了处理这一变化，可以再次调用 av_image_alloc 并将后续的帧解码到另一个原始视频文件中 */
        fprintf(stderr, "错误：在原始视频文件中，宽度、高度和像素格式必须保持不变 "
                "但输入视频的宽度、高度或像素格式发生了改变："
                "旧的参数：宽度 = %d, 高度 = %d, 格式 = %s"
                "新的参数：宽度 = %d, 高度 = %d, 格式 = %s",
                width, height, av_get_pix_fmt_name(pix_fmt),
                frame->width, frame->height,
                av_get_pix_fmt_name((AVPixelFormat)frame->format));
        return -1;
    }

    qDebug("视频帧 n:%d\n",
           video_frame_count++);

    /* 将解码后的帧复制到目标缓冲区:
     * 这是必需的，因为rawvideo期待非对齐的数据 */
    av_image_copy2(video_dst_data, video_dst_linesize,
                   frame->data, frame->linesize,
                   pix_fmt, width, height);

    /* 写入原始视频文件 */
    fwrite(video_dst_data[0], 1, video_dst_bufsize, video_dst_file);
    return 0;
}

/** 输出音频帧 */
static int output_audio_frame(AVFrame *frame)
{
    size_t unpadded_linesize = frame->nb_samples * av_get_bytes_per_sample((AVSampleFormat)frame->format);
    qDebug("audio_frame n:%d nb_samples:%d\n", audio_frame_count++, frame->nb_samples);

    /* 写入第一音频平面的原始音频数据样本
     * 这在打包格式（例如 AV_SAMPLE_FMT_S16）下运行良好
     * 然而，大多数音频解码器输出分立音频，即为每个声道使用单独的音频样本平面（例如 AV_SAMPLE_FMT_S16P）
     * 换句话说，在这些情况下，这段代码只会写入第一个音频声道
     * 你应该使用 libswresample 或 libavfilter 来将帧转换为打包数据
     * 关键点：
     * 1. 对于打包格式（例如 AV_SAMPLE_FMT_S16），直接写入第一平面的音频数据是可行的
     * 2. 大多数音频解码器输出的是分立音频（每个声道有独立的平面）
     * 3. 该代码只处理了第一个音频声道的数据
     * 4. 推荐使用 libswresample 或 libavfilter 库进行数据格式转换
     ***/
    fwrite(frame->extended_data[0], 1, unpadded_linesize, audio_dst_file);

    return 0;
}

/** 解码数据包 */
static int decode_packet(AVCodecContext *dec, const AVPacket *pkt)
{
    int ret = 0;

    // 提交数据包到解码器
    ret = avcodec_send_packet(dec, pkt);
    if (ret < 0) {
        fprintf(stderr, "提交用于解码的数据包时出现错误 (%d)\n", ret);
        return ret;
    }

    // 从解码器获取所有可用的帧
    while (ret >= 0) {
        ret = avcodec_receive_frame(dec, frame);
        if (ret < 0) {
            // 这两条返回值是特殊的，意味着没有输出帧可用
            // 但在解码过程中没有发生错误
            if (ret == AVERROR_EOF || ret == AVERROR(EAGAIN))
                return 0;

            fprintf(stderr, "在解码过程中出现了错误 (%d)\n", ret);
            return ret;
        }

        // 将帧数据写入输出文件
        if (dec->codec->type == AVMEDIA_TYPE_VIDEO)
            ret = output_video_frame(frame);
        else
            ret = output_audio_frame(frame);

        av_frame_unref(frame);
    }

    return ret;
}

/** 打开解码器上下文 */
static int open_codec_context(const char *src_filename, int *stream_idx,
                              AVCodecContext **dec_ctx, AVFormatContext *fmt_ctx, enum AVMediaType type)
{
    int ret, stream_index;
    AVStream *st;
    const AVCodec *dec = NULL;

    // 在输入文件中查找流
    ret = av_find_best_stream(fmt_ctx, type, -1, -1, NULL, 0);
    if (ret < 0) {
        fprintf(stderr, "找不到 %s 流, 在输入文件 '%s'中\n",
                av_get_media_type_string(type), src_filename);
        return ret;
    } else {
        stream_index = ret;
        st = fmt_ctx->streams[stream_index];

        /* 查找流的解码器 */
        dec = avcodec_find_decoder(st->codecpar->codec_id);
        if (!dec) {
            fprintf(stderr, "无法找到 %s 编解码器\n",
                    av_get_media_type_string(type));
            return AVERROR(EINVAL);
        }

        /* 为解码器分配编解码上下文 */
        *dec_ctx = avcodec_alloc_context3(dec);
        if (!*dec_ctx) {
            fprintf(stderr, "未能分配 %s 编解码器上下文\n",
                    av_get_media_type_string(type));
            return AVERROR(ENOMEM);
        }

        /* 将输入流的编解码参数复制到输出编解码上下文 */
        if ((ret = avcodec_parameters_to_context(*dec_ctx, st->codecpar)) < 0) {
            fprintf(stderr, "未能将 %s 编解码器参数复制到解码器上下文中\n",
                    av_get_media_type_string(type));
            return ret;
        }

        /* 初始化解码器 */
        if ((ret = avcodec_open2(*dec_ctx, dec, NULL)) < 0) {
            fprintf(stderr, "无法打开 %s 编解码器\n",
                    av_get_media_type_string(type));
            return ret;
        }
        *stream_idx = stream_index;
    }

    return 0;
}

/** 解码：一段音视频输出原始音频文件跟原始视频文件 */
void ExampleFFMPEG::demux_decode(const char *src_filename, const char *video_dst_filename, const char *audio_dst_filename)
{
    int ret = 0;

    avformat_network_init();

    /* 打开输入文件，并分配格式上下文 */
    if (avformat_open_input(&fmt_ctx, src_filename, NULL, NULL) < 0) {
        fprintf(stderr, "无法打开源文件 %s\n", src_filename);
        exit(1);
    }

    /* 检索流信息 */
    if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
        fprintf(stderr, "无法找到流信息\n");
        exit(1);
    }

    // 打开视频解码器
    if (open_codec_context(src_filename, &video_stream_idx, &video_dec_ctx, fmt_ctx, AVMEDIA_TYPE_VIDEO) >= 0) {
        video_stream = fmt_ctx->streams[video_stream_idx];

        video_dst_file = fopen(video_dst_filename, "wb");
        if (!video_dst_file) {
            fprintf(stderr, "无法打开目标文件 %s\n", video_dst_filename);
            ret = 1;
            goto end;
        }

        /* 分配一个图像存储空间，解码后的图像将被放置于此 */
        width = video_dec_ctx->width;
        height = video_dec_ctx->height;
        pix_fmt = video_dec_ctx->pix_fmt;
        ret = av_image_alloc(video_dst_data, video_dst_linesize,
                             width, height, pix_fmt, 1);
        if (ret < 0) {
            fprintf(stderr, "无法分配原始视频缓冲区\n");
            goto end;
        }
        video_dst_bufsize = ret;
    }

    // 打开音频解码器
    if (open_codec_context(src_filename, &audio_stream_idx, &audio_dec_ctx, fmt_ctx, AVMEDIA_TYPE_AUDIO) >= 0) {
        audio_stream = fmt_ctx->streams[audio_stream_idx];
        audio_dst_file = fopen(audio_dst_filename, "wb");
        if (!audio_dst_file) {
            fprintf(stderr, "无法打开目标文件 %s\n", audio_dst_filename);
            ret = 1;
            goto end;
        }
    }

    /* 将输入信息输出到标准错误流 */
    av_dump_format(fmt_ctx, 0, src_filename, 0);

    // 检查是否有视频或音频流
    if (!audio_stream && !video_stream) {
        fprintf(stderr, "在输入中未找到音频或视频流，正在中止操作\n");
        ret = 1;
        goto end;
    }

    frame = av_frame_alloc();
    if (!frame) {
        fprintf(stderr, "无法分配帧\n");
        ret = AVERROR(ENOMEM);
        goto end;
    }

    pkt = av_packet_alloc();
    if (!pkt) {
        fprintf(stderr, "无法分配数据包\n");
        ret = AVERROR(ENOMEM);
        goto end;
    }

    if (video_stream)
        qDebug("从文件 '%s' 中解复用视频到 '%s'\n", src_filename, video_dst_filename);
    if (audio_stream)
        qDebug("从文件 '%s' 中解复用音频到 '%s'\n", src_filename, audio_dst_filename);

    /* 从文件中读取帧数据 */
    while (av_read_frame(fmt_ctx, pkt) >= 0) {
        // 检查数据包是否属于我们感兴趣的流，否则跳过
        if (pkt->stream_index == video_stream_idx)
            ret = decode_packet(video_dec_ctx, pkt);
        else if (pkt->stream_index == audio_stream_idx)
            ret = decode_packet(audio_dec_ctx, pkt);
        av_packet_unref(pkt);
        if (ret < 0)
            break;
    }

    /* 刷新编码器 */
    if (video_dec_ctx)
        decode_packet(video_dec_ctx, NULL);
    if (audio_dec_ctx)
        decode_packet(audio_dec_ctx, NULL);

    qDebug("解复用成功\n");

    if (video_stream) {
        qDebug("使用命令播放输出视频文件:\n"
               "ffplay -f rawvideo -pix_fmt %s -video_size %dx%d %s\n",
               av_get_pix_fmt_name(pix_fmt), width, height,
               video_dst_filename);
    }

    if (audio_stream) {
        enum AVSampleFormat sfmt = audio_dec_ctx->sample_fmt;
        int n_channels = audio_dec_ctx->ch_layout.nb_channels;
        const char *fmt;

        // 检查采样格式是否为平面格式
        if (av_sample_fmt_is_planar(sfmt)) {
            const char *packed = av_get_sample_fmt_name(sfmt);
            qDebug("警告：解码器产生的样本格式是平面的 "
                   "(%s). 这个示例将只输出第一个声道\n",
                   packed ? packed : "?");
            sfmt = av_get_packed_sample_fmt(sfmt);
            n_channels = 1;
        }

        // 获取格式字符串
        if ((ret = get_format_from_sample_fmt(&fmt, sfmt)) < 0)
            goto end;

        qDebug("使用命令来播放输出的音频文件:\n"
               "ffplay -f %s -ac %d -ar %d %s\n",
               fmt, n_channels, audio_dec_ctx->sample_rate,
               audio_dst_filename);
    }

end:
    avcodec_free_context(&video_dec_ctx);
    avcodec_free_context(&audio_dec_ctx);
    avformat_close_input(&fmt_ctx);
    if (video_dst_file)
        fclose(video_dst_file);
    if (audio_dst_file)
        fclose(audio_dst_file);
    av_packet_free(&pkt);
    av_frame_free(&frame);
    av_free(video_dst_data[0]);
}
