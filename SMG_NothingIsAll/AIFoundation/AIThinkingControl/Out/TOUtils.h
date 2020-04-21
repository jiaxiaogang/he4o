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
 *  MARK:--------------------获取节点所有Plus的所有稀疏码--------------------
 */
+(NSArray*) getAlgAllPlusAllValue_ps:(AIAlgNodeBase*)alg;

@end
