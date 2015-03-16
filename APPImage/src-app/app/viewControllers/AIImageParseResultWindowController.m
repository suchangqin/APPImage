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
    screenRect.size.height -= 40;
    screenRect.origin.y += 40;
    [self.window setFrame:screenRect display:YES];
    
    AIProjectTypeState type = [[self.dictInProject stringForKey:kTable_project_type] intValue];
    NSString *proName = [_dictInProject stringForKey:kTable_project_name];
    NSString *typeName = type == AIProjectTypeAndroidAPP ? @"Android":@"Objective-c";
    self.window.title = [NSString stringWithFormat:@"%@ (%@)",proName,typeName];
    
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
    htmlString = [htmlString stringByReplacingOccurrencesOfString:rWarning withString:DYY_IntString(_intInWarningLevel1)];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:rWarning2 withString:DYY_IntString(_intInWarningLevel2)];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:rPath withString:[_dictInProject stringForKey:kTable_project_path]];
    
//    NSURL *baseURL = [NSURL fileURLWithPath:filePath];
    [[_webView mainFrame] loadHTMLString:htmlString baseURL:nil];
    
}

#pragma mark - window delegate
- (BOOL)windowShouldClose:(id)sender{
    AIAPI *api = [AIAPI sharedInstance];
    [api removeWindowController:self];
    return YES;
}

#pragma mark - webview delegate

-(void) ___webViewDoLog:(NSString *) log{
    DYYLog(@"webView log:%@",log);
}
-(void) ___webViewDoShowFile:(NSString *) filePath{
   [[NSWorkspace sharedWorkspace] selectFile:filePath inFileViewerRootedAtPath:filePath];
}
-(void) ___webViewDoAlert:(NSString *) msg{
    DYYLog(@"webView alert:%@",msg);
    //如果目录不存在
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"确认"];
    [alert setMessageText:@"提示"];
    [alert setInformativeText:msg];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
        
    }];
}
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector {
    if (selector == @selector(___webViewDoLog:)
        || selector == @selector(___webViewDoAlert:)
        || selector == @selector(___webViewDoShowFile:)
        ) {
        return NO;
    }
    return YES;
}
- (void)webView:(WebView *)webView windowScriptObjectAvailable:(WebScriptObject *)windowScriptObject {
    [windowScriptObject setValue:self forKey:@"yyoc"];
}
-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
//    [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
}

+ (NSString *) webScriptNameForSelector:(SEL)sel {
    if (sel == @selector(___webViewDoLog:)) {
        return @"log";
    }else if (sel == @selector(___webViewDoAlert:)) {
        return @"alert";
    }else if (sel == @selector(___webViewDoShowFile:)) {
        return @"showFile";
    }else {
        return nil;
    }
}
- (NSArray*)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems{
    for (NSMenuItem *menuItems in defaultMenuItems) {
        if ([menuItems.title isEqualToString:@"Reload"]) {
            return nil;
        }
    }
    return defaultMenuItems;
}

@end
