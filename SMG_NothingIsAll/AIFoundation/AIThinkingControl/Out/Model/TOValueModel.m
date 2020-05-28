//
//  TOValueModel.m
//  SMG_NothingIsAll
//
//  Created by air on 2020/5/28.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "TOValueModel.h"
#import "TOAlgModel.h"

@interface TOValueModel ()

@property (strong, nonatomic) NSMutableArray *actionFoModels;

@end

@implementation TOValueModel

+(TOValueModel*) newWithSValue:(AIKVPointer*)sValue_p pValue:(AIKVPointer*)pValue_p parent:(TOAlgModel*)parent{
    TOValueModel *result = [[TOValueModel alloc] initWithContent_p:pValue_p];
    result.curValue_p = sValue_p;
    if (parent) [parent.subModels addObject:result];
    return result;
}

- (NSMutableArray *)actionFoModels {
    if (_actionFoModels == nil) {
        _actionFoModels = [[NSMutableArray alloc] init];
    }
    return _actionFoModels;
}

@end
