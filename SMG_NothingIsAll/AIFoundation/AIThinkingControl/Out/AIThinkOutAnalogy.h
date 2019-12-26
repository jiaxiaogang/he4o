//
//  AIThinkOutAnalogy.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/12/26.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------ThinkOut类比器--------------------
 */
@interface AIThinkOutAnalogy : NSObject

/**
 *  MARK:--------------------MC类比--------------------
 *  @param complete : return mcs&ms&cs notnull
 *  @desc 缩写说明: m = matchAlg, c = curAlg, mcs = MCSame, ms = MSpecial, cs = CSpecial
 */
+(void) mcAnalogy:(AIAlgNodeBase*)mAlg cAlg:(AIAlgNodeBase*)cAlg complete:(void(^)(NSArray *mcs,NSArray *ms,NSArray *cs))complete;

@end
