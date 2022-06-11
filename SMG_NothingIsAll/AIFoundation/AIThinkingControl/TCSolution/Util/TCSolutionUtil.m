//
//  TCSolutionUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/6/5.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TCSolutionUtil.h"

@implementation TCSolutionUtil


//MARK:===============================================================
//MARK:                     < 快思考 >
//MARK:===============================================================

/**
 *  MARK:--------------------R快思考--------------------
 *  @desc 习惯 (参考26142);
 */
+(AISolutionModel*) rSolution_Fast:(ReasonDemandModel *)demand except_ps:(NSArray*)except_ps{
    //1. 数据准备;
    except_ps = ARRTOOK(except_ps);
    
    //2. 收集所有解决方案候选集;
    NSArray *cansets = [SMGUtils convertArr:demand.pFos convertItemArrBlock:^NSArray *(AIMatchFoModel *obj) {
        AIFoNodeBase *pFo = [SMGUtils searchNode:obj.matchFo];
        NSArray *itemCansets = [pFo.effectDic objectForKey:@(pFo.count)];
        if (Log4Solution_Fast && ARRISOK(itemCansets)) NSLog(@"\tF%ld的第%ld帧取: %@",pFo.pointer.pointerId,pFo.count,CLEANSTR(itemCansets));
        
        //TODOTOMORROW20220611: 直接用analyst分析打分;
        for (AIEffectStrong *canset in itemCansets) {
            [AIAnalyst compareRCansetFo:canset.solutionFo pFo:obj demand:demand];
        }
        
        
        return itemCansets;
    }];
    
    //3. 快思考算法;
    return [TCSolutionUtil generalSolution_Fast:demand cansets:cansets except_ps:except_ps solutionModelBlock:^AISolutionModel *(AIEffectStrong *canset) {
        return [AIAnalyst compareRCansetFo:canset.solutionFo pFo:nil demand:demand];
    }];
}

/**
 *  MARK:--------------------H快思考--------------------
 *  @desc 习惯 (参考26142);
 */
+(AISolutionModel*) hSolution_Fast:(HDemandModel *)hDemand except_ps:(NSArray*)except_ps{
    //1. 数据准备;
    TOFoModel *targetFoM = (TOFoModel*)hDemand.baseOrGroup.baseOrGroup;
    AIFoNodeBase *targetFo = [SMGUtils searchNode:targetFoM.content_p];
    
    //2. 从targetFo取解决方案候选集;
    NSArray *cansets = [targetFo.effectDic objectForKey:@(targetFoM.actionIndex)];
    
    //3. 快思考算法;
    return [TCSolutionUtil generalSolution_Fast:hDemand cansets:cansets except_ps:except_ps solutionModelBlock:^AISolutionModel *(AIEffectStrong *canset) {
        return [AIAnalyst compareHCansetFo:canset.solutionFo targetFo:targetFoM];
    }];
}

/**
 *  MARK:--------------------快思考--------------------
 *  @desc 习惯 (参考26142);
 *  @version
 *      2022.06.03: 将cansets中hnStrong合并,一直这么设计的,今发现写没实现,补上;
 *      2022.06.03: 排除掉候选方案不适用当前场景的 (参考26192);
 *      2022.06.05: 支持三个阈值 (参考26199);
 *      2022.06.05: 将R快思考和H快思考整理成通用快思考算法;
 *      2022.06.09: 废弃阈值方案和H>5的要求 (参考26222-TODO3);
 *      2022.06.09: 弃用阈值方案,改为综合排名 (参考26222-TODO2);
 */
