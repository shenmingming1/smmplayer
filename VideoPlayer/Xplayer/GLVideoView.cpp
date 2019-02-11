//
//  GLVideoView.cpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/19.
//  Copyright © 2019年 申明明. All rights reserved.
//

#include "GLVideoView.h"
#include "GLVideoView.h"
#include "XTexture.h"
#include "XLog.h"
void GLVideoView::SetRender(void* user,updateD callback)
{
    view = user;
    mCallBack = callback;
}
void GLVideoView::Close()
{
    mux.lock();
    if(txt)
    {
        txt->Drop();
        txt = 0;
    }
    
    mux.unlock();
}
void GLVideoView::Render(XData data)
{
    
    if(!view) return;
    mCallBack(view,data);
//    if(!txt)
//    {
//        txt = XTexture::Create();
//
//        txt->Init(view,(XTextureType)data.format);
//    }
//    txt->Draw(data.datas,data.width,data.height);
}
