//
//  TOModelBase.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/26.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"

@implementation TOModelBase

- (NSMutableArray *)except_ps{
    if (_except_ps == nil) {
        _except_ps = [[NSMutableArray alloc] init];
    }
    return _except_ps;
}

- (NSMutableArray *)subModels{
    if (_subModels == nil) {
        _subModels = [[NSMutableArray alloc] init];
    }
    return _subModels;
}

-(TOModelBase*) getCurSubModel{
    TOModelBase *maxModel = nil;
    for (TOModelBase *model in self.subModels) {
        if (maxModel == nil || maxModel.score < model.score) {
            maxModel = model;
        }
    }
    return maxModel;
}

@end
