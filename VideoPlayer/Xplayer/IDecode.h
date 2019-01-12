//
//  IDecode.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/11.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef IDecode_hpp
#define IDecode_hpp
#include "XParameter.h"
class IDecode {
    
public:
    virtual bool Open(XParameter para) = 0;
};

#endif /* IDecode_hpp */
