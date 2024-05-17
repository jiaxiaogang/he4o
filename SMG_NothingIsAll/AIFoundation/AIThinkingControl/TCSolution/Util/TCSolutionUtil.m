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
//MARK:                     < 求解 >
//MARK:===============================================================

/**
 *  MARK:--------------------H求解--------------------
 *  @version
 *      2023.09.10: 升级v2,支持TCScene和TCCanset (参考30127);
 *      2023.10.04: 测得总是输出无计可施,发现H迁移路径和R是不同的,H经验迁移不过来,所以最终解决如下升级下v3;
 *      2024.02.xx: 升级v3:
 *                  1. HCansetFrom的取值从从pFo下的sceneTree下的rCanset下找 (参考hSolutionV3中筛选出targetPFo,并以此筛选出hSceneFrom);
 *                  2. H与R的迁移路径不同的处理 (H比R的首尾各多一层,参考TCTransferV3);
 */
+(TOFoModel*) hSolutionV3:(HDemandModel *)hDemand {
    //0. 初始化一次,后面只执行generalSolution部分;
    if (hDemand.alreadyInitCansetModels) {
        ELog(@"solution()应该只执行一次,别的全从TCPlan来分发和实时竞争,此处如果重复执行,查下原因");
        return nil;
    }
    hDemand.alreadyInitCansetModels = true;
    
    //1. 数据准备;
    TOAlgModel *targetAlgM = (TOAlgModel*)hDemand.baseOrGroup;
    AIAlgNodeBase *targetAlg = [SMGUtils searchNode:targetAlgM.content_p];
    TOFoModel *targetFoM = (TOFoModel*)targetAlgM.baseOrGroup;
    ReasonDemandModel *baseRDemand = (ReasonDemandModel*)targetFoM.baseOrGroup;//取出rDemand
    AIKVPointer *targetPFo = targetFoM.baseSceneModel.getIScene;
    
    //2. targetFoM转实后的canset就是真正R在推进行为化中的RCanset(也即HScene);
    //结构说明: 其中IScene是RScene,这个sceneTo是挂在IScene下的;
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:targetFoM.transferSiModel.canset];
    
    //2. 取出rCansets (仅取当前pFo树下的) (参考31113-TODO4);
    NSArray *rCansets = [SMGUtils filterArr:baseRDemand.actionFoModels checkValid:^BOOL(TOFoModel *item) {
        return [targetPFo isEqual:item.baseSceneModel.getIScene];
    }];
    
    //3. 依次从rCanset下取hCansets (参考31102);
    for (TOFoModel *rCanset in rCansets) {
        AIFoNodeBase *sceneFrom = [SMGUtils searchNode:rCanset.cansetModel.cansetFo];
        
        //4. 取hCansets(用override取cansets): 从cutIndex到sceneFo.count之间的hCansets (参考31102-第1步);
        //取: 从rCanset.cutIndex + 1到count末尾,之间所有的canset都是来的及尝试执行的;
        NSArray *cansetFroms1 = [sceneFrom getConCansets:rCanset.cansetCutIndex + 1];
        NSArray *allHCanset = [SMGUtils convertArr:sceneFrom.conCansetsDic.allValues convertItemArrBlock:^NSArray *(id obj) {
            return obj;
        }];
        NSLog(@"取HCanset候选集: 从hScene:F%ld 的在%ld帧开始取,取得HCanset数:%ld/%ld",sceneFrom.pId,rCanset.cansetCutIndex + 1,cansetFroms1.count,allHCanset.count);
        if (ARRISOK(cansetFroms1)) {
            NSLog(@"flt1 取到HCanset%@",CLEANSTR([SMGUtils convertArr:cansetFroms1 convertBlock:^id(id obj) {
                return ShortDesc4Pit(obj);
            }]));
            NSLog(@"TODOTOMORROW20240402: 跑两三轮31135的训练步骤试下,看这里能不能取到hCanset...");
            //通过以下四步来测试:
            //1. 先生成NewHCanset (完成);
            //2. 能激活HCanset;
            //  测试方法: 把所有训练生成的RCanset和对应的HCanset记录一下日志,然后再重启后分析激活到的RCanset含不含HCanset等;
            //3. 能反馈到行为化中的HCanset;
            //4. 能生成AbsHCanset;
        }
        
        //5. Override过滤器: 防重已经迁移过的 (override用来过滤避免重复迁移) (参考29069-todo5.2);
        NSArray *alreadyTransfered_Cansets = [sceneTo getTransferedCansetFroms:sceneFrom.p];
        NSArray *cansetFroms2 = [SMGUtils removeSub_ps:alreadyTransfered_Cansets parent_ps:cansetFroms1];
        
        //6. 转为cansetModel格式 (参考31104-第3步);
        NSArray *cansetFroms3 = [SMGUtils convertArr:cansetFroms2 convertBlock:^id(AIKVPointer *cansetFrom) {
            return [TCCanset convert2HCansetModel:cansetFrom hDemand:hDemand rCanset:rCanset];
        }];
        
        //7. 求出匹配度,转为评分模型 (把每个cansetFrom的综合匹配度算出来,用于后面过滤) (参考31121-TODO3 & TODO4);
        NSArray *cansetFrom4 = [SMGUtils convertArr:cansetFroms3 convertBlock:^id(TOFoModel *obj) {
            //a. 取出当前cansetTo的目标帧;
            AIShortMatchModel_Simple *cansetToOrder = ARR_INDEX(obj.transferXvModel.cansetToOrders, obj.cansetTargetIndex);
            AIAlgNodeBase *cansetToAlg = [SMGUtils searchNode:cansetToOrder.alg_p];
            
            //b. 如果是mcIsBro关系,先取出共同的sameAbs;
            
            //2024.04.29: 已经修了IH迁移xvModel返回nil的问题 (随后再观察下这里不报错,则删;
            if (!targetAlgM || !targetAlgM.content_p) {
                NSLog(@"这里闪退过,因为这个m或c是空,如果2024.07之前没见过这个错,这里可删");
            }
            if (!cansetToAlg || !cansetToAlg.p) {
                NSLog(@"这里闪退过,因为这个c或m是空,如果2024.07之前没见过这个错,这里可删");
            }
            NSArray *sameAbses = [TOUtils dataOfMcIsBro:targetAlgM.content_p c:cansetToAlg.p];
            
            //c. 然后再依次判断下和mc二者的匹配度,相乘,取最大值为其综合匹配度,找出综合匹配度最好的值: 即最匹配的 (参考31121-TODO3);
            CGFloat bestScore = [SMGUtils filterBestScore:sameAbses scoreBlock:^CGFloat(AIKVPointer *item) {
                return [targetAlg getAbsMatchValue:item] * [cansetToAlg getAbsMatchValue:item];
            }];
            return [MapModel newWithV1:obj v2:@(bestScore)];
        }];
        
        //8. 过滤掉匹配度为0的 (只要不为0,肯定是有mcIsBro关系的) (参考31103-第2步 & 31121-TODO4);
        NSArray *cansetFrom5 = [SMGUtils filterArr:cansetFrom4 checkValid:^BOOL(MapModel *item) { return NUMTOOK(item.v2).floatValue > 0; }];
        
        //9. 把末尾20%过滤掉 (末尾淘汰制) (参考31121-TODO2);
        NSArray *cansetFrom6 = [SMGUtils sortBig2Small:cansetFrom5 compareBlock:^double(MapModel *obj) { return NUMTOOK(obj.v2).floatValue; }];
        cansetFrom6 = ARR_SUB(cansetFrom6, 0, cansetFrom6.count * 0.8f);
        
        //10. 更新到actionFoModels;
        NSArray *cansetFromFinish = [SMGUtils convertArr:cansetFrom6 convertBlock:^id(MapModel *obj) { return obj.v1; }];
        [hDemand.actionFoModels addObjectsFromArray:cansetFromFinish];
        if (Log4GetCansetResult4H && cansetFroms3.count > 0) NSLog(@"\t item场景(%@):%@ 取得候选数:%ld",SceneType2Str(rCanset.baseSceneModel.type),Pit2FStr(rCanset.baseSceneModel.scene),cansetFromFinish.count);
    }
    NSLog(@"第2步 转为候选集 总数:%ld",hDemand.actionFoModels.count);
    
    //11. 竞争求解: 对hCansets进行实时竞争 (参考31122);
    return [self realTimeRankCansets:hDemand zonHeScoreBlock:nil];//400ms
}

