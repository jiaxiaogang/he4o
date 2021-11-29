//
//  AIThinkIn.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/24.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIPointer,AICMVNodeBase,AIFrontOrderNode,AIAlgNodeBase,AIShortMatchModel;
@protocol AIThinkInDelegate <NSObject>

-(AIFrontOrderNode*) aiThinkIn_CreateCMVModel:(NSArray*)algsArr inputTime:(NSTimeInterval)inputTime isMatch:(BOOL)isMatch;//构建cmv模型;

/**
 *  MARK:--------------------感性mv输入处理--------------------
 *  @desc 输入mv时调用,执行OPushM + 更新P任务池 + 执行P决策;
 *  @param cmvNode  : 要处理的mvNode
 *  @desc 功能说明:
 *      1. 更新energy值
 *      2. 更新需求池
 *      3. 进行dataOut决策行为化;
 */
-(void) aiThinkIn_CommitMv2TC:(AICMVNodeBase*)cmvNode;

/**
 *  MARK:--------------------理性noMv输入处理--------------------
 *  @desc 输入noMv时调用,执行OPushM + 更新R任务池 + 执行R决策;
 *  联想网络杏仁核得来的则false;
 */
-(void) aiThinkIn_CommitNoMv2TC:(AIShortMatchModel*)shortMatchModel;
-(NSArray*) aiThinkIn_getShortMatchModel;                           //获取mModel模型

@end


/**
 *  MARK:--------------------输入思维控制器--------------------
 *  皮层算法调用,类比,规律,抽象,构建,认知,学习,激活思维,发现需求等;
 */
@interface AIThinkIn : NSObject

@property (weak, nonatomic) id<AIThinkInDelegate> delegate;


//MARK:===============================================================
//MARK:                     < FromInput >
//MARK:===============================================================
/**
 *  MARK:--------------------数据输入--------------------
 *  @param dics : 多model (models仅含普通算法model -> 目前没有imv和普通信息掺杂在models中的情况;)
 *  步骤说明:
 *  1. 先构建具象parent节点,再构建抽象sub节点;
 *  2. 仅parent添加到瞬时记忆;
 *  3. 每个subAlg都要单独进行识别操作;
 *
 *  TODOWAIT:
 *  1. 默认为按边缘(ios的view层级)分组,随后可扩展概念内类比,按别的维度分组; 参考: n16p7
 */
-(void) dataInWithModels:(NSArray*)dics algsType:(NSString*)algsType;

/**
 *  MARK:--------------------数据输入--------------------
 *  说明: 单model (普通算法模型 或 imv模型)
 */
-(void) dataIn:(NSDictionary*)modelDic algsType:(NSString*)algsType;

/**
 *  MARK:--------------------行为输出转输入--------------------
 *  @desc 目前行为进行时序识别,也进行概念识别;
 */
-(void) dataInFromOutput:(NSArray*)outValue_ps;


//MARK:===============================================================
//MARK:                     < FromTOR >
//MARK:===============================================================

-(AIShortMatchModel*) dataInFromRethink:(TOFoModel*)toFoModel;

@end
