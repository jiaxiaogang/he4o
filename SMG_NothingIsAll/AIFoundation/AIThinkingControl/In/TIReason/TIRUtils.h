//
//  TIRUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/1/10.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIRUtils : NSObject

/**
 *  MARK:--------------------时序识别之: protoFo&assFo匹配判断--------------------
 */
+(void) TIR_Fo_CheckFoValidMatch:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo checkItemValid:(BOOL(^)(AIKVPointer *itemAlg,AIKVPointer *assAlg))checkItemValid success:(void(^)(NSInteger lastAssIndex,CGFloat matchValue))success;


//MARK:===============================================================
//MARK:                     < 概念局部匹配 >
//MARK:===============================================================

/**
 *  MARK:--------------------概念局部匹配--------------------
 *  @param except_ps : 排除_ps; (如:同一批次输入的概念组,不可用来识别自己)
 */
+(void) partMatching_Alg:(AIAlgNodeBase*)algNode isMem:(BOOL)isMem except_ps:(NSArray*)except_ps complete:(void(^)(AIAlgNodeBase *matchAlg,NSArray *partAlg_ps))complete;


//MARK:===============================================================
//MARK:                     < 模糊匹配 >
//MARK:===============================================================
//+(NSArray*) matchAlg2FuzzyAlgV2:(AIAlgNodeBase*)protoAlg matchAlg:(AIAlgNodeBase*)matchAlg except_ps:(NSArray*)except_ps;


//MARK:===============================================================
//MARK:                     < 内类比 >
//MARK:===============================================================

//内类比构建抽象时序
+(AINetAbsFoNode*)createInnerAbsFo:(AIAlgNodeBase*)backConAlg rangeAlg_ps:(NSArray*)rangeAlg_ps conFo:(AIFoNodeBase*)conFo ds:(NSString*)ds;

//MARK:===============================================================
//MARK:                     < 输入概念判断 >
//MARK:===============================================================

/**
 *  MARK:--------------------输入概念是否老节点--------------------
 *  @desc 目前以其被时序引用数>0,为判断基准;
 */
+(BOOL) inputAlgIsOld:(AIAlgNodeBase*)inputAlg;

@end
