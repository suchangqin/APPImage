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
#import "AIImageNameDefineAPI.h"

@interface AIProjectInfoWindowController ()<NSTableViewDelegate,NSTableViewDataSource,AIImageParseAPIDelegate,AIImageNameDefineAPIDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSView *viewIgnoreButtons;

@property (strong) AITableProjects *tableProjects;

@property (strong) NSArray *arrayIOSInitIgnore;
@property (strong) NSArray *arrayAndroidInitIgnore;
@property (weak) IBOutlet NSButton *buttonRemoveIgnore;

@property (strong) NSMutableArray *arrayIgnoreDir;
@property (weak) IBOutlet NSView *viewProjectinfo;
@property (weak) IBOutlet NSTextField *textFieldLoadingTip;
@property (weak) IBOutlet NSPopUpButton *popupButtonLevel1;
@property (weak) IBOutlet NSPopUpButton *popupButtonLevel2;
@property (weak) IBOutlet GRProgressIndicator *progressIndicator;

@property (strong) AIImageParseAPI *imageParseAPI;
@property (strong) AIImageNameDefineAPI *imageNameDefineAPI;

@property (strong) IBOutlet NSWindow *windowProgress;
@property (weak) IBOutlet NSView *viewDefineImageName;


@end

@implementation AIProjectInfoWindowController


#define _kAPP_IndexFiles   @"is"
#define _kAPP_IndexFiles1x   @"is1x"

-(void)dealloc{
    [self __cancelParse];
}
-(void) ___initProgress{
    self.progressIndicator.doubleValue = 0.0;
    self.textFieldLoadingTip.stringValue = @"";
}
-(void) __cancelParse{
    [self.imageParseAPI cancelParse];
    self.imageParseAPI = nil;
    self.imageNameDefineAPI.delegate = nil;
    self.imageNameDefineAPI = nil;
    [self ___initProgress];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.viewIgnoreButtons setBackgroundColor:RGBACOLOR(250, 250, 250, 1)];
    _viewIgnoreButtons.layer.borderWidth = 1;
    _viewIgnoreButtons.layer.borderColor = [NSColor lightGrayColor].CGColor;
    
    _tableProjects = [[AITableProjects alloc] init];
    
    {   //设置项目的图标，名称和路径
        NSDictionary *dict = _dictInProject;
        
        NSView *cellView = self.viewProjectinfo;
        
        NSImageView *imageView = (NSImageView *) [cellView viewWithTag:1];
        AIProjectTypeState type = [[dict stringForKey:kTable_project_type] intValue];
        NSString *iconName = type == AIProjectTypeAndroidAPP ? kImage_i_app_android:kImage_i_app_mac_ios;
        imageView.image = [NSImage imageNamed:iconName];
        

        NSString *proName = [_dictInProject stringForKey:kTable_project_name];
        
        NSTextField *textFieldName = (NSTextField *) [cellView viewWithTag:2];
        textFieldName.stringValue = proName;
        NSTextField *textFieldPath = (NSTextField *) [cellView viewWithTag:3];
        textFieldPath.stringValue = [dict stringForKey:kTable_project_path];

        
        //其它显示
        NSString *typeFix = @"Android";
        if (type == AIProjectTypeIOSAPP) {
            typeFix = @"Objective-C";
            _viewDefineImageName.hidden = NO;
            [_viewDefineImageName setBackgroundColor:RGBACOLOR(0, 0, 0, 0.1)];
        }
        self.window.title = [NSString stringWithFormat:@"%@ (%@)",proName,typeFix];
    }
    
    
    //读取配置信息
    NSDictionary *dictProperty = [_tableProjects queryPropertyWithId:[_dictInProject stringForKey:kTable_project_id]];
    _arrayAndroidInitIgnore = @[@"build",@"gradle",@"libs",@"libraries"];
    _arrayIOSInitIgnore = @[@"libs",@"libraries"];

    _arrayIgnoreDir = [NSMutableArray array];
    //忽略的配置信息
    NSString *ignorePty = [dictProperty stringForKey:kTable_project_ignore_property];
    if (!DYY_isEmptyString(ignorePty)) {
        [_arrayIgnoreDir addObjectsFromArray:[ignorePty componentsSeparatedByString:@","]];
    }else{
        [_arrayIgnoreDir addObjectsFromArray:[self ___getInitIgnoreArray]];
    }
    //大小的配置信息
    NSString *sizePty = [dictProperty stringForKey:kTable_project_size_property];
    if(!DYY_isEmptyString(sizePty)){
        NSArray *sizes = [sizePty componentsSeparatedByString:@","];
        NSString *level1 = [sizes firstObject];
        NSString *level2 = [sizes lastObject];
        [_popupButtonLevel1 selectItemWithTitle:level1];
        [_popupButtonLevel2 selectItemWithTitle:level2];
    }
    
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

