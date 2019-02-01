//
//  util.h
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/1.
//  Copyright © 2019年 申明明. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>
#include <stdio.h>

NS_ASSUME_NONNULL_BEGIN
GLuint initShader(GLenum shaderType, const char*shaderCode);
GLuint CreateProgram(GLuint vsShader, GLuint fsShader);
GLuint CompileShader(GLenum shaderType, const char*shaderPath);

@interface util : NSObject

@end

NS_ASSUME_NONNULL_END
