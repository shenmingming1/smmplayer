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
        LOGK("avcodec_find_decoder failed !!!");
        return false;
    }
    //2、创建解码器上下文，并复制参数
    AVCodecContext* codecContex = avcodec_alloc_context3(codec);
    avcodec_parameters_copy(mCodecPara, p);
    //3、打开解码器(由于第二步用codec 初始化了codecContex，所以第二个参数可以传0)
    int re = avcodec_open2(codecContex, 0, 0);
    if (re != 0) {
        char buf [1024] = {0};
        av_strerror(re, buf, sizeof(buf)-1);
        LOGK("avcodec_open2 failed :%s",buf);
        return false;
    }
    LOGK("open codec success");
    return true;
}
