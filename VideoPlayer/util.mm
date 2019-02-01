//
//  util.m
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/1.
//  Copyright © 2019年 申明明. All rights reserved.
//

#import "util.h"
GLuint initShader(GLenum shaderType, const char*shaderCode) {
    GLuint shader = glCreateShader(shaderType);
    glShaderSource(shader, 1, &shaderCode, nullptr);
    glCompileShader(shader);
    GLint compileResult = GL_TRUE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileResult);
    if (compileResult == GL_FALSE) {
        char szLog[1024] = { 0 };
        GLsizei logLen = 0;
        glGetShaderInfoLog(shader, 1024, &logLen, szLog);
        printf("Compile Shader fail error log : %s \nshader code :\n%s\n", szLog, shaderCode);
        glDeleteShader(shader);
        shader = 0;
    }
    printf("success");
    return shader;
}
GLuint CreateProgram(GLuint vsShader, GLuint fsShader) {
    GLuint mProgram = glCreateProgram();
    glAttachShader(mProgram, vsShader);
    glAttachShader(mProgram, fsShader);
    glLinkProgram(mProgram);
    glDetachShader(mProgram, vsShader);
    glDetachShader(mProgram, fsShader);
    GLint nResult;
    glGetProgramiv(mProgram, GL_LINK_STATUS, &nResult);
    if (nResult == GL_FALSE){
        char log[1024] = {0};
        GLsizei writed = 0;
        glGetProgramInfoLog(mProgram, 1024, &writed, log);
        printf("create gpu program fail,link error : %s\n", log);
        glDeleteProgram(mProgram);
        mProgram = 0;
    }
    return mProgram;
}
//unsigned char * LoadFileContent(const char*path,int&filesize){
//    unsigned char*fileContent=nullptr;
//    filesize=0;
//    NSString *nsPath=[[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:path] ofType:nil];
//    NSData*data=[NSData dataWithContentsOfFile:nsPath];
//    if([data length]>0){
//        filesize=[data length];
//        fileContent=new unsigned char[filesize+1];
//        memcpy(fileContent, [data bytes], filesize);
//        fileContent[filesize]='\0';
//    }
//    return fileContent;
//}
//float GetFrameTime(){
//    return 0.033f;
//}
//GLuint CompileShader(GLenum shaderType, const char*shaderPath){
//    GLuint shader = glCreateShader(shaderType);
//    if (shader == 0){
//        printf("glCreateShader fail\n");
//        return 0;
//    }
//    int nFileSize = 0;
//    const char* shaderCode = (char*)LoadFileContent(shaderPath, nFileSize);
//    if (shaderCode == nullptr){
//        printf("load shader code from file : %s fail\n", shaderPath);
//        glDeleteShader(shader);
//        return 0;
//    }
//    glShaderSource(shader, 1, &shaderCode, nullptr);
//    glCompileShader(shader);
//    GLint compileResult = GL_TRUE;
//    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileResult);
//    if (compileResult == GL_FALSE){
//        char szLog[1024] = { 0 };
//        GLsizei logLen = 0;
//        glGetShaderInfoLog(shader, 1024, &logLen, szLog);
//        printf("Compile Shader fail error log : %s \nshader code :\n%s\n", szLog, shaderCode);
//        glDeleteShader(shader);
//        shader = 0;
//    }
//    delete shaderCode;
//    return shader;
//}

@implementation util

@end
