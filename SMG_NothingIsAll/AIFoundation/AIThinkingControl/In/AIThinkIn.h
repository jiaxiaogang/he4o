//
//  AIThinkIn.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/24.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIPointer,AICMVNodeBase;
@protocol AIThinkInDelegate <NSObject>

-(void) aiThinkIn_AddToShortMemory:(NSArray*)algNode_ps;        //将祖母节点添加到瞬时记忆
-(AIFrontOrderNode*) aiThinkIn_CreateCMVModel:(NSArray*)algsArr;//构建cmv模型;
-(void) aiThinkIn_CommitMvNode:(AICMVNodeBase*)cmvNode;         //提交mv进行需求处理;
-(void) aiThinkIn_UpdateEnergy:(NSInteger)delta;                //更新思维能量值;
-(BOOL) aiThinkIn_EnergyValid;                                  //能量值是否>0;

@end


/**
 *  MARK:--------------------输入思维控制器--------------------
 *  皮层算法调用,类比,规律,抽象,构建,认知,学习,激活思维,发现需求等;
 */
@interface AIThinkIn : NSObject

@property (weak, nonatomic) id<AIThinkInDelegate> delegate;

/**
 *  MARK:--------------------数据输入--------------------
 *  @param models : 多model (models仅含普通算法model -> 目前没有imv和普通信息掺杂在models中的情况;)
 */
-(void) dataInWithModels:(NSArray*)models;


/**
 *  MARK:--------------------数据输入--------------------
 *  说明: 单model (普通算法模型 或 imv模型)
 */
-(void) dataIn:(NSObject*)algsModel;


@end
