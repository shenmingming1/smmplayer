//
//  XData.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/8.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef XData_hpp
#define XData_hpp

#include <stdio.h>
struct XData{
    unsigned char *data = 0;
    unsigned char *datas[8] = {0};
    int size = 0;
    int isAudio = false;
    int width = 0;
    int height = 0;
    void Drop();
    int format = 0;
};
#endif /* XData_hpp */
