//
//  YYToastView.m
//  test
//
//  Created by suchangqin on 15/3/9.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "YYToastView.h"
#import <QuartzCore/QuartzCore.h>


@implementation YYToastView

+(YYToastView *) toastViewWithTitle:(NSString *) title{
    YYToastView *view = [[[NSBundle mainBundle] loadNibWithNibName:@"YYToastView" owner:self] lastObject];
    view.stringValue = title;
    [view setBackgroundColor:RGBACOLOR(0, 0, 0, 0.75)];
    [view sizeToFit];
    [view setWantsLayer:YES]; //要不不会有动画,同时也是为了画圆弧
    view.layer.cornerRadius = 4;
    return view;
}
-(void) showInWindow:(NSWindow *) inWindow{
    NSView *inView = inWindow.contentView;
    [self showInView:inView];
}

-(void) showInView:(NSView *) inView{
    CGRect frame = self.frame;
    frame.size.width += 2;
    frame.size.height += 2;
    frame.origin.x = (CGRectGetWidth(inView.frame) - CGRectGetWidth(frame))/2.0;
    frame.origin.y = (CGRectGetHeight(inView.frame) - CGRectGetHeight(frame))/2.0;
    self.frame = frame;
    [inView addSubview:self];
    
    //透明度变化
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:0.0];
    opacityAnim.toValue = [NSNumber numberWithFloat:1.0];
    opacityAnim.removedOnCompletion = YES;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects: opacityAnim, nil];
    animGroup.duration = 0.4;
    [self.layer addAnimation:animGroup forKey:nil];
    
    [self performSelector:@selector(___dismiss) withObject:nil afterDelay:2];
}

-(void) ___dismiss{
    NSLog(@"- dismiss ");
    //透明度变化
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnim.toValue = [NSNumber numberWithFloat:0.0];
    opacityAnim.removedOnCompletion = YES;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects: opacityAnim, nil];
    animGroup.duration = 0.4;
    animGroup.delegate = self;
    [self.layer addAnimation:animGroup forKey:nil];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.35];
}
//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
//    DYYLog(@"---finshed");
////    [self removeFromSuperview];
//}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

}

@end