-(void) ___doImageParseValidated:(NSString *) path{
    //保存配置信息
    [self ___doSaveProperty:nil];
    
    // start loading
    [self ___initProgress];
    self.progressIndicator.indeterminate = NO;
    [self.progressIndicator startAnimation:nil];
    [self.window beginSheet:_windowProgress completionHandler:^(NSModalResponse returnCode) {
    }];
    
    // start parse
    AIImageParseAPI *imageParseApi = [[AIImageParseAPI alloc] init];
    imageParseApi.delegate = self;
    imageParseApi.stringProjectPath = path;
    imageParseApi.arrayIgnoreDir = self.arrayIgnoreDir;
    imageParseApi.type = [[_dictInProject stringForKey:kTable_project_type] intValue];
    self.imageParseAPI = imageParseApi;
    [imageParseApi startParseImageProject];
}
- (IBAction)___doImageCancel:(id)sender {
    [self.window endSheet:self.windowProgress];
    [self __cancelParse];
}
- (IBAction)___doSaveProperty:(id)sender {
    NSString *level1 = _popupButtonLevel1.selectedItem.title;
    NSString *level2 = _popupButtonLevel2.selectedItem.title;
    NSString *sizePty = [NSString stringWithFormat:@"%@,%@",level1,level2];
    NSString *ignorePty = [_arrayIgnoreDir componentsJoinedByString:@","];
    [self.tableProjects updateForId:[self.dictInProject stringForKey:kTable_project_id] withSizeProperty:sizePty ignoreProperty:ignorePty];
}
- (IBAction)___doImageNameDefineStart:(NSButton *)sender {
    
    // start loading
    [self ___initProgress];
    self.progressIndicator.indeterminate = YES;
    [self.progressIndicator startAnimation:nil];
    [self.window beginSheet:_windowProgress completionHandler:^(NSModalResponse returnCode) {
    }];
    self.textFieldLoadingTip.stringValue = @"请稍后，正在读取图片信息...";
    
    NSString *path = [self.dictInProject stringForKey:kTable_project_path];
    // start parse
    AIImageNameDefineAPI *api = [[AIImageNameDefineAPI alloc] init];
    api.delegate = self;
    api.stringProjectPath = path;
    api.arrayIgnoreDir = self.arrayIgnoreDir;
    self.imageNameDefineAPI = api;
    [api startImageNameDefineProject:sender.tag];
}

- (IBAction)___doImageParse:(id)sender {
    NSString *path = [self.dictInProject stringForKey:kTable_project_path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
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
    
    [self ___doImageParseValidated:path];
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
        if([self.arrayIgnoreDir containsObject:name]){
            YYToastView *toast = [YYToastView toastViewWithTitle:@"已经存在！"];
            [toast showInView:self.tableView];
            return;
        }
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
    
    [self ___doImageCancel:nil];
    
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
#pragma mark - ImageNameDefineAPI
-(void)imageNameDefineFinishedWithDefineString:(NSString *)defineString{
    [self ___doImageCancel:nil];
    DYYLog(@"%@",defineString);
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType]
               owner:self];
    [pb setString:defineString forType:NSStringPboardType];
    
    YYToastView *toast = [YYToastView toastViewWithTitle:@"生成完毕，已复制到粘贴板！"];
    [toast showInWindow:self.window];
}
@end
