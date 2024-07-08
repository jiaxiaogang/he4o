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
+(NSArray*) recognitionAlgRank:(NSArray*)matchAlgModels;

/**
 *  MARK:--------------------时序识别综合排名 (参考2722d-方案2-todo2 & 2722f-todo14)--------------------
 */
+(NSArray*) recognitionFoRank:(NSArray*)matchFoModels;

/**
 *  MARK:--------------------S综合排名--------------------
 */
+(NSArray*) cansetsRankingV4:(NSArray*)cansets zonHeScoreBlock:(double(^)(TOFoModel *obj))zonHeScoreBlock debugMode:(BOOL)debugMode;

@end
