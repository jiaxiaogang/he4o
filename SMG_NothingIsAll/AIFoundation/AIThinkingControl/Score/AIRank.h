//
//  AIRank.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/12/19.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < 综合竞争 >
//MARK:===============================================================
@interface AIRank : NSObject

/**
 *  MARK:--------------------概念识别综合排名 (参考2722d-方案2-todo2)--------------------
 */
+(NSArray*) recognitonAlgRank:(NSArray*)matchAlgModels;

/**
 *  MARK:--------------------时序识别综合排名 (参考2722d-方案2-todo2 & 2722f-todo14)--------------------
 */
+(NSArray*) recognitonFoRank:(NSArray*)matchFoModels;

/**
 *  MARK:--------------------S综合排名--------------------
 */
+(NSArray*) solutionFoRankingV2:(NSArray*)solutionModels needBack:(BOOL)needBack fromSlow:(BOOL)fromSlow;

/**
 *  MARK:--------------------求解S前段排名 (参考28083-方案2 & 28084-5)--------------------
 */
+(NSArray*) solutionFrontRank:(NSArray*)solutionModels;

@end
