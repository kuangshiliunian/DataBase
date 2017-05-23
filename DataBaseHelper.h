//
//  DataBaseHelper.h
//  Senior_DBHelper_YF
//
//  Created by xalo on 16/12/12.
//  Copyright © 2016年 xalo. All rights reserved.
//


//  数据库
#import <Foundation/Foundation.h>

@interface DataBaseHelper : NSObject
//数据库名称
-(void)dbFileNameWithName:(NSString*)fileName;

//无返回结果集执行的方法
-(BOOL)noQueryWithSql:(NSString*)sql;

//通用查询方法
-(NSArray*)queryWithSql:(NSString*)sql;
//单例方法的声明
+(DataBaseHelper*)sharedDataBaseHelper;
@end
