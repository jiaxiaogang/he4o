//
//  XGRedis.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kXGRedisGCObserver @"kXGRedisGCObserver"    //xgRedis在GC时,会发送广播

/**
 *  MARK:--------------------XGRedis--------------------
 *  注:time只针对设置时的key,并在倒计时后,找到key并remove;(设置time后,不可撤销)
 *
 */
@interface XGRedis : NSObject

+(XGRedis*) sharedInstance;

/**
 *  MARK:--------------------setObject--------------------
 *  @param obj : 数据
 *  @param key : 唯一识别符
 */
-(void) setObject:(NSObject*)obj forKey:(NSString*)key;

/**
 *  MARK:--------------------setObject--------------------
 *  @param time : 当time <= 0时,会移除旧的obj,并且不会添加新的;
 */
-(void) setObject:(NSObject*)obj forKey:(NSString*)key time:(double)time;


-(NSObject*) objectForKey:(NSString*)key;

@end
