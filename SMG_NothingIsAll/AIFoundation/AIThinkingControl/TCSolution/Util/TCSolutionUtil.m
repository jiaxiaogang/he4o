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
    NSArray *cansetModels = [SMGUtils convertArr:demand.pFos convertItemArrBlock:^NSArray *(AIMatchFoModel *pFoM) {
        //a. 取出pFo的effectDic候选集;
        AIFoNodeBase *pFo = [SMGUtils searchNode:pFoM.matchFo];
        NSArray *cansetFos = [pFo getValidEffs:pFo.count];
        if (Log4Solution_Fast && ARRISOK(cansetFos)) NSLog(@"\tF%ld的第%ld帧取: %@",pFo.pointer.pointerId,pFo.count,CLEANSTR(cansetFos));
        
        //b. 分析analyst结果 & 排除掉不适用当前场景的(为nil) (参考26232-TODO8);
        return [SMGUtils convertArr:cansetFos convertBlock:^id(AIEffectStrong *eff) {
            //c. 分析比对结果;
            AISolutionModel *sModel = [AIAnalyst compareRCansetFo:eff.solutionFo pFo:pFoM demand:demand];
            
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
 */
+(AISolutionModel*) hSolution_Fast:(HDemandModel *)hDemand except_ps:(NSArray*)except_ps{
    //1. 数据准备;
    TOFoModel *targetFoM = (TOFoModel*)hDemand.baseOrGroup.baseOrGroup;
    AIFoNodeBase *targetFo = [SMGUtils searchNode:targetFoM.content_p];
    
    //2. 从targetFo取解决方案候选集;
    NSArray *cansetFos = [targetFo.effectDic objectForKey:@(targetFoM.actionIndex)];
    
    //3. 分析analyst结果 & 排除掉不适用当前场景的(为nil) (参考26232-TODO8);
    NSArray *cansetModels = [SMGUtils convertArr:cansetFos convertBlock:^id(AIEffectStrong *eff) {
        //a. 分析比对结果;
        AISolutionModel *sModel = [AIAnalyst compareHCansetFo:eff.solutionFo targetFo:targetFoM];
        
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
    NSArray *sortCansets = [TOUtils solutionTotalRanking:cansets needBack:havBack fromSlow:false];
    NSLog(@"3. 有效率排序后:%ld",cansets.count);
    if (Log4Solution_Fast) for (AISolutionModel *m in ARR_SUB(sortCansets, 0, 5)) {
        NSLog(@"\t(前%.2f 中%.2f 后%.2f) %@",m.frontMatchValue,m.effectScore,m.backMatchValue,Pit2FStr(m.cansetFo));
    }

    //7. 将首条最佳方案返回;
    AISolutionModel *result = ARR_INDEX(sortCansets, 0);
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
    NSArray *cansetFos = [self getCansetFos_Slow:targetFoModel.content_p];
    cansetFos = [self slowCansetFosFilter:cansetFos demand:hDemand];
    
    //3. 转cansetModels候选集 (参考26128-第1步 & 26161-1&2&3);
    NSArray *cansetModels = [SMGUtils convertArr:cansetFos convertBlock:^id(AIKVPointer *item) {
        return [AIAnalyst compareHCansetFo:item targetFo:targetFoModel];
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
        NSArray *cansetFos = [self getCansetFos_Slow:pFo.matchFo];
        cansetFos = [self slowCansetFosFilter:cansetFos demand:demand];
        
        //3. 转cansetModels候选集 (参考26128-第1步 & 26161-1&2&3);
        NSArray *cansetModels = [SMGUtils convertArr:cansetFos convertBlock:^id(AIKVPointer *cansetFo_p) {
            return [AIAnalyst compareRCansetFo:cansetFo_p pFo:pFo demand:demand];
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
    NSArray *sortModels = [TOUtils solutionTotalRanking:cansetModels needBack:havBack fromSlow:true];
    
    //12. debugLog
    for (AISolutionModel *model in sortModels) {
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:model.cansetFo];
        if (Log4Solution_Slow) NSLog(@"> %@\n\t综合排名:%ld (前%.2f 中%.2f 后%.2f) >> %@",Pit2FStr(model.cansetFo),[sortModels indexOfObject:model],model.frontMatchValue,model.stableScore,model.backMatchValue,CLEANSTR(cansetFo.spDic));
    }
    
    //13. 逐条S反思;
    for (AISolutionModel *item in sortModels) {
        NSArray *recogs = [self recognition4SRefrection:item cansets:sortModels demand:demand];
        BOOL score = [self score4SRefrection:recogs demand:demand];
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
 *  @param ptFo_p : R时传pFo, H时传targetFo;
 *  @version
 *      2022.07.14: 将取抽象,同级,自身全废弃掉,改为仅取具象 (参考27049);
 *      2022.07.15: 每个pFo下支持limit (参考27048-TODO6);
 */
+(NSArray*) getCansetFos_Slow:(AIKVPointer*)ptFo_p{
    //1. 取conPFos
    int cansetLimit = 5;
    AIFoNodeBase *ptFo = [SMGUtils searchNode:ptFo_p];
    NSArray *conFos = Ports2Pits([AINetUtils conPorts_All:ptFo]);
    conFos = [SMGUtils removeRepeat:conFos];
    conFos = ARR_SUB(conFos, 0, cansetLimit);
    return conFos;
}

/**
 *  MARK:--------------------cansetFos过滤器--------------------
 *  @version
 *      2022.07.14: S的价值pk迭代: 将过滤负价值的,改成过滤无价值指向的 (参考27048-TODO4&TODO9);
 *      2022.07.20: 不要求mv指向 (参考27055-步骤1);
 */
+(NSArray*) slowCansetFosFilter:(NSArray*)cansetFos demand:(DemandModel*)demand{
    //1. 数据准备;
    BOOL havBack = ISOK(demand, HDemandModel.class); //H有后段,别的没有;
    int minCount = havBack ? 2 : 1;
    
    //2. 过滤器;
    cansetFos = [SMGUtils filterArr:cansetFos checkValid:^BOOL(AIKVPointer *item) {
        //a. 过滤掉长度不够的 (因为前段全含至少要1位,中段修正也至少要0位,后段H目标要1位R要0位);
        AIFoNodeBase *fo = [SMGUtils searchNode:item];
        if (fo.count < minCount) return false;
        
        //b. 闯关成功;
        return true;
    }];
    NSLog(@"第4步 最小长度 & 非负价值过滤后:%ld",cansetFos.count);//测时96条
    return cansetFos;
}

//MARK:===============================================================
//MARK:                     < 反思识别 & 反思评价 >
//MARK:===============================================================

/**
 *  MARK:--------------------S反思识别--------------------
 *  @desc   1. 功能: 从cansets中检查与item匹配度高的部分,并作为识别结果返回;
 *          2. 向性: 下;
 *  @param checkCanset  : 当前canset检查项;
 *  @param cansets      : item所在的cansets;
 *  @version
 *      2022.07.16: 写S评分pk (参考27048-TODO3 & 27049-TODO4);
 */
+(NSArray*) recognition4SRefrection:(AISolutionModel*)checkCanset cansets:(NSArray*)cansets demand:(DemandModel*)demand{
    //1. 向具象取索引;
    AIFoNodeBase *checkFo = [SMGUtils searchNode:checkCanset.cansetFo];
    //此处不用取具象,直接由调用者,把它的cansetFo兄弟们传递进来即可;
    
    
    for (AISolutionModel *otherCanset in cansets) {
        //2. 不与自身比较;
        if ([otherCanset.cansetFo isEqual:checkCanset.cansetFo]) continue;
        
        //3. 对比二者;
        AIFoNodeBase *otherFo = [SMGUtils searchNode:otherCanset.cansetFo];
        
        
        //2. 计算前段匹配度;
        //TODOTOMORROW20220721: 经回顾AIAnalyst方法,有不兼容处,比如它不源于TI流程,所以没有indexDic,说明如下:
        //说明: 在AIAnalyst算法中,假设了cansetFo和maskFo源于TI识别流程,
        //      1. 然后根据它的indexDic来分别比对下标下的alg匹配度的;
        //      2. 但此处明显并没走TI流程,所以无法生成indexDic;
        //      3. 但此处是有抽具象关系的,所以直接对itemAlg判断mIsC抽具象关系即可 (即,有共同抽象,则可以进行比对);
        
        NSInteger otherStart = 0;
        for (NSInteger checkIndex = 0; checkIndex < checkCanset.cutIndex; checkIndex++) {
            AIKVPointer *checkAlg_p = ARR_INDEX(checkFo.content_ps, checkIndex);
            AIAlgNodeBase *checkAlg = [SMGUtils searchNode:checkAlg_p];
            NSArray *checkAbs = [AINetUtils absPorts_All:checkAlg];
            
            for (NSInteger otherIndex = otherStart; otherIndex < otherCanset.cutIndex; otherIndex++) {
                AIKVPointer *otherAlg_p = ARR_INDEX(otherFo.content_ps, otherIndex);
                AIAlgNodeBase *otherAlg = [SMGUtils searchNode:otherAlg_p];
                NSArray *otherAbs = [AINetUtils absPorts_All:otherAlg];
                
                //a. 判断checkAlg与otherFo是否有共同的抽象;
                BOOL sameAbs = ARRISOK([SMGUtils filterArr:checkAbs checkValid:^BOOL(id item) {
                    return [otherAbs containsObject:item];
                }]);
                
                //b. 如果checkAlg找到otherIndex,则记录它的进度;
                if (sameAbs) {
                    otherStart = otherIndex;
                    
                    
                    CGFloat near = [AIAnalyst compareCansetAlg:checkAlg_p protoAlg:otherAlg_p];
                    break;
                }
                
                //c. 如果最后也没找到共同抽象的otherIndex,那则跳过这条;
                
                
                //d. 直至二者循环完,把所有匹配上的alg,算出的匹配值,乘起来,作为最终的fo前段匹配度;
                
                
                //e. 然后根据最终综合匹配度排序;
                
                
            }
        }
        
    }
    
    
    
    
    
    
    
    
    // 无论是H还是R,都向具象根据匹配度取数条,做综合反思 (参考27055-方案1-步骤3);
    
    
    
    return nil;
}

/**
 *  MARK:--------------------S反思评价--------------------
 *  @version
 *      2022.07.16: 写S评分pk (参考27048-TODO3 & 27049-TODO4);
 */
+(BOOL) score4SRefrection:(NSArray*)recogFos demand:(DemandModel*)demand{
    //1. 计算任务评分 (当前pFo评分);
    //H任务向base取所在的solutionFo,然后solutionFo是有评分的;
    //R任务可以直接取后段稳定性xdemand评分;
    
    //任务pFo的评分,应该更多的向具象向性上求解 (参考n27p05);
    
    
    
    //a. 取到fo,判断后段的mv评分;
    for (AIMatchFoModel *item in recogFos) {
        AIFoNodeBase *recogFo = [SMGUtils searchNode:item.matchFo];
        
        
    }
    
    
    //b. 算出后段的"懒"评分;
    
    
    //c. S评分PK: (pk通过 = 任务评分 < (方案评分 + 懒评分));
    return true;
}


@end
