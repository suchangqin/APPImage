//
//  NSColor+YYAdditions.h
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// rgb颜色
#define RGBCOLOR(r,g,b) [NSColor colorWithRed:(CGFloat)(r)/255.0 green:(CGFloat)(g)/255.0 blue:(CGFloat)(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [NSColor colorWithRed:(CGFloat)(r)/255.0 green:(CGFloat)(g)/255.0 blue:(CGFloat)(b)/255.0 alpha:(a)]

@interface NSColor (YYAdditions)

@end
