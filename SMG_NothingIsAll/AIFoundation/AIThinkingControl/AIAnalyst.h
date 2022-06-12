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
 *  @desc 用于核验对比cansetFo与protoFo,并给出分析报告;
 *  @version
 *      2019.xx.xx: PM算法 (参考手稿PM相关涉及);
 *      2022.05.xx: 比对算法 (参考26122);
 */
@interface AIAnalyst : NSObject

/**
 *  MARK:--------------------分析R任务的cansetFo--------------------
 */
+(AISolutionModel*) compareRCansetFo:(AIKVPointer*)cansetFo_p pFo:(AIMatchFoModel*)pFo demand:(ReasonDemandModel*)demand;

/**
 *  MARK:--------------------分析H任务的cansetFo--------------------
 */
+(AISolutionModel*) compareHCansetFo:(AIKVPointer*)cansetFo_p targetFo:(TOFoModel*)targetFoM;

/**
 *  MARK:--------------------对比两个概念匹配度--------------------
 */
+(CGFloat) compareCansetAlg:(AIKVPointer*)cansetAlg_p protoAlg:(AIKVPointer*)protoAlg_p;

/**
 *  MARK:--------------------对比稀疏码相近度--------------------
 */
+(CGFloat) compareCansetValue:(AIKVPointer*)cansetV_p protoValue:(AIKVPointer*)protoV_p;

@end
