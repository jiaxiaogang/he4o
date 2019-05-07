//
//  XGWedis.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/5/7.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kXGWedisSaveObserver @"kXGWedisSaveObserver"    //xgWedis在Save时,会发送广播
typedef void (^XGWedisSaveBlock)(NSDictionary *dic);


@protocol XGWedisDelegate <NSObject>

-(void) xgWedis_Save:(NSDictionary*)dic;

@end

/**
 *  MARK:--------------------XGWedis--------------------
 *  说明:
 *  1. XGWedis用来做异步持久化;
 *  2. 目前每10s持久化一次;
 *  3. XGWedis支持delegate/observer/block三种持久化方式;
 *
 */
@interface XGWedis : NSObject

+(XGWedis*) sharedInstance;
@property (weak, nonatomic) id<XGWedisDelegate> delegate;

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


@end
