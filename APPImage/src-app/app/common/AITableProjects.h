//
//  AITableProjects.h
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kTable_project_id                    @"id"
#define kTable_project_name                  @"name"
#define kTable_project_type                  @"type"
#define kTable_project_path                  @"path"
#define kTable_project_size_property         @"size_pty"
#define kTable_project_ignore_property       @"ignore_pty"

@interface AITableProjects : YYTableBase

-(void) createTable;

-(void) insertWithName:(NSString *) name path:(NSString *) path type:(AIProjectTypeState) type;
-(NSArray *) queryAll;

-(void) changeForId:(NSString *) id_ withName:(NSString *) name;
-(void) deleteForId:(NSString *) id_;

-(BOOL) existWithPath:(NSString *) path;

-(BOOL) updateForId:(NSString *) id_ withSizeProperty:(NSString *) sizeProperty ignoreProperty:(NSString *) ignoreProperty;

-(NSDictionary *) queryPropertyWithId:(NSString *) id_;

@end
