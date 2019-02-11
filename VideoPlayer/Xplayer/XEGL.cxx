//
//  XEGL.cpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/19.
//  Copyright © 2019年 申明明. All rights reserved.
//

#include "XEGL.h"
#include <mutex>
#include "XEGL.h"
#include "XLog.h"
class CXEGL:public XEGL
{
public:
    std::mutex mux;
    
    virtual void Draw()
    {
        
    }
    virtual void Close()
    {
        
    }
    
    virtual bool Init(void *win)
    {
        
        
        return true;
    }
};

XEGL *XEGL::Get()
{
    static CXEGL egl;
    return &egl;
}
