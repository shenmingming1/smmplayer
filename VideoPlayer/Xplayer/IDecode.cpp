//
//  IDecode.cpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/11.
//  Copyright © 2019年 申明明. All rights reserved.
//

#include "IDecode.h"
//观察者接受数据函数
void IDecode::Update(XData pkt){
    if (pkt.isAudio != isAudio) {
        return;
    }
}
void IDecode::Main(){
    
}
