//
//  YYDB.h
//  YYProduct
//
//  Created by suchangqin on 13-5-13.
//  Copyright (c) 2013年 suchangqin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATABASE_NAME    @"yydb.sqlite3"

@interface YYDB : NSObject

// table exist?
-(BOOL) dbExistWithTableName:(NSString *) tableName;
// create table
-(BOOL) dbCreateTableWithSql:(NSString *) sql;
// update , delete , insert
-(BOOL) dbUpdateWithSql:(NSString *) sql;
// query count
-(int) dbQueryCountWithSql:(NSString *) sql;
// query
-(NSArray *) dbQueryWithSql:(NSString *) sql;
// sum
-(float) dbQuerySumWithSql:(NSString *) sql;

@end
