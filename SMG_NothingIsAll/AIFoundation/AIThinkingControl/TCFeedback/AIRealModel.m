//
//  AIRealModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2024.04.10.
//  Copyright © 2024 XiaoGang. All rights reserved.
//

#import "AIRealModel.h"

@implementation AIRealModel

-(NSMutableArray *)realOrders {
    if (!_realOrders) _realOrders = [[NSMutableArray alloc] init];
    return _realOrders;
}

-(NSMutableDictionary *)realSceneIndexDic {
    if (!_realSceneIndexDic) _realSceneIndexDic = [[NSMutableDictionary alloc] init];
    return _realSceneIndexDic;
}

@end
