//
//  OpenGLView.h
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/29.
//  Copyright © 2019 申明明. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenGLView : UIView{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
}

@end

NS_ASSUME_NONNULL_END
