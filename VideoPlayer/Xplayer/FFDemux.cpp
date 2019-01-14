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
    LOGK("Open file %s begin\n",url);
    int re = avformat_open_input(&mContext, url, 0, 0);
    if (re != 0) {
        char buf[1024] = {0};
        av_strerror(re, buf, sizeof(buf));
        LOGK("FFDemx open %s failed!\n",url);
        return false;
    }
    //读取文件信息
    re = avformat_find_stream_info(mContext, 0);
    if (re != 0) {
        char buf[1024] = {0};
        av_strerror(re, buf, sizeof(buf));
        LOGK("avformat_find_stream_info %s failed!\n",url);
        return false;
    }
    mTotalMS = mContext->duration/(AV_TIME_BASE/1000);
    LOGK("totalMS ms = %lld!\n",mTotalMS);
    return true;
}
XParameter FFDemux::GetVPara(){
    if (!mContext) {
        LOGK(" mContex is null");
        return XParameter();
    }
    int ret = av_find_best_stream(mContext, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
    if (ret < 0) {
        return XParameter();
    }
    AVStream* stream = mContext->streams[ret];
    XParameter para;
    para.par = stream->codecpar;
    return para;
}
// 读取一帧数据，数据由调用者清理
XData FFDemux::Read(){
    if(!mContext) return XData();
    XData data;
    AVPacket *pkt = av_packet_alloc();
    int re = av_read_frame(mContext, pkt);
    if (re != 0) {
        av_packet_free(&pkt);
        LOGK("read failed\n");
        return XData();
    }
    LOGK("pack size is %d ptss %lld!\n",pkt->size,pkt->pts);
    data.data = (unsigned char*)pkt;
    data.size = pkt->size;
    return data;
}
FFDemux::FFDemux()
:mTotalMS(0)
,mContext(0)
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
        LOGK("register ffmpeg\n");
    }
    
}
