//
//  MVCacheManager.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/4.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "MVCacheManager.h"
#import "MVCacheModel.h"
#import "ThinkingUtils.h"

@interface MVCacheManager()


/**
 *  MARK:--------------------实时序列--------------------
 *  元素 : <MVCacheModel.class>
 *  思维因子_当前cmv序列(注:所有cmv只与cacheImv中作匹配)(正序,order越大,排越前)
 */
@property (strong,nonatomic) NSMutableArray *loopCache;

@end

@implementation MVCacheManager

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.loopCache = [[NSMutableArray alloc] init];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

/**
 *  MARK:--------------------joinToCMVCache--------------------
 *  1. 添加新的cmv到cache,并且自动撤消掉相对较弱的同类同向mv;
 *  2. 在assData等(内心活动,不抵消cmvCache中旧任务)
 *  3. 在dataIn时,抵消旧任务,并生成新任务;
 */
-(void) updateCMVCache:(NSString*)algsType urgentTo:(NSInteger)urgentTo delta:(NSInteger)delta order:(NSInteger)order{
    //1. 数据检查
    if (delta == 0) {
        return;
    }
    
    //2. 去重_同向撤弱,反向抵消;
    BOOL canNeed = true;
    NSInteger limit = self.loopCache.count;
    for (NSInteger i = 0; i < limit; i++) {
        MVCacheModel *checkItem = self.loopCache[i];
        if ([STRTOOK(algsType) isEqualToString:checkItem.algsType]) {
            if ((delta > 0 == checkItem.delta > 0)) {
                //1) 同向较弱的撤消
                if (labs(urgentTo) > labs(checkItem.urgentTo)) {
                    [self.loopCache removeObjectAtIndex:i];
                    limit--;
                    i--;
                }else{
                    canNeed = false;
                }
            }else{
                //2) 反向抵消
                [self.loopCache removeObjectAtIndex:i];
                limit--;
                i--;
            }
        }
    }
    
    //3. 有需求时且可加入时_加入新的
    BOOL havDemand = [ThinkingUtils getDemand:algsType delta:delta complete:nil];
    if (canNeed && havDemand) {
        MVCacheModel *newItem = [[MVCacheModel alloc] init];
        newItem.algsType = algsType;
        newItem.delta = delta;
        newItem.urgentTo = urgentTo;
        newItem.order = order;
        [self.loopCache addObject:newItem];
    }
}

/**
 *  MARK:--------------------重排序cmvCache--------------------
 *  1. 懒排序,什么时候assLoop,什么时候排序;
 */
-(void) refreshCmvCacheSort{
    [self.loopCache sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        MVCacheModel *itemA = (MVCacheModel*)obj1;
        MVCacheModel *itemB = (MVCacheModel*)obj2;
        return [SMGUtils compareIntA:itemA.order intB:itemB.order];
    }];
}


/**
 *  MARK:--------------------dataIn_Mv时及时加到manager--------------------
 */
-(void) dataIn_CmvAlgsArr:(NSArray*)algsArr{
    [ThinkingUtils parserAlgsMVArr:algsArr success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p, NSInteger delta, NSInteger urgentTo, NSString *algsType) {
        [self updateCMVCache:algsType urgentTo:urgentTo delta:delta order:urgentTo];
    }];
}


/**
 *  MARK:--------------------获取当前最紧急out任务--------------------
 */
-(MVCacheModel*) getCurrentDemand{
    if (ARRISOK(self.loopCache)) {
        //1. 重排序 & 取当前序列最前;
        [self refreshCmvCacheSort];
        return self.loopCache.lastObject;
    }
    return nil;
}

    
    
@end
