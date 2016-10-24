//
//  YYTableTest.m
//  YYProduct
//
//  Created by suchangqin on 13-5-13.
//  Copyright (c) 2013年 suchangqin. All rights reserved.
//

#import "YYTableTest.h"

@implementation YYTableTest

#define TABLE_NAME " test "
-(void)dropTable{
    NSString *sql = @"DROP TABLE" TABLE_NAME;
    [self.dbUtil dbUpdateWithSql:sql];
}
- (void) createTable{
    NSString *sqlString = @"CREATE TABLE IF NOT EXISTS " TABLE_NAME "(id INTEGER PRIMARY KEY, name TEXT,sex TEXT);";
    [self.dbUtil dbCreateTableWithSql:sqlString];
}
- (void) insertSomething{
    NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO" TABLE_NAME "(name,sex) VALUES('%@','%@');",@"苏昌钦",@"男"];
    [self.dbUtil dbUpdateWithSql:sqlString];
}
- (NSArray *) queryAll{
    NSString *sqlString = @"SELECT * FROM " TABLE_NAME;
    NSArray *result = [self.dbUtil dbQueryWithSql:sqlString];
    DYYLog(@"%@",result);
    return result;
}

-(void)test{
    [self createTable];
    NSArray *array = [self queryAll];
    DYYLog(@"%@",array);
    [self insertSomething];
    [self insertSomething];
    [self insertSomething];
    array = [self queryAll];
    DYYLog(@"%@",array);
}

@end
