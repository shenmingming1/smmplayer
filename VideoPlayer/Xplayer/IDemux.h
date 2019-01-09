//
//  IDemux.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/8.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef IDemux_hpp
#define IDemux_hpp
#include "XData.h"
class IDemux{
public:
    //打开文件，或者流媒体 rmtp,http rtsp
    virtual bool Open(const char *url) = 0;
    // 读取一帧数据，数据由调用者清理
    virtual XData Read() = 0;
    
};
#endif /* IDemux_hpp */
