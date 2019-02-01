//
//  XPlayerViewController.m
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/21.
//  Copyright © 2019 申明明. All rights reserved.
//

#import "XPlayerViewController.h"
#import "util.h"
#import "util.h"
#include "Xplayer/FFDemux.h"
#include "Xplayer/XLog.h"
#include "Xplayer/FFDecode.h"

extern "C" {
    typedef int (*updateD)(void* user,XData data);
    
    static int updateData(void* user,XData data) {

        XPlayerViewController *client = (__bridge id)user;
        [client updateDataController:data];
        return -1;
    }
}
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
                                             //输出像素颜色
                                             gl_FragColor = vec4(rgb,1.0);
                                         }
                                         );

class TestObserver : public IObserver{
private:
    void* mUser;
    updateD updateFun;
public:
    TestObserver(void* user,updateD action){
        mUser = user;
        updateFun = action;
    }
    virtual void Update(XData data){
        updateFun(mUser,data);
    }
};
static GLuint InitShader(const char *code,GLint type)
{
    //创建shader
    GLuint sh = glCreateShader(type);
    if(sh == 0)
    {
        LOGK("glCreateShader %d failed!",type);
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
        LOGK("glCompileShader failed!");
        return 0;
    }
    LOGK("glCompileShader success!");
    return sh;
}
@interface XPlayerViewController ()

{
    GLuint vertexBufferId;
    GLuint program;
    GLint positionLocation;
    GLint aTexCoord;
    XData xdata;
    GLuint texts[100];
    unsigned int vsh;
    unsigned int fsh;
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;



@end

@implementation XPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"ViewController's view is not a GLKView");
    
    
    // 创建一个OpenGL ES 2.0 context（上下文）并将其提供给view
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    // 将刚刚创建的context设置为当前context
    [EAGLContext setCurrentContext:view.context];
     [self initShader];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    const char* filePath_char = [filePath UTF8String];
    
    IDemux *demux = new FFDemux();
    demux->Open(filePath_char);
    
    IDecode *vDecode = new FFDecode();
    vDecode->Open(demux->GetVPara());
    
    IDecode *aDecode = new FFDecode();
    aDecode->Open(demux->GetAPara());
    
    demux->AddObservers(vDecode);
    demux->AddObservers(aDecode);
    
    demux->Start();
    vDecode->Start();
    aDecode->Start();
   
    // Do any additional setup after loading the view.
    
    TestObserver * test = new TestObserver((__bridge void*)self,updateData);
    vDecode->AddObservers(test);

}
- (void)initShader{
    vsh = InitShader(vertexShader,GL_VERTEX_SHADER);
    
    //片元yuv420 shader初始化
 
    fsh = InitShader(fragYUV420P,GL_FRAGMENT_SHADER);

    
    if(fsh == 0 || vsh == 0)
    {
        
        LOGK("InitShader GL_FRAGMENT_SHADER failed!");
    
    }
    LOGK("InitShader GL_FRAGMENT_SHADER success!");
    
    
    /////////////////////////////////////////////////////////////
    //创建渲染程序
    program = glCreateProgram();
    if(program == 0)
    {
        
        LOGK("glCreateProgram failed!");
        
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
        
        LOGK("glLinkProgram failed!");
    }
    
    glUseProgram(program);
    LOGK("glLinkProgram success!");
    /////////////////////////////////////////////////////////////
    
    
    //加入三维顶点数据 两个三角形组成正方形
    static float vers[] = {
        1.0f,-1.0f,0.0f,
        -1.0f,-1.0f,0.0f,
        1.0f,1.0f,0.0f,
        -1.0f,1.0f,0.0f,
    };
    GLuint apos = (GLuint)glGetAttribLocation(program,"aPosition");
    glEnableVertexAttribArray(apos);
    //传递顶点
    glVertexAttribPointer(apos,3,GL_FLOAT,GL_FALSE,12,vers);
    
    //加入材质坐标数据
    static float txts[] = {
        1.0f,0.0f , //右下
        0.0f,0.0f,
        1.0f,1.0f,
        0.0,1.0
    };
    GLuint atex = (GLuint)glGetAttribLocation(program,"aTexCoord");
    glEnableVertexAttribArray(atex);
    glVertexAttribPointer(atex,2,GL_FLOAT,GL_FALSE,8,txts);
    
    
    //材质纹理初始化
    //设置纹理层
    glUniform1i(glGetUniformLocation(program,"yTexture"),0); //对于纹理第1层
    glUniform1i(glGetUniformLocation(program, "uTexture"), 1); //对于纹理第2层
    glUniform1i(glGetUniformLocation(program, "vTexture"), 2); //对于纹理第3层
    
    LOGK("初始化Shader成功！");
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.1f, 0.4f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    if (self->xdata.datas) {
        int width = xdata.width;
        int height = xdata.height;
        [self GetTexture:0 width:width height:height buf:xdata.datas[0] isAlpha:false];
        [self GetTexture:1 width:width/2 height:height/2 buf:xdata.datas[1] isAlpha:false];
        [self GetTexture:2 width:width/2 height:height/2 buf:xdata.datas[2] isAlpha:false];
    }
    glDrawArrays(GL_TRIANGLE_STRIP,0,4);
    
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
        //设置纹理的格式和大小
        glTexImage2D(GL_TEXTURE_2D,
                     0,           //细节基本 0默认
                     format,//gpu内部格式 亮度，灰度图
                     width,height, //拉升到全屏
                     0,             //边框
                     format,//数据的像素格式 亮度，灰度图 要与上面一致
                     GL_UNSIGNED_BYTE, //像素的数据类型
                     buffer                    //纹理的数据
                     );
    }
    
    
    //激活第1层纹理,绑定到创建的opengl纹理
    glActiveTexture(GL_TEXTURE0+index);
    glBindTexture(GL_TEXTURE_2D,texts[index]);
    //替换纹理内容
    glTexSubImage2D(GL_TEXTURE_2D,0,0,0,width,height,format,GL_UNSIGNED_BYTE,buffer);
    
    
}
- (void)updateDataController:(XData)data{

    xdata = data;
    
    XSleep(100);
}

@end
