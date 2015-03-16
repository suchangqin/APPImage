//
//  NSDictionary+YYAdditions.h
//  YYProject
//
//  Created by suchangqin on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (YYAdditions)

// 返回字符串，如果没有，默认空字符串
-(NSString *)stringForKey:(id)key;
// 返回数组，如果没有，默认空数组
-(NSArray *)arrayForKey:(id)key;

// 对字典的某一个key对应的值进行对比
- (BOOL)isEqualToCompareDictionary:(NSDictionary *)compareDictionary withKeyString:(NSString *) keyString;

// prettyPrint YES: 友好输出,易于查看， NO: 直接一行输出
-(NSString *)jsonStringWithPrettyPrint:(BOOL) prettyPrint;

@end
