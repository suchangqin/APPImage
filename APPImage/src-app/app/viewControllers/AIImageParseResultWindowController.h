//
//  AIImageParseResultWindowController.h
//  APPImage
//
//  Created by suchangqin on 15/2/28.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AIImageParseResultWindowController : NSWindowController

@property (strong) NSDictionary *dictInProject;
@property (strong) NSDictionary *dictInSource;
@property () int intInWarningLevel1;
@property () int intInWarningLevel2;

@end
