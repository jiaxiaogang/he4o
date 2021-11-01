//
//  VRSReasonResultModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/10/29.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------VRS评价结果模型--------------------
 *  @version
 *      2021.11.01: 废弃pPorts,因为修正目标,不再从pPorts中直接取最近的值 (参考24103-BUG2);
 *      2021.11.01: 将pPercent和margin集成 (参考24103-BUG1);
 */
@interface VRSReasonResultModel : NSObject

+(VRSReasonResultModel*) newWithBaseFo:(AIFoNodeBase*)baseFo pScore:(double)pScore sScore:(double)sScore;
@property (strong, nonatomic) AIFoNodeBase *baseFo; //保留baseFo;
@property (assign, nonatomic) double pScore;        //最终得分;
@property (assign, nonatomic) double sScore;        //最终得分;

@property (assign, nonatomic) double score;         //评分 (-1到1,<0为S,>0为P);
@property (assign, nonatomic) double stablity;      //稳定度 (0-1);

@end
