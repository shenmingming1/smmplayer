//
//  IVideoView.cpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/19.
//  Copyright © 2019年 申明明. All rights reserved.
//

#include "IVideoView.h"
#include "XLog.h"

void IVideoView::Update(XData data)
{
    //("IVideoView->Update(data) %d",data.pts);
    this->Render(data);
}
