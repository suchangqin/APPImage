//
//  AIProjectListViewController.m
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "AIProjectListWindowController.h"
#import "AIAPI.h"
#import "AITableProjects.h"
#import "AIProjectInfoWindowController.h"
#import "AIHelpWindowController.h"

@interface AIProjectListWindowController ()<NSTableViewDelegate,NSTableViewDataSource,NSMenuDelegate>

@property (weak) IBOutlet NSView *viewListTop;
@property (strong) AITableProjects *tableProjects;
@property (weak) IBOutlet NSTableView *tableView;

@property (strong) AIProjectInfoWindowController *projectInfoWindowController;

@property (weak) IBOutlet NSMenuItem *menuItemTerminal;

@property (strong) NSArray *arrayProject;
@property (weak) IBOutlet NSTextField *viewNoProjects;

@property (strong) NSString *stringTerminalPath;
@property (weak) IBOutlet NSView *viewLeft;
@property (weak) IBOutlet NSView *viewRight;
@property (weak) IBOutlet NSTextField *textFieldVersion;
@property (strong) IBOutlet NSView *viewContent;

@end

@implementation AIProjectListWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
//    
//    NSView *view = self.window.contentView;
//    [self.window setBackgroundColor:[NSColor whiteColor]];
//    
//    self.viewContent.frame = view.frame;
//    [view addSubview:self.viewContent];
//    
//    CGRect frame = view.frame;
//    frame.size.height += 12;
//    view.frame = frame;
//    [view setWantsLayer:YES];
//    view.layer.borderWidth = 1.0;
//    view.layer.borderColor = [NSColor redColor].CGColor;
//    return;
    
    [self.viewListTop setBackgroundColor:RGBCOLOR(255, 255, 255)];
    [self.viewLeft setBackgroundColor:[NSColor whiteColor]];
    self.tableView.backgroundColor = RGBCOLOR(241,240,240);
    
    self.tableProjects = [[AITableProjects alloc] init];
    
    [self.tableProjects createTable];
    
    [self.tableView setHeaderView:nil];
    

    [self.tableView setDoubleAction:@selector(___tableViewDoubleClick:)];
    
    [self ___reloadProjects];
    
    self.textFieldVersion.stringValue = [NSString stringWithFormat:@"Version %@",DYY_APP_VERSION];
    
    //查找Terminal项目
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *terminalPath = @"/Applications/Utilities/Terminal.app";
    if(![fm fileExistsAtPath:terminalPath]){
        //不存在，到另一个里去找
        terminalPath = @"/Applications/Terminal.app";
        if (![fm fileExistsAtPath:terminalPath]) {
            terminalPath = nil;
        }
    }
    self.stringTerminalPath = terminalPath;
    //如果没有则禁用
    if (!self.stringTerminalPath) {
        self.menuItemTerminal.action = nil;
    }
}

-(void) ___reloadProjects{
    NSArray *array = [_tableProjects queryAll];
    //目录找不到则自动删除
    NSMutableArray *proArray = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];
    for(NSDictionary *pro in array){
        NSString *path = [pro stringForKey:kTable_project_path];
        if ([fm fileExistsAtPath:path] && [[AIAPI sharedInstance] authorizedURLFromPath:path]) {
            //如果项目存在并且有权限
            [proArray addObject:pro];
        }else{
            [self.tableProjects deleteForId:[pro stringForKey:kTable_project_id]];
//            [[AIAPI sharedInstance] removeAuthorizedURLFromPath:path];
        }
    }
    self.arrayProject = proArray;
    
    [self.tableView reloadData];
    if ([self.arrayProject count]) {
        _viewNoProjects.hidden = YES;
    }else{
        _viewNoProjects.hidden = NO;
    }
}
-(void) ___showProjectInfoViewControllerWithProjectDict:(NSDictionary *) projectDict{
    
    
    NSDictionary *dict = projectDict;
    
    if (self.projectInfoWindowController) {
        [self.projectInfoWindowController.window close];
        self.projectInfoWindowController = nil;
    }
    AIProjectInfoWindowController *wc = [[AIProjectInfoWindowController alloc] initWithWindowNibName:@"AIProjectInfoWindowController"];
    wc.dictInProject = dict;
    [wc showWindow:self];
    self.projectInfoWindowController = wc;
    
//    NSArray *arrayInfoShow = [AIAPI sharedInstance].arrayWindowController;
//    //先判断是不是已经存在了，存在直接激活窗口
//    for (NSWindowController *wc in arrayInfoShow) {
//        if([wc isKindOfClass:[AIProjectInfoWindowController class]]){
//            AIProjectInfoWindowController *infoWC = (AIProjectInfoWindowController*) wc;
//            if ([[infoWC.dictInProject stringForKey:kTable_project_id] isEqualToString:[dict stringForKey:kTable_project_id]]) {
//                [infoWC.window makeKeyAndOrderFront:self];
//                return;
//            }
//        }
//    }
//    AIProjectInfoWindowController *wc = [[AIProjectInfoWindowController alloc] initWithWindowNibName:@"AIProjectInfoWindowController"];
//    wc.dictInProject = dict;
//    [[AIAPI sharedInstance] addWindowController:wc];
//    [wc showWindow:self];
}
- (IBAction)___doAddIOSProject:(id)sender {
    [self ___doAddProjectWithType:AIProjectTypeIOSAPP];
}

