//
//  FFDemux.cpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/8.
//  Copyright © 2019年 申明明. All rights reserved.
//

#include "FFDemux.h"
#include "XLog.h"
extern "C"
{
#include "libavformat/avformat.h"
};
//打开文件，或者流媒体 rmtp,http rtsp
bool FFDemux::Open(const char *url){
    LOGD("Open file %s begin",url);
    int re = avformat_open_input(&mIc, url, 0, 0);
    if (re != 0) {
        char buf[1024] = {0};
        av_strerror(re, buf, sizeof(buf));
        LOGD("FFDemx open %s failed!",url);
        return false;
    }
    //读取文件信息
    re = avformat_find_stream_info(mIc, 0);
    if (re != 0) {
        char buf[1024] = {0};
        av_strerror(re, buf, sizeof(buf));
        LOGD("avformat_find_stream_info %s failed!",url);
        return false;
    }
    mTotalMS = mIc->duration/(AV_TIME_BASE/1000);
    LOGD("totalMS ms = %d!",mTotalMS);
    return true;
}
// 读取一帧数据，数据由调用者清理
XData FFDemux::Read(){
    XData data;
    return data;
}
FFDemux::FFDemux()
:mTotalMS(0)
,mIc(0)
{
    static bool isFirst = true;
    if (isFirst) {
        isFirst = false;
        //注册所有封装器
        av_register_all();
        //注册所有解码器
        avcodec_register_all();
        //初始化网络
        avformat_network_init();
        LOGD("register ffmpeg");
    }
    
}
