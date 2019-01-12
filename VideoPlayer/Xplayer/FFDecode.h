//
//  FFDecode.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/11.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef FFDecode_hpp
#define FFDecode_hpp
#include "IDecode.h"
class FFDecode : public IDecode{
public:
    virtual bool Open(XParameter para);
    
    AVCodecParameters *mCodecPara;
    
};

#endif /* FFDecode_hpp */
