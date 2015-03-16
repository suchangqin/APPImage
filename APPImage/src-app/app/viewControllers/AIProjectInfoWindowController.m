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

@interface AIProjectInfoWindowController ()<NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSView *viewIgnoreButtons;

@property (strong) NSArray *arrayIOSInitIngore;
@property (strong) NSArray *arrayAndroidInitIngore;
@property (weak) IBOutlet NSButton *buttonRemoveIgnore;

@property (strong) NSMutableArray *arrayIngoreDir;
@property (weak) IBOutlet NSView *viewProjectinfo;
@property (weak) IBOutlet NSView *viewLoading;
@property (weak) IBOutlet NSProgressIndicator *progressParse;

@end

@implementation AIProjectInfoWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.viewIgnoreButtons setBackgroundColor:RGBACOLOR(250, 250, 250, 1)];
    
    [self.viewLoading setBackgroundColor:RGBACOLOR(0, 0, 0, 0.1)];
    
    
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

- (IBAction)___doImageParse:(id)sender {
    #define _kAPP_IndexFiles   @"is"
    NSString *path = [self.dictInProject stringForKey:kTable_project_path];
    if (![[NSFileManager defaultManager] isExecutableFileAtPath:path]) {
        //如果目录不存在
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"知道了"];
        [alert setMessageText:@"目录不存在"];
        
        [alert setInformativeText:@"是不是移动到别的目录下了？"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    
    
    self.viewLoading.hidden = NO;
    [self.progressParse startAnimation:nil];
    
    AIProjectTypeState type = [[self.dictInProject stringForKey:kTable_project_type] intValue];
    
    NSDictionary *dictFile = [AIFileParse fileParseWithDirPath:path arrayExtensionName:@[@".png"] stringSpecial:nil stringIgnore:nil arrayIgnoreDir:self.arrayIngoreDir];
    // format
    NSDictionary *dictPNG = [AIFileParse pngFileFormat:dictFile withType:type];

    if (type == AIProjectTypeIOSAPP) {
        
        void (^blockCheckIOSImageNameContains)(NSMutableDictionary *imageDict,NSString *imageName,NSString *lines,NSString *codeFilePath);
        blockCheckIOSImageNameContains = ^(NSMutableDictionary *imageDict,NSString *imageName,NSString *lines,NSString *codeFilePath)
        {
            //#图片索引
            NSString *define_prefix = @"kImage_";
            NSString *imageNameFormat = [NSString stringWithFormat:@"%@%@",
                                         define_prefix,
                                         [[imageName stringByReplacingOccurrencesOfString:@"-" withString:@"_"] stringByReplacingOccurrencesOfString:@".png" withString:@""]
                                         ];
            NSString *imageNameFormat2 = [NSString stringWithFormat:@"\"%@\"",[imageName stringByReplacingOccurrencesOfString:@".png" withString:@""]];
            //#图片文件名包含
            if	([lines containWithString:imageName] || [lines containWithString:imageNameFormat] || [lines containWithString:imageNameFormat2]){
                if (![[imageDict allKeys] containsObject:_kAPP_IndexFiles]) {
                    NSMutableArray *array = [NSMutableArray arrayWithObject:codeFilePath];
                    imageDict[_kAPP_IndexFiles] = array;
                }
                    
                //#如果是2x和3x的还得读取1x的索引数
                if ([imageName hasSuffix:@"@2x.png"] || [imageName hasSuffix:@"@3x.png"]) {
                    NSString *imageName1x = [[imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""] stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
                    imageDict = dictPNG[imageName];
                    blockCheckIOSImageNameContains(imageDict,imageName1x,lines,codeFilePath);
                }
            }
        };
        
        NSDictionary *dictFileCodes = [AIFileParse fileParseWithDirPath:path arrayExtensionName:@[@".xib",@".h",@".m",@".mm",@".plist"] stringSpecial:nil stringIgnore:@"APPImagesDefine.h" arrayIgnoreDir:self.arrayIngoreDir];
        NSArray *imageNames = dictPNG.allKeys;
    
        for (NSString *fileName in dictFileCodes.allKeys) {
            for (NSString *codePath in [dictFileCodes objectForKey:fileName]) {
                NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:codePath];
                NSString *lines = [[NSString alloc] initWithData:[fh readDataToEndOfFile] encoding:NSUTF8StringEncoding];
                for (NSString *imageName in imageNames) {
                    NSMutableDictionary *imageDict = [dictPNG objectForKey:imageName];
                    blockCheckIOSImageNameContains(imageDict,imageName,lines,codePath);
                }
            }
        }
        AIImageParseResultWindowController *wc = [[AIImageParseResultWindowController alloc] initWithWindowNibName:@"AIImageParseResultWindowController"];
        [[AIAPI sharedInstance] addWindowController:wc];
        wc.dictInSource = dictPNG;
        wc.dictInProject = _dictInProject;
        [wc showWindow:self];
    }else{
        NSDictionary *dictFileCodes = [AIFileParse fileParseWithDirPath:path arrayExtensionName:@[@".xml",@".java"] stringSpecial:nil stringIgnore:nil arrayIgnoreDir:self.arrayIngoreDir];
        NSArray *imageNames = dictPNG.allKeys;
        for (NSString *codeFilePath in dictFileCodes.allKeys) {
            NSArray *codePaths = dictFileCodes[codeFilePath];
            for (NSString *p in codePaths) {
                NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:p];
                NSString *lines = [[NSString alloc] initWithData:[fh readDataToEndOfFile] encoding:NSUTF8StringEncoding];
                for (NSString *imageName in imageNames) {
                    NSString *imageNameFormat = [[imageName stringByReplacingOccurrencesOfString:@".9.png" withString:@""] stringByReplacingOccurrencesOfString:@".png" withString:@""];
                    NSString *imageName1 = [NSString stringWithFormat:@"drawable/%@",imageNameFormat];
                    NSString *imageName2 = [NSString stringWithFormat:@"R.drawable.%@",imageNameFormat];
                    if ([lines containsString:imageName1] || [lines containsString:imageName2]) {
                        NSMutableDictionary *imageDict = dictPNG[imageName];
                        if (![imageDict.allKeys containsObject:_kAPP_IndexFiles]) {
                            imageDict[_kAPP_IndexFiles] = [NSMutableArray array];
                        }
                        [imageDict[_kAPP_IndexFiles] addObject:codeFilePath];
                    }
                }
            }
        }
        
        AIImageParseResultWindowController *wc = [[AIImageParseResultWindowController alloc] initWithWindowNibName:@"AIImageParseResultWindowController"];
        [[AIAPI sharedInstance] addWindowController:wc];
        wc.dictInSource = dictPNG;
        wc.dictInProject = _dictInProject;
        [wc showWindow:self];
        
    }
    
    
    
    
    self.viewLoading.hidden = YES;
    [self.progressParse stopAnimation:nil];
    
    
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
    AIAPI *api = [AIAPI sharedInstance];
    [api removeWindowController:self];
    return YES;
}

@end
