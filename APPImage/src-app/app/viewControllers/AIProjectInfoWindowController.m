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
#import "AIImageParseResultWindowController.h"
#import "AIFileParse.h"
#import "AIImageParseAPI.h"
#import "GRProgressIndicator.h"

@interface AIProjectInfoWindowController ()<NSTableViewDelegate,NSTableViewDataSource,AIImageParseAPIDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSView *viewIgnoreButtons;

@property (strong) NSArray *arrayIOSInitIgnore;
@property (strong) NSArray *arrayAndroidInitIgnore;
@property (weak) IBOutlet NSButton *buttonRemoveIgnore;

@property (strong) NSMutableArray *arrayIgnoreDir;
@property (weak) IBOutlet NSView *viewProjectinfo;
@property (weak) IBOutlet NSTextField *textFieldLoadingTip;
@property (weak) IBOutlet NSPopUpButton *popupButtonLevel1;
@property (weak) IBOutlet NSPopUpButton *popupButtonLevel2;
@property (weak) IBOutlet GRProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSButton *buttonParse;

@property (strong) AIImageParseAPI *imageParseAPI;
@property (weak) IBOutlet NSView *viewParsingDisable;


@end

@implementation AIProjectInfoWindowController


#define _kAPP_IndexFiles   @"is"
#define _kAPP_IndexFiles1x   @"is1x"

-(void)dealloc{
    [self __cancelParse];
}

-(void) __cancelParse{
    [self.imageParseAPI cancelParse];
    self.imageParseAPI = nil;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.viewIgnoreButtons setBackgroundColor:RGBACOLOR(250, 250, 250, 1)];
    
    
    {
        NSDictionary *dict = _dictInProject;
        
        NSView *cellView = self.viewProjectinfo;
        
        NSImageView *imageView = (NSImageView *) [cellView viewWithTag:1];
        AIProjectTypeState type = [[dict stringForKey:kTable_project_type] intValue];
        NSString *iconName = type == AIProjectTypeAndroidAPP ? @"i-app-android" : @"i-app-mac-ios";
        imageView.image = [NSImage imageNamed:iconName];
        
        NSTextField *textFieldName = (NSTextField *) [cellView viewWithTag:2];
        textFieldName.stringValue = [dict stringForKey:kTable_project_name];
        NSTextField *textFieldPath = (NSTextField *) [cellView viewWithTag:3];
        textFieldPath.stringValue = [dict stringForKey:kTable_project_path];
    }
    
    _viewIgnoreButtons.layer.borderWidth = 1;
    _viewIgnoreButtons.layer.borderColor = [NSColor lightGrayColor].CGColor;
    
    
    _arrayAndroidInitIgnore = @[@"build",@"gradle",@"libs",@"libraries"];
    _arrayIOSInitIgnore = @[@"libs",@"libraries"];

    _arrayIgnoreDir = [NSMutableArray arrayWithArray:[self ___getInitIgnoreArray]];
    [self.tableView reloadData];
    
    
}
#pragma mark - ___
-(void) ___reloadData{
    [self.tableView reloadData];
    [self.buttonRemoveIgnore setEnabled:NO];
}
-(NSArray *) ___getInitIgnoreArray{
    if ([[_dictInProject stringForKey:kTable_project_type] intValue] == AIProjectTypeAndroidAPP) {
        return _arrayAndroidInitIgnore;
    }
    return _arrayIOSInitIgnore;
}

