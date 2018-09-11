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

-(NSMutableArray*) exceptExpModels{
    if (_exceptExpModels == nil) {
        _exceptExpModels = [[NSMutableArray alloc] init];
    }
    return _exceptExpModels;
}

/**
 *  MARK:--------------------重排序cmvCache--------------------
 *  1. 懒排序,什么时候assLoop,什么时候排序;
 */
-(void) refreshExpCacheSort{
    [self.expCache sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ExpCacheModel *itemA = (ExpCacheModel*)obj1;
        ExpCacheModel *itemB = (ExpCacheModel*)obj2;
        return [SMGUtils compareFloatA:itemB.order floatB:itemA.order];
    }];
    NSLog(@"!!!测试下expCache是否是以order从大到小排序的...");
}

-(ExpCacheModel*) getCurrentExpCacheModel{
    if (ARRISOK(self.expCache)) {
        //1. 重排序 & 取当前序列最前;
        [self refreshExpCacheSort];
        for (ExpCacheModel *cacheModel in self.expCache) {
            BOOL contains = false;
            for (ExpCacheModel *exceptModel in self.exceptExpModels) {
                if ([cacheModel isEqual:exceptModel]) {
                    contains = true;
                    break;
                }
            }
            if (!contains) {
                return cacheModel;
            }
        }
    }
    return nil;
}

-(void) addToExpCache:(ExpCacheModel*)expModel{
    if (expModel) {
        [self.expCache insertObject:expModel atIndex:0];
    }
}

@end
