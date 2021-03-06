//
//  AIThinkOutReason.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIShortMatchModel,DemandModel;
@protocol AIThinkOutReasonDelegate <NSObject>

//转移DemandModel子任务
-(void) aiTOR_MoveForDemand:(DemandModel*)demand;

@end

/**
 *  MARK:--------------------理性ThinkOut部分--------------------
 *  @desc 理性决策分为三种: (参考n17p14)
 *      1. 瞬时 (从TIR中传递过来的识别与预测等)
 *      2. 短时 (优先取内存网络)
 *      3. 长时 (以硬盘网络为根基)
 *  @desc 递归说明:
 *      1. 上级递归 (当FC-Failure时,各节点向上一宏观级递归begin);
 *      2. 本级递归 (当PM/反省类比等Failure时,各节点向本级递归begin);
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
@class AICMVNodeBase,AIAlgNodeBase,AIFoNodeBase,TOFoModel,AIShortMatchModel,DemandModel,ReasonDemandModel;
@interface AIThinkOutReason : NSObject

@property (weak, nonatomic) id<AIThinkOutReasonDelegate> delegate;

/**
 *  MARK:--------------------fromTO主入口--------------------
 */
-(void) reasonSubV4:(ReasonDemandModel*)demand;

/**
 *  MARK:--------------------FromTOP主入口--------------------
 *  @desc 做理性行为化
 */
-(void) commitReasonPlus:(TOFoModel*)outModel mModel:(AIShortMatchModel*)mModel;
-(void) commitReasonSub:(TOFoModel*)foModel demand:(ReasonDemandModel*)demand;
-(void) commitPerceptSub:(TOFoModel*)outModel;
-(void) commitPerceptPlus:(AIFoNodeBase*)matchFo plusFo:(AIFoNodeBase*)plusFo subFo:(AIFoNodeBase*)subFo checkFo:(AIFoNodeBase*)checkFo complete:(void(^)(BOOL actSuccess,NSArray *acts))complete;

/**
 *  MARK:--------------------FromTOP的MvScheme失败入口--------------------
 *  @desc 做反射反应
 */
-(void) commitFromTOP_ReflexOut;

/**
 *  MARK:--------------------尝试输出信息--------------------
 *  @param outArr : orders里筛选出来的algNode组;
 *
 *  三种输出方式:
 *  1. 反射输出 : reflexOut
 *  2. 激活输出 : absNode信息无conPorts方向的outPointer信息时,将absNode的宏信息尝试输出;
 *  3. 经验输出 : expOut指在absNode或conPort方向有outPointer信息;
 *
 *  功能: 将行为概念组成的长时序,转化为真实输出;
 *  1. 找到行为的具象;
 *  2. 正式执行行为 (小脑);
 */
-(void) dataOut_ActionScheme:(NSArray*)outArr;

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 决策--------------------
 */
-(BOOL) tor_OPushM:(DemandModel*)demand latestMModel:(AIShortMatchModel*)latestMModel;

@end
