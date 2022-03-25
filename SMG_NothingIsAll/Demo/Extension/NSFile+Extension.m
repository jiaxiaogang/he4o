//
//  NSFile+Extension.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/12/9.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "NSFile+Extension.h"

@implementation NSFile_Extension

+(NSArray*)subFiles:(NSString*)path{
    //1. 数据准备
    NSArray *subPaths = [self subPaths:path];
    
    //2. 筛选文件夹返回
    return [SMGUtils filterArr:subPaths checkValid:^BOOL(NSString *subPath) {
        BOOL isDirectory = YES;
        return [[NSFileManager defaultManager] fileExistsAtPath:subPath isDirectory:&isDirectory] && !isDirectory;
    }];
}

+ (NSArray*)subFiles_AllDeep:(NSString*)path{
    //1. 数据准备
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *subPaths = [self subPaths:path];
    
    //2. 分别收集子文件;
    for (NSString *subPath in subPaths) {
        BOOL isDirectory = YES;
        if ([[NSFileManager defaultManager] fileExistsAtPath:subPath isDirectory:&isDirectory]) {
            //3. 文件夹时递归收集;
            if (isDirectory) {
                [array addObjectsFromArray:[self subFiles_AllDeep:subPath]];
            }else{
                //4. 文件时,直接收集;
                [array addObject:subPath];
            }
        }
    }
    return array;
}

+(NSArray*)subFolders:(NSString*)path{
    //1. 数据准备
    NSArray *subPaths = [self subPaths:path];
    
    //2. 筛选文件夹返回
    return [SMGUtils filterArr:subPaths checkValid:^BOOL(NSString *subPath) {
        BOOL isDirectory = YES;
        return [[NSFileManager defaultManager] fileExistsAtPath:subPath isDirectory:&isDirectory] && isDirectory;
    }];
}

//所有子文件与文件夹全收集 notnull;
+(NSArray*)subPaths:(NSString*)path{
    //1. 数据准备
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *subFileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    //2. 分别收集子文件;
    for (NSString *fileName in subFileNames) {
        NSString *fullPath = [path stringByAppendingPathComponent:fileName];
        [array addObject:fullPath];
    }
    return array;
}

@end
