//
//  AIMatchFoModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/23.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AIMatchFoModel.h"

@implementation AIMatchFoModel

+(AIMatchFoModel*) newWithMatchFo:(AIFoNodeBase*)matchFo matchFoValue:(CGFloat)matchFoValue cutIndex:(NSInteger)cutIndex{
    AIMatchFoModel *model = [[AIMatchFoModel alloc] init];
    model.matchFo = matchFo;
    model.matchFoValue = matchFoValue;
    model.cutIndex = cutIndex;
    return model;
}

@end