/**
 *  MARK:--------------------R求解--------------------
 *  @version
 *      2023.12.26: 提前在for之前取scene所在的pFo,以优化其性能 (参考31025-代码段-问题1) //共三处优化,此乃其一;
 *      2024.01.24: 只初始化一次,避免重复生成actionFoModels (参考31073-TODO2f);
 */
+(TOFoModel*) rSolution:(ReasonDemandModel *)demand {
    //0. 初始化一次,后面只执行generalSolution部分;
    if (demand.alreadyInitCansetModels) {
        ELog(@"solution()应该只执行一次,别的全从TCPlan来分发和实时竞争,此处如果重复执行,查下原因");
    }
    demand.alreadyInitCansetModels = true;
    
    //1. 收集cansetModels候选集;
    NSArray *sceneModels = [TCScene rGetSceneTree:demand];//600ms
    
    //2. 每个cansetModel转solutionModel;
    NSArray *cansetModels = [SMGUtils convertArr:sceneModels convertItemArrBlock:^NSArray *(AISceneModel *sceneModel) {
        //3. 取所有CansetFroms;
        //2023.12.24: 性能测试记录 (结果: 此方法很卡) (参考31025-代码段-问题1);
        //  a. 记录此处为brother时,   共执行了: 300次 x 每次10ms     = 3s;
        //  b. 记录此处为father时,    共执行了: 16次  x 每次1ms      = 16ms;
        //  c. 记录此处为i时,         共执行了: 16次  x 每次125ms    = 2s;
        AIFoNodeBase *sceneFrom = [SMGUtils searchNode:sceneModel.scene];
        AIFoNodeBase *sceneTo = [SMGUtils searchNode:sceneModel.getIScene];
        
        //2024.05.08: 废弃按"有效和强度"过滤,因为新解往往排最后,这会导致它们永远没机会,这违背了宽入原则 (参考31174-问题2-方案1 & 31175-TODO3);
        NSArray *cansetFroms1 = [sceneFrom getConCansets:sceneFrom.count];//全激活 (调用rSolution平均耗时700ms)
        //NSArray *cansetFroms1 = [AIFilter solutionRCansetFilter:sceneFrom targetIndex:sceneFrom.count];//只激活前20% (调用rSolution平均耗时600ms)
        
        //5. Override过滤器: 防重已经迁移过的 (override用来过滤避免重复迁移) (参考29069-todo5.2);
        NSArray *alreadyTransfered_Cansets = [sceneTo getTransferedCansetFroms:sceneFrom.p];
        NSArray *cansetFroms2 = [SMGUtils removeSub_ps:alreadyTransfered_Cansets parent_ps:cansetFroms1];
        if (Log4TCCanset && cansetFroms1.count > 0) NSLog(@"RCansetFroms过滤已迁移过: 原%ld - 滤%ld = 留%ld",cansetFroms1.count,alreadyTransfered_Cansets.count,cansetFroms2.count);
        
        //6. 转为CansetModel;
        AIMatchFoModel *pFo = [SMGUtils filterSingleFromArr:demand.validPFos checkValid:^BOOL(AIMatchFoModel *item) {
            return [item.matchFo isEqual:sceneModel.getRoot.scene];
        }];
        NSArray *itemCansetModels = [SMGUtils convertArr:cansetFroms2 convertBlock:^id(AIKVPointer *canset) {
            //4. 过滤器 & 转cansetModels候选集 (参考26128-第1步 & 26161-1&2&3);
            return [TCCanset convert2RCansetModel:canset sceneFrom:sceneModel.scene basePFoOrTargetFoModel:pFo sceneModel:sceneModel demand:demand];//1200ms/600次执行
        }];
        if (Log4GetCansetResult4R && cansetFroms2.count > 0) NSLog(@"\t item场景(%@):%@ 取得候选数:%ld 转成候选模型数:%ld",SceneType2Str(sceneModel.type),Pit2FStr(sceneModel.scene),cansetFroms2.count,itemCansetModels.count);
        return itemCansetModels;
    }];
    NSLog(@"第2步 转为候选集 总数:%ld",cansetModels.count);

    //5. 竞争求解;
    return [self realTimeRankCansets:demand zonHeScoreBlock:nil];//400ms
}