- (IBAction)___doAddAndroidProject:(id)sender {
    [self ___doAddProjectWithType:AIProjectTypeAndroidAPP];
}
- (IBAction)___doShowHelp:(id)sender {
    [(AppDelegate *)([NSApplication sharedApplication].delegate) showWindowHelp:nil];
}



- (IBAction)___doMenuOpen:(id)sender {
    NSDictionary *dict = [_arrayProject objectAtIndex:self.tableView.clickedRow];
    [self ___showProjectInfoViewControllerWithProjectDict:dict];
}
- (IBAction)___doMenuDelete:(NSMenuItem *)sender{
    NSDictionary *dict = [_arrayProject objectAtIndex:self.tableView.clickedRow];
    NSString *id_ = [dict stringForKey:kTable_project_id];
//    NSString  *path = [dict stringForKey:kTable_project_path];
    [self.tableProjects deleteForId:id_];
//    [[AIAPI sharedInstance] removeAuthorizedURLFromPath:path];
    [self ___reloadProjects];
}

- (IBAction)___doMenuShowInFinder:(id)sender {
    NSDictionary *dict = [_arrayProject objectAtIndex:self.tableView.clickedRow];
    NSString *path = [dict stringForKey:kTable_project_path];
   [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:path];
}

- (IBAction)___doMenuShowInTerminal:(id)sender {
    NSDictionary *dict = [_arrayProject objectAtIndex:self.tableView.clickedRow];
    NSString *path = [dict stringForKey:kTable_project_path];
    //打开授权
    NSURL *url = [[AIAPI sharedInstance] authorizedURLFromPath:path];
    [url startAccessingSecurityScopedResource];
    [[NSWorkspace sharedWorkspace] openFile:path withApplication:self.stringTerminalPath];
    [url stopAccessingSecurityScopedResource];
}

- (IBAction)___doMenuCopyPath:(id)sender {
    
    NSDictionary *dict = [_arrayProject objectAtIndex:self.tableView.clickedRow];
    NSString *path = [dict stringForKey:kTable_project_path];

    
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType]
               owner:self];
    [pb setString:path forType:NSStringPboardType];
}

- (IBAction)___doMenuRename:(id)sender {
    NSView *cellView = [_tableView viewAtColumn:0 row:self.tableView.clickedRow makeIfNecessary:NO];
    NSTextField *textFieldName = (NSTextField *) [cellView viewWithTag:2];
    [textFieldName becomeFirstResponder];
}

