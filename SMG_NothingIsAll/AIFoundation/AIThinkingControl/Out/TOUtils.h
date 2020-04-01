//
//  TOUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/2.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOUtils : NSObject

/**
 *  MARK:--------------------打出MC调试日志--------------------
 *  @desc 缩写说明: m = matchAlg, c = curAlg, mcs = MCSame, ms = MSpecial, cs = CSpecial
 */
+(void) debugMC_Alg:(AIAlgNodeBase*)mAlg cAlg:(AIAlgNodeBase*)cAlg mcs:(NSArray*)mcs ms:(NSArray*)ms cs:(NSArray*)cs;

@end
