//
//  AISolutionModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/5/27.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "AISolutionModel.h"

@implementation AISolutionModel

+(AISolutionModel*) newWithCansetFo:(AIKVPointer*)cansetFo maskFo:(AIKVPointer*)maskFo
                    frontMatchValue:(CGFloat)frontMatchValue backMatchValue:(CGFloat)backMatchValue
                           cutIndex:(NSInteger)cutIndex targetIndex:(NSInteger)targetIndex{
    AISolutionModel *model = [[AISolutionModel alloc] init];
    model.cansetFo = cansetFo;
    model.maskFo = maskFo;
    model.frontMatchValue = frontMatchValue;
    model.backMatchValue = backMatchValue;
    model.cutIndex = cutIndex;
    model.targetIndex = targetIndex;
    return model;
}

@end
