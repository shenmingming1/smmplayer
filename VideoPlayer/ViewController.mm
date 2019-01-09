//
//  ViewController.m
//  VideoPlayer
//
//  Created by 申明明1 on 2018/10/30.
//  Copyright © 2018年 申明明. All rights reserved.
//

#import "ViewController.h"
#import "util.h"

#include <stdio.h>

#define __STDC_CONSTANT_MACROS

#ifdef _WIN32
//Windows
extern "C"
{
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"
#include "fftools/ffplay.h"
};
#else
//Linux...
#ifdef __cplusplus
extern "C"
{
#endif
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include "libswresample/swresample.h"
#include "fftools/ffplay.h"
#ifdef __cplusplus
};
#endif
#endif

//Refresh
#define SFM_REFRESH_EVENT  (SDL_USEREVENT + 1)
#define MAX_AUDIO_FRAME_SIZE 192000 // 1 second of 48khz 32bit audio

//顶点着色器glsl
#define GET_STR(x) #x
static const char *vertexShader = GET_STR(
                                          attribute vec4 aPosition; //顶点坐标
                                          attribute vec2 aTexCoord; //材质顶点坐标
                                          varying vec2 vTexCoord; //输出的材质坐标
                                          void main(){
                                              vTexCoord = vec2(aTexCoord.x,1.0-aTexCoord.y);
                                              gl_Position = aPosition;
                                          }

);
//片源着色器,软解码和部分x86硬解码
static const char *fragYUV420P = GET_STR(
                                         precision mediump float;
                                         varying vec2 vTexCoord;
                                         uniform sampler2D yTexture; //输入的材质（不透明灰度，单像素）
                                         uniform sampler2D uTexture;
                                         uniform sampler2D vTexture;
                                         void main(){
                                             vec3 yuv;
                                             vec3 rgb;
                                             yuv.r = texture2D(yTexture,vTexCoord).r;
                                             yuv.g = texture2D(uTexture,vTexCoord).r - 0.5;
                                             yuv.g = texture2D(vTexture,vTexCoord).r - 0.5;
                                             rgb = mat3(1.0,1.0,1.0,
                                                       0.0,-0.39465,2.03211,
                                                       1.13983,-0.5806,0.0)*yuv;
                                             gl_FragColor = vec4(rgb,1.0);
                                             
                                         }

);


static double r2d(AVRational r){
    return r.num == 0 || r.den == 0?0:(double)r.num/(double)r.den;
}

