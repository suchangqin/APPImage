//
//  NSDictionary+YYAdditions.m
//  YYProject
//
//  Created by suchangqin on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+YYAdditions.h"

@implementation NSDictionary (YYAdditions)

-(NSString *)stringForKey:(id)key {
    NSString *result = [self objectForKey:key];
    if([result isKindOfClass:[NSString class]])
    {
        return result;
    }else if([result isKindOfClass:[NSNumber class]]){
        return [(NSNumber *)result stringValue];
    }
    else {
        return @"";
    }
}

-(NSArray *)arrayForKey:(id)key{
    NSArray *result = [self objectForKey:key];
    if ([result isKindOfClass:[NSArray class]]) {
        return result;
    }else if( [result isKindOfClass:[NSString class]]  || [result isKindOfClass:[NSDictionary class]] ){
        return @[result];
    }
    return @[];
}

- (BOOL)isEqualToCompareDictionary:(NSDictionary *)compareDictionary withKeyString:(NSString *)keyString{
    if ([[self stringForKey:keyString] isEqualToString:[compareDictionary stringForKey:keyString]]) {
        return YES;
    }
    return NO;
}


-(NSString *)jsonStringWithPrettyPrint:(BOOL) prettyPrint{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    if (! jsonData) {
        return @"{}";
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}

@end
