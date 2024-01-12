//
//  HeLog.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/3/12.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "HeLogModel.h"
#import "PINCache.h"
#import "SMGUtils+General.h"
#import "HeLogUtil.h"

@interface HeLogModel ()

@property (strong, nonatomic) NSMutableArray *datas;
@property (strong,nonatomic) NSTimer *timer;            //计时器
@property (strong, nonatomic) NSString *diskDataIden;   //现持久化数据的标识

@end

@implementation HeLogModel

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    //1. 初始化内存datas等;
    self.datas = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:cHeLog2DBInterval target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
    });
    
    //2. 重新加载硬盘;
    [self reloadData];
    NSLog(@"===========HeLog Init Data %ld============",self.datas.count);
}


//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------重加载--------------------
 */
-(void) reloadData{
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:kPath_HeLog];
    id file = [cache objectForKey:kFile_HeLog];
    [self.datas removeAllObjects];
    [self.datas addObjectsFromArray:file];
    self.diskDataIden = [HeLogUtil idenByData:self.datas];
}

/**
 *  MARK:--------------------addLog--------------------
 */
-(NSDictionary*) addLog:(NSString*)log{
    log = STRTOOK(log);
    long long nowTime = [[NSDate new] timeIntervalSince1970] * 1000L;
    NSDictionary *addDic = @{kTime:@(nowTime),kLog:log};
    [self.datas addObject:addDic];
    return addDic;
}
-(NSArray*) getDatas{
    return self.datas;
}
-(void) clear{
    [self.datas removeAllObjects];
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:kPath_HeLog];
    [cache removeObjectForKey:kFile_HeLog];
}
-(NSInteger) count{
    return self.datas.count;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------持久化--------------------
 */
- (void)notificationTimer{
    //1. md5去重,同样内容避免重复写硬盘;
    NSString *memDatasIden = [HeLogUtil idenByData:self.datas];
    if ([memDatasIden isEqualToString:self.diskDataIden]) {
        return;
    }
    
    //2. 存储 (随后需支持文件流广告写入);
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:kPath_HeLog];
    [cache setObject:self.datas forKey:kFile_HeLog];
    
    //3. 记录硬盘日志文件的md5;
    self.diskDataIden = memDatasIden;
}

@end
