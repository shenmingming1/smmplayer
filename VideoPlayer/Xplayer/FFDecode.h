//
//  FFDecode.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/11.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef FFDecode_hpp
#define FFDecode_hpp
#include "IDecode.h"
struct AVCodecContext;
struct AVFrame;
class FFDecode : public IDecode{
public:
    virtual bool Open(XParameter para);
    //future模型,发送数据到线程解码
    virtual bool SendPacket(XData pkt);
    //从线程中获取解码结果
    virtual XData ReceviceFrame();
protected:
    AVCodecContext *mcodecContex = 0;
    AVFrame *frame;
};

#endif /* FFDecode_hpp */
