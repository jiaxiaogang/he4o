//
//  AIAnalogy.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/3/20.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------类比器--------------------
 *  @desc
 *      1. 外类比 (复用方法)
 *      2. 内类比 (主入口)
 *      3. 反馈类比 (主入口)
 *      4. 反省类比 (主入口)
 *  @callers
 *      1. InReasonSame: 调用内类比
 *      2. InPerceptSame: 调用正向反馈外类比
 *      3. InPerceptDiff: 调用反向反馈外类比
 *      4. InReasonDiff: 调用InRethink类比
 *      5. Out三种ActYes: 调用OutRethink类比
 *  @version
 *      2021.12.26: 仅留下外类比,其它全废弃删掉 (参考Note24-TC新螺旋架构整理);
 */

//MARK:===============================================================
//MARK:                     < Analogy类比 >
//MARK:===============================================================
@interface AIAnalogy : NSObject

+(AINetAbsFoNode*) analogyOutside:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo type:(AnalogyType)type createAbsAlgBlock:(void(^)(AIAlgNodeBase *createAlg,NSInteger foIndex,NSInteger assFoIndex))createAbsAlgBlock;

@end


//MARK:===============================================================
//MARK:                     < 反馈类比 >
//MARK:===============================================================
@interface AIAnalogy (Feedback)

/**
 *  MARK:--------------------正向反馈外类比--------------------
 *  @desc 由TIP调用,执行条件为:当imv与预测mv相符时,执行类比;
 *  @desc 如: (距20,经233) 与 (距20,经244) 可类比为: (距20)->{mv};
 *  @param shortFo : 传瞬时记忆的protoFo;
 */
+(void) analogy_Feedback_Same:(AIFoNodeBase*)matchFo shortFo:(AIFoNodeBase*)shortFo;

@end
