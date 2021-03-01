//
//  DemandManager.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/4.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "DemandManager.h"
#import "ReasonDemandModel.h"
#import "PerceptDemandModel.h"
#import "ThinkingUtils.h"
#import "TOUtils.h"
#import "AIShortMatchModel.h"
#import "AINetIndex.h"
#import "AIScore.h"
#import "AIMatchFoModel.h"
#import "AITime.h"
#import "TOFoModel.h"
#import "AIAnalogy.h"

@interface DemandManager()

/**
 *  MARK:--------------------实时序列--------------------
 *  元素 : <DemandModel.class>
 *  思维因子_当前cmv序列(注:所有cmv只与cacheImv中作匹配)(正序,order越大,排越前)
 */
@property (strong,nonatomic) NSMutableArray *loopCache;

@end

@implementation DemandManager

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
 *  @version
 *      2020.08.24: 在inputMv时,当前demand进行抵消时,其状态设置为Finish;
 */
-(void) updateCMVCache_PMV:(NSString*)algsType urgentTo:(NSInteger)urgentTo delta:(NSInteger)delta{
    //1. 数据检查
    if (delta == 0) {
        return;
    }
    NSLog(@"\n\n------------------------------- PMV -------------------------------");
    
    //2. 去重_同向撤弱,反向抵消;
    BOOL canNeed = true;
    NSInteger limit = self.loopCache.count;
    for (NSInteger i = 0; i < limit; i++) {
        DemandModel *checkItem = self.loopCache[i];
        if ([STRTOOK(algsType) isEqualToString:checkItem.algsType]) {
            if ((delta > 0 == checkItem.delta > 0)) {
                //1) 同向较弱的撤消
                if (labs(urgentTo) > labs(checkItem.urgentTo)) {
                    [self.loopCache removeObjectAtIndex:i];
                    NSLog(@"demandManager >> 同向较弱撤消 %lu",(unsigned long)self.loopCache.count);
                    limit--;
                    i--;
                }else{
                    canNeed = false;
                }
            }else{
                //2) 反向抵消
                [self.loopCache removeObjectAtIndex:i];
                checkItem.status = TOModelStatus_Finish;
                NSLog(@"demandManager >> 反向抵消 %lu",(unsigned long)self.loopCache.count);
                limit--;
                i--;
            }
        }
    }
    
    //3. 有需求时且可加入时_加入新的
    //TODO:>>>>判断需求;(如饿,主动取当前状态,是否饿)
    MVDirection direction = [ThinkingUtils havDemand:algsType delta:delta];
    if (canNeed && (direction != MVDirection_None)) {
        PerceptDemandModel *newItem = [[PerceptDemandModel alloc] init];
        newItem.algsType = algsType;
        newItem.delta = delta;
        newItem.urgentTo = urgentTo;
        [self.loopCache addObject:newItem];
        
        //2. 新需求时,加上活跃度;
        [theTC updateEnergy:urgentTo];
        NSLog(@"demandManager-PMV >> 新需求 %lu",(unsigned long)self.loopCache.count);
    }
}

/**
 *  MARK:--------------------RMV输入更新任务管理器--------------------
 *  @todo
 *      2021.01.21: 抵销: 当汽车冲过来,突然又转向了,任务消除 (理性抵消 (仅能通过matchFo已发生的部分进行比对)) (参考22074-BUG2) T;
 *      2021.01.21: 抵销: 当另一辆更大的车又冲过来,两条matchFo都导致疼不能抵消 (理性抵消不以mv.algsType为准) (参考22074-BUG2) T;
 *      2021.01.21: 抵销&增强: 进度更新后,根据matchFo进行"理性抵消" 或者 "理性增强(进度更新)" 判断 (参考22074-BUG2) T;
 *  @version
 *      2021.01.25: RMV仅对ReasonDemandModel进行抵消防重 (否则会导致R-与P-需求冲突);
 *      2021.01.27: RMV仅对matchFoModel进行抵消防重 (否则会导致inModel预测处理不充分) (参考22074-BUG2);
 *      2021.02.05: 新增任务时,仅将"与旧有同区最大迫切度的差值"累增至活跃度 (参考22116);
 *      2021.03.01: 修复RMV一直在行为输出和被识别间重复死循环BUG (参考22142);
 */
