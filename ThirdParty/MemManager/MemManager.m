//
//  MemManager.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/6/6.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "MemManager.h"
#import "XGRedis.h"
#import "XGWedis.h"
#import "NSFile+Extension.h"
#import "PINDiskCache.h"

@implementation MemManager

+(void) removeAllMemory{
    //1. 数据准备;
    NSArray *kvFolders = kFN_ALL;
    NSString *cachePath = kCachePath;
    NSInteger sumCount = 0;
    
    //1. 清空UserDefaults记忆;
    NSDictionary *dic = DICTOOK([[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    sumCount += dic.count;
    NSLog(@"===> 清空UserDefaults记忆 \t(%lu)",(unsigned long)dic.count);
    for (id key in dic) [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //2. 清空XGWedis
    NSLog(@"===> 清空XGRedis \t(%lu)",XGRedis.sharedInstance.count);
    sumCount += XGRedis.sharedInstance.count;
    [[XGRedis sharedInstance] clear];
    
    //2. 清空XGWedis
    NSLog(@"===> 清空XGWedis记忆 \t(%lu)",XGWedis.sharedInstance.count);
    sumCount += XGWedis.sharedInstance.count;
    [[XGWedis sharedInstance] clear];
    
    //3. 清空KVFile
    for (NSString *folderName in kvFolders) {
        NSMutableString *fileRootPath = [[NSMutableString alloc] initWithFormat:@"%@/%@",cachePath,folderName];
        NSArray *subFiles = [NSFile_Extension subFiles_AllDeep:fileRootPath];
        NSLog(@"===> 清空KVFile记忆:%@ \t(%lu)",folderName,subFiles.count);
        sumCount += subFiles.count;
        [[NSFileManager defaultManager] removeItemAtPath:fileRootPath error:nil];
    }
    
    //4. 清空heLog
    NSLog(@"===> 清空HeLog记忆 \t(%lu)",theApp.heLogView.count);
    sumCount += theApp.heLogView.count;
    [theApp.heLogView clear];
    NSLog(@"======> 清空记忆Finish \t(%lu)",sumCount);
}

+(void) saveAllMemory:(NSString*)saveName{
    //1. 数据准备;
    NSLog(@"存储记忆至: %@",saveName);
    NSArray *kvFolders = kFN_ALL;
    NSString *cachePath = kCachePath;
    NSMutableString *savePath = [[NSMutableString alloc] initWithFormat:@"%@/save/%@",cachePath,saveName];
    NSInteger sumCount = 0;
    
    //2. 备份UserDefaults记忆;
    NSDictionary *dic = DICTOOK([[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    sumCount += dic.count;
    NSLog(@"===> 存储UserDefaults记忆 \t(%lu)",(unsigned long)dic.count);
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:@"" rootPath:savePath];
    [cache setObject:dic forKey:@"UserDefaults"];
    
    //3. 备份KVFile
    for (NSString *folderName in kvFolders) {
        NSMutableString *fromFolder = [[NSMutableString alloc] initWithFormat:@"%@/%@",cachePath,folderName];
        NSMutableString *toFolder = [[NSMutableString alloc] initWithFormat:@"%@/%@",savePath,folderName];
        NSArray *subFiles = [NSFile_Extension subFiles_AllDeep:fromFolder];
        NSLog(@"===> 存储KVFile记忆:%@ \t(%lu)",folderName,subFiles.count);
        sumCount += subFiles.count;
        [[NSFileManager defaultManager] copyItemAtPath:fromFolder toPath:toFolder error:nil];
    }
    
    //4. 备份heLog
    PINDiskCache *readHeLogCache = [[PINDiskCache alloc] initWithName:kPath_HeLog];//读
    NSMutableArray *heLogDatas = [[NSMutableArray alloc] initWithArray:[readHeLogCache objectForKey:kFile_HeLog]];
    sumCount += heLogDatas.count;
    NSLog(@"===> 存储HeLog条数:%lu",heLogDatas.count);
    PINDiskCache *toHeLogCache = [[PINDiskCache alloc] initWithName:kPath_HeLog rootPath:savePath];//写
    [toHeLogCache setObject:heLogDatas forKey:kFile_HeLog];
    
    NSLog(@"======> 存储记忆Finish \t(%lu)",sumCount);
}

+(void) readAllMemory:(NSString*)readName{
    //1. 数据准备;
    NSLog(@"读取储记忆开始: %@",readName);
    NSArray *kvFolders = kFN_ALL;
    NSString *cachePath = kCachePath;
    NSMutableString *readPath = [[NSMutableString alloc] initWithFormat:@"%@/save/%@",cachePath,readName];
    NSInteger sumCount = 0;
    
    //2. 读取前,先清空当前记忆;
    [self removeAllMemory];
    
    //3. 读取UserDefaults记忆;
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:@"" rootPath:readPath];
    NSDictionary *dic = DICTOOK([cache objectForKey:@"UserDefaults"]);
    [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:dic];
    sumCount += dic.count;
    NSLog(@"===> 读取UserDefaults记忆 \t(%lu)",(unsigned long)dic.count);
    
    //4. 读取KVFile
    for (NSString *folderName in kvFolders) {
        NSMutableString *fromFolder = [[NSMutableString alloc] initWithFormat:@"%@/%@",readPath,folderName];
        NSMutableString *toFolder = [[NSMutableString alloc] initWithFormat:@"%@/%@",cachePath,folderName];
        NSArray *subFiles = [NSFile_Extension subFiles_AllDeep:fromFolder];
        NSLog(@"===> 读取KVFile记忆:%@ \t(%lu)",folderName,subFiles.count);
        sumCount += subFiles.count;
        [[NSFileManager defaultManager] copyItemAtPath:fromFolder toPath:toFolder error:nil];
    }
    
    //4. 备份heLog
    PINDiskCache *readHeLogCache = [[PINDiskCache alloc] initWithName:kPath_HeLog rootPath:readPath];//读
    NSMutableArray *heLogDatas = [[NSMutableArray alloc] initWithArray:[readHeLogCache objectForKey:kFile_HeLog]];
    sumCount += heLogDatas.count;
    NSLog(@"===> 读取HeLog条数:%lu",heLogDatas.count);
    PINDiskCache *toHeLogCache = [[PINDiskCache alloc] initWithName:kPath_HeLog];//写
    [toHeLogCache setObject:heLogDatas forKey:kFile_HeLog];
    [theApp.heLogView reloadData:true];//重新加载显示;
    
    NSLog(@"======> 读取记忆Finish \t(%lu)",sumCount);
}

@end
