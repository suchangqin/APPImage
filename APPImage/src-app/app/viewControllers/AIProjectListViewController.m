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
#import "AIProjectInfoWindowController.h"

@interface AIProjectListViewController ()<NSTableViewDelegate,NSTableViewDataSource,NSMenuDelegate>

@property (weak) IBOutlet NSView *viewListTop;
@property (strong) AITableProjects *tableProjects;
@property (weak) IBOutlet NSTableView *tableView;

@property (strong) NSMutableArray *arrayWC;


@property (strong) NSArray *arrayProject;

- (IBAction)___doAddIOSProject:(id)sender;
- (IBAction)___doAddAndroidProject:(id)sender;

- (IBAction)___doMenuOpen:(id)sender;
- (IBAction)___doMenuDelete:(id)sender;
- (IBAction)___doMenuShowInFinder:(id)sender;
- (IBAction)___doMenuShowInTerminal:(id)sender;
- (IBAction)___doMenuCopyPath:(id)sender;
- (IBAction)___doMenuRename:(id)sender;

@end

@implementation AIProjectListViewController


#define Cell_View_Tag(_row) (_row - 1000)
#define Cell_View_Row(_tag) (_tag + 1000)




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.viewListTop setBackgroundColor:RGBCOLOR(255, 255, 255)];
    
    self.tableProjects = [[AITableProjects alloc] init];
    
    [self.tableProjects createTable];
    
    [self.tableView setHeaderView:nil];
    

    [self.tableView setDoubleAction:@selector(___tableViewDoubleClick:)];
    
    [self ___reloadProjects];
    
}

-(void) ___reloadProjects{
    self.arrayProject = [_tableProjects queryAll];
    [self.tableView reloadData];
}
-(void) ___showProjectInfoViewControllerWithProjectDict:(NSDictionary *) projectDict{
    
    NSArray *arrayInfoShow = [AIAPI sharedInstance].arrayWindowController;
    NSDictionary *dict = projectDict;
    for (AIProjectInfoWindowController *infoWC in arrayInfoShow) {
        if ([[infoWC.dictInProject stringForKey:kTable_project_id] isEqualToString:[dict stringForKey:kTable_project_id]]) {
            [infoWC.window makeKeyAndOrderFront:self];
            return;
        }
    }
    
    AIProjectInfoWindowController *wc = [[AIProjectInfoWindowController alloc] initWithWindowNibName:@"AIProjectInfoWindowController"];
    wc.dictInProject = dict;
    [[AIAPI sharedInstance] addWindowController:wc];
    
    NSUInteger fixPositon= [arrayInfoShow count]*10;
    
    CGRect f = self.view.window.frame;
    
    int x = CGRectGetMaxX(f) + fixPositon;
    int y = CGRectGetMinY(f) + CGRectGetHeight(f)-CGRectGetHeight(wc.window.frame) -fixPositon;
    
    [wc.window setFrameOrigin:NSMakePoint(x,y)];
    
    [wc showWindow:self];
    
}
- (IBAction)___doAddIOSProject:(id)sender {
    [self ___doAddProjectWithType:AIProjectTypeIOSAPP];
}

- (IBAction)___doAddAndroidProject:(id)sender {
    [self ___doAddProjectWithType:AIProjectTypeAndroidAPP];
}

- (IBAction)___doMenuOpen:(id)sender {
    NSDictionary *dict = [_arrayProject objectAtIndex:self.tableView.clickedRow];
    [self ___showProjectInfoViewControllerWithProjectDict:dict];
}
- (IBAction)___doMenuDelete:(NSMenuItem *)sender{
    NSDictionary *dict = [_arrayProject objectAtIndex:self.tableView.clickedRow];
    NSString *id_ = [dict stringForKey:kTable_project_id];
    [self.tableProjects deleteForId:id_];
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
    [[NSWorkspace sharedWorkspace] openFile:path withApplication:@"/Applications/Utilities/Terminal.app"];
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
    NSTextField *textField = (NSTextField *)     [self.tableView viewWithTag:2];
    [textField becomeFirstResponder];
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
        NSString *iconName = type == AIProjectTypeAndroidAPP ? @"i-app-android" : @"i-app-iOS";
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
}

#pragma mark - nsmenu delegate
-(void)menuWillOpen:(NSMenu *)menu{
    NSUInteger clickRow = self.tableView.clickedRow;
    NSUInteger allRows = [self.arrayProject count];
    for (NSMenuItem *item in menu.itemArray) {
//        item.action = nil;
        if (clickRow > allRows) {
            item.hidden = YES;
        }else{
            item.hidden = NO;
        }
    }
}
@end
