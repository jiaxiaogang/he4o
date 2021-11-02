//
//  VRSModelBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/2.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------VRS评价器模型--------------------
 *  @desc
 *      1. 用于VRS评价结果模型;
 *      2. 用于VRS修正目标模型;
 */
@interface VRSModelBase : NSObject

@property (strong, nonatomic) AIFoNodeBase *baseFo; //保留baseFo;
@property (assign, nonatomic) double pScore;        //最终得分;
@property (assign, nonatomic) double sScore;        //最终得分;

@property (assign, nonatomic) double score;         //评分 (-1到1,<0为S,>0为P);
@property (assign, nonatomic) double stablity;      //稳定度 (0-1);

@end
