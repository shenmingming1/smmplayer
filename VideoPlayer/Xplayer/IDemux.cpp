//
//  IDemux.cpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/8.
//  Copyright © 2019年 申明明. All rights reserved.
//

#include "IDemux.h"
#include "XLog.h"
void IDemux::Main(){
    while (!isExit) {
        XData d = Read();
        LOGK("IDemux Read %d\n",d.size);
        if (d.size > 0) {
            Notify(d);
        }
    }
}
