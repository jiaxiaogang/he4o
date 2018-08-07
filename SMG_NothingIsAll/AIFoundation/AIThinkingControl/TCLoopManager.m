//
//  TCLoopManager.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/4.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "TCLoopManager.h"
#import "TCLoopModel.h"
#import "ThinkingUtils.h"
#import "AINet.h"
#import "AIPort.h"

@interface TCLoopManager()


/**
 *  MARK:--------------------实时序列--------------------
 *  元素 : <TCLoopModel.class>
 *  思维因子_当前cmv序列(注:所有cmv只与cacheImv中作匹配)(正序,order越大,排越前)
 */
@property (strong,nonatomic) NSMutableArray *loopCache;
@property (assign, nonatomic) NSInteger energy;                 //当前能量值;(在循环中动态更新)(0-2)

@end

@implementation TCLoopManager

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
    //1. 同类同向较弱的被撤消
    for (NSInteger i = 0; i < self.loopCache.count; i++) {
        TCLoopModel *checkItem = self.loopCache[i];
        if ([STRTOOK(algsType) isEqualToString:checkItem.algsType] && labs(delta) > labs(checkItem.delta) && (delta > 0 == checkItem.delta > 0)) {
            [self.loopCache removeObjectAtIndex:i];
            break;
        }
    }
    
    //2. 加入新的;
    TCLoopModel *newItem = [[TCLoopModel alloc] init];
    newItem.algsType = algsType;
    newItem.delta = delta;
    newItem.urgentTo = urgentTo;
    newItem.order = order;
    [self.loopCache addObject:newItem];
}

/**
 *  MARK:--------------------重排序cmvCache--------------------
 *  1. 懒排序,什么时候assLoop,什么时候排序;
 */
-(void) refreshCmvCacheSort{
    [self.loopCache sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TCLoopModel *itemA = (TCLoopModel*)obj1;
        TCLoopModel *itemB = (TCLoopModel*)obj2;
        return [SMGUtils compareIntA:itemA.order intB:itemB.order];
    }];
}

/**
 *  MARK:--------------------dataLoop联想(每次循环的检查执行点)--------------------
 *  注:assExp联想经验(饿了找瓜)(递归)
 *  注:loopAssExp中本身已经是内心活动联想到的mv
 *  1. 有条件(energy>0)
 *  2. 有尝(energy-1)
 *  3. 不指定model (从cmvCache取)
 *
 */
-(void) dataLoop_AssociativeExperience {
    if (self.energy > 0 && ARRISOK(self.loopCache)) {
        //1. 重排序 & 取当前序列最前;
        [self refreshCmvCacheSort];
        TCLoopModel *mvCacheModel = self.loopCache.lastObject;
        
        //2. 联想相关"解决经验";(取曾经历的最强解决;)
        [ThinkingUtils getDemand:mvCacheModel.algsType delta:mvCacheModel.delta complete:^(BOOL upDemand, BOOL downDemand) {
            MVDirection direction = downDemand ? MVDirection_Negative : MVDirection_Positive;
            AIPort *mvPort = [[AINet sharedInstance] getNetNodePointersFromDirectionReference_Single:mvCacheModel.algsType direction:direction];
            if (mvPort) {
                //3. 取"解决经验"对应的cmvNode;
                NSObject *expMvNode = [SMGUtils searchObjectForPointer:mvPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];
                
                //4. 决策输出
                if (self.delegate && [self.delegate respondsToSelector:@selector(tcLoopManager_decisionOut:)]) {
                    [self.delegate tcLoopManager_decisionOut:expMvNode];
                }
            }
        }];
        
        //3. 思考与决策消耗能量;
        [self updateEnergy:-1];
        
        //4. 记录思考mv结果到叠加mvCacheModel.order;
        
        //5. 记录思考data结果到thinkFeedCache;
        
        
        [self dataLoop_AssociativeExperience];
    }
}


/**
 *  MARK:--------------------更新energy--------------------
 */
-(void) updateEnergy:(NSInteger)delta{
    self.energy = [ThinkingUtils updateEnergy:self.energy delta:delta];
}


/**
 *  MARK:--------------------dataIn_Mv时及时加到manager--------------------
 */
-(void) dataIn_CmvAlgsArr:(NSArray*)algsArr{
    //1. 抵消 | 合并
    [ThinkingUtils parserAlgsMVArr:algsArr success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p, NSInteger delta, NSInteger urgentTo, NSString *algsType) {
        BOOL findSeemType = false;
        for (NSInteger i = 0 ; i < self.loopCache.count; i++) {
            TCLoopModel *checkItem = self.loopCache[i];
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

@end
