//
//  NSString+YYAdditions.m
//  YYProject
//
//  Created by suchangqin on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+YYAdditions.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (YYAdditions)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    CFStringRef sRef = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding));
    NSString *re = [NSString stringWithFormat:@"%@",sRef];
    CFRelease(sRef);
    return re;
}

-(NSString *)urlEncodeWithEncodingUTF8{
    return [self urlEncodeUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *) stringFromMD5{
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

// 消除头尾的空格和换行
-(NSString *) trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

// 是否包含某个字符串
-(BOOL)containWithString:(NSString *)string{
    if ([self rangeOfString:string].location == NSNotFound) {
        return NO;
    }
    return YES;
}

// 格式化输出数字，使用千位分隔符，保留2位小数
-(NSString*) moneyFormat{
    NSNumber *num = [NSNumber numberWithDouble:[self doubleValue]];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	formatter.numberStyle = NSNumberFormatterDecimalStyle;
	formatter.maximumFractionDigits = 2;
    formatter.minimumFractionDigits = 2;
    return [formatter stringFromNumber:num];
}

@end
