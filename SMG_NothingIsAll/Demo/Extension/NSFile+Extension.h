//
//  NSFile+Extension.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/12/9.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFile_Extension : NSObject

//所有子文件收集 notnull
+(NSArray*)subFiles:(NSString*)path;
+ (NSArray*)subFiles_AllDeep:(NSString*)dirString;

//所有子文件夹收集 notnull;
+(NSArray*)subFolders:(NSString*)path;

//所有子文件与文件夹全收集 notnull;
+(NSArray*)subPaths:(NSString*)path;

@end
