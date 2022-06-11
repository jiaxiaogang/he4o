//
//  AISolutionModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/5/27.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------单条S候选集与proto对比结果模型--------------------
 */
@interface AISolutionModel : NSObject

/**
 *  MARK:--------------------newWith--------------------
 *  @desc
 *      1. R任务时,backMatchValue和targetIndex两个参数无用;
 *      2. H任务时,所有参数都有效;
 *  @param ptFo : R任务时为pFo,H任务时为targetFo;
 */
+(AISolutionModel*) newWithCansetFo:(AIKVPointer*)cansetFo ptFo:(AIKVPointer*)ptFo
                    frontMatchValue:(CGFloat)frontMatchValue backMatchValue:(CGFloat)backMatchValue
                           cutIndex:(NSInteger)cutIndex targetIndex:(NSInteger)targetIndex;

@property (strong, nonatomic) AIKVPointer *cansetFo;    //候选集fo;
@property (strong, nonatomic) AIKVPointer *ptFo;        //R任务时为pFo,H任务时为targetFo;

@property (assign, nonatomic) CGFloat frontMatchValue;  //前段(已发生部分)匹配度 (相近度和/已发生数);
@property (assign, nonatomic) CGFloat backMatchValue;   //后段匹配度 (R时为1,H时为目标帧相近度);

@property (assign, nonatomic) CGFloat stableScore;      //中段稳定性分 (用于慢思考);
@property (assign, nonatomic) CGFloat effectScore;      //整体有效率分 (用于快思考);

@property (assign, nonatomic) NSInteger cutIndex;       //已发生截点 (含cutIndex也已发生);
@property (assign, nonatomic) NSInteger targetIndex;    //目标index (R时为cansetFo.count,H时为目标帧下标);

@end
