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
    return [self newWithV1:v1 v2:v2 v3:nil];
}

+(MapModel*) newWithV1:(id)v1 v2:(id)v2 v3:(id)v3 {
    return [self newWithV1:v1 v2:v2 v3:v3 v4:nil];
}

+(MapModel*) newWithV1:(id)v1 v2:(id)v2 v3:(id)v3 v4:(id)v4 {
    MapModel *result = [[MapModel alloc] init];
    result.v1 = v1;
    result.v2 = v2;
    result.v3 = v3;
    result.v4 = v4;
    return result;
}

@end
