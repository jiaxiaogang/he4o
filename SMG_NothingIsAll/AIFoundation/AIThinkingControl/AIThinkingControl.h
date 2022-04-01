//
//  AIThinkingControl.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------思维控制器--------------------
 *  1. 主要负责思维 (前额叶) 功能;
 *  2. 次要负责分发激活等 (丘脑) 功能;
 */
@class ShortMatchManager,DemandManager;
@interface AIThinkingControl : NSObject

+(AIThinkingControl*) shareInstance;

/**
 *  MARK:--------------------当前能量值--------------------
 *  1. 激活: mv输入时激活;
 *  2. 消耗: 思维的循环中消耗;
 *      1. 构建"概念节点"消耗0.1;
 *      2. 构建"时序节点"消耗1;
 *
 *  3. 范围: 0-20;
 */
@property (assign, nonatomic) CGFloat energy;

//MARK:===============================================================
//MARK:                     < 数据输入 >
//MARK:===============================================================

/**
 *  MARK:--------------------流入input--------------------
 */
-(void) commitInput:(NSObject*)algsModel;
-(void) commitInputWithModels:(NSArray*)dics algsType:(NSString*)algsType;

/**
 *  MARK:--------------------输出的日志入网(输入小脑)--------------------
 *  @param outputModels : 输出内容(如:eat)
 *  注: 大脑为引,小脑为行
 */
-(void) commitOutputLog:(NSArray*)outputModels;


//MARK:===============================================================
//MARK:                     < 短时记忆 >
//MARK:===============================================================
-(ShortMatchManager*) inModelManager;
-(DemandManager*) outModelManager;


//MARK:===============================================================
//MARK:                     < 活跃度 >
//MARK:===============================================================
-(void) updateEnergy:(CGFloat)delta;
-(BOOL) energyValid;

//MARK:===============================================================
//MARK:                     < 操作计数 >
//MARK:===============================================================
-(void) updateOperCount;
-(long long) getOperCount;

@end
