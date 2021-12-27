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
#import "AINetUtils.h"

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
 *  MARK:--------------------生成P任务--------------------
 *  1. 添加新的cmv到cache,并且自动撤消掉相对较弱的同类同向mv;
 *  2. 在assData等(内心活动,不抵消cmvCache中旧任务)
 *  3. 在dataIn时,抵消旧任务,并生成新任务;
 *  @version
 *      2020.08.24: 在inputMv时,当前demand进行抵消时,其状态设置为Finish;
 *      2021.09.04: 当R任务的 (R部分发生完毕 & P部分也发生完毕 & R任务又没在ActYes/OutBack状态),则销毁这一任务 (参考23224-方案-代码2);
 */
-(void) updateCMVCache_PMV:(NSString*)algsType urgentTo:(NSInteger)urgentTo delta:(NSInteger)delta{
    //1. 数据检查
    if (delta == 0) {
        return;
    }
    ISTitleLog(@"PMV");
    
    //2. 去重_同向撤弱,反向抵消;
    BOOL canNeed = true;
    NSInteger limit = self.loopCache.count;
    for (NSInteger i = 0; i < limit; i++) {
        DemandModel *checkItem = self.loopCache[i];
        if ([STRTOOK(algsType) isEqualToString:checkItem.algsType]) {
            if (ISOK(checkItem, PerceptDemandModel.class)) {
                if ((delta > 0 == checkItem.delta > 0)) {
                    //1) 同向较弱的撤消
                    if (labs(urgentTo) > labs(checkItem.urgentTo)) {
                        [self.loopCache removeObjectAtIndex:i];
                        NSLog(@"demandManager >> PMV移除P任务: 同向较弱撤消 %@,%ld",checkItem.algsType,(long)checkItem.delta);
                        limit--;
                        i--;
                    }else{
                        canNeed = false;
                    }
                }else{
                    //2) 反向抵消
                    [self.loopCache removeObjectAtIndex:i];
                    checkItem.status = TOModelStatus_Finish;
                    NSLog(@"demandManager >> PMV移除P任务: 反向抵消 %@,%ld",checkItem.algsType,(long)checkItem.delta);
                    limit--;
                    i--;
                }
            }
        }
    }
    
    //3. R任务未决策,就已错过的,销毁掉;
    self.loopCache = [SMGUtils removeArr:self.loopCache checkValid:^BOOL(ReasonDemandModel *item) {
        if (ISOK(item, ReasonDemandModel.class)) {
            
            //a. 当现发生的mv与R预测的mv同区同向;
            if ([STRTOOK(algsType) isEqualToString:item.algsType] && (delta > 0 == item.delta > 0)) {
                
                //b. 当已发生cutIndex所有content发生完毕时,PMV反馈可销毁R任务;
                if (item.mModel.cutIndex2 + 1 >= item.mModel.matchFo.count) {
                    
                    //c. 判断rDemand是否处于actYes/outBack状态;
                    BOOL isActYesOrOutBack = ARRISOK([SMGUtils filterArr:item.actionFoModels checkValid:^BOOL(TOFoModel *foModel) {
                        return foModel.status == TOModelStatus_ActYes || foModel.status == TOModelStatus_OuterBack;
                    }]);
                    
                    //d. 理性概念预测发生完毕,感性价值预测也发生完毕,且rDemand并不在等待反馈状态,则废弃移除出任务池;
                    if (!isActYesOrOutBack) {
                        NSLog(@"demandManager >> PMV移除已过期R任务:%@",Fo2FStr(item.mModel.matchFo));
                        return true;
                    }
                }
            }
        }
        return false;
    }];
    
    //3. 有需求时且可加入时_加入新的
    //TODO:>>>>判断需求;(如饿,主动取当前状态,是否饿)
    MVDirection direction = [ThinkingUtils getDemandDirection:algsType delta:delta];
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
 *  MARK:--------------------生成R任务--------------------
 *  @desc RMV输入更新任务管理器 (理性思维预测mv加入)
 *  @todo
 *      2021.01.21: 抵销: 当汽车冲过来,突然又转向了,任务消除 (理性抵消 (仅能通过matchFo已发生的部分进行比对)) (参考22074-BUG2) T;
 *      2021.01.21: 抵销: 当另一辆更大的车又冲过来,两条matchFo都导致疼不能抵消 (理性抵消不以mv.algsType为准) (参考22074-BUG2) T;
 *      2021.01.21: 抵销&增强: 进度更新后,根据matchFo进行"理性抵消" 或者 "理性增强(进度更新)" 判断 (参考22074-BUG2) T;
 *  @version
 *      2021.01.25: RMV仅对ReasonDemandModel进行抵消防重 (否则会导致R-与P-需求冲突);
 *      2021.01.27: RMV仅对matchFoModel进行抵消防重 (否则会导致inModel预测处理不充分) (参考22074-BUG2);
 *      2021.02.05: 新增任务时,仅将"与旧有同区最大迫切度的差值"累增至活跃度 (参考22116);
 *      2021.03.01: 修复RMV一直在行为输出和被识别间重复死循环BUG (参考22142);
 *      2021.07.14: 循环matchPFos时,采用反序,因为优先级和任务池优先级上弄反了 (参考23172);
 *      2021.11.11: 迭代RMV的生成机制,此代码其实啥也没改 (参考24107-1);
 */
-(void) updateCMVCache_RMV:(AIShortMatchModel*)inModel{
    //1. 数据检查;
    if (!inModel || !inModel.protoFo || !ARRISOK(inModel.matchPFos) || !Switch4RS) return;
    ISTitleLog(@"RMV");
    
    //2. 多时序识别预测分别进行处理;
    for (NSInteger i = 0; i < inModel.matchPFos.count; i++) {
        
        //2. 因为matchPFos排序是更好(引用强度强)的在先,而任务池是以迫切度+initTime靠后优先,所以倒序,使强度强的initTime更靠后;
        AIMatchFoModel *mModel = ARR_INDEX_REVERSE(inModel.matchPFos, i);
        //3. 单条数据准备;
        //2021.03.28: 此处algsType由urgentTo.at改成cmv.at,从mvNodeManager看这俩一致,如果出现bug再说;
        if (!mModel.matchFo.cmvNode_p) continue;
        NSString *algsType = mModel.matchFo.cmvNode_p.algsType;
            
        //4. 抵消_同一matchFo将旧有移除 (仅保留最新的);
        self.loopCache = [SMGUtils removeArr:self.loopCache checkValid:^BOOL(ReasonDemandModel *oldItem) {
            if (ISOK(oldItem, ReasonDemandModel.class)) {
                if ([oldItem.mModel.matchFo isEqual:mModel.matchFo] && oldItem.mModel.cutIndex2 < mModel.cutIndex2) {
                    NSLog(@"RMV移除R任务(更新的抵消旧的):%@",Fo2FStr(oldItem.mModel.matchFo));
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
            
            //7. 有需求时,则加到需求序列中;
            ReasonDemandModel *newItem = [ReasonDemandModel newWithMModel:mModel inModel:inModel baseFo:nil];
            [self.loopCache addObject:newItem];
            
            //8. 新需求时_将新需求迫切度的差值(>0时) (增至活跃度 = 新迫切度 - 旧有最大迫切度);
            //2021.05.27: 为方便测试,所有imv都给20迫切度 (因为迫切度太低话,还没怎么思考就停了);
            //NSInteger sameIdenOldMax = 0;
            //for (DemandModel *item in self.loopCache) {
            //    if ([item.algsType isEqualToString:algsType]) {
            //        sameIdenOldMax = MAX(sameIdenOldMax, item.urgentTo);
            //    }
            //}
            //[theTC updateEnergy:MAX(0, newItem.urgentTo - sameIdenOldMax)];
            [theTC setEnergy:20];
            
            NSLog(@"RMV新需求: %@->%@ (条数+1=%ld 评分:%@)",Fo2FStr(mModel.matchFo),Pit2FStr(mModel.matchFo.cmvNode_p),self.loopCache.count,Double2Str_NDZ(score));
        }else{
            NSLog(@"当前,预测mv未形成需求:%@ 基于:%@ 评分:%f",algsType,Pit2FStr(mModel.matchFo.cmvNode_p),score);
        }
    }
}

/**
 *  MARK:--------------------重排序cmvCache--------------------
 *  1. 懒排序,什么时候assLoop,什么时候排序;
 *  @version
 *      2021.01.02: loopCache排序后未被接收,所以一直是未生效的BUG;
 *      2021.01.27: 支持第二级排序:initTime (参考22074-BUG2);
 *      2021.11.13: R任务排序根据 "迫切度*匹配度" 得出 (参考24107-2);
 */
-(void) refreshCmvCacheSort{
    NSArray *sort = [self.loopCache sortedArrayUsingComparator:^NSComparisonResult(DemandModel *o1, DemandModel *o2) {
        if (o1.demandUrgentTo != o2.demandUrgentTo){
            return [SMGUtils compareFloatA:o1.demandUrgentTo floatB:o2.urgentTo];;
        }else {
            return [SMGUtils compareDoubleA:o1.initTime doubleB:o2.initTime];
        }
    }];
    [self.loopCache removeAllObjects];
    [self.loopCache addObjectsFromArray:sort];
}

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

/**
 *  MARK:--------------------获取当前,可以继续决策的任务--------------------
 *  @version
 *      xxxx.xx.xx: (未完成 & 非等待反馈ActYes);
 *      2021.12.23: root非WithOut状态的 (参考24212-6);
 *      2021.12.23: 最优末枝处在actYes状态时,继续secondRoot (参考24212-7);
 */
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
        
        //4. 已无计可施,下一个 (TCPlan会优先从末枝执行,所以当root就是末枝时,说明整个三条大树干全烂透没用了);
        if (item.status == TOModelStatus_WithOut) continue;
        
        //5. 最优末枝处在actYes状态时,继续secondRoot;
        if (item.status == TOModelStatus_ActYes) continue;
        
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
    if (ISOK(demand, ReasonDemandModel.class)) NSLog(@"demandManager >> 移除R任务:%@",Fo2FStr(((ReasonDemandModel*)demand).mModel.matchFo));
    if (demand) [self.loopCache removeObject:demand];
}

/**
 *  MARK:--------------------获取R任务的抽具象路径上的所有R任务--------------------
 *  @desc 获取同类场景RDemands (参考24107-3);
 *  @version
 *      2021.11.13: mModel的抽具象路径写成方法,实时从loopCache中获取 (参考24107-3);
 *      2021.11.14: 返回结果排序为抽象有前具象在后 (参考24127-示图-需要它有序);
 *  @result notnull 元素类型为ReasonDemandModel,排序方式: 越抽象排在前面,反之越后;
 */
-(NSArray*) getRDemandsBySameClass:(ReasonDemandModel *)rDemand{
    //1. 获取抽象方向;
    NSMutableArray *result = [[NSMutableArray alloc] initWithObjects:rDemand, nil];
    
    //2. 获取抽象方向 (倒序,使更抽象的排在更前面);
    NSArray *absSameClass = [self getRDemandBySameClass:rDemand isAbs:true];
    absSameClass = [[absSameClass reverseObjectEnumerator] allObjects];
    [result addObjectsFromArray:absSameClass];
    
    //3. 获取具象方向;
    [result addObjectsFromArray:[self getRDemandBySameClass:rDemand isAbs:false]];
    return nil;
}

/**
 *  MARK:--------------------获取同抽/具象路径的R任务组--------------------
 *  @param isAbs    : 抽象方向/具象方向;
 *  @param rDemand  : 出发R任务;
 *  @version
 *      2021.11.14: 只有同区mv的才作为结果返回 (参考24127-步骤1);
 *  @result notnull : 元素类型为ReasonDemandModel,抽具象层离rDemand越远,越排在后面;
 */
-(NSArray*) getRDemandBySameClass:(ReasonDemandModel*)rDemand isAbs:(BOOL)isAbs{
    //0. 数据准备;
    NSString *mvIden = STRTOOK(rDemand.mModel.matchFo.cmvNode_p.identifier);
    NSMutableArray *result = [[NSMutableArray alloc] initWithObjects:rDemand, nil];
    NSArray *curLayerRs = @[rDemand];
    do {
        //1. 分别对当前层元素取下一层;
        NSMutableArray *nextLayerRs = [[NSMutableArray alloc] init];
        for (ReasonDemandModel *curR in curLayerRs) {
            NSArray *nextFos = nil;
            if (isAbs) {
                nextFos = Ports2Pits([AINetUtils absPorts_All_Normal:curR.mModel.matchFo]);
            }else{
                nextFos = Ports2Pits([AINetUtils conPorts_All_Normal:curR.mModel.matchFo]);
            }
            
            //2. 将当前元素下,在nextFos且在loopCache中的R,新收集到nextLayerRs中;
            NSArray *curRs = [SMGUtils filterArr:self.loopCache checkValid:^BOOL(ReasonDemandModel *item) {
                BOOL isR = ISOK(item, ReasonDemandModel.class);
                BOOL sameMvIden = [mvIden isEqualToString:item.mModel.matchFo.cmvNode_p.identifier];
                BOOL inNextFos = [SMGUtils containsSub_p:item.mModel.matchFo.pointer parent_ps:nextFos];
                return isR && sameMvIden && inNextFos;
            }];
            [nextLayerRs addObjectsFromArray:curRs];
        }
        
        //3. nextLayerRs防重;
        nextLayerRs = [SMGUtils removeRepeat:nextLayerRs];
        
        //4. 下一层更新至当前层;
        curLayerRs = nextLayerRs;
        
        //5. 如果已包含,则先移除掉,再重新收集至总result中 (使更后层的,放在result更后面);
        result = [SMGUtils removeArr:result checkValid:^BOOL(ReasonDemandModel *item) {
            return [nextLayerRs containsObject:item];
        }];
        [result addObjectsFromArray:nextLayerRs];
    } while (ARRISOK(curLayerRs));
    return result;
}

@end
