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
 *  @version
 *      2022.11.30: 先关掉快思考功能,因为慢思考有了indexDic和相似度复用后并不慢,并且effectDic和SP等效 (参考27205);
 */
+(AISolutionModel*) rSolution_Fast:(ReasonDemandModel *)demand except_ps:(NSArray*)except_ps{
    if (!Switch4FastSolution) return nil;
    //1. 数据准备;
    except_ps = ARRTOOK(except_ps);
    
    //2. 收集所有解决方案候选集;
    NSArray *cansetModels = [SMGUtils convertArr:demand.pFos convertItemArrBlock:^NSArray *(AIMatchFoModel *pFoM) {
        //a. 取出pFo的effectDic候选集;
        AIFoNodeBase *pFo = [SMGUtils searchNode:pFoM.matchFo];
        NSArray *cansetFos = [pFo getValidEffs:pFo.count];
        if (Log4Solution_Fast && ARRISOK(cansetFos)) NSLog(@"\tF%ld的第%ld帧取: %@",pFo.pointer.pointerId,pFo.count,CLEANSTR(cansetFos));
        
        //b. 分析analyst结果 & 排除掉不适用当前场景的(为nil) (参考26232-TODO8);
        return [SMGUtils convertArr:cansetFos convertBlock:^id(AIEffectStrong *eff) {
            //c. 分析比对结果;
            NSInteger rAleardayCount = [self getRAleardayCount:demand pFo:pFoM];
            AISolutionModel *sModel = [AIAnalyst compareCansetFo:eff.solutionFo basePFoOrTargetFoModel:pFoM ptAleardayCount:rAleardayCount isH:false];
            
            //d. 快思考附加effScore分,并收集成果;
            if (sModel) sModel.effectScore = [TOUtils getEffectScore:eff];
            return sModel;
        }];
    }];
    
    //3. 快思考算法;
    return [TCSolutionUtil generalSolution_Fast:demand cansets:cansetModels except_ps:except_ps];
}

/**
 *  MARK:--------------------H快思考--------------------
 *  @desc 习惯 (参考26142);
 *  @version
 *      2022.11.30: 先关掉快思考功能,因为慢思考有了indexDic和相似度复用后并不慢,并且effectDic和SP等效 (参考27205);
 */
