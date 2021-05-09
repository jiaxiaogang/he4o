//
//  AINoRepeatRun.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/5/9.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AINoRepeatRun.h"

#define theData [AINoRepeatRun sharedData]

@implementation AINoRepeatRun

static NSMutableDictionary *_data;
+(NSMutableDictionary*) sharedData{
    if (_data == nil) _data = [[NSMutableDictionary alloc] init];
    return _data;
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
/**
 *  MARK:--------------------报名--------------------
 */
+(void) sign:(id)key{
    NSLog(@"防重登记:%@",key);
    [theData setObject:@"" forKey:key];
}

/**
 *  MARK:--------------------执行--------------------
 */
+(void) run:(id)key block:(void(^)())block {
    //仅执行一次,就把登记key移除掉;
    if ([theData objectForKey:key]) {
        [theData removeObjectForKey:key];
        NSLog(@"防重执行:%@",key);
        if (block) block();
    }
}

@end
