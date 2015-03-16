//
//  AIImageParseAPI.m
//  APPImage
//
//  Created by suchangqin on 15/3/2.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "AIImageParseAPI.h"
#import "AIFileParse.h"


@interface AIImageParseAPI()

@property (strong, nonatomic) dispatch_block_t blockParse;


@end

@implementation AIImageParseAPI

#define _kAPP_IndexFiles   @"is"
#define _kAPP_IndexFiles1x   @"is1x"

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void) ___checkIOSImageNameContainsWithImageDict:(NSMutableDictionary *) imageDict imageName:(NSString *) imageName lines:(NSString *) lines codeFilePath:(NSString *) codeFilePath dictPng:(NSDictionary *) dictPNG fileName:(NSString *) fileName kIndexPaths:(NSString *) kIndexPaths{
    //#图片索引
    NSString *define_prefix = @"kImage_";
    NSString *imageNameFormat = [NSString stringWithFormat:@"%@%@",
                                 define_prefix,
                                 [[imageName stringByReplacingOccurrencesOfString:@"-" withString:@"_"] stringByReplacingOccurrencesOfString:@".png" withString:@""]
                                 ];
    NSString *imageNameFormat2 = [NSString stringWithFormat:@"\"%@\"",[imageName stringByReplacingOccurrencesOfString:@".png" withString:@""]];
    //    NSArray *fileNames = @[@"OFPJCarOrderCheckViewController.xib",
    //    @"OFPayAllSelectedOrdersViewController.xib",
    //    @"OFPJCartOrderResultViewController.xib",
    //    @"OFWDOrderPayResultViewController.xib",
    //    @"OFOrderPayResultViewController.xib",
    //    @"OFMyJiFenViewController.xib",
    //                           ];
    //    if ([imageName containsString:@"address_top_banner_bg"] && [fileNames containsObject:fileName]) {
    //
    //    }
    //#图片文件名包含
    if	([lines containWithString:imageName] || [lines containWithString:imageNameFormat] || [lines containWithString:imageNameFormat2]){
        if (![[imageDict allKeys] containsObject:kIndexPaths]) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [imageDict setObject:array forKey:kIndexPaths];
        }
        NSMutableArray *arrayIndexFiles =  imageDict[kIndexPaths];
        [arrayIndexFiles addObject:fileName];
    }
    
    //#如果是2x和3x的还得读取1x的索引数
    if ([imageName hasSuffix:@"@2x.png"] || [imageName hasSuffix:@"@3x.png"]) {
        NSString *imageName1x = [[imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""] stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
        imageDict = dictPNG[imageName];
        [self ___checkIOSImageNameContainsWithImageDict:imageDict imageName:imageName1x lines:lines codeFilePath:codeFilePath dictPng:dictPNG fileName:fileName kIndexPaths:_kAPP_IndexFiles1x];
    }
}
-(void) ___log:(NSString *) log index:(float) index all:(float) all{
    dispatch_async(dispatch_get_main_queue(), ^{
        DYYLog(@"%@",log);
        [self.delegate imageParseDoParseWithLogInfo:log currentIndex:index allCount:all];
    });
}
-(void) ___endParse:(NSDictionary *) dictPNG{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate imageParseDoParseEndWithImageParseResult:dictPNG];
    });
}
-(void) startParseImageProject{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = self.stringProjectPath;
        AIProjectTypeState type = self.type;
        
        // step 1, load png file
        [self ___log:@"正在加载PNG图片信息..." index:0 all:100];
        NSDictionary *dictFile = [AIFileParse fileParseWithDirPath:path arrayExtensionName:@[@".png"] stringSpecial:nil stringIgnore:nil arrayIgnoreDir:self.arrayIgnoreDir];
        // format
        // step 2, load png file size and width,height
        NSDictionary *dictPNG = [AIFileParse pngFileFormat:dictFile withType:type];
        if (type == AIProjectTypeIOSAPP) {
            // step 3 load source file
            [self ___log:@"开始加载源代码信息..." index:1 all:100];
            NSDictionary *dictFileCodes = [AIFileParse fileParseWithDirPath:path arrayExtensionName:@[@".xib",@".m",@".mm",@".plist"] stringSpecial:nil stringIgnore:nil arrayIgnoreDir:self.arrayIgnoreDir];
            NSArray *imageNames = dictPNG.allKeys;
            NSInteger allSouceCount = [dictFileCodes.allKeys count];
            int index = 0;
            for (NSString *fileName in dictFileCodes.allKeys) {
                for (NSString *codePath in [dictFileCodes objectForKey:fileName]) {
                    if (!self.delegate) {
                        goto EndBlock;
                    }
                    index ++;
                    NSString *log = [NSString stringWithFormat:@"正在分析：%@",codePath];
                    [self ___log:log index:(1+(index*1.0/allSouceCount * 90)) all:100];

                    @autoreleasepool {
                        NSString *lines = nil;
                        @autoreleasepool{
                            // step 4 read a file source
                            NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:codePath];
                            NSData *data = [fh readDataToEndOfFile];
                            lines = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        }
                        for (NSString *imageName in imageNames) {
                            NSMutableDictionary *imageDict = [dictPNG objectForKey:imageName];
                            [self ___checkIOSImageNameContainsWithImageDict:imageDict imageName:imageName lines:lines codeFilePath:codePath dictPng:dictPNG fileName:fileName kIndexPaths:_kAPP_IndexFiles];
                        }
                    }
                }
            }
        }else{
            // step 3 load source file
            [self ___log:@"开始加载源代码信息..." index:1 all:100];
            NSDictionary *dictFileCodes = [AIFileParse fileParseWithDirPath:path arrayExtensionName:@[@".xml",@".java"] stringSpecial:nil stringIgnore:nil arrayIgnoreDir:self.arrayIgnoreDir];
            NSArray *imageNames = dictPNG.allKeys;
            NSInteger allSouceCount = [dictFileCodes.allKeys count];
            int index = 0;
            for (NSString *codeFilePath in dictFileCodes.allKeys) {
                NSArray *codePaths = dictFileCodes[codeFilePath];
                for (NSString *p in codePaths) {
                    if (!self.delegate) {
                        goto EndBlock;
                    }
                    index ++;
                    DYYLog(@"%d",index);
                    NSString *log = [NSString stringWithFormat:@"正在分析：%@",p];
                    [self ___log:log index:(1+(index*1.0/allSouceCount * 90)) all:100];
                    NSString *lines = nil;
                    @autoreleasepool{
                        // step 4 read a file source
                        NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:p];
                        NSData *data = [fh readDataToEndOfFile];
                        lines = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    }
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
        }
        [self ___log:@"分析完毕！" index:100 all:100];
        [self ___endParse:dictPNG];
        
        EndBlock:{
            DYYLogError(@"end parse");
            return;
        }
    });
}
-(void) cancelParse{
    self.delegate = nil;
}

@end