- (IBAction)___doImageParse:(id)sender {

    NSString *path = [self.dictInProject stringForKey:kTable_project_path];
    if (![[NSFileManager defaultManager] isExecutableFileAtPath:path]) {
        //如果目录不存在
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"知道了"];
        [alert setMessageText:@"项目不存在"];
        
        [alert setInformativeText:@"是不是已经删除或者移动到别的目录下了？"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    [self __cancelParse];
    // start loading
    self.progressIndicator.doubleValue = 0.0;
    [self.progressIndicator startAnimation:nil];
    [self.buttonParse setTitle:@"Parsing..."];
    self.buttonParse.enabled = NO;
    self.viewParsingDisable.hidden = NO;
    
    // start parse
    AIImageParseAPI *api = [[AIImageParseAPI alloc] init];
    api.delegate = self;
    api.stringProjectPath = path;
    api.arrayIgnoreDir = self.arrayIgnoreDir;
    api.type = [[_dictInProject stringForKey:kTable_project_type] intValue];
    self.imageParseAPI = api;
    [api startParseImageProject];
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
    [self.arrayIgnoreDir replaceObjectAtIndex:row withObject:newString];
}
-(void) ___selectLastRowToChangeName{
    NSView *cellView = [self.tableView viewAtColumn:0 row:[self.arrayIgnoreDir count]-1 makeIfNecessary:NO];
    NSTextField *textFieldName = (NSTextField *) [cellView viewWithTag:1];
    [textFieldName becomeFirstResponder];
    
    [self.buttonRemoveIgnore setState:YES];
}
- (IBAction)___doAddIgnore:(id)sender {
    
    NSString *path = [self.dictInProject stringForKey:kTable_project_path];
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setDirectoryURL:[NSURL URLWithString:path]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    //    [panel setAllowedFileTypes:@[@"xcodeproj"]];
    //    [panel setAllowsOtherFileTypes:YES];
    if ([panel runModal] == NSModalResponseOK) {
        NSString *name = [[panel.URLs.firstObject path] lastPathComponent];
        [self.arrayIgnoreDir addObject:name];
        [self ___reloadData];
        [self.tableView scrollRowToVisible:self.tableView.numberOfRows-1];
    }
    
//    [self.arrayIgnoreDir addObject:@"dir"];
//    [self ___reloadData];
//    [self.tableView scrollRowToVisible:self.tableView.numberOfRows-1];
//    //不做延迟不能相应focus方法
//    [self performSelector:@selector(___selectLastRowToChangeName) withObject:nil afterDelay:0.1];

}
-(void) ___buttonIgnoreStateChange{
    if (self.tableView.selectedRow > [[self ___getInitIgnoreArray] count]-1 && self.tableView.selectedRow<[_arrayIgnoreDir count]) {
        self.buttonRemoveIgnore.enabled = YES;
    }else{
        self.buttonRemoveIgnore.enabled = NO;
    }
}
- (IBAction)___doRemoveIgnore:(id)sender {
    DYYLog(@"-");
    NSInteger row = self.tableView.selectedRow;
    [self.arrayIgnoreDir removeObjectAtIndex:row];
    [self ___reloadData];
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row-1] byExtendingSelection:NO];
    [self ___buttonIgnoreStateChange];
}


#pragma mark - tableview datasource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_arrayIgnoreDir count];
}
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [_arrayIgnoreDir objectAtIndex:row];
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *CellIdent = @"AICellProjectView";
    
    NSString *iden = [ tableColumn identifier ];
    if ([iden isEqualToString:CellIdent]) {
        
        NSString *ignore = [_arrayIgnoreDir objectAtIndex:row];
        
        NSView *cellView = [ tableView makeViewWithIdentifier:CellIdent owner:self ];
        
        NSTextField *textFieldName = (NSTextField *) [cellView viewWithTag:1];
        textFieldName.stringValue = ignore;
        
        if (row>[[self ___getInitIgnoreArray] count]-1) {
            [textFieldName setTextColor:[NSColor controlTextColor]];
//            [textFieldName setEditable:YES];
            //不让编辑
            [textFieldName setEditable:NO];
        }else{
            [textFieldName setTextColor:[NSColor lightGrayColor]];
            [textFieldName setEditable:NO];
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
    [self __cancelParse];
    return YES;
}
#pragma mark - ImageParseAPI
-(void)imageParseDoParseEndWithImageParseResult:(NSDictionary *)imageParseResult{
    self.buttonParse.enabled = YES;
    [self.buttonParse setTitle:@"Parse Again"];
    self.viewParsingDisable.hidden = YES;
    [self.progressIndicator stopAnimation:nil];
    
    int level1 = [_popupButtonLevel1.selectedItem.title intValue];
    int level2 = [_popupButtonLevel2.selectedItem.title intValue];


    
    AIImageParseResultWindowController *wc = [[AIImageParseResultWindowController alloc] initWithWindowNibName:@"AIImageParseResultWindowController"];
    [[AIAPI sharedInstance] addWindowController:wc];
    wc.dictInSource = imageParseResult;
    wc.dictInProject = _dictInProject;
    wc.intInWarningLevel1 = level1;
    wc.intInWarningLevel2 = level2;
    [wc showWindow:self];
}
-(void)imageParseDoParseWithLogInfo:(NSString *)logInfo currentIndex:(float)currentIndex allCount:(float)allCount{
    self.textFieldLoadingTip.stringValue = logInfo;
    self.progressIndicator.maxValue = allCount;
    self.progressIndicator.doubleValue = currentIndex;
}
@end
