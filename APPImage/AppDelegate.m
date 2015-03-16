//
//  AppDelegate.m
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "AppDelegate.h"
#import "AIProjectListViewController.h"
#import "AIFileParse.h"
#import "AIHelpWindowController.h"
#import "AIAPI.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong) NSViewController *viewControllerRoot;
@property (strong) NSWindowController *windowControllerProjectInfo;
@property (strong) AIHelpWindowController *windowControllerHelp;


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [AIFileParse yytest];
    
    // Insert code here to initialize your application
    AIProjectListViewController *vc = [[AIProjectListViewController alloc] init];
    self.viewControllerRoot = vc;
    self.window.contentView = vc.view;

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (!flag){
        [NSApp activateIgnoringOtherApps:NO];
        [self.window makeKeyAndOrderFront:self];
    }
    return YES;
}
-(IBAction)___doShowHelp:(id)sender{
    AIHelpWindowController *wc = self.windowControllerHelp;
    if (!wc) {
        wc =[[AIHelpWindowController alloc] initWithWindowNibName:@"AIHelpWindowController"];
        self.windowControllerHelp = wc;
        [wc showWindow:self];
    }else{
        [wc.window makeKeyAndOrderFront:self];
    }
}


@end
