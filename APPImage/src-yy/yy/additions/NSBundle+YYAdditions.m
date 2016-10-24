//
//  NSBundle+YYAdditions.m
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "NSBundle+YYAdditions.h"

@implementation NSBundle (YYAdditions)

- (NSArray *) loadNibWithNibName:(NSString *)nibName owner:(id)owner{
    NSArray *topLevelObjects;
    if ([[NSBundle mainBundle] loadNibNamed:nibName owner:owner topLevelObjects:&topLevelObjects]) {
        NSMutableArray *reArray = [NSMutableArray array];
        for (id one in topLevelObjects) {
            if ([one isKindOfClass:[NSWindow class]] || [one isKindOfClass:[NSView class]]) {
                [reArray addObject:one]; //只要视图列表
            }
        }
        return reArray;
    }
    return nil;
}

@end
