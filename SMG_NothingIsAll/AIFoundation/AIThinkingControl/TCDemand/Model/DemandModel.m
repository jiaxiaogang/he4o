//
//  DemandModel.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/2.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "DemandModel.h"

@interface DemandModel()

@property (strong, nonatomic) NSMutableArray *actionFoModels;

@end

@implementation DemandModel

-(id) init{
    self = [super init];
    if (self) {
        self.initTime = [[NSDate new] timeIntervalSince1970];
    }
    return self;
}

-(NSMutableArray *)actionFoModels{
    if (_actionFoModels == nil) {
        _actionFoModels = [[NSMutableArray alloc] init];
    }
    return _actionFoModels;
}

/**
 *  MARK:--------------------取出besting/bested的解决方案--------------------
 *  @desc 作用: 过滤出best过的Cansets;
 *        起因: 只有best过的,才有必要计算评分,别的Cansets都是默认分 (参考31083-TODO1);
 */
-(NSArray*) bestCansets {
    NSArray *actionFoModels = [self.actionFoModels copy];
    return [SMGUtils filterArr:actionFoModels checkValid:^BOOL(TOFoModel *actionFo) {
        return actionFo.cansetStatus == CS_Besting || actionFo.cansetStatus == CS_Bested;
    }];
}

//-(id) getCurSubModel{
//    TOFoModel *maxModel = nil;
//    for (TOModelBase *model in self.subModels) {
//        //1. 取不在except中的;
//        if (![SMGUtils containsSub_p:model.content_p parent_ps:self.except_ps]) {
//
//            //2. 最高得分的返回;
//            if (maxModel == nil || maxModel.score < model.score) {
//                maxModel = model;
//            }
//        }
//    }
//    return maxModel;
//}

//MARK:===============================================================
//MARK:                     < private_Method >
//MARK:===============================================================

/**
 *  MARK:--------------------重排序cmvCache--------------------
 *  1. 懒排序,什么时候assLoop,什么时候排序;
 */
//-(void) refreshExpCacheSort{
//    [self.subModels sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        TOModelBase *itemA = (TOModelBase*)obj1;
//        TOModelBase *itemB = (TOModelBase*)obj2;
//        return [SMGUtils compareFloatA:itemB.score floatB:itemA.score];
//    }];
//}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.actionFoModels = [aDecoder decodeObjectForKey:@"actionFoModels"];
        self.urgentTo = [aDecoder decodeIntegerForKey:@"urgentTo"];
        self.delta = [aDecoder decodeIntegerForKey:@"delta"];
        self.algsType = [aDecoder decodeObjectForKey:@"algsType"];
        self.initTime = [aDecoder decodeDoubleForKey:@"initTime"];
        self.updateTime = [aDecoder decodeDoubleForKey:@"updateTime"];
        self.effectStatus = [aDecoder decodeIntegerForKey:@"effectStatus"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.actionFoModels forKey:@"actionFoModels"];
    [aCoder encodeInteger:self.urgentTo forKey:@"urgentTo"];
    [aCoder encodeInteger:self.delta forKey:@"delta"];
    [aCoder encodeObject:self.algsType forKey:@"algsType"];
    [aCoder encodeDouble:self.initTime forKey:@"initTime"];
    [aCoder encodeDouble:self.updateTime forKey:@"updateTime"];
    [aCoder encodeInteger:self.effectStatus forKey:@"effectStatus"];
}

@end
