//
//  XLog.hpp
//  VideoPlayer
//
//  Created by 申明明1 on 2019/1/9.
//  Copyright © 2019年 申明明. All rights reserved.
//

#ifndef XLog_hpp
#define XLog_hpp


#include <stdio.h>
#define __DEBUG__
#define __IOS__
#define __OS_LOG__

#ifdef __DEBUG__
#ifdef __OS_LOG__
#if defined(__ANDROID__)
#define LOGK(...) __android_log_print(LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define LOGI(...) __android_log_print(LOG_INFO,LOG_TAG,__VA_ARGS__)
#define LOGL()    __android_log_print(LOG_INFO,LOG_TAG,"<%s,%s,%d>",__FILENAME__,__FUNCTION__,__LINE__)
#define LOGK(...) __android_log_print(LOG_KILL,LOG_TAG,__VA_ARGS__)
#define LOGP(...) __android_log_print(LOG_KILL,LOG_TAG,__VA_ARGS__)
#define LOGF(...) __android_log_print(LOG_KILL,LOG_TAG,__VA_ARGS__)
#define LOGTAGI(TAG,...) __android_log_print(LOG_KILL,TAG,__VA_ARGS__)
#define LOGTAGL(TAG)    __android_log_print(LOG_KILL,TAG,"<%s,%s,%d>",__FILENAME__,__FUNCTION__,__LINE__)
#elif defined(__IOS__)
#define LOGK(...) printf(__VA_ARGS__)
#define LOGI(...) printf(__VA_ARGS__)
#define LOGK(...) printf(__VA_ARGS__)
#define LOGF(...) printf(__VA_ARGS__)
#define LOGP(...) printf(__VA_ARGS__)
#define LOGL() printf("<%s,%s,%d>",__FILENAME__,__FUNCTION__,__LINE__)
#define LOGTAGI(TAG,...) printf(__VA_ARGS__)
#define LOGTAGL(TAG) printf("<%s,%s,%d>",__FILENAME__,__FUNCTION__,__LINE__)
#else
#define LOGK(...) printf(__VA_ARGS__)
#define LOGI(...) printf(__VA_ARGS__)
#define LOGK(...) printf(__VA_ARGS__)
#define LOGF(...) printf(__VA_ARGS__)
#define LOGP(...) printf(__VA_ARGS__)
#define LOGTAGI(TAG,...) printf(__VA_ARGS__)
#define LOGTAGL(TAG) printf("<%s,%s,%d>",__FILENAME__,__FUNCTION__,__LINE__)
#endif
#else
#define LOGK(...) av_logger_nprintf(LOG_DEBUG,LOG_TAG,nullptr,__FILENAME__,__FUNCTION__,__LINE__,__VA_ARGS__)
#define LOGI(...) av_logger_nprintf(LOG_INFO,LOG_TAG,nullptr,__FILENAME__,__FUNCTION__,__LINE__,__VA_ARGS__)
#define LOGL()    av_logger_lprintf(LOG_INFO,LOG_TAG,__FILENAME__,__FUNCTION__,__LINE__)
#define LOGK(...) av_logger_nprintf(LOG_KILL,LOG_TAG,this,__FILENAME__,__FUNCTION__,__LINE__,__VA_ARGS__)
#define LOGF(...) av_logger_nprintf(LOG_KILL,LOG_TAG,this,__FILENAME__,__FUNCTION__,__LINE__,__VA_ARGS__)
#if defined(__DEBUG_PTR__)
#define LOGP(...) av_logger_nprintf(LOG_PTR,"ttpoint",nullptr,__FILENAME__,__FUNCTION__,__LINE__,__VA_ARGS__)
#else
#define LOGP(...)
#endif
#if defined(__DEBUG_TAG_LOG__)
#define LOGTAGI(TAG,...) av_logger_nprintf(LOG_KILL,TAG,this,__FILENAME__,__FUNCTION__,__LINE__,__VA_ARGS__)
#define LOGTAGL(TAG)     av_logger_lprintf(LOG_KILL,TAG,__FILENAME__,__FUNCTION__,__LINE__)
#else
#define LOGTAGI(TAG,...)
#define LOGTAGL(TAG)
#endif
#endif
#else
#define LOGV(...)
#define LOGK(...)
#define LOGI(...)
#define LOGK(...)
#define LOGL()
#define LOGP(...)
#define LOGTAGI(TAG,...)
#define LOGTAGL(TAG)
#endif

#endif /* XLog_hpp */
