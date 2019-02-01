//
//  XEGL.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/19.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef XEGL_hpp
#define XEGL_hpp
class XEGL
{
public:
    virtual bool Init(void *win) = 0;
    virtual void Close() = 0;
    virtual void Draw() = 0;
    static XEGL *Get();
    
protected:
    XEGL(){}
};

#endif /* XEGL_hpp */
