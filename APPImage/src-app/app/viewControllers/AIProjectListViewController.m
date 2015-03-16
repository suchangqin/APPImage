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
@interface AIProjectListViewController ()<NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSView *viewListTop;
@property (strong) AITableProjects *tableProjects;
@property (weak) IBOutlet NSTableView *tableView;


@property (strong) NSArray *arrayProject;

- (IBAction)___doAddIOSProject:(id)sender;
- (IBAction)___doAddAndroidProject:(id)sender;


@end

@implementation AIProjectListViewController

#define ___kPath_recent_dir @"sdfjlsjflsjflks"




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

- (IBAction)___doAddIOSProject:(id)sender {
    [self ___doAddProjectWithType:AIProjectTypeIOSAPP];
}

- (IBAction)___doAddAndroidProject:(id)sender {
    [self ___doAddProjectWithType:AIProjectTypeAndroidAPP];
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
    NSDictionary *dict = [_arrayProject objectAtIndex:self.tableView.selectedRow];
    
    DYYLog(@"double click with: %@",dict);
    
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
        
        NSTableCellView *cell = [ tableView makeViewWithIdentifier:CellIdent owner:self ];

        NSImageView *imageView = (NSImageView *) [cell viewWithTag:1];
        AIProjectTypeState type = [[dict stringForKey:kTable_project_type] intValue];
        NSString *iconName = type == AIProjectTypeAndroidAPP ? @"i-app-android" : @"i-app-iOS";
        imageView.image = [NSImage imageNamed:iconName];
        
        NSTextField *textFieldName = (NSTextField *) [cell viewWithTag:2];
        textFieldName.stringValue = [dict stringForKey:kTable_project_name];
        DYY_setYYUserInfo(textFieldName, @(row));
        NSTextField *textFieldPath = (NSTextField *) [cell viewWithTag:3];
        textFieldPath.stringValue = [dict stringForKey:kTable_project_path];
        
        
        return cell;
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
-(void)tableViewSelectionDidChange:(NSNotification *)notification
{

}
@end
