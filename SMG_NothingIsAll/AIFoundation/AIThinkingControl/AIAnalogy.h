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


//+(void) analogyOutside:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo type:(AnalogyType)type createAbsAlgBlock:(void(^)(AIAlgNodeBase *createAlg,NSInteger foIndex,NSInteger assFoIndex))createAbsAlgBlock;


/**
 *  MARK:--------------------fo内类比 (内中有外,找不同算法)--------------------
 *  _param checkFo      : 要处理的fo.orders;
 *  _param canAssBlock  : energy判断器 (为null时,无限能量);
 *  _param updateEnergy : energy消耗器 (为null时,不消耗能量值);
 */
+(void) analogyInner:(AIShortMatchModel*)mModel;

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
+(void) analogy_ReasonRethink:(TOFoModel*)foModel cutIndex:(NSInteger)cutIndex type:(AnalogyType)type;

@end
