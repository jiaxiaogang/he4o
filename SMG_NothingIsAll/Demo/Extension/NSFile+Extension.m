//
//  NSFile+Extension.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/12/9.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "NSFile+Extension.h"

@implementation NSFile_Extension

+ (NSArray*)subFiles_AllDeep:(NSString*)path{
    //1. 数据准备
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *subFileNames = [fileMgr contentsOfDirectoryAtPath:path error:nil];
    
    //2. 分别收集子文件;
    for (NSString *fileName in subFileNames) {
        BOOL isDirectory = YES;
        NSString *fullPath = [path stringByAppendingPathComponent:fileName];
        if ([fileMgr fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
            //3. 文件夹时递归收集;
            if (isDirectory) {
                [array addObjectsFromArray:[self subFiles_AllDeep:fullPath]];
            }else{
                //4. 文件时,直接收集;
                [array addObject:fullPath];
            }
        }
    }
    return array;
}

@end
