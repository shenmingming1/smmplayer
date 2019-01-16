//
//  IObserver.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/11.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef IObserver_hpp
#define IObserver_hpp
#include "XData.h"
#include <vector>
#include <mutex>
#include "XThread.h"
// 观察者和主体
class IObserver : public XThread{
public:
    //观察者接受数据函数
    virtual void Update(XData pkt){}
    //主体函数，添加观察者(线程安全)
    void AddObservers(IObserver *obs);
    //通知所有观察者(线程安全)
    void Notify(XData data);
protected:
    std::vector<IObserver *> obss;
    std::mutex mux;
};

#endif /* IObserver_hpp */