+(AISolutionModel*) generalSolution_Fast:(DemandModel *)demand cansets:(NSArray*)cansets except_ps:(NSArray*)except_ps solutionModelBlock:(AISolutionModel*(^)(AIEffectStrong *canset))solutionModelBlock{
    //1. 数据准备;
    except_ps = ARRTOOK(except_ps);
    BOOL havBack = ISOK(demand, HDemandModel.class); //H有后段,别的没有;
    NSLog(@"1. 快思考protoCansets数:%ld",cansets.count);

    //2. 将同cansetFo的effStrong累计;
    cansets = [TOUtils mergeCansets:cansets];
    NSLog(@"2. 按HNStrong合并后:%ld %@",cansets.count,CLEANSTR(cansets));

    //3. cansets过滤器;
    cansets = [SMGUtils filterArr:cansets checkValid:^BOOL(AIEffectStrong *item) {
        //1. hStrong阈值 (参考26199-TODO2);
        //if (item.hStrong < 5) return false;

        //2. 排除不应期;
        if ([except_ps containsObject:item.solutionFo]) return false;

        //3. 闯关成功;
        return true;
    }];
    NSLog(@"3. HStrong>5和不应期过滤后:%ld",cansets.count);

    //4. 转solutionModel & 排除掉候选方案不适用当前场景(为nil)的 和 有效率为0的 (参考26192);;
    NSArray *solutionModels = [SMGUtils convertArr:cansets convertBlock:^id(AIEffectStrong *obj) {
        AISolutionModel *sModel = solutionModelBlock(obj);
        if (sModel) sModel.effectScore = [TOUtils getEffectScore:obj];
        return sModel;
    }];
    solutionModels = [SMGUtils filterArr:solutionModels checkValid:^BOOL(AISolutionModel *item) {
        return item.effectScore > 0;
    }];
    NSLog(@"4. 时序对比有效后:%ld",solutionModels.count);

    //5. solutionModels过滤器;
    solutionModels = [SMGUtils filterArr:solutionModels checkValid:^BOOL(AISolutionModel *item) {
        //1. 时间不急评价: 不急 = 解决方案所需时间 <= 父任务能给的时间 (参考:24057-方案3,24171-7);
        if (![AIScore FRS_Time:demand solutionModel:item]) return false;

        ////2. 后段-目标匹配 (阈值>80%) (参考26199-TODO1);
        //if (item.backMatchValue < 0.8f) return false;
        //
        ////3. 中段-按有效率 (effectScore>0) (参考26199-TODO2);
        //if (item.effectScore <= 0) return false;
        //
        ////4. 前段-场景匹配 (阈值>80%) (参考26199-TODO3);
        //if (item.frontMatchValue < 0.8) return false;

        //5. 闯关成功;
        return true;
    }];
    NSLog(@"5. (FRSTime & 后段阈值 & 中段阈值 & 前段阈值)过滤后:%ld",solutionModels.count);

    //6. 对候选集排序;
    NSArray *sortSolutionModels = [TOUtils solutionTotalRanking:solutionModels needBack:havBack fromSlow:false];
    NSLog(@"6. 有效率排序后:%ld",sortSolutionModels.count);
    if (Log4Solution_Fast) for (AISolutionModel *m in sortSolutionModels) {
        AIEffectStrong *c = [SMGUtils filterSingleFromArr:cansets checkValid:^BOOL(AIEffectStrong *item) {
            return [item.solutionFo isEqual:m.cansetFo];
        }];
        NSLog(@"\tH%ldN%ld %@",c.hStrong,c.nStrong,Pit2FStr(m.cansetFo));
    }

    //7. 将首条最佳方案返回;
    AISolutionModel *result = ARR_INDEX(sortSolutionModels, 0);
    if (Log4Solution && result) NSLog(@"7. 快思考最佳结果:F%ld 有效率:%.2f",result.cansetFo.pointerId,result.effectScore);
    return result;
}


//MARK:===============================================================
//MARK:                     < 慢思考 >
//MARK:===============================================================

/**
 *  MARK:--------------------H慢思考--------------------
 */
