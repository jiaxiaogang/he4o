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
#define kPath_HeLog @"helog"
#define kFile_HeLog @"datas"

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
 *  MARK:--------------------重加载--------------------
 */
-(void) reloadData;

/**
 *  MARK:--------------------addLog--------------------
 */
-(NSDictionary*) addLog:(NSString*)log;
-(NSArray*) getDatas;
-(void) clear;
-(NSInteger) count;

@end
