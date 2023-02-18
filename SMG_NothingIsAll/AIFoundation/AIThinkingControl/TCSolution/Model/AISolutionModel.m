//
//  AISolutionModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/5/27.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "AISolutionModel.h"

@implementation AISolutionModel

+(AISolutionModel*) newWithCansetFo:(AIKVPointer*)cansetFo
                 protoFrontIndexDic:(NSDictionary *)protoFrontIndexDic
                 matchFrontIndexDic:(NSDictionary *)matchFrontIndexDic
                    frontMatchValue:(CGFloat)frontMatchValue
                   frontStrongValue:(CGFloat)frontStrongValue
                     backMatchValue:(CGFloat)backMatchValue
                           cutIndex:(NSInteger)cutIndex
                        targetIndex:(NSInteger)targetIndex
             basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel {
    AISolutionModel *model = [[AISolutionModel alloc] init];
    model.cansetFo = cansetFo;
    model.basePFoOrTargetFoModel = basePFoOrTargetFoModel;
    model.protoFrontIndexDic = protoFrontIndexDic;
    model.matchFrontIndexDic = matchFrontIndexDic;
    model.frontMatchValue = frontMatchValue;
    model.frontStrongValue = frontStrongValue;
    model.backMatchValue = backMatchValue;
    model.cutIndex = cutIndex;
    model.targetIndex = targetIndex;
    return model;
}

@end
