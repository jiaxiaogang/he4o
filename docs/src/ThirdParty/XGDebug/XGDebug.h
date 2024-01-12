//
//  XGDebug.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/4/23.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------整体模块Debug性能调试器--------------------
 *  @use 使用说明: 每条显示的用时为,当前条到下条执行间的代码用时;
 *  @callers 用于调试性能,是TCDebug工具的底层核心;
 *  @desc XGDebug主要关注整体性能的统计情况;
 *  @常用: 1. 常用于观察每个代码块在当前循环loopId内的性能,并可打印;
 *              > 使用方法1. AddDebugCodeBlock_Key(@"代码块KEY", @"步骤"); PrintDebugCodeBlock_Key(@"代码块KEY");
 *        2. 被用到DebugS()和DebugE(),用来长时间统计每个TC的执行性能情况;
 *  @特性: 1. 长时间整体统计;   2. 在TC中有S有E两个夹着;
 */
@class XGDebugModel;
@interface XGDebug : NSObject

+(XGDebug*) sharedInstance;

//MARK:===============================================================
//MARK:                     < IN >
//MARK:===============================================================

/**
 *  MARK:--------------------追加一条记录--------------------
 *  @param fileName : 调用者类名 (参考防重);
 *  @param suffix   : 调用者后辍 (参与防重);
 *  _param prefix   : 调用者前辍 (参考防重);
 *  @desc 参数说明: 一般容易写死判断匹配的作为前辍 (如FILENAME或LoopId),常变不易匹配的用作后辍(如代码块标识:"R1.1");
 */
-(void) debugModuleWithFileName:(NSString*)fileName suffix:(NSString*)suffix;
-(void) debugModuleWithPrefix:(NSString*)prefix suffix:(NSString*)suffix;

/**
 *  MARK:--------------------磁盘读写计数器--------------------
 *  @desc 每次磁盘读写操作时,调用DebugW或DebugR来计数+1;
 */
-(void) debugWrite;
-(void) debugRead;
-(NSMutableArray *)models; //notnull

//MARK:===============================================================
//MARK:                     < OUT >
//MARK:===============================================================

/**
 *  MARK:--------------------打印结果--------------------
 */
-(void) print:(NSString*)prefix rmPrefix:(NSString*)rmPrefix;

@end
