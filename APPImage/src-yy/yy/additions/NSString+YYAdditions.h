//
//  NSString+YYAdditions.h
//  YYProject
//
//  Created by suchangqin on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// url utf8编码
#define UTF8(string_) string_?[string_ urlEncodeWithEncodingUTF8]:@""

#define DYY_isEmptyString(s_) ![s_ length]

#define DYY_IntString(int_) [NSString stringWithFormat:@"%d",int_]

@interface NSString (YYAdditions)

// url encode
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
-(NSString *)urlEncodeWithEncodingUTF8;

// md5加密
-(NSString *) stringFromMD5;

// 消除头尾的空格和换行
-(NSString *) trim;

// 是否包含某个字符串
-(BOOL) containWithString:(NSString *) string;

// 格式化输出数字，使用千位分隔符，保留2位小数，例如: 1,234.00
-(NSString*) moneyFormat;


@end