-(void) updateCMVCache_RMV:(AIShortMatchModel*)inModel{
    //1. 数据检查;
    if (!inModel || !inModel.protoFo || !ARRISOK(inModel.matchFos)) return;
    NSLog(@"\n\n------------------------------- RMV -------------------------------");
    
    //2. 多时序识别预测分别进行处理;
    for (AIMatchFoModel *mModel in inModel.matchFos) {
        
        //3. 单条数据准备;
        AICMVNodeBase *mvNode = [SMGUtils searchNode:mModel.matchFo.cmvNode_p];
        if (!mvNode) continue;
        NSInteger delta = [NUMTOOK([AINetIndex getData:mvNode.delta_p]) integerValue];
        NSString *algsType = mvNode.urgentTo_p.algsType;
        NSInteger urgentTo = [NUMTOOK([AINetIndex getData:mvNode.urgentTo_p]) integerValue];
        urgentTo = (int)(urgentTo * inModel.matchFoValue);
            
        //4. 抵消_同一matchFo将旧有移除 (仅保留最新的);
        self.loopCache = [SMGUtils removeArr:self.loopCache checkValid:^BOOL(ReasonDemandModel *item) {
            if (ISOK(item, ReasonDemandModel.class)) {
                if ([item.mModel.matchFo isEqual:mModel.matchFo] && item.mModel.cutIndex < mModel.cutIndex) {
                    return true;
                }
            }
            return false;
        }];
        
        //4. 防重
        BOOL containsRepeat = false;
        for (ReasonDemandModel *item in self.loopCache) {
            if (ISOK(item, ReasonDemandModel.class) && [item.mModel.matchFo isEqual:mModel.matchFo]) {
                containsRepeat = true;
            }
        }
        
        //5. 取迫切度评分: 判断matchingFo.mv有值才加入demandManager,同台竞争,执行顺应mv;
        CGFloat score = [AIScore score4MV:mModel.matchFo.cmvNode_p ratio:mModel.matchFoValue];
        if (score < 0 && !containsRepeat) {
            
            //6. 新需求时_取同区旧有最大迫切度;
            NSInteger sameIdenOldMax = 0;
            for (DemandModel *item in self.loopCache) {
                if ([item.algsType isEqualToString:algsType]) {
                    sameIdenOldMax = MAX(sameIdenOldMax, item.urgentTo);
                }
            }
            
            //7. 有需求时,则加到需求序列中;
            ReasonDemandModel *newItem = [ReasonDemandModel newWithMModel:mModel inModel:inModel];
            newItem.algsType = algsType;
            newItem.delta = delta;
            newItem.urgentTo = urgentTo;
            [self.loopCache addObject:newItem];
            
            //8. 新需求时_将新需求迫切度的差值(>0时),增至活跃度;
            [theTC updateEnergy:MAX(0, urgentTo - sameIdenOldMax)];
            NSLog(@"demandManager-RMV >> 新需求+1=%lu 评分:%f\n%@->%@",(unsigned long)self.loopCache.count,score,Fo2FStr(mModel.matchFo),Pit2FStr(mModel.matchFo.cmvNode_p));
        }else{
            NSLog(@"当前,预测mv未形成需求:%@ 差值:%ld 评分:%f",algsType,(long)delta,score);
        }
    }
}

/**
 *  MARK:--------------------重排序cmvCache--------------------
 *  1. 懒排序,什么时候assLoop,什么时候排序;
 *  @version
 *      2021.01.02: loopCache排序后未被接收,所以一直是未生效的BUG;
 *      2021.01.27: 支持第二级排序:initTime (参考22074-BUG2);
 */
-(void) refreshCmvCacheSort{
    NSArray *sort = [self.loopCache sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        DemandModel *itemA = (DemandModel*)obj1;
        DemandModel *itemB = (DemandModel*)obj2;
        NSComparisonResult result = [SMGUtils compareIntA:itemA.urgentTo intB:itemB.urgentTo];
        if (result == NSOrderedSame) {
            result = [SMGUtils compareDoubleA:itemA.initTime doubleB:itemB.initTime];
        }
        return result;
    }];
    [self.loopCache removeAllObjects];
    [self.loopCache addObjectsFromArray:sort];
}


/**
 *  MARK:--------------------dataIn_Mv时及时加到manager--------------------
 */
//-(void) dataIn_CmvAlgsArr:(NSArray*)algsArr{
//    [ThinkingUtils parserAlgsMVArr:algsArr success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p, NSInteger delta, NSInteger urgentTo, NSString *algsType) {
//        [self updateCMVCache_PMV:algsType urgentTo:urgentTo delta:delta order:urgentTo];
//    }];
//}


/**
 *  MARK:--------------------获取任务--------------------
 */

/**
 *  MARK:--------------------获取当前,最紧急任务--------------------
 *  @version
 *      2021.01.29: 将last改为取first (因为顺序是从大到小,第一个才是最紧急的最新任务);
 */
-(DemandModel*) getCurrentDemand{
    if (ARRISOK(self.loopCache)) {
        //1. 重排序 & 取当前序列最前;
        [self refreshCmvCacheSort];
        return self.loopCache.firstObject;
    }
    return nil;
}
//获取当前,可以继续决策的任务 (未完成 & 非等待反馈ActYes);
-(DemandModel*) getCanDecisionDemand{
    //1. 数据检查
    if (!ARRISOK(self.loopCache)) return nil;
        
    //2. 重排序 & 取当前序列最前;
    [self refreshCmvCacheSort];
    
    //3. 逐个判断条件
    for (NSInteger i = 0; i < self.loopCache.count; i++) {
        DemandModel *item = ARR_INDEX(self.loopCache, i);
        
        //4. 已完成时,下一个;
        if (item.status == TOModelStatus_Finish) continue;
        
        //5. 等待反馈中,下一个;
        NSArray *actYeses = [TOUtils getSubOutModels_AllDeep:item validStatus:@[@(TOModelStatus_ActYes)]];
        if (ARRISOK(actYeses)) continue;
        
        //6. 有效,则返回;
        return item;
    }
    return nil;
}

/**
 *  MARK:--------------------返回所有demand任务--------------------
 *  @desc 排序方式: 从大到小;
 */
-(NSArray*) getAllDemand{
    [self refreshCmvCacheSort];
    return self.loopCache;
}

/**
 *  MARK:--------------------移除某任务--------------------
 */
-(void) removeDemand:(DemandModel*)demand{
    if (demand) [self.loopCache removeObject:demand];
}

@end
