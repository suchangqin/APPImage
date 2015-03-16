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
#define kTable_project_property              @"property"

@interface AITableProjects : YYTableBase

-(void) createTable;

-(void) inserWithName:(NSString *) name path:(NSString *) path type:(AIProjectTypeState) type property:(NSString *) property;
-(NSArray *) queryAll;

-(void) changeForId:(NSString *) id_ withName:(NSString *) name;

-(BOOL) existWithPath:(NSString *) path;

@end
