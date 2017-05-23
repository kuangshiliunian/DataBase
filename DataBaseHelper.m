//
//  DataBaseHelper.m
//  Senior_DBHelper_YF
//
//  Created by xalo on 16/12/12.
//  Copyright © 2016年 xalo. All rights reserved.
//

#import "DataBaseHelper.h"
#import <sqlite3.h>

@interface DataBaseHelper (){
    sqlite3* sqliteHandle;
}
@property(nonatomic,retain)NSString* dbFileName;//数据库文件路径
@end

@implementation DataBaseHelper

+(DataBaseHelper*)sharedDataBaseHelper{
    static DataBaseHelper* dbHelper=nil;
    if (dbHelper==nil) {
        dbHelper=[[DataBaseHelper alloc] init];
    }
    return dbHelper;
}

//创建数据库文件存储的路径，一般在documents和library/caches

-(void)dbFileNameWithName:(NSString*)fileName{
    //将fileName中的空格替换掉
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //判断用户传递进来的文件名是否为nil或者为空字符串
    if (fileName) {
        //判断文件名是否为空字符串
        if (fileName.length == 0) {
            //空字符串@""
             NSLog(@"数据库文件无名称,当程序关闭的时候，数据库文件也会销毁");
        }else{
            //判断文件名是否带后缀名，如果有就直接使用，如果没有，就添加后缀名之后在使用
            if (![fileName hasSuffix:@".sqlite"]) {
                //如果没有后缀名，添加后缀名之后在使用
                fileName = [fileName stringByAppendingString:@".sqlite"];
            }
            
        }
    }else{
        //说明文件名为nil
        NSLog(@"数据库文件无名称,当程序关闭的时候，数据库文件也会销毁");
        fileName=@"";
    }
    //将文件名称拼接成有效的文件路径
    NSString* docPath=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    fileName=[docPath stringByAppendingPathComponent:fileName];
    //将处理好的文件名赋值给属性，让其他方法使用
    self.dbFileName=fileName;
    
    NSLog(@"文件地址------%@",fileName);
    
}

//打开或者创建数据库文件
-(sqlite3*)creatDB{
    int result=sqlite3_open(self.dbFileName.UTF8String, &sqliteHandle);
    if (result==SQLITE_OK) {
         NSLog(@"创建或者打开数据库成功");
        return sqliteHandle;
    }else{
        NSLog(@"创建或者打开数据库失败----%d",result);
        return NULL;
    }
    
}

//无返回结果集执行的方法
-(BOOL)noQueryWithSql:(NSString*)sql{
    //执行任何数据库操作之前，先打开数据库；操作执行完毕之后记得关闭数据库
    sqlite3* sqlite=[self creatDB];
    //执行sql语句
    if (sqlite) {//保证数据库打开成功
        int result=sqlite3_exec(sqlite, sql.UTF8String, NULL, NULL, NULL);
        //当操作有结果的时候一定要关闭数据库
        sqlite3_close(sqlite);
        if (result==SQLITE_OK) {
            NSLog(@"执行非查询操作成功");
            return YES;
        }else{
            NSLog(@"执行非查询操作失败-----%d",result);
            return NO;
        }
    }
    //说明数据库打开失败
    NSLog(@"执行查询操作的时候，打开数据库失败了");
    return NO;
   
   
}

//通用查询方法
-(NSArray*)queryWithSql:(NSString*)sql{
    //打开数据库
    sqlite3* sqlite=[self creatDB];
    //创建可变数组，用来存放所有的记录
    NSMutableArray* resultMArray=[[NSMutableArray alloc] init];
    //声明伴随指针，用来存放所有的记录
    sqlite3_stmt* stmt=NULL;
    //预执行
    int result=sqlite3_prepare(sqlite, sql.UTF8String, -1, &stmt, NULL);
    if (result==SQLITE_OK) {
        //说明sql语句没有问题
        NSLog(@"执行查询操作成功");
        //从伴随指针中取出每一条记录
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            //每执行一次循环体，就取出一条记录
            NSMutableDictionary* mDic=[[NSMutableDictionary alloc] init];
            //确定改条记录有几个字段
            int sumColumn=sqlite3_column_count(stmt);
            //for循环遍历一条记录中的所有字段
            for (int i=0; i<sumColumn; i++) {
                //获取当前列的数据类型
               int type = sqlite3_column_type(stmt, i);
                //获取字段名
               const char * name = sqlite3_column_name(stmt, i);
                NSString* key=[NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                
                //取出每一列的值
                switch (type) {
                    case SQLITE_INTEGER:{
                        //int类型
                        int value=sqlite3_column_int(stmt, i);
                        //为字典赋值
                        [mDic setObject:@(value) forKey:key];
                        
                    }
                 
                        break;
                    case SQLITE_TEXT:{
                        //字符串类型
                       const unsigned char* value=sqlite3_column_text(stmt, i);
                        NSString* valueStr=[NSString stringWithCString:( const char *)value encoding:NSUTF8StringEncoding];
                        [mDic setObject:valueStr forKey:key];
                        
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            
          //一次for循环结束，一条记录才转换为一个字典
            [resultMArray addObject:mDic];
           
        }
        
    }else{
         //说明sql语句有问题
        NSLog(@"执行查询操作失败-----%d",result);
       
    }
    
    //将伴随指针所持有的资源释放掉,关闭数据库
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    //while循环结束，说明所有的记录都已经获取完整
    return resultMArray;
    
}











@end
