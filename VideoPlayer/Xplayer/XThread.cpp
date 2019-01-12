//
//  XThread.cpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/9.
//  Copyright © 2019年 申明明. All rights reserved.
//

#include "XThread.h"
#include <thread>
#include "XLog.h"

using namespace std;
void XSleep(int mis){
    chrono::milliseconds du(mis);
    this_thread::sleep_for(du);
}
//启动线程
void XThread::Start(){
    thread th(&XThread::ThreadMain,this);
    th.detach();
}
//安全停止线程（不一定成功）
void XThread::Stop(){
    isExit = true;
    for(int i = 0;i<200;i++) {
        if (!isRuning) {
            LOGK("Stop 停止线程成功！\n");
            return;
        }
        XSleep(1);
    }
    LOGK("停止线程超时\n");
}

void XThread::ThreadMain(){
    isRuning = true;
    LOGK("线程函数进入\n");
    Main();
    LOGK("线程函数退出\n");
    isRuning = false;
}