+(AISolutionModel*) hSolution_Fast:(HDemandModel *)hDemand except_ps:(NSArray*)except_ps{
    if (!Switch4FastSolution) return nil;
    //1. 数据准备;
    TOFoModel *targetFoM = (TOFoModel*)hDemand.baseOrGroup.baseOrGroup;
    AIFoNodeBase *targetFo = [SMGUtils searchNode:targetFoM.content_p];
    
    //2. 从targetFo取解决方案候选集;
    NSArray *cansetFos = [targetFo.effectDic objectForKey:@(targetFoM.actionIndex)];
    
    //3. 分析analyst结果 & 排除掉不适用当前场景的(为nil) (参考26232-TODO8);
    NSArray *cansetModels = [SMGUtils convertArr:cansetFos convertBlock:^id(AIEffectStrong *eff) {
        //a. 分析比对结果;
        NSInteger hAleardayCount = [self getHAleardayCount:targetFoM];
        AISolutionModel *sModel = [AIAnalyst compareCansetFo:eff.solutionFo basePFoOrTargetFoModel:targetFoM ptAleardayCount:hAleardayCount isH:true];
        
        //b. 快思考附加effScore分,并收集成果;
        if (sModel) sModel.effectScore = [TOUtils getEffectScore:eff];
        return sModel;
    }];
    
    //3. 快思考算法;
    return [TCSolutionUtil generalSolution_Fast:hDemand cansets:cansetModels except_ps:except_ps];
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
 *      2022.06.12: 废弃同cansetFo的effStrong累计 (参考26232-TODO8);
 *      2022.06.12: 每个pFo独立做analyst比对,转为cansetModels (参考26232-TODO8);
 *      2022.10.15: 快思考支持反思,不然因为一点点小任务就死循环 (参考27143-问题2);
 */
+(AISolutionModel*) generalSolution_Fast:(DemandModel *)demand cansets:(NSArray*)cansets except_ps:(NSArray*)except_ps{
    //1. 数据准备;
    except_ps = ARRTOOK(except_ps);
    BOOL havBack = ISOK(demand, HDemandModel.class); //H有后段,别的没有;
    NSLog(@"1. 快思考protoCansets数:%ld",cansets.count);
    
    //2. solutionModels过滤器;
    cansets = [SMGUtils filterArr:cansets checkValid:^BOOL(AISolutionModel *item) {
        //a. 排除不应期;
        if([except_ps containsObject:item.cansetFo]) return false;
        
        //b. 时间不急评价: 不急 = 解决方案所需时间 <= 父任务能给的时间 (参考:24057-方案3,24171-7);
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
    NSLog(@"2. (不应期 & FRSTime & 后中后段阈值)过滤后:%ld",cansets.count);

    //6. 对候选集排序;
    NSArray *sortCansets = [AIRank solutionFoRanking:cansets needBack:havBack fromSlow:false];
    NSLog(@"3. 有效率排序后:%ld",cansets.count);
    if (Log4Solution_Fast) for (AISolutionModel *m in ARR_SUB(sortCansets, 0, 5)) {
        NSLog(@"\t(前%.2f 中%.2f 后%.2f) %@",m.frontMatchValue,m.effectScore,m.backMatchValue,Pit2FStr(m.cansetFo));
    }

    //6. 逐条S反思;
    AISolutionModel *result = nil;
    for (AISolutionModel *item in sortCansets) {
        BOOL score = [TCRefrection refrection:item demand:demand];
        if (score) {
            result = item;
            break;
        }
    }
    
    //7. 将首条最佳方案返回;
    if (Log4Solution && result) NSLog(@"4. 快思考最佳结果:F%ld (前%.2f 中%.2f 后%.2f",result.cansetFo.pointerId,result.frontMatchValue,result.effectScore,result.backMatchValue);
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
    
    //2. 取出cansetFos候选集;
    //TODOTEST20221123: 测下此处取actionIndex是否正确...
    NSArray *cansetFos = [self getCansetFos_SlowV2:targetFoModel.content_p targetIndex:targetFoModel.actionIndex];
    
    //3. 过滤器;
    NSInteger hAleardayCount = [self getHAleardayCount:targetFoModel];
    cansetFos = [self slowCansetFosFilterV2:cansetFos demand:hDemand ptAleardayCount:hAleardayCount basePFoOrTargetFoModel:targetFoModel];
    
    //3. 转cansetModels候选集 (参考26128-第1步 & 26161-1&2&3);
    NSArray *cansetModels = [SMGUtils convertArr:cansetFos convertBlock:^id(AIKVPointer *cansetFo_p) {
        return [AIAnalyst compareCansetFo:cansetFo_p basePFoOrTargetFoModel:targetFoModel ptAleardayCount:hAleardayCount isH:true];
    }];
    
    //4. 慢思考;
    return [self generalSolution_Slow:hDemand cansetModels:cansetModels except_ps:except_ps];
}

/**
 *  MARK:--------------------R慢思考--------------------
 */
+(AISolutionModel*) rSolution_Slow:(ReasonDemandModel *)demand except_ps:(NSArray*)except_ps {
    //1. 收集cansetModels候选集;
    NSArray *cansetModels = [SMGUtils convertArr:demand.pFos convertItemArrBlock:^NSArray *(AIMatchFoModel *pFo) {
        
        //2. 取出cansetFos候选集;
        AIFoNodeBase *matchFo = [SMGUtils searchNode:pFo.matchFo];
        NSArray *cansetFos = [self getCansetFos_SlowV2:pFo.matchFo targetIndex:matchFo.count];
        
        //3. 过滤器;
        NSInteger rAleardayCount = [self getRAleardayCount:demand pFo:pFo];
        cansetFos = [self slowCansetFosFilterV2:cansetFos demand:demand ptAleardayCount:rAleardayCount basePFoOrTargetFoModel:pFo];
        
        //3. 转cansetModels候选集 (参考26128-第1步 & 26161-1&2&3);
        NSArray *cansetModels = [SMGUtils convertArr:cansetFos convertBlock:^id(AIKVPointer *cansetFo_p) {
            return [AIAnalyst compareCansetFo:cansetFo_p basePFoOrTargetFoModel:pFo ptAleardayCount:rAleardayCount isH:false];
        }];
        return cansetModels;
    }];

    //4. 慢思考;
    return [self generalSolution_Slow:demand cansetModels:cansetModels except_ps:except_ps];
}

/**
 *  MARK:--------------------慢思考--------------------
 *  @desc 思考求解: 前段匹配,中段加工,后段静默 (参考26127);
 *  @version
 *      2022.06.04: 修复结果与当前场景相差甚远BUG: 分三级排序窄出 (参考26194 & 26195);
 *      2022.06.09: 将R和H的慢思考封装成同一方法,方便调用和迭代;
 *      2022.06.09: 弃用阈值方案,改为综合排名 (参考26222-TODO2);
 *      2022.06.12: 每个pFo独立做analyst比对,转为cansetModels (参考26232-TODO8);
 */
+(AISolutionModel*) generalSolution_Slow:(DemandModel *)demand cansetModels:(NSArray*)cansetModels except_ps:(NSArray*)except_ps {
    //1. 数据准备;
    [AITest test13:cansetModels];
    except_ps = ARRTOOK(except_ps);
    AISolutionModel *result = nil;
    BOOL havBack = ISOK(demand, HDemandModel.class); //H有后段,别的没有;
    NSLog(@"第5步 Anaylst匹配成功:%ld",cansetModels.count);//测时94条
    
    //8. 排除不应期;
    cansetModels = [SMGUtils filterArr:cansetModels checkValid:^BOOL(AISolutionModel *item) {
        return ![except_ps containsObject:item.cansetFo];
    }];
    NSLog(@"第6步 排除不应期:%ld",cansetModels.count);//测时xx条
    
    //9. 对下一帧做时间不急评价: 不急 = 解决方案所需时间 <= 父任务能给的时间 (参考:24057-方案3,24171-7);
    cansetModels = [SMGUtils filterArr:cansetModels checkValid:^BOOL(AISolutionModel *item) {
        return [AIScore FRS_Time:demand solutionModel:item];
    }];
    NSLog(@"第7步 排除FRSTime来不及的:%ld",cansetModels.count);//测时xx条
    
    //10. 计算衰后stableScore并筛掉为0的 (参考26128-2-1 & 26161-5);
    NSArray *outOfFos = [SMGUtils convertArr:cansetModels convertBlock:^id(AISolutionModel *obj) {
        return obj.cansetFo;
    }];
    for (AISolutionModel *model in cansetModels) {
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:model.cansetFo];
        model.stableScore = [TOUtils getColStableScore:cansetFo outOfFos:outOfFos startSPIndex:model.cutIndex + 1 endSPIndex:model.targetIndex];
    }
    cansetModels = [SMGUtils filterArr:cansetModels checkValid:^BOOL(AISolutionModel *item) {
        return item.stableScore > 0;
    }];
    NSLog(@"第8步 排序中段稳定性<=0的:%ld",cansetModels.count);//测时xx条
    
    //11. 根据候选集综合分排序 (参考26128-2-2 & 26161-4);
    NSArray *sortModels = [AIRank solutionFoRanking:cansetModels needBack:havBack fromSlow:true];
    
    //12. debugLog
    for (AISolutionModel *model in sortModels) {
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:model.cansetFo];
        if (Log4Solution_Slow) NSLog(@"> %@\n\t综合排名:%ld (前%.2f 中%.2f 后%.2f) >> %@",Pit2FStr(model.cansetFo),[sortModels indexOfObject:model],model.frontMatchValue,model.stableScore,model.backMatchValue,CLEANSTR(cansetFo.spDic));
    }
    
    //13. 逐条S反思;
    for (AISolutionModel *item in sortModels) {
        BOOL score = [TCRefrection refrection:item demand:demand];
        if (score) {
            result = item;
            break;
        }
    }
    
    //14. 返回最佳解决方案;
    if (result) {
        AIFoNodeBase *resultFo = [SMGUtils searchNode:result.cansetFo];
        NSLog(@"慢思考最佳结果:F%ld (前%.2f 中%.2f 后%.2f) %@",result.cansetFo.pointerId,result.frontMatchValue,result.stableScore,result.backMatchValue,CLEANSTR(resultFo.spDic));
    }
    return result;
}


//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------取候选集fos--------------------
 *  @param pFoOrTargetFoOfMatch_p : R时传pFo, H时传targetFo;
 *  @version
 *      2022.07.14: 将取抽象,同级,自身全废弃掉,改为仅取具象 (参考27049);
 *      2022.07.15: 每个pFo下支持limit (参考27048-TODO6);
 *      2022.11.19: v2更新,支持从conCansets中取数据 (参考20202-1)
 *      2022.11.19: v2的limit由5改为500 (因为conCansets的复用数据更多,性能ok) (参考27202-2);
 */
+(NSArray*) getCansetFos_SlowV2:(AIKVPointer*)pFoOrTargetFoOfMatch_p targetIndex:(NSInteger)targetIndex{
    int cansetLimit = 500;
    AIFoNodeBase *matchFo = [SMGUtils searchNode:pFoOrTargetFoOfMatch_p];
    return ARR_SUB([matchFo getConCansets:targetIndex], 0, cansetLimit);
}

/**
 *  MARK:--------------------cansetFos过滤器--------------------
 *  @version
 *      2022.07.14: S的价值pk迭代: 将过滤负价值的,改成过滤无价值指向的 (参考27048-TODO4&TODO9);
 *      2022.07.20: 不要求mv指向 (参考27055-步骤1);
 *      2023.01.08: 加上条件满足过滤器-R任务部分 (参考28022);
 *      2023.01.08: V1末版说明: 根据28025,递归找match,proto,canset三者的映射,来判断条件满足,已废弃 (参考28023&28051);
 *      2023.02.04: V2版本,解决原方式条件满足不完全问题 (参考28052);
 *      2023.02.04: 修复条件满足不完全问题 (参考28052);
 *  @param ptAleardayCount : 即取得"canset的basePFoOrTargetFo推进到哪了"的截点 (aleardayCount = cutIndex+1 或 actionIndex);
 */
+(NSArray*) slowCansetFosFilterV2:(NSArray*)cansetFos demand:(DemandModel*)demand ptAleardayCount:(NSInteger)ptAleardayCount basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel{
    //1. 数据准备;
    BOOL havBack = ISOK(demand, HDemandModel.class); //H有后段,别的没有;
    int minCount = havBack ? 2 : 1;
    
    //2. 过滤器;
    cansetFos = [SMGUtils filterArr:cansetFos checkValid:^BOOL(AIKVPointer *cansetFo_p) {
        //3. 过滤器1===: 过滤掉长度不够的 (因为前段全含至少要1位,中段修正也至少要0位,后段H目标要1位R要0位);
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:cansetFo_p];
        if (cansetFo.count < minCount) return false;
        
        //4. 取出pFoOrTargetFo
        AIKVPointer *matchFo_p = [TOUtils convertBaseFoFromBasePFoOrTargetFoModel:basePFoOrTargetFoModel];
        AIFoNodeBase *matchFo = [SMGUtils searchNode:matchFo_p];
        
        //5. 根据matchFo取得与canset的indexDic映射;
        NSDictionary *cansetMatchIndexDic = [matchFo getConIndexDic:cansetFo.pointer];
        //NSLog(@"第3步 cansetFo%@",Fo2FStr(cansetFo));
        
        //7. 根据ptAleardayCount取出对应的cansetIndex,做为中段截点 (aleardayCount - 1 = cutIndex);
        NSInteger matchCutIndex = ptAleardayCount - 1;
        NSInteger cansetCutIndex = NUMTOOK([cansetMatchIndexDic objectForKey:@(matchCutIndex)]).integerValue;
        
        //8. 过滤器2===: 过滤掉canset没后段的 (没可行为化的东西) (参考28052-4);
        if (cansetFo.count <= cansetCutIndex + 1) return false;
        
        //9. 递归找到protoFo;
        AIMatchFoModel *pFo = [self getPFo:cansetFo_p basePFoOrTargetFoModel:basePFoOrTargetFoModel];
        AIKVPointer *protoFo_p = pFo.baseRDemand.protoOrRegroupFo;
        AIFoNodeBase *protoFo = [SMGUtils searchNode:protoFo_p];
        
        //10. 过滤器3===: 过滤掉条件不满足的 (protoFo对cansetFo条件满足) 注:此时canset是proto的抽象 (参考28052-2);
        //说明: 所有已发生帧,都要判断一下条件满足 (ptAleardayCount之前全是前段) (参考28022-todo4);
        BOOL findAbsFromProto = [self sceneIsOk:protoFo absFo:cansetFo absCutIndex:cansetCutIndex];
        if (!findAbsFromProto) return false;
        
        //11. 闯关成功;
        NSLog(@"\t过滤器全部通过\n");
        return true;
    }];
    NSLog(@"第4步 最小长度 & 非负价值过滤后:%ld",cansetFos.count);//测时96条
    return cansetFos;
}

