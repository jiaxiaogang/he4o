//
//  TOModelBase.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/26.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"
#import "AIKVPointer.h"

@implementation TOModelBase

-(id) initWithContent_p:(AIPointer*)content_p{
    self = [super init];
    if (self) {
        self.content_p = content_p;
    }
    return self;
}

- (NSMutableArray *)except_ps{
    if (_except_ps == nil) {
        _except_ps = [[NSMutableArray alloc] init];
    }
    return _except_ps;
}

- (NSMutableArray *)subModels{
    if (_subModels == nil) {
        _subModels = [[NSMutableArray alloc] init];
    }
    return _subModels;
}

-(id) getCurSubModel{
    TOModelBase *maxModel = nil;
    for (TOModelBase *model in self.subModels) {
        //1. 取不在except中的;
        if (![SMGUtils containsSub_p:model.content_p parent_ps:self.except_ps]) {
            
            //2. 最高得分的返回;
            if (maxModel == nil || maxModel.score < model.score) {
                maxModel = model;
            }
        }
    }
    return maxModel;
}

-(BOOL) isEqual:(TOModelBase*)object{
    if (object && object.content_p) {
        return [object.content_p isEqual:self.content_p];
    }
    return false;
}

-(CGFloat) allNiceScore{
    TOModelBase *subModel = [self getCurSubModel];
    if (subModel) {
        return self.score + [subModel allNiceScore];
    }
    return self.score;
}


//MARK:===============================================================
//MARK:                     < private_Method >
//MARK:===============================================================

/**
 *  MARK:--------------------重排序cmvCache--------------------
 *  1. 懒排序,什么时候assLoop,什么时候排序;
 */
-(void) refreshExpCacheSort{
    [self.subModels sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TOModelBase *itemA = (TOModelBase*)obj1;
        TOModelBase *itemB = (TOModelBase*)obj2;
        return [SMGUtils compareFloatA:itemB.score floatB:itemA.score];
    }];
    NSLog(@"!!!测试下expCache是否是以order从大到小排序的...");
}

@end
