//
//  NSObject+YYAdditions.h
//  YYProduct
//
//  Created by suchangqin on 13-5-10.
//  Copyright (c) 2013年 suchangqin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kYYUserInfo @"yyuserinfo"

#define DYY_setYYUserInfo(obj_,value_) [obj_ setAssociatedObject:(value_) forKey:kYYUserInfo]
#define DYY_getYYUserInfo(obj_) [(obj_) associatedObjectForKey:kYYUserInfo]

@interface NSObject (YYAdditions)

// 设置关联对象
-(void) setAssociatedObject:(id) obj forKey:(NSString *) key;
// 取回关联对象
-(id) associatedObjectForKey:(NSString *) key;
// 删除所有的关联对象
-(void) removeAssociatedObjects;


@end
