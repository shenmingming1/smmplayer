//
//  ViewController.m
//  VideoPlayer
//
//  Created by 申明明1 on 2018/10/30.
//  Copyright © 2018年 申明明. All rights reserved.
//

#import "ViewController.h"
#import "util.h"
#include "Xplayer/FFDemux.h"
#include "Xplayer/XLog.h"
#include "Xplayer/FFDecode.h"
#include "XPlayerViewController.h"
#import "OpenGLView.h"
#include "GLVideoView.h"
extern "C" {
    
    static int updateData(void* user,XData data) {
        
        OpenGLView *client = (__bridge id)user;
        XSleep(30);
        [client updateDataController:data];
        return -1;
    }
}

class TestObserver : public IObserver{
public:
    virtual void Update(XData data){
//        LOGK("TestObserver Update data Size is %d\n",data.size);
    }
};
@interface ViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) OpenGLView* openglView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
//    XPlayerViewController *viewController = [[XPlayerViewController alloc] init];
//    [self.navigationController pushViewController:viewController animated:NO];
    self.openglView = [[OpenGLView alloc] init];
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
    IVideoView *view = new GLVideoView();
    view->SetRender((__bridge void*)_openglView, updateData);
    vDecode->AddObservers(view);
    
    demux->Start();
    vDecode->Start();
    aDecode->Start();
    _openglView.frame = self.view.bounds;
    _openglView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_openglView];

}
@end
