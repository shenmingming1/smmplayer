//
//  FFDemux.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/8.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef FFDemux_hpp
#define FFDemux_hpp
#include "IDemux.h"
struct AVFormatContext;
class FFDemux: public IDemux{
public:
    FFDemux();
    //打开文件，或者流媒体 rmtp,http rtsp
    virtual bool Open(const char *url);
    virtual XParameter GetVPara();
    // 读取一帧数据，数据由调用者清理
    virtual XData Read();
    int64_t mTotalMS;
private:
    AVFormatContext *mContext;
    
    
};

#endif /* FFDemux_hpp */
