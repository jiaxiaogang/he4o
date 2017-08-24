//
//  AIThinkModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/8/24.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "ThinkModel.h"

@implementation ThinkModel

-(NSMutableArray *)lightModels{
    if (_lightModels == nil) {
        _lightModels = [[NSMutableArray alloc] init];
    }
    return _lightModels;
}

@end
