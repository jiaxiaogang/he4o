//
//  TOInputAlgModel.m
//  SMG_NothingIsAll
//
//  Created by air on 2020/6/30.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "TOInputAlgModel.h"
#import "TOFoModel.h"

@interface TOInputAlgModel()

@property (strong, nonatomic) NSMutableArray *actionFoModels;
@property (strong, nonatomic) NSMutableArray *subModels;

@end

@implementation TOInputAlgModel

+(TOInputAlgModel*) newWithAlg_p:(AIKVPointer*)alg_p group:(id<ISubModelsDelegate>)group{
    TOInputAlgModel *result = [[TOInputAlgModel alloc] initWithContent_p:alg_p];
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
