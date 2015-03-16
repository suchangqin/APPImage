//
//  AIProjectInfoWindowController.m
//  APPImage
//
//  Created by suchangqin on 15/2/27.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "AIProjectInfoWindowController.h"
#import "AIAPI.h"
#import "AITableProjects.h"

@interface AIProjectInfoWindowController ()<NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSView *viewIgnoreButtons;

@property (strong) NSArray *arrayIOSInitIngore;
@property (strong) NSArray *arrayAndroidInitIngore;
@property (weak) IBOutlet NSButton *buttonRemoveIgnore;

@property (strong) NSMutableArray *arrayIngoreDir;
@property (weak) IBOutlet NSView *viewProjectinfo;

@end

@implementation AIProjectInfoWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.viewIgnoreButtons setBackgroundColor:RGBACOLOR(250, 250, 250, 1)];
    
    
    {
        NSDictionary *dict = _dictInProject;
        
        NSView *cellView = self.viewProjectinfo;
        
        NSImageView *imageView = (NSImageView *) [cellView viewWithTag:1];
        AIProjectTypeState type = [[dict stringForKey:kTable_project_type] intValue];
        NSString *iconName = type == AIProjectTypeAndroidAPP ? @"i-app-android" : @"i-app-iOS";
        imageView.image = [NSImage imageNamed:iconName];
        
        NSTextField *textFieldName = (NSTextField *) [cellView viewWithTag:2];
        textFieldName.stringValue = [dict stringForKey:kTable_project_name];
        NSTextField *textFieldPath = (NSTextField *) [cellView viewWithTag:3];
        textFieldPath.stringValue = [dict stringForKey:kTable_project_path];
    }
    
    _viewIgnoreButtons.layer.borderWidth = 1;
    _viewIgnoreButtons.layer.borderColor = [NSColor lightGrayColor].CGColor;
    
    
    _arrayAndroidInitIngore = @[@"build",@"gradle",@"libs",@"libraries"];
    _arrayIOSInitIngore = @[@"libs",@"libraries"];

    _arrayIngoreDir = [NSMutableArray arrayWithArray:[self ___getInitIgnoreArray]];
    [self.tableView reloadData];
    
    
    
}
#pragma mark - ___
-(void) ___reloadData{
    [self.tableView reloadData];
    [self.buttonRemoveIgnore setEnabled:NO];
}
-(NSArray *) ___getInitIgnoreArray{
    if ([[_dictInProject stringForKey:kTable_project_type] intValue] == AIProjectTypeAndroidAPP) {
        return _arrayAndroidInitIngore;
    }
    return _arrayIOSInitIngore;
}
- (IBAction)___changeDirName:(NSTextField *)sender {
    
    NSString *newString = sender.stringValue;
    NSInteger row = self.tableView.selectedRow;
    if ( row < 0 ) {
        //是最后一行
        row = self.tableView.numberOfRows - 1;
    }
    if (DYY_isEmptyString(newString)) {
        newString = @"dir";
    }
    [self.arrayIngoreDir replaceObjectAtIndex:row withObject:newString];
}
-(void) ___selectLastRowToChangeName{
    NSView *cellView = [self.tableView viewAtColumn:0 row:[self.arrayIngoreDir count]-1 makeIfNecessary:NO];
    NSTextField *textFieldName = (NSTextField *) [cellView viewWithTag:1];
    [textFieldName becomeFirstResponder];
    
    [self.buttonRemoveIgnore setState:YES];
}
- (IBAction)___doAddIgnore:(id)sender {
    DYYLog(@"+");
    [self.arrayIngoreDir addObject:@"dir"];
    [self ___reloadData];
    [self.tableView scrollRowToVisible:self.tableView.numberOfRows-1];
    //不做延迟不能相应focus方法
    [self performSelector:@selector(___selectLastRowToChangeName) withObject:nil afterDelay:0.1];

}
-(void) ___buttonIgnoreStateChange{
    if (self.tableView.selectedRow > [[self ___getInitIgnoreArray] count]-1 && self.tableView.selectedRow<[_arrayIngoreDir count]) {
        self.buttonRemoveIgnore.enabled = YES;
    }else{
        self.buttonRemoveIgnore.enabled = NO;
    }
}
- (IBAction)___doRemoveIgnore:(id)sender {
    DYYLog(@"-");
    NSInteger row = self.tableView.selectedRow;
    [self.arrayIngoreDir removeObjectAtIndex:row];
    [self ___reloadData];
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row-1] byExtendingSelection:NO];
    [self ___buttonIgnoreStateChange];
}


#pragma mark - tableview datasource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_arrayIngoreDir count];
}
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [_arrayIngoreDir objectAtIndex:row];
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *CellIdent = @"AICellProjectView";
    
    NSString *iden = [ tableColumn identifier ];
    if ([iden isEqualToString:CellIdent]) {
        
        NSString *ignore = [_arrayIngoreDir objectAtIndex:row];
        
        NSView *cellView = [ tableView makeViewWithIdentifier:CellIdent owner:self ];
        
        NSTextField *textFieldName = (NSTextField *) [cellView viewWithTag:1];
        textFieldName.stringValue = ignore;
        
        if (row>[[self ___getInitIgnoreArray] count]-1) {
            [textFieldName setTextColor:[NSColor controlTextColor]];
            [textFieldName setEditable:YES];
        }else{
            [textFieldName setTextColor:[NSColor lightGrayColor]];
            [textFieldName setEditable:YES];
        }
        
        return cellView;
    }
    return nil;
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    [self ___buttonIgnoreStateChange];
}
#pragma mark - window delegate
- (BOOL)windowShouldClose:(id)sender{
    AIAPI *api = [AIAPI sharedInstance];
    [api removeWindowController:self];
    return YES;
}

@end
