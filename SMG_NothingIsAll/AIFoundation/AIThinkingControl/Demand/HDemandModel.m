//
//  HDemandModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "HDemandModel.h"

@implementation HDemandModel

+(HDemandModel*) newWithAlgModel:(TOAlgModel*)base{
    HDemandModel *result = [[HDemandModel alloc] init];
    result.baseOrGroup = base;
    [base.subModels addObject:result];
    return result;
}

@end
