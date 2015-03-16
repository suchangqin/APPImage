//
//  AppDelegate.m
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "AppDelegate.h"
#import "AIProjectListWindowController.h"
#import "AIFileParse.h"
#import "AIHelpWindowController.h"
#import "AIAPI.h"

@interface AppDelegate ()

@property (strong) NSWindowController *windowControllerProjectList;
@property (strong) AIHelpWindowController *windowControllerHelp;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    AIProjectListWindowController *wc = [[AIProjectListWindowController alloc] initWithWindowNibName:@"AIProjectListWindowController"];
    self.windowControllerProjectList = wc;
    [wc showWindow:self];
    [wc.window makeKeyAndOrderFront:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (!flag){
        [NSApp activateIgnoringOtherApps:NO];
        [self.windowControllerProjectList.window makeKeyAndOrderFront:self];
    }
    return YES;
}
-(IBAction)showWindowHelp:(id)sender{
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
