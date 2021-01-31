//
//  AIShortMatchModel_Simple.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/8/20.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------短时记忆模型 (简化版)--------------------
 */
@interface AIShortMatchModel_Simple : NSObject

@property (strong, nonatomic) AIKVPointer *alg_p;       //概念
@property (assign, nonatomic) NSTimeInterval inputTime; //概念输入时间 (单位:s)

@end
