//
//  IDecode.cpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/11.
//  Copyright © 2019年 申明明. All rights reserved.
//

#include "IDecode.h"
#include "XLog.h"
//观察者接受数据函数
void IDecode::Update(XData pkt){
    if (pkt.isAudio != isAudio) {
        return;
    }
    while (!isExit) {
        packsMutex.lock();
        // 阻塞
        if (packs.size() < maxPacksSize) {
            packs.push_back(pkt);
            packsMutex.unlock();
            break;
        }
        packsMutex.unlock();
        XSleep(1);
    }
}
void IDecode::Main(){
    while (!isExit) {
        packsMutex.lock();
        if (packs.empty()) {
            packsMutex.unlock();
            XSleep(1);
            continue;
        }
        //取出packet
        XData pkt = packs.front();
        packs.pop_front();
        //发送数据到解码线程，一个数据包，可能有解码多个结果
        if (this->SendPacket(pkt)){
            while (!isExit) {
                //获取解码器
                XData frame = ReceviceFrame();
                LOGK("ReceviceFrame:frameSize:%d\n",frame.size);
                if (!frame.data) {
                    break;
                }
                //发送数据给观察者
                this->Notify(frame);
            }
        }
        pkt.Drop();
        packsMutex.unlock();
    }
}