+(AISolutionModel*) hSolution_Slow:(HDemandModel *)hDemand except_ps:(NSArray*)except_ps{
    //1. 取targetFo;
    TOFoModel *targetFoModel = (TOFoModel*)hDemand.baseOrGroup.baseOrGroup;
    AIFoNodeBase *targetFo = [SMGUtils searchNode:targetFoModel.content_p];
    
    //2. 慢思考;
    return [self generalSolution_Slow:hDemand maskFos:@[targetFo.pointer] except_ps:except_ps solutionModelBlock:^AISolutionModel *(AIKVPointer *canset) {
        return [AIAnalyst compareHCansetFo:canset targetFo:targetFoModel];
    }];
}

/**
 *  MARK:--------------------R慢思考--------------------
 */
+(AISolutionModel*) rSolution_Slow:(ReasonDemandModel *)demand except_ps:(NSArray*)except_ps {
    //1. 取pFos;
    NSArray *pFos = [SMGUtils convertArr:demand.pFos convertBlock:^id(AIMatchFoModel *obj) {
        return obj.matchFo;
    }];

    //2. 慢思考;
    return [self generalSolution_Slow:demand maskFos:pFos except_ps:except_ps solutionModelBlock:^AISolutionModel *(AIKVPointer *canset) {
        return [AIAnalyst compareRCansetFo:canset pFo:nil demand:demand];
    }];
}

/**
 *  MARK:--------------------慢思考--------------------
 *  @desc 思考求解: 前段匹配,中段加工,后段静默 (参考26127);
 *  @param maskFos : R时传pFos & H时传targetFo;
 *  @version
 *      2022.06.04: 修复结果与当前场景相差甚远BUG: 分三级排序窄出 (参考26194 & 26195);
 *      2022.06.09: 将R和H的慢思考封装成同一方法,方便调用和迭代;
 *      2022.06.09: 弃用阈值方案,改为综合排名 (参考26222-TODO2);
 */
