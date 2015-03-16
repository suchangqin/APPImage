//
//  NSObject+YYAdditions.m
//  YYProduct
//
//  Created by suchangqin on 13-5-10.
//  Copyright (c) 2013年 suchangqin. All rights reserved.
//

#import "NSObject+YYAdditions.h"
#import <objc/runtime.h>

@implementation NSObject (YYAdditions)

-(void) setAssociatedObject:(id)obj forKey:(NSString *)key{
    objc_setAssociatedObject(self, (const void *)(key), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id) associatedObjectForKey:(NSString *)key{
    return objc_getAssociatedObject(self, (const void *)(key));
}

-(void)removeAssociatedObjects{
    objc_removeAssociatedObjects(self);
}

@end