+(NSInteger) getRAleardayCount:(ReasonDemandModel*)rDemand pFo:(AIMatchFoModel*)pFo{
    //1. 数据准备;
    BOOL isRoot = !rDemand.baseOrGroup;
    TOFoModel *demandBaseFo = (TOFoModel*)rDemand.baseOrGroup;
    
    //3. 取pFo已发生个数 (参考26232-TODO3);
    NSInteger pFoAleardayCount = 0;
    if (isRoot) {
        //a. 根R任务时 (参考26232-TODO5);
        pFoAleardayCount = pFo.cutIndex + 1;
    }else{
        //b. 子R任务时 (参考26232-TODO6);
        pFoAleardayCount = [SMGUtils filterArr:pFo.indexDic2.allValues checkValid:^BOOL(NSNumber *item) {
            int maskIndex = item.intValue;
            return maskIndex <= demandBaseFo.actionIndex;
        }].count;
    }
    return pFoAleardayCount;
}

+(NSInteger) getHAleardayCount:(TOFoModel*)targetFoM {
    //1. 已发生个数 (targetFo已行为化部分即已发生) (参考26161-模型);
    NSInteger targetFoAleardayCount = targetFoM.actionIndex;
    return targetFoAleardayCount;
}

/**
 *  MARK:--------------------递归找出pFo (参考28025-todo8)--------------------
 *  @desc 适用范围: 即可用于R任务,也可用于H任务;
 *  @desc 执行说明: H任务会自动递归,直到找到R为止   /   R任务不会递归,直接返回R的pFo;
 */
