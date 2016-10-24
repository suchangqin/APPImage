//
//  AIImageNameDefineAPI.h
//  APPImage
//
//  Created by suchangqin on 15/3/7.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AIImageNameDefineAPIDelegate <NSObject>

-(void) imageNameDefineFinishedWithDefineString:(NSString *) defineString;

@end

@interface AIImageNameDefineAPI : NSObject

@property (strong) NSString *stringProjectPath;
@property (strong) NSArray *arrayIgnoreDir;
@property (assign) id<AIImageNameDefineAPIDelegate> delegate;

-(void) startImageNameDefineProject:(BOOL) suffixPNG;

@end
