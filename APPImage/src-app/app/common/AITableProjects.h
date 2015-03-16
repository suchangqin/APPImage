//
//  AITableProjects.h
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    AITableProjectsTypeIOSAPP,
    AITableProjectsTypeAndroidAPP,
} AITableProjectsTypeState;

@interface AITableProjects : YYTableBase

-(void) createTable;

-(void) inserWithName:(NSString *) name path:(NSString *) path type:(AITableProjectsTypeState) type property:(NSString *) property;
-(NSArray *) queryAll;

-(BOOL) existWithPath:(NSString *) path;

@end