/**
 *  MARK:--------------------Cansets实时竞争--------------------
 *  @desc 思考求解: 前段匹配,中段加工,后段静默 (参考26127);
 *  @param zonHeScoreBlock TCSolution初次求解调用时传nil & 非初次求解:TCPlan调用时传TCScore算出的综合得分;
 *  @version
 *      2022.06.04: 修复结果与当前场景相差甚远BUG: 分三级排序窄出 (参考26194 & 26195);
 *      2022.06.09: 将R和H的求解封装成同一方法,方便调用和迭代;
 *      2022.06.09: 弃用阈值方案,改为综合排名 (参考26222-TODO2);
 *      2022.06.12: 每个pFo独立做analyst比对,转为cansetModels (参考26232-TODO8);
 *      2023.02.19: 最终激活后,将match和canset的前段抽具象强度+1 (参考28086-todo2);
 *      2024.01.28: 改为无计可施的失败TOFoModel,计为不应期 (参考31073-TODO8);
 *      2024.02.04: 直接重命名为Cansets实时竞争;
 */
+(TOFoModel*) realTimeRankCansets:(DemandModel *)demand zonHeScoreBlock:(double(^)(TOFoModel *obj))zonHeScoreBlock {
    //1. 数据准备;
    [AITest test13:demand.actionFoModels];
    TOFoModel *result = nil;
    NSLog(@"第5步 Anaylst匹配成功:%ld",demand.actionFoModels.count);//测时94条

    //2. 不应期 (可以考虑) (源于:反思且子任务失败的 或 fo行为化最终失败的,参考24135);
    //8. 排除不应期: 无计可施的失败TOFoModel计为不应期 (参考31073-TODO8);
    //1. 过滤掉actNo,withOut,scoreNo,finish这些状态的;
    NSArray *cansetModels = [SMGUtils filterArr:demand.actionFoModels checkValid:^BOOL(TOFoModel *item) {
        return item.status != TOModelStatus_ActNo && item.status != TOModelStatus_ScoreNo && item.status != TOModelStatus_WithOut && item.status != TOModelStatus_Finish;
    }];
    NSLog(@"第6步 排除不应期:%ld",cansetModels.count);//测时xx条

    //9. 对下一帧做时间不急评价: 不急 = 解决方案所需时间 <= 父任务能给的时间 (参考:24057-方案3,24171-7);
    cansetModels = [SMGUtils filterArr:cansetModels checkValid:^BOOL(TOFoModel *item) {
        return [AIScore FRS_Time:demand solutionModel:item];
    }];
    NSLog(@"flt2 第7步 排除FRSTime来不及的:%ld for%@",cansetModels.count,ISOK(demand, HDemandModel.class)?@"H":@"R");//测时xx条

    //10. 计算衰后stableScore并筛掉为0的 (参考26128-2-1 & 26161-5);
    //NSArray *outOfFos = [SMGUtils convertArr:cansetModels convertBlock:^id(TOFoModel *obj) {
    //    return obj.cansetFo;
    //}];
    //for (TOFoModel *model in cansetModels) {
    //    AIFoNodeBase *cansetFo = [SMGUtils searchNode:model.cansetFo];
    //    model.stableScore = [TOUtils getColStableScore:cansetFo outOfFos:outOfFos startSPIndex:model.cutIndex + 1 endSPIndex:model.targetIndex];
    //}
    //cansetModels = [SMGUtils filterArr:cansetModels checkValid:^BOOL(TOFoModel *item) {
    //    return item.stableScore > 0;
    //}];
    //NSLog(@"第8步 排序中段稳定性<=0的:%ld",cansetModels.count);//测时xx条
    
    //11. 根据候选集综合分排序 (参考26128-2-2 & 26161-4);
    NSArray *sortModels = [AIRank cansetsRankingV4:cansetModels zonHeScoreBlock:zonHeScoreBlock];

    //13. 取通过S反思的最佳S;
    for (TOFoModel *item in sortModels) {
        BOOL score = [TCRefrection refrection:item demand:demand];
        if (!score) {
            //13. 不通过时,将状态及时改为ScoreNo (参考31083-TODO5);
            item.status = TOModelStatus_ScoreNo;
            continue;
        }

        //14. 闯关成功,取出最佳,跳出循环;
        result = item;
        break;
    }
    
    //13. 输出前: 可行性检查;
    result = [TCRealact checkRealactAndReplaceIfNeed:result fromCansets:sortModels];
    
    //14. 只在初次best时执行一次由虚转实,以及因激活更新强度等 (避免每次实时竞争导致重复跑这些);
    if (result && result.cansetStatus == CS_None) {
        AIFoNodeBase *resultFo = [SMGUtils searchNode:result.cansetModel.cansetFo];
        NSLog(@"求解最佳结果:F%ld %@",result.cansetModel.cansetFo.pointerId,CLEANSTR(resultFo.spDic));
        
        //15. bestResult由虚转实迁移;
        [TCTransfer transferSi:result];

        //16. 更新前中后段con和abs的抽具象强度 (参考28086-todo2 & 28092-todo4);
        [AINetUtils updateConAndAbsStrongByIndexDic:result.transferXvModel.sceneToCansetToIndexDic matchFo:result.sceneTo cansetFo:result.transferSiModel.canset];

        //17. 更新其前段alg引用value的强度;
        NSArray *frontCansetToIndexArr = [SMGUtils filterArr:result.transferXvModel.sceneToCansetToIndexDic.allValues checkValid:^BOOL(NSNumber *item) {
            return item.intValue <= result.cansetCutIndex;;
        }];
        [AINetUtils updateAlgRefStrongByIndexArr:frontCansetToIndexArr fo:result.transferSiModel.canset];
    }
    
    //15. 更新状态besting和bested (参考31073-TODO2d);
    [TCSolutionUtil updateCansetStatus:result demand:demand];
    
    //19. 返回最佳解决方案;
    return result;
}


//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
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
            return maskIndex <= demandBaseFo.cansetCutIndex;
        }].count;
    }
    return pFoAleardayCount;
}

/**
 *  MARK:--------------------更新状态besting和bested (参考31073-TODO2d)--------------------
 *  @desc best设成besting & 曾best的设为bested & 其它的默认为none状态;
 */
+(void) updateCansetStatus:(TOFoModel*)bestCanset demand:(DemandModel*)demand {
    if (!bestCanset || !demand) return;
    for (TOFoModel *cansetModel in demand.actionFoModels) {
        if (cansetModel.cansetStatus == CS_Besting) {
            cansetModel.cansetStatus = CS_Bested;
        }
    }
    bestCanset.cansetStatus = CS_Besting;
}

@end
