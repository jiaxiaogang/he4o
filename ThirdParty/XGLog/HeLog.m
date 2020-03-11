//
//  HeLog.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/3/12.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "HeLog.h"
#import "PINCache.h"
#import "SMGUtils+General.h"

@interface HeLog ()

@property (strong, nonatomic) NSMutableArray *datas;
@property (strong,nonatomic) NSTimer *timer;            //计时器

@end

@implementation HeLog

static HeLog *_instance;
+(HeLog*) sharedInstance{
    if (_instance == nil) {
        _instance = [[HeLog alloc] init];
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
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:kFolderName];
    id file = [cache objectForKey:kFileName];
    self.datas = [[NSMutableArray alloc] initWithArray:file];
    NSLog(@"===========HeLog Init Data %ld============",self.datas.count);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
}


//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
/**
 *  MARK:--------------------addLog--------------------
 */
-(void) addLog:(NSString*)log{
    log = STRTOOK(log);
    long long nowTime = [[NSDate date] timeIntervalSince1970];
    [self.datas addObject:@{kTime:@(nowTime),kLog:log}];
}
-(NSArray*) getDatas{
    return self.datas;
}

/**
 *  MARK:--------------------filter--------------------
 */
-(NSArray*) filterByTime:(NSString*)startT endT:(NSString*)endT{
    //1. 转换startT和endT的时间戳;
    NSDate *startDate = [SMGUtils dateFromTimeStr_yyyyMMddHHmmssSSS:startT];
    NSDate *endDate = [SMGUtils dateFromTimeStr_yyyyMMddHHmmssSSS:endT];
    if (!startDate || !endDate) {
        ELog(@"输入时间格式错误!!! (%@,%@)",startT,endT);
        return nil;
    }
    long long startTime = [startDate timeIntervalSince1970];
    long long endTime = [endDate timeIntervalSince1970];
    
    //2. 找起始index
    NSInteger startIndex = 0;
    NSInteger endIndex = self.datas.count - 1;
    for (NSDictionary *item in self.datas) {
        long long itemTime = [NUMTOOK([item objectForKey:kTime]) longLongValue];
        if (itemTime >= startTime) {
            startIndex = [self.datas indexOfObject:item];
        }
        if (itemTime == endTime) {
            endIndex = [self.datas indexOfObject:item];
        }else if(itemTime < endTime){
            endIndex = [self.datas indexOfObject:item] - 1;
        }
    }
    
    //3. 截取
    NSInteger length = endIndex - startIndex + 1;
    return ARR_SUB(self.datas, startIndex,length);
}

-(NSArray*) filterByKeyword:(NSString*)keyword{
    //1. 数据准备
    keyword = STRTOOK(keyword);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //2. 筛选
    for (NSDictionary *item in self.datas) {
        NSString *log = [item objectForKey:kLog];
        if ([log containsString:keyword]) {
            [result addObject:item];
        }
    }
    return result;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
- (void)notificationTimer{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PINDiskCache *cache = [[PINDiskCache alloc] initWithName:kFolderName];
        [cache setObject:self.datas forKey:kFileName];
        //dispatch_async(dispatch_get_main_queue(), ^{});
    });
}

@end
