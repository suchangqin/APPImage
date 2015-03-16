//
//  YYDB.m
//  YYProduct
//
//  Created by suchangqin on 13-5-13.
//  Copyright (c) 2013年 suchangqin. All rights reserved.
//

#import "YYDB.h"
#import <sqlite3.h>

@interface YYDB()

@property() sqlite3 *database;

@end

@implementation YYDB

NSString *databasePath(){
//    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_NAME];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:DATABASE_NAME];
}

-(BOOL) connectDatabase{
    DYYLog(@"%@",databasePath());
    if (sqlite3_open([databasePath() UTF8String], &_database) != SQLITE_OK) {
        sqlite3_close(_database);
        DYYLog(@"Error:  Failed to open database");
		return NO;
    }
	return YES;
}
-(BOOL) executeWithSqlString:(NSString *)sqlString{
    DYYLog(@"execute sql: %@",sqlString);
    BOOL re = NO;
    if([self connectDatabase]){
		char *errorMsg;
		if (sqlite3_exec (_database, [sqlString  UTF8String],NULL, NULL, &errorMsg) == SQLITE_OK) {
            re = YES;
            DYYLog( @"Success");
		}else{
			DYYLog( @"Error: %s", errorMsg);
        }
        sqlite3_close(_database);
	}
    return re;
}
#pragma mark - 
-(int)dbQueryCountWithSql:(NSString *)sql{
    int count = 0;
    if([self connectDatabase]){
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
                count = sqlite3_column_int(statement, 0);
			}
			sqlite3_finalize(statement);
		}
		sqlite3_close(_database);
	}
    DYYLog(@"count:%d",count);
    return count;
}
-(BOOL)dbExistWithTableName:(NSString *)tableName{
    NSString *sql = [NSString stringWithFormat:@"select count(type) from sqlite_master where type='table' and name ='%@'",[tableName trim]];
    int count = [self dbQueryCountWithSql:sql];
    return count;
}
-(BOOL)dbUpdateWithSql:(NSString *)sql{
    return [self executeWithSqlString:sql];
}
-(BOOL)dbDeleteWithSql:(NSString *)sql{
    return [self executeWithSqlString:sql];
}
-(BOOL)dbCreateTableWithSql:(NSString *)sql{
    return [self executeWithSqlString:sql];
}
-(float)dbQuerySumWithSql:(NSString *)sql{
    double sum = 0;
    if([self connectDatabase]){
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
                sum = sqlite3_column_double(statement, 0);
			}
			sqlite3_finalize(statement);
		}
		sqlite3_close(_database);
	}
    DYYLog(@"sum:%f",sum);
    return sum;
}
-(NSArray *)dbQueryWithSql:(NSString *)sql{
    NSMutableArray *result = nil;
    if([self connectDatabase]){
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            result = [NSMutableArray array];
            NSMutableArray *arrayKey = [NSMutableArray array];
            for (int i=0; i<sqlite3_column_count(statement);i++) {
                [arrayKey addObject:[NSString stringWithUTF8String:sqlite3_column_name(statement, i)]];
            }
			while (sqlite3_step(statement) == SQLITE_ROW) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                for (int i=0; i<sqlite3_column_count(statement); i++) {
                    char *col_value = (char *)sqlite3_column_text(statement, i);
                    if (col_value == NULL) {
                        continue;
                    }
                    NSString *value = [NSString stringWithUTF8String:col_value];
                    NSString *key = [arrayKey objectAtIndex:i];
                    [dict setObject:value forKey:key];
                }
                [result addObject:dict];
			}
			sqlite3_finalize(statement);
		}
		sqlite3_close(_database);
	}
    DYYLog(@"result:%@",result);
    return result;
}

@end
