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

@interface HeLogModel ()

@property (strong, nonatomic) NSMutableArray *datas;
@property (strong,nonatomic) NSTimer *timer;            //计时器

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
    NSLog(@"===========HeLog Init Data %ld============",self.datas.count);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
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
