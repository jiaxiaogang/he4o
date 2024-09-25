//
//  TCSolution.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------求解--------------------
 *  @注意:
 *      1. 取解决方案-不得脱离场景;
 *      2. 行为化过程-不得脱离场景;
 */
@interface TCSolution : NSObject

+(TCResult*) solutionV2:(TOModelBase*)endBranch;

@end
