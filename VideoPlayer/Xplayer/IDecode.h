//
//  IDecode.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/11.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef IDecode_hpp
#define IDecode_hpp
#include "XParameter.h"
#include "XData.h"
#include "IObserver.h"
#include <list>
class IDecode : public IObserver{
    
public:
    //打开解码器
    virtual bool Open(XParameter para) = 0;
    //future模型,发送数据到线程解码
    virtual bool SendPacket(XData pkt) = 0;
    //从线程中获取解码结果,再次调用是复用上次的结果，线程不安全
    virtual XData ReceviceFrame() = 0;
    //观察者接受数据函数
    virtual void Update(XData pkt);
    int maxPacksSize = 100;
    bool isAudio = false;
protected:
    
    virtual void Main();
    //读取缓冲
    std::list<XData> packs;
    std::mutex packsMutex;
};

#endif /* IDecode_hpp */
