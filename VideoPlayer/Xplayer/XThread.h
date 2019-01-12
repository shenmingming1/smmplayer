//
//  XThread.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/9.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef XThread_hpp
#define XThread_hpp
void XSleep(int mis);
class XThread{
public:
    //启动线程
    virtual void Start();
    //安全停止线程（不一定成功）
    virtual void Stop();
    //入口主函数
    virtual void Main(){};
protected:
    bool isExit = false;
    bool isRuning = false;
private:
    void ThreadMain();
};

#endif /* XThread_hpp */
