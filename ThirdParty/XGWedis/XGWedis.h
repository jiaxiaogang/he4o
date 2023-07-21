//
//  XGWedis.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/5/7.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^XGWedisSaveBlock)(id dic);

/**
 *  MARK:--------------------XGWedis--------------------
 *  说明:
 *  1. XGWedis用来做异步持久化;
 *  2. 目前每10s持久化一次;
 *  3. XGWedis支持delegate/observer/block三种持久化方式;
 *  @version
 *      2023.07.20: 废弃delegate和广播方式持久化 (也没用,留着费眼看代码);
 */
@interface XGWedis : NSObject

+(XGWedis*) sharedInstance;

/**
 *  MARK:--------------------setObject--------------------
 *  @param obj : 数据
 *  @param key : 唯一识别符
 */
-(void) setObject:(NSObject*)obj forKey:(NSString*)key;
-(id) objectForKey:(NSString*)key;

/**
 *  MARK:--------------------指定持久化saveBlock--------------------
 */
-(void)setSaveBlock:(XGWedisSaveBlock)saveBlock;

/**
 *  MARK:--------------------清空--------------------
 */
-(void) clear;

/**
 *  MARK:--------------------记忆长度--------------------
 */
-(NSInteger) count;

/**
 *  MARK:--------------------调用一次保存--------------------
 */
-(void) save;

@end
