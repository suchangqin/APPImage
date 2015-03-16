//
//  AIAPI.h
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIAPI : NSObject

@property (nonatomic,copy) NSString *stringRecentSelectedDir;     //最近打开的文件目录

@property (strong) NSMutableArray *arrayWindowController;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(AIAPI);

-(void) addWindowController:(NSWindowController *) windowController;
-(void) removeWindowController:(NSWindowController *) windowController;

@end
