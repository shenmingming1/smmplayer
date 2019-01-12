//
//  IObserver.cpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/11.
//  Copyright © 2019年 申明明. All rights reserved.
//

#include "IObserver.h"

void IObserver::AddObservers(IObserver *obs){
    if (obs == nullptr) {
        return;
    }
    mux.lock();
    obss.push_back(obs);
    mux.unlock();
}
void IObserver::Notify(XData data){
    mux.lock();
    for (int i =0 ; i < obss.size(); i++) {
        obss[i]->Update(data);
    }
    mux.unlock();
}
