//
//  AICansetModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/5/27.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "AICansetModel.h"

@implementation AICansetModel

+(AICansetModel*) newWithCansetFo:(AIKVPointer*)cansetFo
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
             basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel {
    AICansetModel *model = [[AICansetModel alloc] init];
    model.cansetFo = cansetFo;
    model.sceneFo = sceneFo;
    model.basePFoOrTargetFoModel = basePFoOrTargetFoModel;
    model.protoFrontIndexDic = protoFrontIndexDic;
    model.matchFrontIndexDic = matchFrontIndexDic;
    model.frontMatchValue = frontMatchValue;
    model.frontStrongValue = frontStrongValue;
    model.midEffectScore = midEffectScore;
    model.midStableScore = midStableScore;
    model.backMatchValue = backMatchValue;
    model.backStrongValue = backStrongValue;
    model.cutIndex = cutIndex;
    model.targetIndex = targetIndex;
    return model;
}

@end
