//
//  AITableProjects.m
//  APPImage
//
//  Created by suchangqin on 15/2/26.
//  Copyright (c) 2015年 suchangqin. All rights reserved.
//

#import "AITableProjects.h"

@implementation AITableProjects

#define TABLE_NAME " t_projects_103 " //数据库有更新就用新表格，比较简单

- (void) createTable{
    NSString *sqlString = @"CREATE TABLE IF NOT EXISTS " TABLE_NAME "(id INTEGER PRIMARY KEY, name TEXT,path TEXT,type INTEGER,size_pty TEXT,ignore_pty TEXT);";
    [self.dbUtil dbCreateTableWithSql:sqlString];
}

-(void) insertWithName:(NSString *) name path:(NSString *) path type:(AIProjectTypeState) type{
    if([self existWithPath:path]){
        return;
    }
    NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO" TABLE_NAME "(name,path,type) VALUES('%@','%@',%lu);",
                           DB_STRING_FORMAT(name),
                           DB_STRING_FORMAT(path),
                           type
                           ];
    [self.dbUtil dbUpdateWithSql:sqlString];
}
-(NSArray *)queryAll{
    NSString *sqlString = @"SELECT * FROM " TABLE_NAME " ORDER BY id DESC";
    NSArray *result = [self.dbUtil dbQueryWithSql:sqlString];
    return result;
}
-(void) changeForId:(NSString *) id_ withName:(NSString *) name{
    NSString *sql = [NSString stringWithFormat:@"UPDATE " TABLE_NAME " SET name = '%@' WHERE id = %@",
                     DB_STRING_FORMAT(name),
                     DB_STRING_FORMAT(id_)
                     ];
    [self.dbUtil dbUpdateWithSql:sql];
}
-(void) deleteForId:(NSString *) id_{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM " TABLE_NAME " WHERE id = %@",
                     DB_STRING_FORMAT(id_)
                     ];
    [self.dbUtil dbUpdateWithSql:sql];
}
-(BOOL) existWithPath:(NSString *) path{
    NSString *sqlString = [NSString stringWithFormat:@"SELECT count(*) FROM" TABLE_NAME "WHERE path='%@'",DB_STRING_FORMAT(path)];
    return [self.dbUtil dbQueryCountWithSql:sqlString];
}
-(BOOL) updateForId:(NSString *) id_ withSizeProperty:(NSString *) sizeProperty ignoreProperty:(NSString *) ignoreProperty{
    NSString *sql = [NSString stringWithFormat:@"UPDATE " TABLE_NAME " SET size_pty = '%@', ignore_pty='%@' WHERE id = %@",
                     DB_STRING_FORMAT(sizeProperty),
                     DB_STRING_FORMAT(ignoreProperty),
                     DB_STRING_FORMAT(id_)
                     ];
    return [self.dbUtil dbUpdateWithSql:sql];
}
-(NSDictionary *) queryPropertyWithId:(NSString *) id_{
    NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM " TABLE_NAME " WHERE id = %@",
                           DB_STRING_FORMAT(id_)
                           ];
    NSArray *result = [self.dbUtil dbQueryWithSql:sqlString];
    return [result firstObject];
}

@end
