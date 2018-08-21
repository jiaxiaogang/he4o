//
//  MVCacheModel.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/2.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "MVCacheModel.h"
#import "ExpCacheModel.h"

@implementation MVCacheModel

-(NSInteger)order{
    _order = _order;//TODO:>>>>>进行时间衰减
    return _order;
}

-(NSMutableArray*) expCache{
    if (_expCache == nil) {
        _expCache = [[NSMutableArray alloc] init];
    }
    return _expCache;
}

-(void) addExpCacheModel:(MindHappyType)type urgentTo:(NSInteger)urgentTo outArr:(NSArray*)outArr exp_p:(AIPointer*)exp_p{
    ExpCacheModel *expModel = [[ExpCacheModel alloc] init];
    expModel.outArr = outArr;
    if (type == MindHappyType_Yes) {
        expModel.score = (CGFloat)urgentTo / 2.0f;
    }else if (type == MindHappyType_No){
        expModel.score = -(CGFloat)urgentTo / 2.0f;
    }
    expModel.exp_p = exp_p;
    [self.expCache addObject:expModel];
}

@end