- (void)___doAddProjectWithType:(AIProjectTypeState)type {
    AIAPI *api = [AIAPI sharedInstance];
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setDirectoryURL:[NSURL URLWithString:[api stringRecentSelectedDir]]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    //    [panel setAllowedFileTypes:@[@"xcodeproj"]];
    //    [panel setAllowsOtherFileTypes:YES];
    if ([panel runModal] == NSModalResponseOK) {
        
        NSURL *selectedURL = panel.URLs.firstObject;
        NSString *path = [selectedURL path];
        [api addAuthorizedURL:selectedURL path:path];//保存授权信息
        [api setStringRecentSelectedDir:path];//保存最近浏览目录
        
        if ([_tableProjects existWithPath:path]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"确定"];
            [alert setMessageText:@"文件目录已经存在"];
            
            [alert setInformativeText:@"请在列表中查找"];
            
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
                
            }];
        }else{
            NSString *name = [path lastPathComponent];
            [_tableProjects inserWithName:name path:path type:type property:nil];
            [self ___reloadProjects];
        }
    }

    
}
#pragma mark - tableview datasource
-(void) ___tableViewDoubleClick:(id) sender{
    NSUInteger seletedRow = self.tableView.selectedRow;
    if (seletedRow>[self.arrayProject count]) {
        return;
    }
    NSDictionary *dict = [_arrayProject objectAtIndex:self.tableView.selectedRow];
    [self ___showProjectInfoViewControllerWithProjectDict:dict];
    
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_arrayProject count];
}
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [_arrayProject objectAtIndex:row];
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *CellIdent = @"AICellProjectView";
    
    NSString *iden = [ tableColumn identifier ];
    if ([iden isEqualToString:CellIdent]) {
        
        NSDictionary *dict = [_arrayProject objectAtIndex:row];
        
        NSView *cellView = [ tableView makeViewWithIdentifier:CellIdent owner:self ];

        NSImageView *imageView = (NSImageView *) [cellView viewWithTag:1];
        AIProjectTypeState type = [[dict stringForKey:kTable_project_type] intValue];
        NSString *iconName = type == AIProjectTypeAndroidAPP ? @"i-app-android" : @"i-app-mac-ios";
        imageView.image = [NSImage imageNamed:iconName];
        
        NSTextField *textFieldName = (NSTextField *) [cellView viewWithTag:2];
        textFieldName.stringValue = [dict stringForKey:kTable_project_name];
        DYY_setYYUserInfo(textFieldName, @(row));
        NSTextField *textFieldPath = (NSTextField *) [cellView viewWithTag:3];
        textFieldPath.stringValue = [dict stringForKey:kTable_project_path];
        
        return cellView;
    }
    return nil;
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
//    高亮变色，效果不好，不能用
//    for (int i=0;i<[_arrayProject count]; i++) {
//        NSView *cellView = [_tableView viewAtColumn:0 row:i makeIfNecessary:NO];
//        NSTextField *textFieldName = (NSTextField *) [cellView viewWithTag:2];
//        NSTextField *textFieldPath = (NSTextField *) [cellView viewWithTag:3];
//        if (i == self.tableView.selectedRow) {
//            [textFieldName setTextColor:[NSColor whiteColor]];
//            [textFieldPath setTextColor:[NSColor whiteColor]];
//        }else{
//            [textFieldName setTextColor:RGBCOLOR(51, 51, 51)];
//            [textFieldPath setTextColor:RGBCOLOR(61, 61, 61)];
//        }
//    }
    
}
-(IBAction) ___doProjectNameChanged:(NSTextField *) sender{
    NSString *name = sender.stringValue;
    int row = [DYY_getYYUserInfo(sender) intValue];
    DYYLog(@"%@ -> %d ",name,row);
    
    NSDictionary *dict = [_arrayProject objectAtIndex:row];
    NSString *nameOld = [dict stringForKey:kTable_project_name];
    if (DYY_isEmptyString(name)) {
        sender.stringValue = nameOld;
        return;
    }
    if([name isEqualToString:nameOld]){
        return;
    }
    [self.tableProjects changeForId:[dict stringForKey:kTable_project_id] withName:name];
    [self ___reloadProjects];
}

#pragma mark - nsmenu delegate
-(void)menuWillOpen:(NSMenu *)menu{
    NSUInteger clickRow = self.tableView.clickedRow;
    NSUInteger allRows = [self.arrayProject count];
    for (NSMenuItem *item in menu.itemArray) {
        if (clickRow > allRows) {
            item.hidden = YES;
        }else{
            item.hidden = NO;
        }
    }
}
@end
