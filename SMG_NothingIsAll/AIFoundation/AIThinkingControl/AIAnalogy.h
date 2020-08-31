//
//  AIAnalogy.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/3/20.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < Analogy类比 >
//MARK:===============================================================
@class AIAbsAlgNode,AIAlgNode,AIShortMatchModel,TOFoModel;
@interface AIAnalogy : NSObject

/**
 *  MARK:--------------------fo外类比 (外中有内,找相同算法)--------------------
 *  @param canAssBlock      : energy判断器 (为null时,无限能量);
 *  @param updateEnergy     : energy消耗器 (为null时,不消耗能量值);
 *  @desc                   : orderSames用于构建absFo
 *  @callers
 *      1. analogy_Feedback_Same()  : 同向反馈类比
 *      2. analogyInner()           : 内类比
 *      3. reasonRethink()          : 反省类比
 *
 *  1. 连续信号中,找重复;(连续也是拆分,多事务处理的)
 *  2. 两条信息中,找交集;
 *  3. 在连续信号的处理中,实时将拆分单信号存储到内存区,并提供可检索等,其形态与最终存硬盘是一致的;
 *  4. 类比处理(瓜是瓜)
 *  注: 类比的处理,是足够细化的,对思维每个信号作类比操作;(而将类比到的最基本的结果,输出给thinking,以供为构建网络的依据,最终是以网络为目的的)
 *  注: 随后可以由一个sames改为多个sames并实时使用block抽象 (并消耗energy);
 */
+(void) analogyOutside:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy type:(AnalogyType)type;


/**
 *  MARK:--------------------fo内类比 (内中有外,找不同算法)--------------------
 *  _param checkFo      : 要处理的fo.orders;
 *  _param canAssBlock  : energy判断器 (为null时,无限能量);
 *  _param updateEnergy : energy消耗器 (为null时,不消耗能量值);
 */
+(void) analogyInner:(AIFoNodeBase*)protoFo matchAFo:(AIFoNodeBase*)matchAFo;

@end


//MARK:===============================================================
//MARK:                     < 反馈类比 >
//MARK:===============================================================
@interface AIAnalogy (Feedback)

/**
 *  MARK:--------------------反馈类比_反向--------------------
 *  @callers : 由TIP调用;
 *  @param shortFo  : 在TIP中,输入mv,新生成的protoFo;
 *  @param mModel   : 在上一桢的识别预测模型;
 *  @desc
 *      1. 执行条件: 当imv与预测mv不符时,执行类比;
 *      2. 功能作用: 用类比的方式,分析出预测不符的原因(两种,见下),并抽象之;
 *      3. 不符的原因: a.该出现的未出现; b.不该出现的出现;
 */
+(void) analogy_Feedback_Diff:(AIShortMatchModel*)mModel shortFo:(AIFoNodeBase*)shortFo;

/**
 *  MARK:--------------------反馈类比_同向--------------------
 *  @desc 由TIP调用,执行条件为:当imv与预测mv相符时,执行类比;
 *  @desc 如: (距20,经233) 与 (距20,经244) 可类比为: (距20)->{mv};
 *  @param shortFo : 传瞬时记忆的protoFo(70%) 或 matchFo(30%);
 */
+(void) analogy_Feedback_Same:(AIShortMatchModel*)mModel shortFo:(AIFoNodeBase*)shortFo;

@end


//MARK:===============================================================
//MARK:                     < Out阶段类比 >
//MARK:===============================================================
@interface AIAnalogy (Out)

/**
 *  MARK:--------------------反省类比--------------------
 */
+(void) analogy_ReasonRethink:(TOFoModel*)foModel cutIndex:(NSInteger)cutIndex;

@end
