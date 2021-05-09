//
//  AINoRepeatRun.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/5/9.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AINoRepeatRun.h"

@interface AINoRepeatRun ()

@property (strong, nonatomic) NSMutableDictionary *signDic;

@end

@implementation AINoRepeatRun

static AINoRepeatRun *_instance;
//static NSMutableDictionary *dic;
+(AINoRepeatRun*) sharedInstance{
    if (_instance == nil) {
        _instance = [[AINoRepeatRun alloc] init];
    }
    return _instance;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
-(NSMutableDictionary *)signDic{
    if (_signDic == nil) {
        _signDic = [[NSMutableDictionary alloc] init];
    }
    return _signDic;
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
/**
 *  MARK:--------------------报名--------------------
 */
-(void) sign:(id)key{
    [self.signDic setObject:@"" forKey:key];
}

/**
 *  MARK:--------------------执行--------------------
 */
-(void) run:(id)key block:(void(^)())block {
    if ([self.signDic objectForKey:key] && block) {
        [self.signDic removeObjectForKey:key];
        block();
    }
}

@end
