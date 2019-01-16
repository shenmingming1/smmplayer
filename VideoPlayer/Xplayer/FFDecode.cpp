//
//  FFDecode.cpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/11.
//  Copyright © 2019年 申明明. All rights reserved.
//
extern "C"{
#include "libavcodec/avcodec.h"
}
#include "FFDecode.h"
#include "XLog.h"
bool FFDecode::Open(XParameter para){
    if (!para.par) {
        return false;
    }
    AVCodecParameters *p = para.par;
    //1、查找解码器
    AVCodec *codec = avcodec_find_decoder(p->codec_id);
    if (!codec) {
        LOGK("avcodec_find_decoder failed !!!\n");
        return false;
    }
    //2、创建解码器上下文，并复制参数
    mcodecContex = avcodec_alloc_context3(codec);
//    avcodec_parameters_copy(mCodecPara, p);
    avcodec_parameters_to_context(mcodecContex, p);
    //3、打开解码器(由于第二步用codec 初始化了codecContex，所以第二个参数可以传0)
    mcodecContex->thread_count = 8;
    int re = avcodec_open2(mcodecContex, 0, 0);
    if (re != 0) {
        char buf [1024] = {0};
        av_strerror(re, buf, sizeof(buf)-1);
        LOGK("avcodec_open2 failed :%s\n",buf);
        return false;
    }
    if (codec->type == AVMEDIA_TYPE_AUDIO) {
        isAudio = true;
    }else if (codec->type == AVMEDIA_TYPE_VIDEO){
        isAudio = false;
    }
    LOGK("open codec success\n");
    return true;
}
bool FFDecode::SendPacket(XData pkt){
    if (!pkt.data || pkt.size <= 0) {
        LOGK("pkt.data is null \n");
        return false;
    }
    int ret = avcodec_send_packet(mcodecContex, (AVPacket*)pkt.data);
    if (ret != 0) {
        return false;
    }
    return true;
}
//从线程中获取解码结果
XData FFDecode::ReceviceFrame(){
    if (!mcodecContex) {
        return XData();
    }
    if (!frame) {
        frame = av_frame_alloc();
    }
    int ret = avcodec_receive_frame(mcodecContex, frame);
    if (ret != 0) {
        return XData();
    }
    XData d;
    d.data = (unsigned char *)frame;
    if (mcodecContex->codec_type == AVMEDIA_TYPE_VIDEO){
        d.size = (frame->linesize[0]+frame->linesize[1]+frame->linesize[2])*frame->height;
    }
    
    return d;
}
