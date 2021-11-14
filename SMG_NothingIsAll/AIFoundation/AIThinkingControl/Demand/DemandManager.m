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
        self.loopCache = [SMGUtils removeArr:self.loopCache checkValid:^BOOL(ReasonDemandModel *item) {
            if (ISOK(item, ReasonDemandModel.class)) {
                if ([item.mModel.matchFo isEqual:mModel.matchFo] && item.mModel.cutIndex2 < mModel.cutIndex2) {
                    NSLog(@"RMV移除R任务(更新的抵消旧的):%@",Fo2FStr(item.mModel.matchFo));
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
 *  MARK:--------------------生成子任务--------------------
 *  @param rtInModel : 反思结果;
 *  @param baseFo : 反思基于此fo进行的,将反思产生的子任务挂在这下面;
 *  @desc
 *      2021.08.14: 防重说明:
 *                  1. 同树防重: 同树不可有一模一样的树叶;
 *                  2. ds范围防重: 将dsFo可用于解决的所有任务都做防重 (不能因为十个钉子准备十把锤子);
 *                  3. 抽象防重: 对于抽象子任务,其下的任何具象子任务都不再生成子任务 (吃过饭了,有面条也不吃了);
 *
 *  @version
 *      2021.06.05: v2_子任务协同,将先执行顺利的ds解决方案下的场景fos加入到不应期 (参考23102 & 23103);
 *      2021.06.08: 子任务的actYes状态由任意subModel为actYes状态为准 (参考23122);
 *      2021.06.24: 第四类不应期,将全树中未失败任务下已成功或静默等待下的dsFo适用的任务全收集为不应期 (参考23142-方案);
 *      2021.08.14: 抽象防重: 对于抽象任务下的具象子任务都进行防重 (参考23216);
 *
 */
+(void) updateSubDemand:(AIShortMatchModel*)rtInModel baseFo:(TOFoModel*)baseFo createSubDemandBlock:(void(^)(ReasonDemandModel*))createSubDemandBlock finishBlock:(void(^)(NSArray*))finishBlock{
    //1. 数据检查;
    if (!rtInModel || !baseFo) return;
    
    //2. 取出当前短时树上主子任务下,所有的解决方案,做为不应期 (避免子任务死循环) (参考23092);
    NSMutableArray *baseDemands = [TOUtils getBaseDemands_AllDeep:baseFo];
    NSArray *baseExcepts = RDemands2Pits(baseDemands);
    
    //3. 取出所有已无计可施的demand (参考23095);
    DemandModel *rootDemand = ARR_INDEX_REVERSE(baseDemands, 0);
    NSArray *failureDemans = [TOUtils getSubDemands_AllDeep:rootDemand validStatus:@[@(TOModelStatus_ActNo)]];
    NSArray *failureExcepts = RDemands2Pits(failureDemans);
    
    //4. 收集不应期_之四(dsFo的全树不应期) (所有未失败的(用all减去actNo得出)dsFo可适用于的问题全不应期掉) (参考23142-方案);
    NSArray *allSubDemands = [TOUtils getSubDemands_AllDeep:rootDemand validStatus:nil];
    NSArray *noActNoDemands = [SMGUtils removeArr:allSubDemands checkValid:^BOOL(id item) {
        return [failureDemans containsObject:item];
    }];
    NSMutableArray *dsExcepts = [[NSMutableArray alloc] init];
    for (DemandModel *subDemand in noActNoDemands){
        [dsExcepts addObjectsFromArray:[ThinkingUtils collectDiffBaseFoWhenDSFoIsFinishOrActYes:subDemand]];
    }
    
    //4. 收集不应期_之抽象防重_收集当前还未失败所有任务的具象;
    NSMutableArray *absExcepts = [[NSMutableArray alloc] init];
//    for (ReasonDemandModel *subDemand in noActNoDemands){
//        if (ISOK(subDemand, ReasonDemandModel.class)) {
//            [absExcepts addObjectsFromArray:Ports2Pits([AINetUtils conPorts_All:subDemand.mModel.matchFo])];
//        }
//    }
    
    //4. 收集不应期_之(1.父级 2.子级已失败 3.当前全树dsFo可适用于的所有问题);
    NSMutableArray *except_ps = [[NSMutableArray alloc] init];
    [except_ps addObjectsFromArray:baseExcepts];
    [except_ps addObjectsFromArray:failureExcepts];
    [except_ps addObjectsFromArray:dsExcepts];
    [except_ps addObjectsFromArray:absExcepts];
    
    //5. 子任务_对反思预测fo尝试转为子任务;
    for (AIMatchFoModel *item in rtInModel.matchPFos) {
        
        //6. 排除不应期
        if ([except_ps containsObject:item.matchFo.pointer]) continue;
        
        //7. 子任务_评分为负时才生成;
        CGFloat score = [AIScore score4MV:item.matchFo.cmvNode_p ratio:item.matchFoValue];
        if (score >= 0) continue;
        ReasonDemandModel *subDemand = [ReasonDemandModel newWithMModel:item inModel:rtInModel baseFo:baseFo];
        
        //8. 子任务_对其决策;
        NSInteger index = [rtInModel.matchPFos indexOfObject:item];
        NSLog(@"=====> 基于%@的反思PFo结果:(%ld/%ld)",FoP2FStr(baseFo.content_p),index,rtInModel.matchPFos.count);
        NSLog(@"=====> 生成R子任务:%@->%@",Fo2FStr(item.matchFo),Mvp2Str(item.matchFo.cmvNode_p));
        
        //NSLog(@"%@",TOModel2Root2Str(subDemand));
        NSLog(@"%@",TOModel2Sub2Str(rootDemand));
        if (createSubDemandBlock) {
            createSubDemandBlock(subDemand);
        }
        
        //9. 收集不应期之3: 已行为化的子任务中已顺利执行的ds解决方案,其下的所有场景fo加入不应期 (参考23102 & 23103);
        [except_ps addObjectsFromArray:[ThinkingUtils collectDiffBaseFoWhenDSFoIsFinishOrActYes:subDemand]];
        
        //9. 收集不应期_之抽象防重_收集当前还未失败所有任务的具象;
//        [except_ps addObjectsFromArray:Ports2Pits([AINetUtils conPorts_All:subDemand.mModel.matchFo])];
    }
    
    //10. 完成;
    if (finishBlock) {
        finishBlock(except_ps);
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
 *  MARK:--------------------dataIn_Mv时及时加到manager--------------------
 */
//-(void) dataIn_CmvAlgsArr:(NSArray*)algsArr{
//    [ThinkingUtils parserAlgsMVArr:algsArr success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p, NSInteger delta, NSInteger urgentTo, NSString *algsType) {
//        [self updateCMVCache_PMV:algsType urgentTo:urgentTo delta:delta order:urgentTo];
//    }];
//}

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
        if (ARRISOK(actYeses)) {
            //2021.03.17: 当actYes时,return nil即为单任务,continue即是多任务 (现为多任务,为调试直观可临时调为单任务,参考22173);
            continue;
        }
        
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
 *  @result notnull : 元素类型为ReasonDemandModel,抽具象层离rDemand越远,越排在后面;
 */
-(NSArray*) getRDemandBySameClass:(ReasonDemandModel*)rDemand isAbs:(BOOL)isAbs{
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
                return ISOK(item, ReasonDemandModel.class) && [SMGUtils containsSub_p:item.mModel.matchFo.pointer parent_ps:nextFos];
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
