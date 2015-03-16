//
//  YYToastView.h
//  test
//
//  Created by suchangqin on 15/3/9.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface YYToastView : NSTextField

+(YYToastView *) toastViewWithTitle:(NSString *) title;

-(void) showInView:(NSView *) inView;
-(void) showInWindow:(NSWindow *) inWindow;

@end
