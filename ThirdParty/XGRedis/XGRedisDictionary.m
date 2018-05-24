//
//  XGRedisDictionary.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "XGRedisDictionary.h"
#import "XGRedisUtil.h"

@interface XGRedisDictionary()

@property (strong, nonatomic) NSMutableArray *keys;
@property (strong, nonatomic) NSMutableArray *values;
@property (strong, nonatomic) NSMutableArray *gcMarks;  //回收时间记录;(时间从先到后_有序)
@property (strong,nonatomic) NSTimer *timer;            //计时器

@end


@implementation XGRedisDictionary

static XGRedisDictionary *_instance;
+(XGRedisDictionary*) sharedInstance{
    if (_instance == nil) {
        _instance = [[XGRedisDictionary alloc] init];
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
    _keys = [[NSMutableArray alloc] init];
    _values = [[NSMutableArray alloc] init];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
    self.gcMarks = [[NSMutableArray alloc] init];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(NSArray*) allKeys{
    return [self.keys copy];
}

-(NSInteger) count{
    return self.keys.count;
}

-(BOOL) removeObjectAtIndex:(NSInteger)index{
    if (index >= 0 && index < self.count) {
        [self.keys removeObjectAtIndex:index];
        [self.values removeObjectAtIndex:index];
        return true;
    }
    return false;
}

//add
-(BOOL) addObject:(NSObject*)obj forKey:(NSString*)key{
    if (obj && STRISOK(key)) {
        [self.keys addObject:key];
        [self.values addObject:obj];
        return true;
    }
    return false;
}

//addWithTime
-(BOOL) addObject:(NSObject*)obj forKey:(NSString*)key time:(double)time{
    //1. 插入数据
    BOOL success = [self addObject:obj forKey:key];
    
    //2. 插入gcMark
    if (success && time!= NSNotFound) {
        [self createGCMark:key time:time];
    }
    
    return success;
}

//insert
-(BOOL) insertObject:(NSObject*)obj key:(NSString*)key atIndex:(NSInteger)index{
    if (index < self.count && obj && STRISOK(key)) {
        [self.keys insertObject:key atIndex:index];
        [self.values insertObject:obj atIndex:index];
        return true;
    }
    return false;
}

//insertWithTime
-(BOOL) insertObject:(NSObject*)obj key:(NSString*)key atIndex:(NSInteger)index time:(double)time{
    //1. 插入数据
    BOOL success = [self insertObject:obj key:key atIndex:index];
    
    //2. 插入gcMark
    if (success && time!= NSNotFound) {
        [self createGCMark:key time:time];
    }
    
    return success;
}

-(NSString*) keyForIndex:(NSInteger)index{
    return ARR_INDEX(self.keys, index);
}

-(NSObject*) valueForIndex:(NSInteger)index{
    return ARR_INDEX(self.values, index);
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
                NSString *checkKey = [self keyForIndex:checkIndex];
                return [XGRedisUtil compareStrA:mark.key strB:checkKey];
            } startIndex:0 endIndex:self.count - 1 success:^(NSInteger index) {
                [self removeObjectAtIndex:index];
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



//MARK:===============================================================
//MARK:                     < 回收模型 >
//MARK:===============================================================
@implementation XGRedisGCMark

@end