+(AISolutionModel*) generalSolution_Slow:(DemandModel *)demand maskFos:(NSArray*)maskFos except_ps:(NSArray*)except_ps solutionModelBlock:(AISolutionModel*(^)(AIKVPointer *canset))solutionModelBlock{
    //1. 数据准备;
    except_ps = ARRTOOK(except_ps);
    AISolutionModel *result = nil;
    BOOL havBack = ISOK(demand, HDemandModel.class); //H有后段,别的没有;
    NSLog(@"第1步 起点Fos数:%ld",maskFos.count);
    
    //2. 取absPFos
    NSArray *absFos = [SMGUtils convertArr:maskFos convertItemArrBlock:^NSArray *(AIKVPointer *obj) {
        AIFoNodeBase *pFo = [SMGUtils searchNode:obj];
        return Ports2Pits([AINetUtils absPorts_All:pFo]);
    }];
    absFos = [SMGUtils removeRepeat:absFos];
    NSLog(@"第2步 absFos数:%ld",absFos.count);//测时10条
    
    //3. 取同级;
    NSArray *sameLayerFos = [SMGUtils convertArr:absFos convertItemArrBlock:^NSArray *(AIKVPointer *obj) {
        AIFoNodeBase *absFo = [SMGUtils searchNode:obj];
        return Ports2Pits([AINetUtils conPorts_All:absFo]);
    }];
    sameLayerFos = [SMGUtils removeRepeat:sameLayerFos];
    NSLog(@"第3步 sameLayerFos数:%ld",sameLayerFos.count);//测时749条
    
    //4. 收集起来 (参考26161-0);
    NSMutableArray *cansetFos = [[NSMutableArray alloc] init];
    [cansetFos addObjectsFromArray:maskFos];
    [cansetFos addObjectsFromArray:absFos];
    [cansetFos addObjectsFromArray:sameLayerFos];
    cansetFos = [SMGUtils removeRepeat:cansetFos];
    NSLog(@"第4步 cansetFos数:%ld",cansetFos.count);//测时758条
    
    //5. 过滤掉长度不够的 (因为前段全含至少要1位,中段修正也至少要0位,后段H目标要1位R要0位);
    int minCount = havBack ? 2 : 1;
    cansetFos = [SMGUtils filterArr:cansetFos checkValid:^BOOL(AIKVPointer *item) {
        AIFoNodeBase *fo = [SMGUtils searchNode:item];
        return fo.count >= minCount;
    }];
    NSLog(@"第5步 最小长度2:%ld",cansetFos.count);//测时149条
    
    //6. 过滤掉有负mv指向的 (参考26063 & 26127-TODO8);
    cansetFos = [SMGUtils filterArr:cansetFos checkValid:^BOOL(AIKVPointer *item) {
        AIFoNodeBase *fo = [SMGUtils searchNode:item];
        return ![ThinkingUtils havDemand:fo.cmvNode_p];
    }];
    NSLog(@"第6步 非负价值:%ld",cansetFos.count);//测时96条
    
    //7. 对比cansetFo和protoFo/taretFo匹配,得出对比结果 (参考26128-第1步 & 26161-1&2&3);
    NSArray *solutionModels = [SMGUtils convertArr:cansetFos convertBlock:^id(AIKVPointer *obj) {
        return solutionModelBlock(obj);
    }];
    NSLog(@"第7步 对比匹配成功:%ld",solutionModels.count);//测时94条
    
    //8. 排除不应期;
    solutionModels = [SMGUtils filterArr:solutionModels checkValid:^BOOL(AISolutionModel *item) {
        return ![except_ps containsObject:item.cansetFo];
    }];
    NSLog(@"第8步 排除不应期:%ld",solutionModels.count);//测时xx条
    
    //9. 对下一帧做时间不急评价: 不急 = 解决方案所需时间 <= 父任务能给的时间 (参考:24057-方案3,24171-7);
    solutionModels = [SMGUtils filterArr:solutionModels checkValid:^BOOL(AISolutionModel *item) {
        return [AIScore FRS_Time:demand solutionModel:item];
    }];
    NSLog(@"第9步 排除FRSTime来不及的:%ld",solutionModels.count);//测时xx条
    
    //10. 计算衰后stableScore并筛掉为0的 (参考26128-2-1 & 26161-5);
    NSArray *outOfFos = [SMGUtils convertArr:solutionModels convertBlock:^id(AISolutionModel *obj) {
        return obj.cansetFo;
    }];
    for (AISolutionModel *model in solutionModels) {
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:model.cansetFo];
        model.stableScore = [TOUtils getColStableScore:cansetFo outOfFos:outOfFos startSPIndex:model.cutIndex + 1 endSPIndex:model.targetIndex];
    }
    solutionModels = [SMGUtils filterArr:solutionModels checkValid:^BOOL(AISolutionModel *item) {
        return item.stableScore > 0;
    }];
    
    //11. 根据候选集综合分排序 (参考26128-2-2 & 26161-4);
    NSArray *sortModels = [TOUtils solutionTotalRanking:solutionModels needBack:havBack fromSlow:true];
    
    //12. debugLog
    for (AISolutionModel *model in sortModels) {
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:model.cansetFo];
        if (Log4Solution_Slow) NSLog(@"> %@\n\t综合排名:%ld = 前匹配:%.2f x 中稳定:%.2f x 后相近:%.2f >> %@",Pit2FStr(model.cansetFo),[sortModels indexOfObject:model],model.frontMatchValue,model.stableScore,model.backMatchValue,CLEANSTR(cansetFo.spDic));
    }
    
    //13. 返回最佳解决方案;
    result = ARR_INDEX(sortModels, 0);
    AIFoNodeBase *resultFo = [SMGUtils searchNode:result.cansetFo];
    NSLog(@"取得慢思考最佳结果:F%ld 评分 = 前匹配:%.2f x 中稳定:%.2f x后相近:%.2f %@",result.cansetFo.pointerId,result.frontMatchValue,result.stableScore,result.backMatchValue,CLEANSTR(resultFo.spDic));
    return result;
}

@end
