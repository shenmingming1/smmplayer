//
//  OpenGLView.h
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/29.
//  Copyright © 2019 申明明. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "XData.h"
NS_ASSUME_NONNULL_BEGIN

@interface OpenGLView : UIView{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    GLuint vertexBufferId;
    GLuint program;
    GLint positionLocation;
    GLint aTexCoord;
    XData xdata;
    GLuint texts[100];
    unsigned int vsh;
    unsigned int fsh;
    int             _vertCount;
    GLuint          _vbo;
}
- (void)updateDataController:(XData)data;
@end

NS_ASSUME_NONNULL_END
