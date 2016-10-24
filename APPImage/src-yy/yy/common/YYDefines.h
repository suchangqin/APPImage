//
//  YYDefines.h
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import <Foundation/Foundation.h>

// 只有定义了DEBUG宏的情况下才输出日志
#ifdef DEBUG

#   define DYYLog(fmt, ...) NSLog((@"%s [Line %d] ✅ " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define DYYLogWarning(fmt,...) NSLog((@"%s [Line %d] ⚠️ " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define DYYLogError(fmt,...) NSLog((@"%s [Line %d] ❌ " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#else

#   define DYYLog(...)
#   define DYYLogWarning(...)
#   define DYYLogError(...)

#endif // DEBUG

/**
 * 快捷设置成员变量
 * @property_ 成员变量
 * @value_ 成员的值
 */
#define DYY_Property_set_object_retain(property_,value_) {\
if (property_) {\
[property_ release];\
property_ = nil;\
}\
property_ = [value_ retain];\
}
#define DYY_Property_set_object_copy(property_,value_) {\
if (property_) {\
[property_ release];\
property_ = nil;\
}\
property_ = [value_ copy];\
}

// 版本号
#define DYY_APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

@interface YYDefines : NSObject

@end
