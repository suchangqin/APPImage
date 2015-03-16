//
//  AIImageNameDefineAPI.m
//  APPImage
//
//  Created by suchangqin on 15/3/7.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "AIImageNameDefineAPI.h"
#import "AIFileParse.h"

@implementation AIImageNameDefineAPI

#define PREFIX_IMAGE  @"kImage_"

#define BLANK @"                                                                                                                                                                        "

-(void) startImageNameDefineProject:(BOOL)suffixPNG{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = self.stringProjectPath;
        NSDictionary *dictFile = [AIFileParse fileParseWithDirPath:path arrayExtensionName:@[@".png"] stringSpecial:nil stringIgnore:nil arrayIgnoreDir:self.arrayIgnoreDir];
        
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedCompare:)];
        NSArray *pngs = [[dictFile allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSMutableArray *arrayDefines = [NSMutableArray array];
        [arrayDefines addObject:@" "];
        [arrayDefines addObject:@"// 请新建一个.h文件存放，如果放置在.m或者.swift文件里，检查索引会有问题"];
        [arrayDefines addObject:@" "];
        [arrayDefines addObject:@"#ifndef APPImage_autocreate_image_name_h"];
        [arrayDefines addObject:@"#define APPImage_autocreate_image_name_h"];
        [arrayDefines addObject:@" "];
        NSInteger maxL = 0;
        for (NSString *png in pngs) {
            maxL = MAX(maxL,png.length);
        }
        
        NSMutableArray *outPng = [NSMutableArray array];
        for (NSString *png in pngs) {
            NSString *pngDefine = [[png stringByReplacingOccurrencesOfString:@"@2x" withString:@""] stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
            if ([outPng containsObject:pngDefine]) {
                //如果有了就继续
                continue;
            }
            [outPng addObject:pngDefine];
            NSString *pngFormat = [png stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
            pngFormat = [pngFormat stringByReplacingOccurrencesOfString:@"@2x.png" withString:@""];
            pngFormat = [pngFormat stringByReplacingOccurrencesOfString:@"@3x.png" withString:@""];
            pngFormat = [pngFormat stringByReplacingOccurrencesOfString:@".png" withString:@""];
            NSInteger l = [pngFormat length];
            
            NSString *pngWrite = pngDefine;
            if (!suffixPNG) {
                pngWrite =[pngWrite stringByReplacingOccurrencesOfString:@".png" withString:@""];
            }
            
            NSString *defineString = [NSString stringWithFormat:@"  #define %@%@ %@@\"%@\"",PREFIX_IMAGE,pngFormat,[BLANK substringToIndex:maxL - l],pngWrite];
            [arrayDefines addObject:defineString];
        }
        [arrayDefines addObject:@" "];
        [arrayDefines addObject:@"#endif"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate imageNameDefineFinishedWithDefineString:[arrayDefines componentsJoinedByString:@"\n"]];
        });
    });
}

@end
