//
//  TCScene.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/17.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------TCScene--------------------
 *  @desc 用于得出brother->father->i的结构化Scene (参考29069-todo3 & 686示图);
 */
@interface TCScene : NSObject

+(NSArray*) rGetSceneTree:(ReasonDemandModel*)demand;
+(NSArray*) hGetSceneTree:(HDemandModel*)demand;

@end