@interface ViewController ()
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    openFile();
    [self setOpenGL];
   
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)setOpenGL{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];//3.0
    if(!self.context)
    {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];//2.0
    }
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    //
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.context];
    
    GLint vsh = initShader(GL_VERTEX_SHADER, vertexShader);
    GLint fsh = initShader(GL_FRAGMENT_SHADER, fragYUV420P);
    GLuint program = CreateProgram(vsh, fsh);
    
    static float vers[] = {
        1.0f,-1.0f,0.0f,
        -1.0f,-1.0f,0.0f,
        1.0f,1.0f,0.0f,
        -1.0f,1.0f,0.0f,
    };
    GLuint apos = glGetAttribLocation(program, "aPosition");
    glEnableVertexAttribArray(apos);
    glVertexAttribPointer(apos, 3, GL_FLOAT, GL_FALSE, 12, vers);
    static float txts[] = {
        1.0f,0.0f,
        0.0f,0.0f,
        1.0f,1.0f,
        0.0f,1.0f
    };
    GLuint atex = glGetAttribLocation(program, "aTexCoord");
    glEnableVertexAttribArray(atex);
    glVertexAttribPointer(apos, 2, GL_FLOAT, GL_FALSE, 8, txts);
    //材质纹理初始化

    GLint yTexture = glGetUniformLocation(program, "yTexture");
    glUniform1i(yTexture, 0);
    GLint uTexture = glGetUniformLocation(program, "uTexture");
    glUniform1i(uTexture, 1);
    GLint vTexture = glGetUniformLocation(program, "vTexture");
    glUniform1i(vTexture, 2);
    //创建opengl 纹理
    GLuint texts[3] = {0};
    //创建三个纹理
    glGenTextures(3,texts);
    //设置纹理属性
    int width = 424;
    int height = 240;
    glBindTexture(GL_TEXTURE_2D, texts[0]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);//该函数表示的是当所显示的纹理比加载进来的纹理大时，采用GL_LINEAR的方法来处理
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);//该函数表示的是当所显示的纹理比加载进来的纹理小时，采用GL_LINEAR的方法来处理
    //设置纹理的格式和大小
    glTexImage2D(GL_TEXTURE_2D,
                 0,//0是默认
                 GL_LUMINANCE,// gpu内部格式亮度，灰度图
                 width, height,//拉伸到全屏
                 0, GL_LUMINANCE,//数据的像素格式
                 GL_UNSIGNED_BYTE,//像素的数据类型
                 nullptr);
    ////////////////////////////////////////////////////
   



}
void openFile() {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    const char* filePath_char = [filePath UTF8String];
    //初始化解封装
    av_register_all();
    //初始化网络
    avformat_network_init();
    avcodec_register_all();
    AVFormatContext *ic = NULL;
    
    int ret = avformat_open_input(&ic,filePath_char,0,0);
    if (ret == 0){
        NSLog(@"open success");
        NSLog(@"duration = %lld,nb_streams:=%d",ic->duration,ic->nb_streams);
    } else {
        NSLog(@"open failed:%s",av_err2str(ret));
    }
    ret = avformat_find_stream_info(ic, NULL);
    if (ret != 0) {
        NSLog(@"avformat_find_stream_info failed !");
    }
    NSLog(@"duration = %lld,nb_streams:=%d",ic->duration,ic->nb_streams);
    int width = 0;
    int height = 0;
    int videoStream = 0;
    int audioStream;
    int fps = 0;
//    av_find_best_stream(<#AVFormatContext *ic#>, <#enum AVMediaType type#>, <#int wanted_stream_nb#>, <#int related_stream#>, <#AVCodec **decoder_ret#>, <#int flags#>)
    for (int i=0; i<ic->nb_streams; i++) {
        AVStream *as = ic->streams[i];
        if (as->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoStream = i;
            fps = r2d(as->avg_frame_rate);
            NSLog(@"fps = %d,width = %d height = %d,format=%d",fps,as->codecpar->width,as->codecpar->height,as->codecpar->format);
        }else if (as->codecpar->codec_type == AVMEDIA_TYPE_AUDIO){
            audioStream = i;
            NSLog(@"audioStream=%d, sample_rate = %d,channels = %d sample_format = %d",audioStream,as->codecpar->sample_rate,as->codecpar->channels,as->codecpar->format);
        }
    }
    audioStream = av_find_best_stream(ic, AVMEDIA_TYPE_AUDIO, -1, -1, NULL, 0);
    NSLog(@"av_find_best_stream audioStream:%d",audioStream);
    
    //软解码器
    AVCodec *vcodec = avcodec_find_decoder(ic->streams[videoStream]->codecpar->codec_id);
    //硬解码
//    codec = avcodec_find_decoder_by_name("h264_mediacodec");
    if (!vcodec) {
        
        NSLog(@"find video codec faile");
        return;
    }
    //初始化解码器
    AVCodecContext *vcc = avcodec_alloc_context3(vcodec);
    avcodec_parameters_to_context(vcc, ic->streams[videoStream]->codecpar);
    vcc->thread_count = 1;
    //打开解码器 因为创建解码器上下文的时候，已经传入codec，所以第二个参数不需要传入vcodec
    ret = avcodec_open2(vcc, 0, 0);
    if (ret != 0) {
        NSLog(@"open video avcodec_faile");
    }
    ///////////////////////////////////////////////////////////////
    //初始化音频解码器
    AVCodec *acodec = avcodec_find_decoder(ic->streams[audioStream]->codecpar->codec_id);
    if (!acodec) {
        NSLog(@"find acodec faile");
        return;
    }
    AVCodecContext *acc = avcodec_alloc_context3(acodec);
    avcodec_parameters_to_context(acc, ic->streams[audioStream]->codecpar);
    ret = avcodec_open2(acc, 0, 0);
    if (ret != 0) {
        NSLog(@"open avcodec faile");
        return;
    }
    
    
//    av_packet_clone(<#const AVPacket *src#>)
//    av_packet_ref(<#AVPacket *dst#>, <#const AVPacket *src#>)
    AVPacket *packet = av_packet_alloc();
    AVFrame *frame = av_frame_alloc();
    
    //初始化像素格式转换的上下文
    SwsContext *vctx = NULL;
    int outWidth = 128;
    int outHeight = 72;
    
    char *rgb = new char[1920*1080*4];
    char *pcm = new char[48000*4*2];
    long long start = GetNowTime();
    int frameCount = 0;
    //音频重采样上下文初始化
    SwrContext *actx = swr_alloc();
    actx = swr_alloc_set_opts(actx, av_get_default_channel_layout(2), AV_SAMPLE_FMT_S16, acc->sample_rate, av_get_default_channel_layout(acc->channels), acc->sample_fmt, acc->sample_rate, 0, 0);
    ret = swr_init(actx);
    if (ret != 0) {
        NSLog(@"swr_init failed");
    }else {
        NSLog(@"swr_init success");
    }
    
    for (; ; ) {
        //超过三秒
        if (GetNowTime() - start >= 3000) {
            NSLog(@"now decode fps is %d",frameCount/3);
            start = GetNowTime();
            frameCount = 0;
        }
        int ret = av_read_frame(ic, packet);
        
        if (ret !=0) {
            NSLog(@"读到结尾处了");
            int pos = 20*r2d(ic->streams[videoStream]->time_base);
            av_seek_frame(ic, videoStream, pos, AVSEEK_FLAG_BACKWARD|AVSEEK_FLAG_FRAME);
            continue;
        }
        AVCodecContext* cc = vcc;
        
        if (packet->stream_index == audioStream) {
//            NSLog(@"packet is not videoStream");
            cc = acc;
//            continue;
        }
        //发送到线程中解码
        ret = avcodec_send_packet(cc, packet);
        av_packet_unref(packet);
        if (ret != 0) {
            NSLog(@"avcodec_send_packet failed");
            continue;
        }
       
        for (; ; ) {
            ret = avcodec_receive_frame(cc, frame);
            if (ret != 0) {
                NSLog(@"avcodec_receive_frame failed");
                break;
            }
            NSLog(@"avcodec_receive_frame:pts:%lld",frame->pts);
            //如果是视频帧
            if (cc == vcc) {
                frameCount++;
                vctx = sws_getCachedContext(vctx, frame->width, frame->height, (AVPixelFormat)frame->format, outWidth, outHeight, AV_PIX_FMT_RGBA, SWS_FAST_BILINEAR, 0, 0, 0);
                if (!vctx) {
                    NSLog(@"sws_getCachedContext failed");
                }else {
                    uint8_t *data[AV_NUM_DATA_POINTERS] = {0};
                    data[0] =  (uint8_t*)rgb;
                    int lines[AV_NUM_DATA_POINTERS]  = {0};
                    lines[0] = outWidth*4;
                    int h = sws_scale(vctx,
                                      frame->data,
                                      frame->linesize,
                                      0,
                                      frame->height,
                                      data,
                                      lines);
                    NSLog(@"sws_scale = %d",h);
                    
                    
                }
            }else {  //音频
                uint8_t *outAudio[2] = {0};
                outAudio[0] = (uint8_t*)pcm;
                //音频重采样
                int len = swr_convert(actx, outAudio,frame->nb_samples, (const uint8_t**)frame->data, frame->nb_samples);
                NSLog(@"swr_convert = %d",len);
                
                
            }
            
        }
       
//
//        NSLog(@"stream = %d size = %d,pts == %lld flag = %d",packet->stream_index,packet->size,packet->pts,packet->flags);
//        ///////////////////////////////
//
//        av_packet_unref(packet);
    }
    delete []rgb;
}
long long GetNowTime(){
    return (long long)([[NSDate date] timeIntervalSince1970] * 1000);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //    Draw();
    static float txts[] = {
        1.0f,0.0f,
        0.0f,0.0f,
        1.0f,1.0f,
        0.0f,1.0f
    };
    int width = 424;
    int height = 240;
    //纹理的修改和显示
    unsigned char *buf[3] = {0};
    buf[0] = new unsigned char[width*height];
    buf[1] = new unsigned char[width*height/4];
    buf[2] = new unsigned char[width*height/4];
    
    for (int i = 0; i<10000; i++) {
        memset(buf[0], i, width*height);
        memset(buf[1], i, width*height/4);
        memset(buf[2], i, width*height/4);
        //激活第一层纹理，绑定到创建的opengl纹理
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, txts[0]);
        //替换纹理内容
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_LUMINANCE, GL_UNSIGNED_BYTE, buf[0]);
        
        
        //激活第二层纹理，绑定到创建的opengl纹理
        glActiveTexture(GL_TEXTURE0+1);
        glBindTexture(GL_TEXTURE_2D, txts[1]);
        //替换纹理内容
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width/2, height/2, GL_LUMINANCE, GL_UNSIGNED_BYTE, buf[1]);
        
        //激活第二层纹理，绑定到创建的opengl纹理
        glActiveTexture(GL_TEXTURE0+2);
        glBindTexture(GL_TEXTURE_2D, txts[2]);
        //替换纹理内容
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width/2, height/2, GL_LUMINANCE, GL_UNSIGNED_BYTE, buf[2]);
        //三维绘制
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        //窗口显示
        
        
    }
    
}

@end
