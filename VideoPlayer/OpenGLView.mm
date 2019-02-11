//
//  OpenGLView.m
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/29.
//  Copyright © 2019 申明明. All rights reserved.
//

#import "OpenGLView.h"
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>
#include "Xplayer/XLog.h"

///顶点着色器glsl
#define GET_STR(x) #x
static const char *vertexShader = GET_STR(
                                          attribute vec4 aPosition; //顶点坐标
                                          attribute vec2 aTexCoord; //材质顶点坐标
                                          varying vec2 vTexCoord;   //输出的材质坐标
                                          void main(){
                                              vTexCoord = vec2(aTexCoord.x,1.0-aTexCoord.y);
                                              gl_Position = aPosition;
                                          }
                                          );

//片元着色器,软解码和部分x86硬解码
static const char *fragYUV420P = GET_STR(
                                         precision mediump float;    //精度
                                         varying vec2 vTexCoord;     //顶点着色器传递的坐标
                                         uniform sampler2D yTexture; //输入的材质（不透明灰度，单像素）
                                         uniform sampler2D uTexture;
                                         uniform sampler2D vTexture;
                                         void main(){
                                             vec3 yuv;
                                             vec3 rgb;
                                             yuv.r = texture2D(yTexture,vTexCoord).r;
                                             yuv.g = texture2D(uTexture,vTexCoord).r - 0.5;
                                             yuv.b = texture2D(vTexture,vTexCoord).r - 0.5;
                                             rgb = mat3(1.0,     1.0,    1.0,
                                                        0.0,-0.39465,2.03211,
                                                        1.13983,-0.58060,0.0)*yuv;
                        
                                             gl_FragColor = vec4(rgb,1.0);
                                         }
                                         );

static GLuint InitShader(const char *code,GLint type)
{
    //创建shader
    GLuint sh = glCreateShader(type);
    if(sh == 0)
    {
        LOGK("glCreateShader %d failed!\n",type);
        return 0;
    }
    //加载shader
    glShaderSource(sh,
                   1,    //shader数量
                   &code, //shader代码
                   0);   //代码长度
    //编译shader
    glCompileShader(sh);
    
    //获取编译情况
    GLint status;
    glGetShaderiv(sh,GL_COMPILE_STATUS,&status);
    if(status == 0)
    {
        LOGK("glCompileShader failed!\n");
        return 0;
    }
    LOGK("glCompileShader success!\n");
    return sh;
}

GLuint createVBO(GLenum target, int usage, int datSize, void *data)
{
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(target, vbo);
    glBufferData(target, datSize, data, usage);
    return vbo;
}

unsigned char * LoadFileContent(const char*path,int&filesize){
    unsigned char*fileContent=nullptr;
    filesize=0;
    NSString *nsPath=[[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:path] ofType:nil];
    NSData*data=[NSData dataWithContentsOfFile:nsPath];
    if([data length]>0){
        filesize=[data length];
        fileContent=new unsigned char[filesize+1];
        memcpy(fileContent, [data bytes], filesize);
        fileContent[filesize]='\0';
    }
    return fileContent;
}
unsigned char* DecodeBMP(unsigned char*bmpFileData, int&width, int&height) {
    if (0x4D42 == *((unsigned short*)bmpFileData)) {
        int pixelDataOffset = *((int*)(bmpFileData + 10));
        width = *((int*)(bmpFileData + 18));
        height = *((int*)(bmpFileData + 22));
        unsigned char*pixelData = bmpFileData + pixelDataOffset;
        for (int i = 0; i < width*height * 3; i += 3) {
            unsigned char temp = pixelData[i];
            pixelData[i] = pixelData[i + 2];
            pixelData[i + 2] = temp;
        }
        return pixelData;
    }
    return nullptr;
}
GLuint CreateTexture2D(unsigned char*pixelData, int width, int height, GLenum type) {
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);//该函数表示的是当所显示的纹理比加载进来的纹理大时，采用GL_LINEAR的方法来处理
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);//该函数表示的是当所显示的纹理比加载进来的纹理小时，采用GL_LINEAR的方法来处理
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, type, width, height, 0, type, GL_UNSIGNED_BYTE, pixelData);//将像素数据上传到GPU上，　参数1为纹理目标；参数2为目标的层次，即目标的详细程度，一般情况采用0即可；参数3表示的是数据成分的个数，如果数据由RGB构成，则将该参数设置为3；参数4和5分别为创建纹理数据的长和宽；参数6为边框的值，一般也设为0；参数8为数据的通道格式；参数9为纹理的数据元素类型；参数10为纹理的数据内容。
    
    
//    glBindTexture(GL_TEXTURE_2D, 0);
    return texture;
}
GLuint CreateTexture2DFromBMP(const char*bmpPath) {
    int nFileSize = 0;
    unsigned char *bmpFileContent = LoadFileContent(bmpPath, nFileSize);
    if (bmpFileContent == nullptr) {
        return 0;
    }
    int bmpWidth = 0, bmpHeight = 0;
    unsigned char*pixelData = DecodeBMP(bmpFileContent, bmpWidth, bmpHeight);
    if (bmpWidth == 0) {
        return 0;
    }
    GLuint texture = CreateTexture2D(pixelData, bmpWidth, bmpHeight, GL_RGB);
    delete bmpFileContent;
    return texture;
}
@implementation OpenGLView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self initShader];
      
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (Class)layerClass
{
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}


- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}
- (void)setupContext {
    // 指定OpenGL渲染API的版本，在这里我们使用OpenGL ES 2.0
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}
- (void)setupFrameAndRenderBuffer{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}


- (void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}
- (void)render:(XData)data {
    glClearColor(0.1f, 0.4f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glLineWidth(2.0);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    int width = xdata.width;
    int height = xdata.height;
    [self GetTexture:0 width:width height:height buf:xdata.datas[0] isAlpha:false];
    [self GetTexture:1 width:width/2 height:height/2 buf:xdata.datas[1] isAlpha:false];
    [self GetTexture:2 width:width/2 height:height/2 buf:xdata.datas[2] isAlpha:false];
//    const char* filePath = "earth.bmp";
//    CreateTexture2DFromBMP(filePath);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // 索引数组
    //unsigned int indices[] = {0,1,2,3,2,0};
    //glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, indices);
    
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)initShader{
    vsh = InitShader(vertexShader,GL_VERTEX_SHADER);
    
    //片元yuv420 shader初始化
    
    fsh = InitShader(fragYUV420P,GL_FRAGMENT_SHADER);
    
    
    if(fsh == 0 || vsh == 0)
    {
        
        LOGK("InitShader GL_FRAGMENT_SHADER failed!");
        
    }
    LOGK("InitShader GL_FRAGMENT_SHADER success!\n");
    
    
    /////////////////////////////////////////////////////////////
    //创建渲染程序
    program = glCreateProgram();
    if(program == 0)
    {
        
        LOGK("glCreateProgram failed!\n");
        
    }
    //渲染程序中加入着色器代码
    glAttachShader(program,vsh);
    glAttachShader(program,fsh);
    
    //链接程序
    glLinkProgram(program);
    GLint status = 0;
    glGetProgramiv(program,GL_LINK_STATUS,&status);
    if(status != GL_TRUE)
    {
        
        LOGK("glLinkProgram failed!\n");
    }
    
    glUseProgram(program);
    LOGK("glLinkProgram success!\n");
    /////////////////////////////////////////////////////////////
    [self setupVBO];
    
//    //加入三维顶点数据 两个三角形组成正方形
//    static float vers[] = {
//        1.0f,-1.0f,-1.0f,
//        -1.0f,-1.0f,-1.0f,
//        1.0f,1.0f,-1.0f,
////        -1.0f,1.0f,0.0f,
//    };
//    GLuint apos = (GLuint)glGetAttribLocation(program,"aPosition");
//    glEnableVertexAttribArray(apos);
//    //传递顶点
//    glVertexAttribPointer(apos,3,GL_FLOAT,GL_FALSE,9,vers);
//
//    //加入材质坐标数据
//    static float txts[] = {
//        1.0f,0.0f , //右下
//        0.0f,0.0f,
//        1.0f,1.0f,
//        0.0,1.0
//    };
//    GLuint atex = (GLuint)glGetAttribLocation(program,"aTexCoord");
//    glEnableVertexAttribArray(atex);
//    glVertexAttribPointer(atex,2,GL_FLOAT,GL_FALSE,8,txts);
//
    
    //材质纹理初始化
    //设置纹理层
    glUniform1i(glGetUniformLocation(program,"yTexture"),0); //对于纹理第1层
    glUniform1i(glGetUniformLocation(program, "uTexture"), 1); //对于纹理第2层
    glUniform1i(glGetUniformLocation(program, "vTexture"), 2); //对于纹理第3层
    const char* filePath = "earth.bmp";
//    CreateTexture2DFromBMP(filePath);
    LOGK("初始化Shader成功！");
    
}
- (void)setupVBO
{
    
    //    GLfloat vertices[] = {
    //         1.0f,-1.0f,-1.0f, 1.0f, 1.0f,   // 右上
    //        0.5f, -0.5f, 0.0f, 1.0f, 0.0f,   // 右下
    //        -0.5f, -0.5f, 0.0f, 0.0f, 0.0f,  // 左下
    //        -0.5f,  0.5f, 0.0f, 0.0f, 1.0f   // 左上
    //    };
    
    GLfloat vertices[] = {
        1.0f,-1.0f,0.0f, 1.0f,0.0f,   // 右下
        -1.0f,-1.0f,0.0f, 0.0f,0.0f,   // 左下
        1.0f,1.0f,0.0f, 1.0f,1.0f,  // 右上
        -1.0f,1.0f,0.0f, 0.0,1.0,  // 左上
    };
    
    // 创建VBO
    _vbo = createVBO(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(vertices), vertices);
    
    glEnableVertexAttribArray(glGetAttribLocation(program,"aPosition"));
    glVertexAttribPointer(glGetAttribLocation(program,"aPosition"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    
    glEnableVertexAttribArray(glGetAttribLocation(program,"aTexCoord"));
    glVertexAttribPointer(glGetAttribLocation(program, "aTexCoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (void*)(sizeof(GL_FLOAT)*3));
}


- (void)GetTexture:(unsigned int )index width:(int)width height:(int)height buf:(unsigned char* )buffer isAlpha:(bool)isAlpha{
    unsigned int format =GL_LUMINANCE;
    if(isAlpha)
        format = GL_LUMINANCE_ALPHA;
    
    if(texts[index] == 0)
    {
        //材质初始化
        glGenTextures(1,&texts[index]);
        
        //设置纹理属性
        glBindTexture(GL_TEXTURE_2D,texts[index]);
        //缩小的过滤器
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);

        //设置纹理的格式和大小
        glTexImage2D(GL_TEXTURE_2D,
                     0,           //细节基本 0默认
                     format,//gpu内部格式 亮度，灰度图
                     width,height, //拉升到全屏
                     0,             //边框
                     format,//数据的像素格式 亮度，灰度图 要与上面一致
                     GL_UNSIGNED_BYTE, //像素的数据类型
                     nullptr                    //纹理的数据
                     );
         glGenerateMipmap(GL_TEXTURE_2D);
    }
    
    
    //激活第1层纹理,绑定到创建的opengl纹理
    glActiveTexture(GL_TEXTURE0+index);
    glBindTexture(GL_TEXTURE_2D,texts[index]);
    //替换纹理内容
    glTexSubImage2D(GL_TEXTURE_2D,0,0,0,width,height,format,GL_UNSIGNED_BYTE,buffer);
}

- (void)updateDataController:(XData)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [EAGLContext setCurrentContext:_context];
        [self destoryRenderAndFrameBuffer];
        [self setupFrameAndRenderBuffer];
        xdata = data;
        [self render:data];
    });
    
}
@end
