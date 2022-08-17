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
@property (assign, nonatomic) BOOL stopThink;   //强行停止思维工作

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

/**
 *  MARK:--------------------消耗活跃度--------------------
 */
-(void) updateEnergyDelta:(CGFloat)delta;

/**
 *  MARK:--------------------设新活跃度--------------------
 *  @desc 只有当新的更大时,才有效;
 */
-(void) updateEnergyValue:(CGFloat)value;
-(BOOL) energyValid;

//MARK:===============================================================
//MARK:                     < 操作计数 >
//MARK:===============================================================
-(void) updateOperCount:(NSString*)operater;
-(long long) getOperCount;

//MARK:===============================================================
//MARK:                     < 循环Id >
//MARK:===============================================================
-(void) updateLoopId;
-(long long) getLoopId;

//MARK:===============================================================
//MARK:                     < 清思维 >
//MARK:===============================================================
-(void) clear;

@end
