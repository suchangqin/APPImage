//
//  AIImageParseResultWindowController.m
//  APPImage
//
//  Created by suchangqin on 15/2/28.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "AIImageParseResultWindowController.h"
#import "AIAPI.h"
#import <WebKit/WebKit.h>
#import "AITableProjects.h"
@interface AIImageParseResultWindowController ()

@property (weak) IBOutlet WebView *webView;

@end

@implementation AIImageParseResultWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
     NSRect screenRect = [[NSScreen mainScreen] frame];

    [self.window setFrame:screenRect display:YES];
    
    AIProjectTypeState type = [[self.dictInProject stringForKey:kTable_project_type] intValue];
    NSString *tempName = type == AIProjectTypeAndroidAPP ? @"android_image_parse":@"ios_image_parse";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:tempName ofType:@"html" inDirectory:@"htmlTemp"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    //replace
    NSString *rSource = @"${ai source}";
    NSString *rWarning = @"${ai warning}";
    NSString *rWarning2 = @"${ai warning2}";
    NSString *rPath	  = @"${ai filePath}";
    //NULL//
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"//NULL//" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:rSource withString:[_dictInSource jsonStringWithPrettyPrint:YES]];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:rWarning withString:@"30"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:rWarning2 withString:@"50"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:rPath withString:[_dictInProject stringForKey:kTable_project_path]];
    
    
    NSURL *baseURL = [NSURL fileURLWithPath:filePath];
    [[_webView mainFrame] loadHTMLString:htmlString baseURL:baseURL];
    
}

#pragma mark - window delegate
- (BOOL)windowShouldClose:(id)sender{
    AIAPI *api = [AIAPI sharedInstance];
    [api removeWindowController:self];
    return YES;
}

@end
