//
//  AISolutionModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/5/27.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "AISolutionModel.h"

@implementation AISolutionModel

+(AISolutionModel*) newWithCansetFo:(AIKVPointer*)cansetFo protoFo:(AIKVPointer*)protoFo matchValue:(CGFloat)matchValue cutIndex:(NSInteger)cutIndex{
    AISolutionModel *model = [[AISolutionModel alloc] init];
    model.cansetFo = cansetFo;
    model.protoFo = protoFo;
    model.matchValue = matchValue;
    model.cutIndex = cutIndex;
    return model;
}

@end
