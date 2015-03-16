//
//  AIFileParse.h
//  APPImage
//
//  Created by suchangqin on 15/2/28.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIFileParse : NSObject

+(void) yytest;

+(NSDictionary *) fileParseWithDirPath:(NSString *) dirPath arrayExtensionName:(NSArray *) arrayExtensionName stringSpecial:(NSString *) stringSpecial stringIgnore:(NSString *) stringIgnore arrayIgnoreDir:(NSArray *) arrayIgnoreDir;

+(NSMutableDictionary *) pngFileFormat:(NSDictionary *) pngDict withType:(AIProjectTypeState) type;


@end