+(AIMatchFoModel*) getPFo:(AIKVPointer*)cansetFo_p basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel {
    //1. 本次非R时: 继续递归;
    if (ISOK(basePFoOrTargetFoModel, TOFoModel.class)) {
        TOFoModel *baseTargetFo = (TOFoModel*)basePFoOrTargetFoModel;
        return [self getPFo:baseTargetFo.content_p basePFoOrTargetFoModel:baseTargetFo.basePFoOrTargetFoModel];
    }
    //2. 本次是R时: 返回最终找到的pFo;
    else {
        return basePFoOrTargetFoModel;
    }
}

/**
 *  MARK:--------------------判断条件满足--------------------
 *  @desc 即从proto中找abs: 判断当前proto场景对abs是条件满足的 (参考28052-2);
 *  @param absCutIndex : 其中absFo执行到的最大值 (含absCutIndex);
 *  @version
 *      2023.02.04: 初版,为解决条件满足不完全的问题,此方法将尝试从proto找出canset前段的每帧 (参考28052);
 *  @result 在proto中全找到canset的前段则返回true;
 */
+(BOOL) sceneIsOk:(AIFoNodeBase*)protoFo absFo:(AIFoNodeBase*)absFo absCutIndex:(NSInteger)absCutIndex {
    //1. 数据准备;
    if (!protoFo || !absFo) return false;
        
    //2. 每帧match都到proto里去找,找到则记录proto的进度,找不到则全部失败;
    NSInteger protoMin = 0;
    for (NSInteger absI = 0; absI < absCutIndex + 1; absI ++) {
        AIKVPointer *absAlg = ARR_INDEX(absFo.content_ps, absI);
        BOOL findItem = false;
        for (NSInteger protoI = protoMin; protoI < protoFo.count; protoI++) {
            AIKVPointer *protoAlg = ARR_INDEX(protoFo.content_ps, protoI);
            //3. B源于absFo,此处只判断B是1层抽象 (参考27161-调试1&调试2);
            //3. 单条判断方式: 此处proto抽象仅指向刚识别的matchAlgs,所以与contains等效 (参考28052-3);
            BOOL mIsC = [TOUtils mIsC_1:protoAlg c:absAlg];
            //if (Log4OutAna) NSLog(@"proto第%ld A%ld 是 ass第%ld A%ld (%@)",protoI,protoAlg.pointerId,absI,absAlg.pointerId,mIsC?@"成立":@"不成立");
            if (mIsC) {
                //4. 找到了 & 记录protoI的进度;
                findItem = true;
                protoMin = protoI + 1;
                NSLog(@"\t第%ld帧,条件满足通过 proto:%@ canset:%@",absI,Pit2FStr(protoAlg),Pit2FStr(absAlg));
                break;
            }
        }
        
        //5. 有一条失败,则全失败;
        if (!findItem) {
            NSLog(@"\t第%ld帧,条件满足未通过 canset:%@",absI,Pit2FStr(absAlg));
            return false;
        }
    }
    
    //6. 全找到,则成功;
    NSLog(@"\t全部条件满足通过\n");
    return true;
}

@end
