//
//  IVideoView.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/19.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef IVideoView_hpp
#define IVideoView_hpp

#include "XData.h"
#include "IObserver.h"

class IVideoView:public IObserver
{
public:
    virtual void SetRender(void *win) = 0;
    virtual void Render(XData data) = 0;
    virtual void Update(XData data);
    virtual void Close() = 0;
};


#endif /* IVideoView_hpp */
