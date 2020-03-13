//
//  HeLog.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/3/12.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTime @"t"
#define kLog @"l"
#define kFolderName @"helog"
#define kFileName @"datas"

/**
 *  MARK:--------------------XGWedis--------------------
 *  说明:
 *  1. XGWedis用来做异步持久化;
 *  2. 目前每10s持久化一次;
 *  3. XGWedis支持delegate/observer/block三种持久化方式;
 *
 */
@interface HeLogModel : NSObject

/**
 *  MARK:--------------------addLog--------------------
 */
-(NSDictionary*) addLog:(NSString*)log;
-(NSArray*) getDatas;

/**
 *  MARK:--------------------filter--------------------
 *  @param startT : 格式为yyyyMMddHHmmssSSS 如: 20200312055959000
 */
-(NSArray*) filterByTime:(NSString*)startT endT:(NSString*)endT;
-(NSArray*) filterByKeyword:(NSString*)keyword;

@end
