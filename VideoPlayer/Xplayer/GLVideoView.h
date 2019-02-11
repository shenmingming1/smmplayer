//
//  GLVideoView.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/19.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef GLVideoView_hpp
#define GLVideoView_hpp

#include "XData.h"
#include "IVideoView.h"
//#import "OpenGLView.h"
class XTexture;

class GLVideoView: public IVideoView {
public:
    virtual void SetRender(void* user,updateD callback);
    virtual void Render(XData data);
    virtual void Close();
protected:
    void *view = 0;
    XTexture *txt = 0;
    std::mutex mux;
    updateD mCallBack;
//    OpenGLView* openView;
};


#endif /* GLVideoView_hpp */
