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
        return topLevelObjects;
    }
    return nil;
}

@end
