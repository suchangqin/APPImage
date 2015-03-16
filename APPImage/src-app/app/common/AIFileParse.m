//
//  AIFileParse.m
//  APPImage
//
//  Created by suchangqin on 15/2/28.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "AIFileParse.h"

@interface AIFileParse()

@property (strong) NSString *dirPath;
@property (strong) NSArray *arrayExtensionName;
@property (strong) NSString *stringSpecial;
@property (strong) NSString *stringIgnore;
@property (strong) NSArray *arrayIgnoreDir;

@property (strong) NSMutableDictionary *dictResult;

@end

@implementation AIFileParse

#define _kAPP_Width         @"w"
#define _kAPP_Height        @"h"
#define _kAPP_Size          @"s"
#define _kAPP_FilePath      @"fp"
#define _kAPP_IndexFiles    @"is"
#define _kAPP_IndexFiles1x  @"is1x"
#define _kAPP_Files         @"fs"



- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dictResult = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) loadFileAtDirPath:(NSString *) dirPath{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error;
    NSArray *files = [fm contentsOfDirectoryAtPath:dirPath error:&error];
//    if (error) {
//        DYYLogError(@"%@",error);
//    }
//    DYYLog(@"%@",files);
    for (NSString *fileName in files) {
        //忽略一切以点开头的文件和文件夹
        if ([fileName hasPrefix:@"."]) {
            continue;
        }
        NSString *path = [NSString pathWithComponents:@[dirPath,fileName]];

        BOOL isDir;
        if([fm fileExistsAtPath:path isDirectory:&isDir] && isDir){
            //目录
            if([self.arrayIgnoreDir containsObject:fileName]){
                //忽略继续
                continue;
            }
            //递归遍历
            [self loadFileAtDirPath:path];
        }else{
            //文件
            for (NSString *name in _arrayExtensionName) {
                if ([fileName hasSuffix:name]) {
                    if (_stringSpecial && [fileName rangeOfString:_stringSpecial].location == NSNotFound) {
                        continue;
                    }
                    if(_stringIgnore && [fileName rangeOfString:_stringIgnore].location != NSNotFound){
                        continue;
                    }
                    NSArray *allKeys = [self.dictResult allKeys];
                    if (![allKeys containsObject:fileName]) {
                        [self.dictResult setObject:[NSMutableArray array] forKey:fileName];
                    }
                    NSMutableArray *array = [self.dictResult objectForKey:fileName];
                    [array addObject:path];
                }
            }
        }
    }
}

+(void) yytest{
//    NSString *path = @"/Users/suchangqin/Documents/workspace-qeegoo/iOS/YYProduct";
//    path = @"/Users/suchangqin/Desktop";
//    NSDictionary *dict = [AIFileParse fileParseWithDirPath:path arrayExtensionName:@[@".png"] stringSpecial:nil stringIgnore:nil arrayIgnoreDir:nil];
//    DYYLogWarning(@"%@",dict);
}

+(NSDictionary *) fileParseWithDirPath:(NSString *) dirPath arrayExtensionName:(NSArray *) arrayExtensionName stringSpecial:(NSString *) stringSpecial stringIgnore:(NSString *) stringIgnore arrayIgnoreDir:(NSArray *) arrayIgnoreDir{
    
    AIFileParse *fp = [[AIFileParse alloc] init];
    
    fp.arrayExtensionName = arrayExtensionName;
    fp.stringSpecial = stringSpecial;
    fp.stringIgnore = stringIgnore;
    fp.arrayIgnoreDir = arrayIgnoreDir;
    
    [fp loadFileAtDirPath:dirPath];
    return fp.dictResult;
}
+(NSMutableDictionary *) pngFileFormat:(NSDictionary *) pngDict withType:(AIProjectTypeState) type{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    for (NSString *pngName in [pngDict allKeys]) {
        @autoreleasepool {
            if(type == AIProjectTypeAndroidAPP){
                NSMutableArray *files = [NSMutableArray array];
                for (NSString *path in [pngDict arrayForKey:pngName]) {
                    NSDictionary * attributes = [fm attributesOfItemAtPath:path error:nil];
                    NSNumber *fileSize = [attributes objectForKey:NSFileSize];
                    
                    
                    NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
                    float h = image.size.height;
                    float w = image.size.width;
                    NSDictionary *format = @{
                                             _kAPP_FilePath:path,
                                             _kAPP_Size:fileSize,
                                             _kAPP_Width:@(w),
                                             _kAPP_Height:@(h)
                                             };
                    [files addObject:[NSMutableDictionary dictionaryWithDictionary:format]];
                }
                NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
                [newDict setObject:files forKey:_kAPP_Files];
                
                [dict setObject:newDict forKey:pngName];
            }else{
                NSString *path = [[pngDict arrayForKey:pngName] firstObject];
                
                
                NSDictionary * attributes = [fm attributesOfItemAtPath:path error:nil];
                NSNumber *fileSize = [attributes objectForKey:NSFileSize];
                
                int scale = 1;
                if ([pngName hasSuffix:@"@3x.png"]) {
                    scale = 3;
                }
                if ([pngName hasSuffix:@"@2x.png"]) {
                    scale = 2;
                }
                
                NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
                float h = image.size.height*scale;
                float w = image.size.width*scale;
                
                
                NSDictionary *format = @{
                                         _kAPP_FilePath:path,
                                         _kAPP_Size:fileSize,
                                         _kAPP_Width:@(w),
                                         _kAPP_Height:@(h)
                                         };
                [dict setObject:[NSMutableDictionary dictionaryWithDictionary:format] forKey:pngName];
            }
        }
    }
    return dict;
}


@end
