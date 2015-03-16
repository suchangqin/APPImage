//
//  YYTableBase.h
//  YYProduct
//
//  Created by suchangqin on 13-5-13.
//  Copyright (c) 2013年 suchangqin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYDB.h"

#define DB_STRING_FORMAT(string_) [self formatWithString:string_]

typedef enum : NSUInteger {
    YYTableBaseSortASC,
    YYTableBaseSortDESC,
} YYTableBaseSortState;

@interface YYTableBase : NSObject

@property (nonatomic, retain) YYDB *dbUtil;

-(NSString *)formatWithString:(NSString *)string;

@end
