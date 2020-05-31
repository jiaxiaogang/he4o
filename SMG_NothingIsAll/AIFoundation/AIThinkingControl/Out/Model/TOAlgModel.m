//
//  TOAlgModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/12.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOAlgModel.h"
#import "TOFoModel.h"

@interface TOAlgModel()

@property (strong, nonatomic) NSMutableArray *actionFoModels;
@property (strong, nonatomic) NSMutableArray *subModels;

@end

@implementation TOAlgModel

+(TOAlgModel*) newWithAlg_p:(AIKVPointer*)alg_p group:(id<ISubModelsDelegate>)group{
    TOAlgModel *result = [[TOAlgModel alloc] initWithContent_p:alg_p];
    result.status = TOModelStatus_Runing;
    if (group) [group.subModels addObject:result];
    result.baseOrGroup = group;
    return result;
}

-(NSMutableArray *)actionFoModels{
    if (_actionFoModels == nil) {
        _actionFoModels = [[NSMutableArray alloc] init];
    }
    return _actionFoModels;
}

-(NSMutableArray *)subModels {
    if (_subModels == nil) {
        _subModels = [[NSMutableArray alloc] init];
    }
    return _subModels;
}

@end
