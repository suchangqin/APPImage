//
//  AIProjectListViewController.m
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "AIProjectListViewController.h"
#import "AIAPI.h"
#import "AITableProjects.h"
@interface AIProjectListViewController ()

@property (weak) IBOutlet NSView *viewListTop;
@property (strong) AITableProjects *tableProjects;

- (IBAction)___doAddProject:(id)sender;


@end

@implementation AIProjectListViewController

#define ___kPath_recent_dir @"sdfjlsjflsjflks"




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.viewListTop setBackgroundColor:RGBCOLOR(255, 255, 255)];
    
    self.tableProjects = [[AITableProjects alloc] init];
    
    [self.tableProjects createTable];
    
}

- (IBAction)___doAddProject:(id)sender {
    AIAPI *api = [AIAPI sharedInstance];
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setDirectoryURL:[NSURL URLWithString:[api stringRecentSelectedDir]]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
//    [panel setAllowedFileTypes:@[@"xcodeproj"]];
//    [panel setAllowsOtherFileTypes:YES];
    if ([panel runModal] == NSModalResponseOK) {
        NSString *path = [panel.URLs.firstObject path];
        [api setStringRecentSelectedDir:path];
        DYYLog(@"select dir : %@",path);
        
        if ([_tableProjects existWithPath:path]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"确定"];
            [alert setMessageText:@"文件目录已经存在"];
            
            [alert setInformativeText:@"请在列表中查找"];
            
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
                
            }];
        }else{
            NSString *name = [[path componentsSeparatedByString:@"/"] lastObject];
            [_tableProjects inserWithName:name path:path type:AITableProjectsTypeIOSAPP property:nil];
            [_tableProjects queryAll];
        }
    }
}



@end
