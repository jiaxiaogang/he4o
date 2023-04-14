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
 */
+(AISolutionModel*) newWithCansetFo:(AIKVPointer*)cansetFo
                            sceneFo:(AIKVPointer*)sceneFo
                 protoFrontIndexDic:(NSDictionary *)protoFrontIndexDic
                 matchFrontIndexDic:(NSDictionary *)matchFrontIndexDic
                    frontMatchValue:(CGFloat)frontMatchValue
                   frontStrongValue:(CGFloat)frontStrongValue
                     midEffectScore:(CGFloat)midEffectScore
                     midStableScore:(CGFloat)midStableScore
                       backIndexDic:(NSDictionary*)backIndexDic
                     backMatchValue:(CGFloat)backMatchValue
                    backStrongValue:(CGFloat)backStrongValue
                           cutIndex:(NSInteger)cutIndex
                        targetIndex:(NSInteger)targetIndex
             basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel;

@property (strong, nonatomic) AIKVPointer *cansetFo;    //候选集fo;
@property (strong, nonatomic) AIKVPointer *sceneFo;
@property (strong, nonatomic) id basePFoOrTargetFoModel;//R任务时为pFoModel,H任务时为targetFoModel;

//MARK:===============================================================
//MARK:                     < 前段部分 >
//MARK:===============================================================

@property (strong, nonatomic) NSDictionary *protoFrontIndexDic;//前段canset与proto的映射字典 (canset是抽象);
@property (strong, nonatomic) NSDictionary *matchFrontIndexDic;//前段canset与scene的映射字典 (scene是抽象);

/**
 *  MARK:--------------------前段匹配度--------------------
 *  @desc 目前其表示cansetFo与protoFo的前段匹配度;
 *  @version
 *      2023.01.13: 求乘版: 用canset前段和match的帧映射计算前段匹配度 (参考28035-todo3);
 *      2023.02.18: AIRank细分版: 用canset前段和proto的帧映射计算前段匹配度 (参考28083-方案2);
 */
@property (assign, nonatomic) CGFloat frontMatchValue;

/**
 *  MARK:--------------------前段强度竞争值 (参考28083-方案2)--------------------
 *  @desc cansetFo的前段部分的refStrong平均强度;
 */
@property (assign, nonatomic) CGFloat frontStrongValue;


//MARK:===============================================================
//MARK:                     < 后段部分 >
//MARK:===============================================================
@property (assign, nonatomic) CGFloat backMatchValue;   //后段匹配度 (R时为1,H时为目标帧相近度) (参考28092-todo1);
@property (assign, nonatomic) CGFloat backStrongValue;  //后段强度值 (R时为0,H时为目标帧conStrong强度) (参考28092-todo2);
@property (strong, nonatomic) NSDictionary *backIndexDic;//后段canset与match的映射字典 (match是抽象);

@property (assign, nonatomic) CGFloat midStableScore;    //中段稳定性分;
@property (assign, nonatomic) CGFloat midEffectScore;    //整体有效率分;

@property (assign, nonatomic) NSInteger cutIndex;       //已发生截点 (含cutIndex也已发生);
@property (assign, nonatomic) NSInteger targetIndex;    //目标index (R时为cansetFo.count,H时为目标帧下标);

@end
