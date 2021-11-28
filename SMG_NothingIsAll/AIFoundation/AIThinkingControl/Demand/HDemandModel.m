//
//  HDemandModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "HDemandModel.h"

@implementation HDemandModel

+(HDemandModel*) newWithAlgModel:(TOAlgModel*)algModel{
    HDemandModel *result = [[HDemandModel alloc] init];
    result.algModel = algModel;
    return result;
}

@end
