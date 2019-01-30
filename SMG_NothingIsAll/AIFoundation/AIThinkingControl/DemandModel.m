//
//  DemandModel.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/2.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "DemandModel.h"
#import "AIThinkOutMvModel.h"

@implementation DemandModel

-(NSInteger)order{
    _order = _order;//TODO:>>>>>进行时间衰减
    return _order;
}

-(NSMutableArray*) outMvModels{
    if (_outMvModels == nil) {
        _outMvModels = [[NSMutableArray alloc] init];
    }
    return _outMvModels;
}

-(NSMutableArray*) exceptOutMvModels{
    if (_exceptOutMvModels == nil) {
        _exceptOutMvModels = [[NSMutableArray alloc] init];
    }
    return _exceptOutMvModels;
}

/**
 *  MARK:--------------------重排序cmvCache--------------------
 *  1. 懒排序,什么时候assLoop,什么时候排序;
 */
-(void) refreshExpCacheSort{
    [self.outMvModels sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        AIThinkOutMvModel *itemA = (AIThinkOutMvModel*)obj1;
        AIThinkOutMvModel *itemB = (AIThinkOutMvModel*)obj2;
        return [SMGUtils compareFloatA:itemB.order floatB:itemA.order];
    }];
    NSLog(@"!!!测试下expCache是否是以order从大到小排序的...");
}

-(AIThinkOutMvModel*) getCurrentAIThinkOutMvModel{
    if (ARRISOK(self.outMvModels)) {
        //1. 重排序 & 取当前序列最前;
        [self refreshExpCacheSort];
        for (AIThinkOutMvModel *cacheModel in self.outMvModels) {
            BOOL contains = false;
            for (AIThinkOutMvModel *exceptModel in self.exceptOutMvModels) {
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

-(void) addToExpCache:(AIThinkOutMvModel*)outMvModel{
    if (outMvModel) {
        [self.outMvModels insertObject:outMvModel atIndex:0];
    }
}

@end
