//
//  AIThinkOutReason.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIShortMatchModel;
@protocol AIThinkOutReasonDelegate <NSObject>

//更新思维活跃度
-(void) aiThinkOutReason_UpdateEnergy:(CGFloat)delta;
-(BOOL) aiThinkOutReason_EnergyValid;
//反思
-(AIShortMatchModel*) aiTOR_LSPRethink:(AIAlgNodeBase*)rtAlg rtFoContent_ps:(NSArray*)rtFoContent_ps;

@end

/**
 *  MARK:--------------------理性ThinkOut部分--------------------
 *  @desc 理性决策分为三种: (参考n17p14)
 *      1. 瞬时 (从TIR中传递过来的识别与预测等)
 *      2. 短时 (优先取内存网络)
 *      3. 长时 (以硬盘网络为根基)
 *
 *  @todo 可以根据此maxMatchValue匹配度,来做感性预测;
 *  @todo 对TOP的运作5个scheme做改动,以应用"激活"节点 (理性支持瞬时网络);
 *      1. 取demandManager中,首个任务,看是否与当前mv有匹配,并逐步进行匹配,(参考:n17p9/168_TOR代码实践示图);
 *      2. 参考n17p8 TOR模型; n17p9 代码实践示图, TOR通过,避免需求,找行为化,改变实;
 *      3. 如预测到车将撞到自己,去查避免被撞的方法;如,飞行改变距离,改变方向,改变车的尺寸,改变车的速度,改变红绿灯为红灯等方式;
 *      191121回执: 目前已在行为化中支持瞬时网络;但仅支持MC匹配;对于matchFo,matchMv这些并未支持;随后再思考是否需要;
 *  @todo 191121随后可以考虑,将foScheme也搬由TOP搬到TOR的行为化中;
 *
 */
@class AICMVNodeBase,AIAlgNodeBase,AIFoNodeBase,TOFoModel,AIShortMatchModel;
@interface AIThinkOutReason : NSObject

@property (weak, nonatomic) id<AIThinkOutReasonDelegate> delegate;


/**
 *  MARK:--------------------FromTIR主入口--------------------
 */
-(void) commitFromTIR:(AIShortMatchModel*)shortMatchModel;

/**
 *  MARK:--------------------FromTOP主入口--------------------
 *  @desc 做理性行为化
 */
-(void) commitFromTOP_Convert2Actions:(TOFoModel*)foModel;

/**
 *  MARK:--------------------FromTOP的MvScheme失败入口--------------------
 *  @desc 做反射反应
 */
-(void) commitFromTOP_ReflexOut;

@end
