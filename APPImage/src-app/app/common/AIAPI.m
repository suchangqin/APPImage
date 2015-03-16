//
//  AIAPI.m
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "AIAPI.h"

@implementation AIAPI

#define __kUser_stringRecentSelectedDir  @"ef896ca200f3ecf8265fd058074f009e"

@synthesize stringRecentSelectedDir = _stringRecentSelectedDir;

SYNTHESIZE_SINGLETON_FOR_CLASS(AIAPI);

- (void)dealloc
{
    [_stringRecentSelectedDir release];
    [super dealloc];
}

-(NSString *) stringRecentSelectedDir{
    if (!_stringRecentSelectedDir) {
        NSString *n = [[NSUserDefaults standardUserDefaults] stringForKey:__kUser_stringRecentSelectedDir];
        if (n) {
            _stringRecentSelectedDir = [n copy];
        }
    }
    return _stringRecentSelectedDir;
}
-(void) setStringRecentSelectedDir:(NSString *) stringRecentSelectedDir{
    if ([_stringRecentSelectedDir isEqualToString:stringRecentSelectedDir]) return;
    DYY_Property_set_object_copy(_stringRecentSelectedDir, stringRecentSelectedDir);
    [[NSUserDefaults standardUserDefaults] setObject:_stringRecentSelectedDir forKey:__kUser_stringRecentSelectedDir];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
