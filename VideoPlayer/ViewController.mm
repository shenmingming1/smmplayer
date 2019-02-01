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
 
    XPlayerViewController *viewController = [[XPlayerViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:NO];
    
//    XSleep(3000);
//    demux->Stop();
//    for (; ; ) {
//        XData d = demux->Read();
//        LOGK("read size",d->size);
//    }
//    openFile();

   
    // Do any additional setup after loading the view, typically from a nib.
}
@end
