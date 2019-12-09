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

-(void) aiThinkIn_AddToShortMemory:(NSArray*)algNode_ps;        //将概念节点添加到瞬时记忆
-(NSArray*) aiThinkIn_GetShortMemory;
-(AIFrontOrderNode*) aiThinkIn_CreateCMVModel:(NSArray*)algsArr;//构建cmv模型;

/**
 *  MARK:--------------------感性mv输入处理--------------------
 *  @param cmvNode  : 要处理的mvNode
 *  @desc 功能说明:
 *      1. 更新energy值
 *      2. 更新需求池
 *      3. 进行dataOut决策行为化;
 */
-(void) aiThinkIn_CommitPercept:(AICMVNodeBase*)cmvNode;

/**
 *  MARK:--------------------理性输入识别处理--------------------
 *  联想网络杏仁核得来的则false;
 */
-(void) aiThinkIn_Commit2TC:(AIShortMatchModel*)shortMatchModel;
-(void) aiThinkIn_UpdateEnergy:(CGFloat)delta;                //更新思维能量值;
-(BOOL) aiThinkIn_EnergyValid;                                  //能量值是否>0;

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


//MARK:===============================================================
//MARK:                     < FromTOR >
//MARK:===============================================================
/**
 *  MARK:--------------------TOR反思调用--------------------
 */
-(AIShortMatchModel*) dataInFromTORLSPRethink:(AIAlgNodeBase*)rtAlg rtFoContent_ps:(NSArray*)rtFoContent_ps;

@end
