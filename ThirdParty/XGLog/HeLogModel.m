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
@property (strong, nonatomic) NSString *diskDatasMd5;

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
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:kFolderName];
    id file = [cache objectForKey:kFileName];
    self.datas = [[NSMutableArray alloc] initWithArray:file];
    self.diskDatasMd5 = STRTOOK([HeLogUtil md5ByData:OBJ2DATA(self.datas)]);
    NSLog(@"===========HeLog Init Data %ld============",self.datas.count);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
}


//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

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
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:kFolderName];
    [cache removeObjectForKey:kFileName];
}
-(NSInteger) count{
    return self.datas.count;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
- (void)notificationTimer{
    //1. md5去重,同样内容避免重复写硬盘;
    NSString *memDatasMd5 = STRTOOK([HeLogUtil md5ByData:OBJ2DATA(self.datas)]);
    if ([memDatasMd5 isEqualToString:self.diskDatasMd5]) {
        return;
    }
    
    //2. 存储 (随后需支持文件流广告写入);
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:kFolderName];
    [cache setObject:self.datas forKey:kFileName];
    
    //3. 记录硬盘日志文件的md5;
    self.diskDatasMd5 = memDatasMd5;
}

@end
