//
//  TOValueModel.m
//  SMG_NothingIsAll
//
//  Created by air on 2020/5/28.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "TOValueModel.h"

@interface TOValueModel ()

@property (strong, nonatomic) NSMutableArray *actionFoModels;

@end

@implementation TOValueModel

- (NSMutableArray *)actionFoModels {
    if (_actionFoModels == nil) {
        _actionFoModels = [[NSMutableArray alloc] init];
    }
    return _actionFoModels;
}

@end
