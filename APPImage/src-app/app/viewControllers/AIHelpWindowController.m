//
//  AIHelpWindowController.m
//  APPImage
//
//  Created by suchangqin on 15/3/3.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "AIHelpWindowController.h"
#import <WebKit/WebKit.h>
#import "AIAPI.h"

@interface AIHelpWindowController ()

@property (weak) IBOutlet WebView *webView;

@end

@implementation AIHelpWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"appimage_help" ofType:@"html" inDirectory:@"htmlTemp"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    
    NSURL *baseURL = [NSURL fileURLWithPath:filePath];
    [[_webView mainFrame] loadHTMLString:htmlString baseURL:baseURL];
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:filePath]]];
}
#pragma mark - window delegate
- (BOOL)windowShouldClose:(id)sender{
    AIAPI *api = [AIAPI sharedInstance];
    [api removeWindowController:self];
    return YES;
}
@end
