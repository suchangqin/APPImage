//
//  AIImageParseAPI.h
//  APPImage
//
//  Created by suchangqin on 15/3/2.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AITableProjects.h"
@protocol AIImageParseAPIDelegate <NSObject>

-(void) imageParseDoParseWithLogInfo:(NSString *) logInfo currentIndex:(float) currentIndex allCount:(float) allCount;
-(void) imageParseDoParseEndWithImageParseResult:(NSDictionary *) imageParseResult;

@end


@interface AIImageParseAPI : NSObject

@property (strong) NSString *stringProjectPath;
@property () AIProjectTypeState type;
@property (strong) NSArray *arrayIgnoreDir;
@property (assign) id<AIImageParseAPIDelegate> delegate;

-(void) startParseImageProject;
-(void) cancelParse;

@end
