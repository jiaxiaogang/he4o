//
//  DemandManager.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/4.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "DemandManager.h"

@interface DemandManager()

/**
 *  MARK:--------------------实时序列--------------------
 *  元素 : <DemandModel.class>
 *  思维因子_当前cmv序列(注:所有cmv只与cacheImv中作匹配)(正序,order越大,排越前)
 */
@property (strong,nonatomic) AsyncMutableArray *loopCache;

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
    self.loopCache = [[AsyncMutableArray alloc] init];
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
 *      2022.05.18: 废弃抵消功能 (反馈功能早已由TCFeedback来做,不需要这里弄);
 *      2022.09.20: 加PDemand开关功能,先继续开着,其实现在P任务已经不怎么用了,逐步关掉;
 *  @todo
 *      2022.xx.xx: 废弃P模式 (参考xx);
 */
-(void) updateCMVCache_PMV:(NSString*)algsType urgentTo:(NSInteger)urgentTo delta:(NSInteger)delta{
    //1. 数据检查
    if (delta == 0 || !Switch4PDemand) {
        return;
    }
    
    //2. 去重_同向撤弱,反向抵消;
    BOOL canNeed = true;
    NSInteger limit = self.loopCache.count;
    for (NSInteger i = 0; i < limit; i++) {
        DemandModel *checkItem = [self.loopCache objectAtIndex:i];
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
        [theTC updateEnergyDelta:urgentTo];
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
 *      2021.03.28: 此处algsType由urgentTo.at改成cmv.at,从mvNodeManager看这俩一致,如果出现bug再说;
 *      2021.07.14: 循环matchPFos时,采用反序,因为优先级和任务池优先级上弄反了 (参考23172);
 *      2021.11.11: 迭代RMV的生成机制,此代码其实啥也没改 (参考24107-1);
 *      2022.03.10: 为使鸟躲避及时停下,将迫切度再改回受评分迫切度等影响 (参考25142-改进);
 *      2022.05.02: 未形成新需求时,也更新energy (参考2523a-方案1);
 *      2022.05.18: 多pFos形成单个任务 (参考26042-TODO1);
 *      2022.05.18: 废弃抵消和防重功能,现在root各自工作,共用R和P反馈即可各自工作;
 *      2023.08.15: 传入protoFo,因为在pInput时和rInput时的protoFo是不同的,这个protoFo到决策时还要用 (参考30095代码段2);
 *  @result 将新增的root任务收集返回;
 */
-(NSArray*) updateCMVCache_RMV:(AIShortMatchModel*)inModel protoFo:(AIFoNodeBase*)protoFo{
    //1. 数据检查;
    NSMutableArray *newRootsResult = [[NSMutableArray alloc] init];
    if (!inModel || !protoFo || !Switch4RS) return newRootsResult;
    NSDictionary *fos4Demand = inModel.fos4Demand;
    
    //2. 多时序识别预测分别进行处理;
    for (NSString *atKey in fos4Demand.allKeys) {
        
        //3. 数据准备
        NSArray *pFosValue = [fos4Demand objectForKey:atKey];
        CGFloat score = [AIScore score4PFos:pFosValue];
        
        //5. 取迫切度评分: 判断matchingFo.mv有值才加入demandManager,同台竞争,执行顺应mv;
        if (score < 0) {
            
            //7. 有需求时,则加到需求序列中;
            ReasonDemandModel *newItem = [ReasonDemandModel newWithAlgsType:atKey pFos:pFosValue shortModel:inModel baseFo:nil protoFo:protoFo];
            [self.loopCache addObject:newItem];
            [newRootsResult addObject:newItem];
            
            //8. 设活跃度_将最大的任务x2取负值,为当前活跃度 (参考25142-改进);;
            //2021.05.27: 为方便测试,所有imv都给20迫切度 (因为迫切度太低话,还没怎么思考就停了);
            //2022.03.10: 为使鸟躲避及时停下,将迫切度再改回受评分迫切度等影响;
            [theTC updateEnergyValue:-score * 20];
            NSLog(@"RMV新需求: %@ (条数+1=%ld 评分:%@)",ClassName2Str(atKey),self.loopCache.count,Double2Str_NDZ(score));
            for (AIMatchFoModel *pFo in pFosValue) {
                AIFoNodeBase *matchFo = [SMGUtils searchNode:pFo.matchFo];
                NSLog(@"\t pFo:%@->{%.2f} SP:%@ indexDic:%@",Pit2FStr(pFo.matchFo),[AIScore score4MV_v2FromCache:pFo],CLEANSTR(matchFo.spDic),CLEANSTR(pFo.indexDic2));
            }
        }else{
            [theTC updateEnergyValue:-score * 20];
            NSLog(@"当前,预测mv未形成需求:%@ 评分:%f",atKey,score);
        }
    }
    NSLog(@"生成NewRoot数:%ld from:%@",newRootsResult.count,Fo2FStr(protoFo));
    
    //先试下新旧pFo有一致的情况;
    for (ReasonDemandModel *newRRoot in newRootsResult) {
        NSInteger newIndex = [self.loopCache indexOfObject:newRRoot];
        for (ReasonDemandModel *oldRRoot in self.loopCache.array) {
            if (![newRootsResult containsObject:newRRoot]) {
                //旧的成立;
                NSInteger oldIndex = [self.loopCache indexOfObject:oldRRoot];
                
                //取新旧有一样的matchFo (这里pFo没有重写equal方法,可能是不成的,试下先);
                NSArray *jiaoJi = [SMGUtils filterArrA:newRRoot.pFos arrB:oldRRoot.pFos];
                if (ARRISOK(jiaoJi)) {
                    NSLog(@"旧的pFos和新的有交集 %ld => %ld",oldIndex,newIndex);
                }
            }
        }
    }
    
    
    return newRootsResult;
}

/**
 *  MARK:--------------------重排序cmvCache--------------------
 *  1. 懒排序,什么时候assLoop,什么时候排序;
 *  @version
 *      2021.01.02: loopCache排序后未被接收,所以一直是未生效的BUG;
 *      2021.01.27: 支持第二级排序:initTime (参考22074-BUG2);
 *      2021.11.13: R任务排序根据 "迫切度*匹配度" 得出 (参考24107-2);
 *      2022.03.15: 将排序方式更新为用score4Demand (参考25142);
 *      2023.03.01: 修复排序反了的BUG: 评分越低越应该优先 (参考28136-修复);
 */
-(void) refreshCmvCacheSort{
    NSArray *sort = [SMGUtils sortBig2Small:self.loopCache.array compareBlock1:^double(DemandModel *obj) {
        return -[AIScore score4Demand:obj];
    } compareBlock2:^double(DemandModel *obj) {
        return obj.initTime;
    }];
    [self.loopCache removeAllObjects];
    [self.loopCache addObjectsFromArray:sort];
}

/**
 *  MARK:--------------------获取任务 (决策部分: 可继续决策的部分)--------------------
 *  @version
 *      xxxx.xx.xx: (未完成 & 非等待反馈ActYes);
 *      2021.12.23: root非WithOut状态的 (参考24212-6);
 *      2021.12.23: 最优末枝处在actYes状态时,继续secondRoot (参考24212-7);
 *      2022.06.01: 末端actYes时,root不应期,因为actYes是向上传染不向下 (参考26185-TODO3);
 *      2022.09.24: 失效处理: 根任务失效时,不进行决策 (参考27123-问题2-todo2);
 */
-(DemandModel*) getCanDecisionDemand{
    //1. 数据检查
    DemandModel *result = nil;
    if (!ARRISOK(self.loopCache.array)) return nil;
    
    //2. 重排序 & 取当前序列最前;
    [self refreshCmvCacheSort];
    
    //3. 逐个判断条件
    for (NSInteger j = 0; j < self.loopCache.count; j++) {
        ReasonDemandModel *item = ARR_INDEX(self.loopCache.array, j);
        if (Log4CanDecisionDemand) NSLog(@"root(%ld/%ld):%@ (%@) %@",j,self.loopCache.count,Pit2FStr(item.protoFo),[SMGUtils date2Str:kHHmmss timeInterval:item.initTime],[TOModelVision cur2Sub:item]);
    }
    for (NSInteger i = 0; i < self.loopCache.count; i++) {
        ReasonDemandModel *item = ARR_INDEX(self.loopCache.array, i);
        NSArray *pFoTitles = [SMGUtils convertArr:item.pFos convertBlock:^id(AIMatchFoModel *obj) {
            return STRFORMAT(@"F%ld",obj.matchFo.pointerId);
        }];
        NSString *itemDesc = STRFORMAT(@"proto:F%ld pFos:%@",item.protoFo.pointerId,CLEANSTR(pFoTitles));
        
        //3. 即使已经找到result,也把日志打完,方便调试日志中查看Demand的完整竞争情况;
        if (result) {
            if (Log4CanDecisionDemand) NSLog(@"\t第%ld条 %@ 评分%.2f \t\t\t{%@}",i+1,ClassName2Str(item.algsType),[AIScore score4Demand:item],itemDesc);
            continue;
        }
        
        //4. 已完成时,下一个;
        if (item.status == TOModelStatus_Finish) {
            if (Log4CanDecisionDemand) NSLog(@"\t第%ld条 %@ 评分%.2f 因FINISH 失败 \t{%@}",i+1,ClassName2Str(item.algsType),[AIScore score4Demand:item],itemDesc);
            continue;
        }
        
        //4. 已无计可施,下一个 (TCPlan会优先从末枝执行,所以当root就是末枝时,说明整个三条大树干全烂透没用了);
        if (item.status == TOModelStatus_WithOut) {
            if (Log4CanDecisionDemand) NSLog(@"\t第%ld条 %@ 评分%.2f 因WithOut 失败 \t{%@}",i+1,ClassName2Str(item.algsType),[AIScore score4Demand:item],itemDesc);
            continue;
        }
        
        //4. 当任务失效时,不返回;
        if (ISOK(item, ReasonDemandModel.class) && ((ReasonDemandModel*)item).isExpired) {
            if (Log4CanDecisionDemand) NSLog(@"\t第%ld条 %@ 评分%.2f 因isExpired 失败 \t{%@}",i+1,ClassName2Str(item.algsType),[AIScore score4Demand:item],itemDesc);
            continue;
        }
        
        //5. 最末枝在actYes状态时,不应期,继续secondRoot;
        BOOL endHavActYes = [TOUtils endHavActYes:item];
        if (endHavActYes){
            if (Log4CanDecisionDemand) NSLog(@"\t第%ld条 %@ 评分%.2f 因endHavActYes 失败 \t{%@}",i+1,ClassName2Str(item.algsType),[AIScore score4Demand:item],itemDesc);
            continue;
        }
        
        //6. 有效,则记录;
        NSLog(@"\t第%ld条 %@ 评分%.2f 激活成功 \t{%@}",i+1,ClassName2Str(item.algsType),[AIScore score4Demand:item],itemDesc);
        result = item;
    }
    NSLog(@"Demand竞争 <<<== %@ 共%ld条",result?@"SUCCESS":@"FAILURE",self.loopCache.count);
    return result;
}

/**
 *  MARK:--------------------获取任务 (全部返回: 用于反馈和可视化等)--------------------
 *  @desc 排序方式: 从大到小;
 */
-(NSArray*) getAllDemand{
    [self refreshCmvCacheSort];
    return self.loopCache.array;
}

/**
 *  MARK:--------------------移除某任务--------------------
 */
-(void) removeDemand:(DemandModel*)demand{
    if (ISOK(demand, ReasonDemandModel.class)) NSLog(@"demandManager >> 移除R任务:%@",((ReasonDemandModel*)demand).algsType);
    if (demand) [self.loopCache removeObject:demand];
}

-(void) clear{
    [self.loopCache removeAllObjects];
}

@end
