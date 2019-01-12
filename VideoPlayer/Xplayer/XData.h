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
    int size = 0;
    void Drop();
};
#endif /* XData_hpp */
