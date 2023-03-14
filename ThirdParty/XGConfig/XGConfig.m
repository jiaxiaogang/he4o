//
//  XGConfig.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/8/25.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "XGConfig.h"

@interface XGConfig ()

@property (strong, nonatomic) NSString *lastReloadIden;         //加载标识 (当标识变化时,会触发重新加载);
@property (strong, nonatomic) NSMutableDictionary *configDic;   //配置字典;

@end

@implementation XGConfig

static id mInstance;
+(XGConfig*) instance{
    if (mInstance == nil) mInstance = [[XGConfig alloc] init];
    return mInstance;
}

/**
 *  MARK:--------------------初始配置--------------------
 */
-(void) initConfig{
    self.configDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                      @(false),xgConfigKeyZiWuMode,
                      @(true),xgConfigKeyTest,
                      @(false),xgConfigKeyPauseRLT,
                      nil];
    NSLog(@"%@",[self url].path);
    [[NSFileManager defaultManager] createDirectoryAtPath:[self folder] withIntermediateDirectories:false attributes:nil error:nil];
    BOOL success = [self.configDic writeToURL:[self url] atomically:true];
    NSLog(@"======> XGConfig初始化%@",success ? @"成功" : @"失败");
}

/**
 *  MARK:--------------------响应配置变化到系统--------------------
 */
-(void) responseXGConfig2HE {
    //1. 重加载
    [self reloadConfigDic];
    
    //2. 更新配置导致的变化到系统;
    if (NUMTOOK([self.configDic objectForKey:xgConfigKeyZiWuMode]).boolValue) {
        theTC.thinkMode = 2;
        NSLog(@"======> XGConfig响应: 进入植物模式");
    }
    
    //b. 暂停强化训练;
    if (NUMTOOK([self.configDic objectForKey:xgConfigKeyPauseRLT]).boolValue) {
        [theRT setPlaying:false];
        NSLog(@"======> XGConfig响应: 暂停强化训练");
    }
}

/**
 *  MARK:--------------------写配置--------------------
 */
-(void) setValue:(id)value forKey:(NSString*)key{
    //1. 未加载过,则先初始化加载;
    if (!self.configDic) {
        [self reloadConfigDic];
    }
    
    //2. 新值写入;
    [self.configDic setObject:value forKey:key];
    BOOL success = [self.configDic writeToURL:[self url] atomically:true];
    NSLog(@"======> 配置写入K:%@ V:%@ (%@)",key,value,success ? @"成功" : @"失败");
}

/**
 *  MARK:--------------------读配置--------------------
 */
-(id) valueForKey:(NSString*)key reloadIden:(NSString*)reloadIden{
    if (![STRTOOK(self.lastReloadIden) isEqualToString:reloadIden]) {
        [self reloadConfigDic];
    }
    id value = [self.configDic objectForKey:key];
    NSLog(@"======> 配置取值K:%@ V:%@",key,value);
    return value;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

//重加载数据;
-(void) reloadConfigDic{
    //1. 取数据;
    @try {
        NSDictionary *db = DICTOOK([NSDictionary dictionaryWithContentsOfURL:[self url]]);
        self.configDic = [[NSMutableDictionary alloc] initWithDictionary:db];
    }@catch (NSException *exception) {}
}

// notnull
-(NSURL*) url{
    return [NSURL fileURLWithPath:STRFORMAT(@"%@/%@",[self folder],xgConfigFile)];
}

-(NSString*) folder{
    NSString *cachePath = kCachePath;
    return STRFORMAT(@"%@/%@",cachePath,xgConfigPath);
}

@end
