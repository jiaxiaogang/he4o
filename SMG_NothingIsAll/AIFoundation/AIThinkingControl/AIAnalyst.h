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
 */
@interface AIAnalyst : NSObject

//MARK:===============================================================
//MARK:                     < Fo相似度 (由TO调用) >
//MARK:===============================================================

/**
 *  MARK:--------------------分析R任务的cansetFo--------------------
 */
+(AISolutionModel*) compareRCansetFo:(AIKVPointer*)cansetFo_p pFo:(AIMatchFoModel*)pFo demand:(ReasonDemandModel*)demand;

/**
 *  MARK:--------------------分析H任务的cansetFo--------------------
 */
+(AISolutionModel*) compareHCansetFo:(AIKVPointer*)cansetFo_p targetFo:(TOFoModel*)targetFoM;


//MARK:===============================================================
//MARK:                     < Value相近度 (由TI调用) >
//MARK:===============================================================

/**
 *  MARK:--------------------比对稀疏码相近度--------------------
 */
+(CGFloat) compareCansetValue:(AIKVPointer*)cansetV_p protoValue:(AIKVPointer*)protoV_p;

@end
