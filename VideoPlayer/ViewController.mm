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
class TestObserver : public IObserver{
public:
    virtual void Update(XData data){
//        LOGK("TestObserver Update data Size is %d\n",data.size);
    }
};
@interface ViewController ()
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    const char* filePath_char = [filePath UTF8String];
    TestObserver * test = new TestObserver();
    IDemux *demux = new FFDemux();
    demux->Open(filePath_char);
    demux->AddObservers(test);
    demux->Start();
    IDecode *decode = new FFDecode();
    decode->Open(demux->GetVPara());
    XSleep(3000);
    demux->Stop();
//    for (; ; ) {
//        XData d = demux->Read();
//        LOGK("read size",d->size);
//    }
//    openFile();

   
    // Do any additional setup after loading the view, typically from a nib.
}
@end
