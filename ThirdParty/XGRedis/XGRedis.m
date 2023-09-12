//
//  XGRedis.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "XGRedis.h"
#import "XGRedisUtil.h"
#import "XGRedisDictionary.h"
#import "AIKVPointer.h"

@interface XGRedis ()

@property (strong, nonatomic) AsyncMutableDictionary *dic;   //核心字典
@property (strong, nonatomic) AsyncMutableDictionary *gcMarks;  //回收时间记录;(时间从先到后_有序)
@property (strong,nonatomic) NSTimer *timer;            //计时器

@end

@implementation XGRedis

static XGRedis *_instance;
+(XGRedis*) sharedInstance{
    if (_instance == nil) {
        _instance = [[XGRedis alloc] init];
    }
    return _instance;
}

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.dic = [[AsyncMutableDictionary alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
    });
    self.gcMarks = [[AsyncMutableDictionary alloc] init];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) setObject:(NSObject*)obj forKey:(NSString*)key {
    [self setObject:obj forKey:key time:NSNotFound];
}

-(void) setObject:(NSObject*)obj forKey:(NSString*)key time:(double)time{
    long long gcTime = (long long)([[NSDate date] timeIntervalSince1970] + MAX(0, time));
    [self.dic setObject:obj forKey:key];
    [self.gcMarks setObject:@(gcTime) forKey:key];
}

-(id) objectForKey:(NSString*)key{
    return [self.dic objectForKey:key];
}

-(void) clear{
    [self.dic removeAllObjects];
    [self.gcMarks removeAllObjects];
}

-(NSInteger) count{
    return self.dic.count;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
- (void)notificationTimer{
    //1. 计时器执行
    double now = [[NSDate date] timeIntervalSince1970];
    
    //2. 找到需要销毁的并销毁;
    NSArray *gcMarkKeys = [self.gcMarks.allKeys copy];
    for (NSString *key in gcMarkKeys) {
        long long gcTime = NUMTOOK([self.gcMarks objectForKey:key]).longLongValue;
        if (gcTime < now) {
            [self.dic removeObjectForKey:key];
            [self.gcMarks removeObjectForKey:key];
        }
    }
}

@end
