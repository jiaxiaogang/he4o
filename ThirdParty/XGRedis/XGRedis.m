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

@interface XGRedis ()

@property (strong, nonatomic) XGRedisDictionary *dic;   //核心字典
@property (strong, nonatomic) NSMutableArray *gcMarks;  //回收时间记录;(时间从先到后_有序)
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
    self.dic = [[XGRedisDictionary alloc] init];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
    self.gcMarks = [[NSMutableArray alloc] init];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) setObject:(NSObject*)obj forKey:(NSString*)key {
    [self setObject:obj forKey:key time:NSNotFound];
}

-(void) setObject:(NSObject*)obj forKey:(NSString*)key time:(double)time{
    //1. 二分查找index;
    __block NSInteger findOldIndex = 0;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        NSString *checkKey = [self.dic keyForIndex:checkIndex];
        return [XGRedisUtil compareStrA:key strB:checkKey];
    } startIndex:0 endIndex:self.dic.count - 1 success:^(NSInteger index) {
        [self.dic removeObjectAtIndex:index];
        findOldIndex = index;
    } failure:^(NSInteger index) {
        findOldIndex = index;
    }];
    
    if (time > 0) {
        //2. 插入数据
        BOOL success = false;
        if(self.dic.count <= findOldIndex) {
            success = [self.dic addObject:obj forKey:key];
        }else{
            success = [self.dic insertObject:obj key:key atIndex:findOldIndex];
        }
        
        //3. 插入gcMark
        if (success && time!= NSNotFound) {
            [self createGCMark:key time:time];
        }
    }
}

-(NSObject*) objectForKey:(NSString*)key{
    //二分法查找
    __block NSObject *obj = nil;
    if (STRISOK(key)) {
        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
            NSString *checkKey = [self.dic keyForIndex:checkIndex];
            return [XGRedisUtil compareStrA:key strB:checkKey];
        } startIndex:0 endIndex:self.dic.count - 1 success:^(NSInteger index) {
            obj = [self.dic valueForIndex:index];
        } failure:nil];
    }
    return obj;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
- (void)notificationTimer{
    //1. 计时器执行
    double now = [[NSDate date] timeIntervalSince1970];
    NSInteger findCount = 0;
    
    //2. 找到需要销毁的并销毁;
    for (XGRedisGCMark *mark in self.gcMarks) {
        if (mark.time < now) {
            findCount ++;
            [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
                NSString *checkKey = [self.dic keyForIndex:checkIndex];
                return [XGRedisUtil compareStrA:mark.key strB:checkKey];
            } startIndex:0 endIndex:self.dic.count - 1 success:^(NSInteger index) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kXGRedisGCObserver object:[self.dic keyForIndex:index]];
                [self.dic removeObjectAtIndex:index];
            } failure:nil];
        }else{
            //3.
            break;
        }
    }
    
    //3. 并将已销毁的除出gcMarks
    [self.gcMarks removeObjectsInRange:NSMakeRange(0, findCount)];
}

-(void) createGCMark:(NSString*)key time:(double)time{
    //1. 找到gcMark的插入位置;(从小到大的排)
    long long gcTime = (long long)([[NSDate date] timeIntervalSince1970] + MAX(0, time));
    __block NSInteger findOldIndex = 0;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        XGRedisGCMark *checkMark = ARR_INDEX(self.gcMarks, checkIndex);
        if (ISOK(checkMark, XGRedisGCMark.class)) {
            return checkMark.time > gcTime ? NSOrderedDescending : (checkMark.time < gcTime ? NSOrderedAscending : NSOrderedSame);
        }else{
            return NSOrderedDescending;
        }
    } startIndex:0 endIndex:self.gcMarks.count - 1 success:^(NSInteger index) {
        findOldIndex = index;
    } failure:^(NSInteger index) {
        findOldIndex = index;
    }];
    
    //2. 插入gcMark
    XGRedisGCMark *mark = [[XGRedisGCMark alloc] init];
    mark.time = gcTime;
    mark.key = key;
    [self.gcMarks insertObject:mark atIndex:findOldIndex];
}

@end
