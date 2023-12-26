//
//  MapModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/12/26.
//  Copyright © 2023 XiaoGang. All rights reserved.
//

#import "MapModel.h"

@implementation MapModel

+(MapModel*) newWithV1:(id)v1 v2:(id)v2 {
    MapModel *result = [[MapModel alloc] init];
    result.v1 = v1;
    result.v2 = v2;
    return result;
}

@end
