//
//  AIThinkOutFoModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/30.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkOutFoModel.h"

@implementation AIThinkOutFoModel

-(NSMutableArray *)algModels{
    if (!_algModels) {
        _algModels = [[NSMutableArray alloc] init];
    }
    return _algModels;
}

@end
