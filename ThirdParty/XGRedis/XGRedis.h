//
//  XGRedis.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------XGRedis--------------------
 *  注:time只针对设置时的key,并在倒计时后,找到key并remove;(设置time后,不可撤销)
 *
 */
@interface XGRedis : NSObject

-(void) setObject:(NSObject*)obj forKey:(NSString*)key;
-(void) setObject:(NSObject*)obj forKey:(NSString*)key time:(double)time;
-(NSObject*) objectForKey:(NSString*)key;

@end
