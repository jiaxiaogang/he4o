//
//  TOUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/2.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIAlgNodeBase;
@interface TOUtils : NSObject

/**
 *  MARK:--------------------找价值确切的具象概念--------------------
 *  @desc 时序的抽具象是价值确切的,而概念不是,所以本方法,在时序的具象指引下,找具象概念,以使概念也是价值确切的;
 *  @note 参考:18206示图;
 */
+(void) findConAlg_StableMV:(AIAlgNodeBase*)curAlg curFo:(AIFoNodeBase*)curFo itemBlock:(BOOL(^)(AIAlgNodeBase* validAlg))itemBlock;

/**
 *  MARK:--------------------判断mIsC--------------------
 *  @desc 从M向上,找匹配C,支持三层 (含本层):
 */
+(BOOL) mIsC:(AIAlgNodeBase*)m c:(AIAlgNodeBase*)c;

/**
 *  MARK:--------------------收集概念节点的稀疏码--------------------
 */
+(NSArray*) convertValuesFromAlg_ps:(NSArray*)alg_ps;

/**
 *  MARK:--------------------收集多层的absPorts--------------------
 *  @desc 从alg取指定type的absPorts,再从具象,从抽象,各取指定层absPorts,收集返回;
 *  @param conLayer : 从具象取几层 (不含当前层),一般取:1层当前层+1层具象层=共两层即可;
 */
+(NSArray*) collectAbsPs:(AINodeBase*)alg type:(AnalogyType)type conLayer:(NSInteger)conLayer absLayer:(NSInteger)absLayer;

@end
