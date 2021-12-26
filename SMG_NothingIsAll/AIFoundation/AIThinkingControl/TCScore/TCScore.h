//
//  TCScore.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/19.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------综合评分--------------------
 *  @todo
 *      2021.12.26: 支持多条hSolution共同行为化: hSolution执行完成时,它的baseRDemand可能完成了一定比率;
 *                  > 一条S未必全效,即只解决了一定率,此时还可以继续别的方案 (比如为了安全,即带枪又穿防弹衣);
 */
@interface TCScore : NSObject

+(void) score;

@end
