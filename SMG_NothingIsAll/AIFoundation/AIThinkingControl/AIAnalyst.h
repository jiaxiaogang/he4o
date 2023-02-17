//
//  AIAnalyst.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/6/10.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------分析师--------------------
 *  @desc 用于核验比对cansetFo与protoFo,并给出分析报告;
 *  @version
 *      2019.xx.xx: PM算法 (参考手稿PM相关涉及);
 *      2022.05.xx: 比对算法 (参考26122);
 *      2022.11.30: 在前段时间改indexDic和matchValue复用后,此处TI调用alg相似度早已废弃,今天彻底删掉它的代码;
 *      2023.02.17: 将时序比对移到TCSolutionUtil中 (因为它现在其实就是个获取SolutionModel的算法,而不是比对了);
 */
@interface AIAnalyst : NSObject

/**
 *  MARK:--------------------对比canset和match (复用indexDic和相似度)--------------------
 */
+(CGFloat) compareCansetAlg:(NSInteger)matchIndex cansetFo:(AIKVPointer*)cansetFo_p matchFo:(AIKVPointer*)matchFo_p;

//MARK:===============================================================
//MARK:                     < Value相近度 (由TI调用) >
//MARK:===============================================================

/**
 *  MARK:--------------------比对稀疏码相近度--------------------
 */
+(CGFloat) compareCansetValue:(AIKVPointer*)cansetV_p protoValue:(AIKVPointer*)protoV_p;

@end
