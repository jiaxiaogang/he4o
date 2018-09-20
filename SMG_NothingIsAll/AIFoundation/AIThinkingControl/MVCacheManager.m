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
-(void) addToCMVCache:(NSString*)algsType urgentTo:(NSInteger)urgentTo delta:(NSInteger)delta order:(NSInteger)order{
    //1. 反向的被抵消
    
    //BOOL havDemand = [ThinkingUtils getDemand:cmvNode.urgentTo_p.algsType delta:delta complete:nil];
    
    
    
    
    
    //2. 有需求时_同类同向较弱的被撤消
    BOOL needAdd = true;
    for (NSInteger i = 0; i < self.loopCache.count; i++) {
        MVCacheModel *checkItem = self.loopCache[i];
        if ([STRTOOK(algsType) isEqualToString:checkItem.algsType] && (delta > 0 == checkItem.delta > 0)) {
            if (labs(delta) > labs(checkItem.delta)) {
                [self.loopCache removeObjectAtIndex:i];
            }else{
                needAdd = false;
            }
            break;
        }
    }
    
    //3. 有需求时_加入新的
    if (needAdd) {
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
    //1. 抵消 | 合并
    [ThinkingUtils parserAlgsMVArr:algsArr success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p, NSInteger delta, NSInteger urgentTo, NSString *algsType) {
        BOOL findSeemType = false;
        for (NSInteger i = 0 ; i < self.loopCache.count; i++) {
            MVCacheModel *checkItem = self.loopCache[i];
            if ([STRTOOK(algsType) isEqualToString:checkItem.algsType]) {
                //2. 同向且更迫切时,替换到合适位置
                if ((checkItem.delta > 0) == (delta > 0)) {
                    if (labs(delta) > labs(checkItem.delta)) {
                        [self.loopCache removeObject:checkItem];
                        [self addToCMVCache:algsType urgentTo:urgentTo delta:delta order:urgentTo];
                    }
                }else{//3. 异向抵消
                    [self.loopCache removeObject:checkItem];
                }
                findSeemType = true;
                break;
            }
        }
        
        //4. 未找到相同类型,加到cmvCache中
        if (!findSeemType) {
            [self addToCMVCache:algsType urgentTo:urgentTo delta:delta order:urgentTo];
        }
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
