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
    cansetFos = [self slowCansetFosFilter:cansetFos demand:hDemand ptAleardayCount:hAleardayCount basePFoOrTargetFoModel:targetFoModel];
    
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
        cansetFos = [self slowCansetFosFilter:cansetFos demand:demand ptAleardayCount:rAleardayCount basePFoOrTargetFoModel:pFo];
        
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
 */
+(NSArray*) slowCansetFosFilter:(NSArray*)cansetFos demand:(DemandModel*)demand ptAleardayCount:(NSInteger)ptAleardayCount basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel{
    //1. 数据准备;
    BOOL havBack = ISOK(demand, HDemandModel.class); //H有后段,别的没有;
    int minCount = havBack ? 2 : 1;
    
    //2. 过滤器;
    cansetFos = [SMGUtils filterArr:cansetFos checkValid:^BOOL(AIKVPointer *cansetFo_p) {
        //3. 过滤掉长度不够的 (因为前段全含至少要1位,中段修正也至少要0位,后段H目标要1位R要0位);
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:cansetFo_p];
        if (cansetFo.count < minCount) return false;
        
        //4. 通过contains来判断是否前段条件满足: 数据准备 (参考28021 & 28022);
        AIMatchFoModel *pFo = [self getPFo:cansetFo_p basePFoOrTargetFoModel:basePFoOrTargetFoModel];
        AIKVPointer *protoFo_p = pFo.baseRDemand.protoOrRegroupFo;
        AIFoNodeBase *protoFo = [SMGUtils searchNode:protoFo_p];
        AIFoNodeBase *matchFo = [SMGUtils searchNode:pFo.matchFo];
        
        //6. 根据matchFo取得与canset的indexDic映射;
        NSDictionary *cansetMatchIndexDic = [self getCansetMatchIndexDic:cansetFo_p basePFoOrTargetFoModel:basePFoOrTargetFoModel sumIndexDic:nil];
        
        //7. 根据matchFo取得proto的indexDic映射;
        NSDictionary *protoMatchIndexDic = [matchFo getConIndexDic:protoFo_p];
        
        //7. 所有已发生帧,都要判断一下条件满足 (ptAleardayCount之前全是前段) (28022-todo4);
        for (NSInteger matchIndex = 0; matchIndex < ptAleardayCount; matchIndex++) {
            [AITest test23:protoMatchIndexDic cmDic:cansetMatchIndexDic matchIndex:matchIndex];
            
            //7. 取得match当前帧对应的protoAlg;
            NSInteger protoIndex = NUMTOOK([protoMatchIndexDic objectForKey:@(matchIndex)]).integerValue;
            AIKVPointer *protoAlg_p = ARR_INDEX(protoFo.content_ps, protoIndex);
            
            //8. 取得match当前帧对应的cansetAlg;
            NSInteger cansetIndex = NUMTOOK([cansetMatchIndexDic objectForKey:@(matchIndex)]).integerValue;
            AIKVPointer *cansetAlg_p = ARR_INDEX(cansetFo.content_ps, cansetIndex);
            
            //9. 根据protoAlg取得matchAlgs (参考28021-问题2-结果);
            AIAlgNodeBase *protoAlg = [SMGUtils searchNode:protoAlg_p];
            NSArray *matchAlg_ps = Ports2Pits([AINetUtils absPorts_All:protoAlg]);
            
            //10. 判断是否包含cansetAlg (只要有一条不包含,则条件不满足,返回过滤掉) (参考28022-todo2&3);
            if (![matchAlg_ps containsObject:cansetAlg_p]) {
                return false;
            }
            NSLog(@"第%ld帧,条件满足通过 proto:%@ canset:%@",matchIndex,Pit2FStr(protoAlg_p),Pit2FStr(cansetAlg_p));
        }
        
        //b. 闯关成功;
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
 *  MARK:--------------------综合求出canset与match的indexDic映射 (参考28024-回答1&回答2)--------------------
 *  @desc 递归方法,从工作记忆的末枝向头枝,直至递归到R任务中的protoFo为止;
 *  @desc 适用范围: (参考28025-todo7);
 *          1. H任务可以递归取到R为止 (含R);
 *          2. R任务也可以直接取到R的结果 (含R);
 *
 *  @param cansetFo_p : 传入H任务取的候选集中的其中一条 (正在检查过滤的一条);
 *  @param basePFoOrTargetFoModel : H传入cansetFo_p基于的targetFoModel / R传canset基于的pFo;
 *  @param sumIndexDic : 传入空即可 (用来递归间收集的,最初就是空);
 *  @result 顺着targetFoModel向头枝直至找到protoFo,将整个寻找途径的indexDic映射综合(含R)返回 (参考28025-todo6);
 */
+(NSDictionary*) getCansetMatchIndexDic:(AIKVPointer*)cansetFo_p basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel sumIndexDic:(NSDictionary*)sumIndexDic {
    //1. base还是H时: 取出这层的itemIndexDic映射;
    AIKVPointer *matchFo_p = [TOUtils convertBaseFoFromBasePFoOrTargetFoModel:basePFoOrTargetFoModel];
    AIFoNodeBase *matchFo = [SMGUtils searchNode:matchFo_p];
    NSDictionary *itemIndexDic = [matchFo getConIndexDic:cansetFo_p];
    NSMutableDictionary *newSumIndexDic = [[NSMutableDictionary alloc] init];
    
    //2. 首条时: 当sumIndexDic为空时,说明是首条,当前itemIndexDic即当前综合映射;
    if (!sumIndexDic) {
        [newSumIndexDic setDictionary:itemIndexDic];
    } else {
        //3. 非首条时: 将本层itemIndexDic与往层综合sumIndexDic再综合一下 (计算方法参考28024-回答2);
        for (NSNumber *sumKey in sumIndexDic.allKeys) {
            NSNumber *sumValue = [sumIndexDic objectForKey:sumKey];
            for (NSNumber *itemKey in itemIndexDic.allKeys) {
                NSNumber *itemValue = [itemIndexDic objectForKey:itemKey];
                
                //3. 当sum的抽象=item的具象时: 记录一条综合结果;
                if ([sumKey isEqualToNumber:itemValue]) {
                    
                    //4. 综合结果计为: <K:item的抽象, V:sum的具象>;
                    [newSumIndexDic setObject:sumValue forKey:itemKey];
                }
            }
        }
    }
    
    //5. 本次非R时: 继续递归;
    if (ISOK(basePFoOrTargetFoModel, TOFoModel.class)) {
        TOFoModel *baseTargetFo = (TOFoModel*)basePFoOrTargetFoModel;
        return [self getCansetMatchIndexDic:baseTargetFo.content_p basePFoOrTargetFoModel:baseTargetFo.basePFoOrTargetFoModel sumIndexDic:newSumIndexDic];
    }
    //6. 本次是R时: 返回最终结果;
    else {
        return newSumIndexDic;
    }
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

@end
