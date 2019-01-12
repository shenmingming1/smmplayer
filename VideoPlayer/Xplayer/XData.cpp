//
//  XData.cpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/8.
//  Copyright © 2019年 申明明. All rights reserved.
//

#include "XData.h"
extern "C"
{
    #include "libavformat/avformat.h"
};
void XData::Drop(){
    if (!data) {
        return;
    }
    av_packet_free((AVPacket **)&data);
    data = 0;
    size = 0;
}
