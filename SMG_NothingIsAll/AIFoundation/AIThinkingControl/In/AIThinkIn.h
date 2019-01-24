//
//  AIThinkIn.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/24.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIPointer;
@protocol AIThinkInDelegate <NSObject>

-(void) aiThinkIn_AddToShortMemory:(NSArray*)algNode_ps;        //将祖母节点添加到瞬时记忆
-(AIFrontOrderNode*) aiThinkIn_CreateCMVModel:(NSArray*)algsArr;//构建cmv模型;
-(void) aiThinkIn_ToThinkOut;                                   //由in转换到out;
-(void) aiThinkIn_UpdateEnergy:(NSInteger)delta;                //更新思维能量值;
-(BOOL) aiThinkIn_EnergyValid;                                  //能量值是否>0;
-(void) aiThinkIn_UpdateCMVCache:(NSString*)algsType urgentTo:(NSInteger)urgentTo delta:(NSInteger)delta order:(NSInteger)order;                    //更新demandManager

@end


/**
 *  MARK:--------------------输入思维控制器--------------------
 *  皮层算法调用,类比,规律,抽象,构建,认知,学习,激活思维,发现需求等;
 */
@interface AIThinkIn : NSObject

@property (weak, nonatomic) id<AIThinkInDelegate> delegate;

/**
 *  MARK:--------------------数据输入--------------------
 */
-(void) dataIn:(NSObject*)algsModel;


@end
