//
//  XPlayerViewController.h
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/21.
//  Copyright © 2019 申明明. All rights reserved.
//

#import <GLKit/GLKit.h>
#include "XData.h"
NS_ASSUME_NONNULL_BEGIN

@interface XPlayerViewController : GLKViewController

- (void)initShader;
- (void)GetTexture:(unsigned int )index width:(int)width height:(int)height buf:(unsigned char* )buffer isAlpha:(bool)isAlpha;
- (void)updateDataController:(XData)data;

@end

NS_ASSUME_NONNULL_END
