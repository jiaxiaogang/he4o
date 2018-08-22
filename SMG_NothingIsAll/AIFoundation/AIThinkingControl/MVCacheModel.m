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
        expModel.score = (CGFloat)urgentTo / 2.0f;//v2TODO:此处,暂时这么写score;但这是伪精度;
    }else if (type == MindHappyType_No){
        expModel.score = -(CGFloat)urgentTo / 2.0f;
    }
    expModel.exp_p = exp_p;
    [self.expCache addObject:expModel];
}

/**
 *  MARK:--------------------重排序cmvCache--------------------
 *  1. 懒排序,什么时候assLoop,什么时候排序;
 */
-(void) refreshExpCacheSort{
    [self.expCache sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ExpCacheModel *itemA = (ExpCacheModel*)obj1;
        ExpCacheModel *itemB = (ExpCacheModel*)obj2;
        return [SMGUtils compareFloatA:itemA.score floatB:itemB.score];
    }];
}

-(ExpCacheModel*) getCurrentExpCacheModel{
    if (ARRISOK(self.expCache)) {
        //1. 重排序 & 取当前序列最前;
        [self refreshExpCacheSort];
        return self.expCache.lastObject;
    }
    return nil;
}


@end
