//
//  NSView+YYAdditions.m
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "NSView+YYAdditions.h"

@implementation NSView (YYAdditions)

-(void) setBackgroundColor:(NSColor *) backgroundColor{
    [self setWantsLayer:YES];
    self.layer.backgroundColor = backgroundColor.CGColor;
}

@end
