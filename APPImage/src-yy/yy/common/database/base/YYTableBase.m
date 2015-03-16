//
//  YYTableBase.m
//  YYProduct
//
//  Created by suchangqin on 13-5-13.
//  Copyright (c) 2013年 suchangqin. All rights reserved.
//

#import "YYTableBase.h"

@implementation YYTableBase

- (id)init
{
    self = [super init];
    if (self) {
        self.dbUtil = [[YYDB alloc] init];
    }
    return self;
}

-(NSString *)formatWithString:(NSString *)string{
    if ([string length] == 0) {
        return @"";
    }
    NSString *reString = [string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    return  reString;
}

@end
