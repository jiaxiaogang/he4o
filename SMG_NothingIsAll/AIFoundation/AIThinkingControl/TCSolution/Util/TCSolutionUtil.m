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
 */
+(TOFoModel*) hSolutionV2:(HDemandModel *)demand {
    //0. 初始化一次,后面只执行generalSolution部分;
    if (demand.alreadyInitCansetModels) {
        ELog(@"solution()应该只执行一次,别的全从TCPlan来分发和实时竞争,此处如果重复执行,查下原因");
        return nil;
    }
    demand.alreadyInitCansetModels = true;
    
    //1. 收集cansetModels候选集;
    NSArray *sceneModels = [TCScene hGetSceneTree:demand];
    TOFoModel *targetFoM = (TOFoModel*)demand.baseOrGroup.baseOrGroup;

    //2. 每个cansetModel转solutionModel;
    NSArray *cansetModels = [SMGUtils convertArr:sceneModels convertItemArrBlock:^NSArray *(AISceneModel *sceneModel) {
        //3. 取出overrideCansets;
        NSArray *cansets = ARRTOOK([TCCanset getOverrideCansets:sceneModel sceneTargetIndex:sceneModel.cutIndex + 1]);//127ms
        NSArray *itemCansetModels = [SMGUtils convertArr:cansets convertBlock:^id(AIKVPointer *canset) {
            //4. 过滤器 & 转cansetModels候选集 (参考26128-第1步 & 26161-1&2&3);
            NSInteger aleardayCount = sceneModel.cutIndex + 1;
            return [TCCanset convert2CansetModel:canset sceneFo:sceneModel.scene basePFoOrTargetFoModel:targetFoM ptAleardayCount:aleardayCount isH:true sceneModel:sceneModel demand:demand];//245ms
        }];
        
        if (Log4GetCansetResult4H && cansets.count > 0) NSLog(@"\t item场景(%@):%@ 取得候选数:%ld 转成候选模型数:%ld",SceneType2Str(sceneModel.type),Pit2FStr(sceneModel.scene),cansets.count,itemCansetModels.count);
        return itemCansetModels;
    }];
    //TODOTOMORROW20231004:
    //查下,这里hSolution总是输出无计可施,而此时"皮果"已经有了,按道理说,前段条件满足已经满足了;
    //日志: 第1步 H场景树枝点数 I:1 + Father:0 + Brother:0 = 总:1 (这里总是取到hCanset=0条);
    
    
    
    NSLog(@"第2步 转为候选集 总数:%ld",cansetModels.count);

    //5. 竞争求解;
    return [self realTimeRankCansets:demand zonHeScoreBlock:nil];//400ms
}

+(TOFoModel*) hSolutionV3:(HDemandModel *)demand {
    //0. 初始化一次,后面只执行generalSolution部分;
    if (demand.alreadyInitCansetModels) {
        ELog(@"solution()应该只执行一次,别的全从TCPlan来分发和实时竞争,此处如果重复执行,查下原因");
        return nil;
    }
    demand.alreadyInitCansetModels = true;
    
    //1. 数据准备;
    TOFoModel *targetFoM = (TOFoModel*)demand.baseOrGroup.baseOrGroup;
    ReasonDemandModel *baseRDemand = (ReasonDemandModel*)targetFoM.baseOrGroup;//取出rDemand
    
    //2. 再根据rDemand取出场景树;
    NSArray *sceneModels = [TCScene rGetSceneTree:baseRDemand];
    //3. 再根据r场景树,找出cansets;
    
    //2. 每个cansetModel转solutionModel;
    NSArray *cansetModels = [SMGUtils convertArr:sceneModels convertItemArrBlock:^NSArray *(AISceneModel *sceneModel) {
        //3. 取出overrideCansets;
        NSArray *cansets = ARRTOOK([TCCanset getOverrideCansets:sceneModel sceneTargetIndex:sceneModel.cutIndex + 1]);//127ms
        NSArray *itemCansetModels = [SMGUtils convertArr:cansets convertBlock:^id(AIKVPointer *canset) {
            //4. 过滤器 & 转cansetModels候选集 (参考26128-第1步 & 26161-1&2&3);
            NSInteger aleardayCount = sceneModel.cutIndex + 1;
            
            
            //TODOTOMORROW20240106: 测下h任务也从r场景树迁移 (参考31053);
            //1. 从cansets中过滤出与hDemand有抽具象关系的 (用hAlg取抽具象关系的,判断交集即可);
            //问题: 此处再跑一次R的流程有点浪费,并且R流程也不行,得再改代码,往H再深入一层,有点复杂且麻烦;
            
            //2. 此处有RCansets初始化后,可以试下直接顺着它迁移过来...
            //  a. Cansets大多数还是用非体状态
            //  b. 所以最好可以从sceneModel的原canset下,找hCanset;
            //  c. 关键1-要怎么判断这个hCanset是否适用于当前hDemand;
            //  d. 关键2-要怎么迁移下 (也是有用有体两步);
            //  e. 关键3-画图分析下,然后看把h时该重构的地方重构下,尽量全复用;
            //  f. 所以: 相当于,hSolution,迁移,实时竞争,等代码,都兼容下H任务;
            //  结果: 先画图对比下H和R的结构区别,分析迁移区别,和hSolutionV3该怎么写;
            //      分析: 根据记忆网络结构分析: hCansets怎么取?
            //      1. 从rCansets中取所有hCanset;
            //      2. 需要各自>cutIndex的 且 <cutIndex+1的所有hCansets: 或者说,本来就是取cutIndex+1的hCansets;
            //      3. 应该是当前RCanset的cutIndex+1对应的rScene树上别的场景的那一帧的hCansets;
            //      4. 即从当前rCanset出发,找rScene,然后再...画下图,应该是不通的,得根据mIsC来判断?
            
            
            
            return [TCCanset convert2CansetModel:canset sceneFo:sceneModel.scene basePFoOrTargetFoModel:targetFoM ptAleardayCount:aleardayCount isH:true sceneModel:sceneModel demand:demand];//245ms
        }];
        
        if (Log4GetCansetResult4H && cansets.count > 0) NSLog(@"\t item场景(%@):%@ 取得候选数:%ld 转成候选模型数:%ld",SceneType2Str(sceneModel.type),Pit2FStr(sceneModel.scene),cansets.count,itemCansetModels.count);
        return itemCansetModels;
    }];
    NSLog(@"第2步 转为候选集 总数:%ld",cansetModels.count);

    //5. 竞争求解;
    return [self realTimeRankCansets:demand zonHeScoreBlock:nil];//400ms
}

+(TOFoModel*) debugHSolution:(HDemandModel *)demand {
    
    //1. 取出rSolution的成果,在它的基础上继续做hSolution;
    ReasonDemandModel *rDemand = (ReasonDemandModel*)demand.baseOrGroup.baseOrGroup.baseOrGroup;
    
    //2. CansetModels可用于从中寻找可供迁移的hCanset;
    //TODOTOMORROW20240126: 随时继续做这里,当时应该有手稿
    //  1. 这里的rCansetModels其实就是scene树
    //  2. 到时候分析一下它和scene树的区别,前者元素是TOFoModel,后者是AISceneModel;
    //  3. 但前者可能只是用非体阶段,即H的迁移比R中要复杂一两层的;
    
    NSArray *rCansetModels = rDemand.actionFoModels;
    NSLog(@"第1步 rCansetModels数: %ld",rCansetModels.count);
    
    //2. 根据当前hAlg取抽具象树;
    TOAlgModel *hAlgModel = (TOAlgModel*)demand.baseOrGroup;
    AIFoNodeBase *hAlg = [SMGUtils searchNode:hAlgModel.content_p];
    NSArray *absHAlgs = Ports2Pits([AINetUtils absPorts_All:hAlg]);
    NSArray *conHAlgs = [SMGUtils convertArr:absHAlgs convertItemArrBlock:^NSArray *(AIKVPointer *obj) {
        AIAlgNodeBase *absHAlg = [SMGUtils searchNode:obj];
        return Ports2Pits([AINetUtils conPorts_All:absHAlg]);
    }];
    
    NSMutableArray *allHAlgs = [[NSMutableArray alloc] init];
    [allHAlgs addObject:hAlg.pointer];
    [allHAlgs addObjectsFromArray:absHAlgs];
    [allHAlgs addObjectsFromArray:conHAlgs];
    NSLog(@"第2步 absHAlg数:%ld conHAlg数:%ld HAlg树总数:%ld",absHAlgs.count,conHAlgs.count,allHAlgs.count);
//    NSLog(@"=====> %@",CLEANSTR([SMGUtils convertArr:allHAlgs convertBlock:^id(AIKVPointer *obj) {
//        return STRFORMAT(@"F%ld",obj.pointerId);
//    }]));
    
    NSString *hAlgStr = Alg2FStr(hAlg);
    NSMutableArray *havHCansetOfRCanset = [[NSMutableArray alloc] init];
    if ([hAlgStr containsString:@"皮果"]) {
        NSLog(@"直接调试以下,rCanset中就没有包含 果 的...");
        //1. 可是不对啊,都生成皮果hDemand了,怎么可能rCanset里没一个有"果"的呢?
        //2. 即使就真的全没果,那么只好再多训练一些newHCanset出来了...
        //3. 可是下面havHAlgRCansetModelsCount又显示计数5,就奇怪了...,既然没有"果",又哪里计到5呢?
        
        
        NSInteger step1 = 0,step2 = 0;
        for (TOFoModel *item in rCansetModels) {
            AIFoNodeBase *rCanset = [SMGUtils searchNode:item.cansetFo];
            for (NSInteger i = 0; i < rCanset.count; i++) {
                AIKVPointer *rCansetAlg = ARR_INDEX(rCanset.content_ps, i);
                NSString *rCansetAlgStr = Pit2FStr(rCansetAlg);
                if (![rCansetAlgStr containsString:@"皮果"]) {
                    step1++;
                    continue;
                }
                
                NSArray *hCansets = [rCanset getConCansets:i];
                if (!ARRISOK(hCansets)) {
                    step2++;
                    continue;
                }
                
                [havHCansetOfRCanset addObject:item];
                NSLog(@"挂载有hCanset Success");
            }
        }
        NSLog(@"==============>>> %ld %ld",step1,step2);//包含有皮果的rCanset共192条,但它们全部都没有挂截hCanset;
    }
    
    
    //3. 从所有rCanset中,筛选出包含hAlg抽具象树的;
    __block NSMutableArray *havHAlgRCansetModels = [[NSMutableArray alloc] init];
    NSArray *hCansets = [SMGUtils convertArr:rCansetModels convertItemArrBlock:^NSArray *(TOFoModel *item) {
        //a. 从每条rCanset中,找是否包含hAlg树的任何一个枝叶;
        AIFoNodeBase *rCansetFo = [SMGUtils searchNode:item.cansetFo];
        NSInteger findIndex = -1;
        for (NSInteger i = 0; i < rCansetFo.count; i++) {
            AIKVPointer *rCansetAlg = ARR_INDEX(rCansetFo.content_ps, i);
            if ([allHAlgs containsObject:rCansetAlg]) {
                findIndex = i;
                break;
            }
        }
        if (findIndex == -1) return nil;//找hAlg树枝叶失败: 则此rCanset不具备迁移给hScene.hAlg帧的条件;
        [havHAlgRCansetModels addObject:item];
        
        //b. 从所有rCanset中,筛选出有hAlg的hCanset解的部分;
        NSArray *hCansets = [rCansetFo getConCansets:findIndex];
        if (!ARRISOK(hCansets)) return nil;//rCanset这帧无H解: 则它没任何hCanset可迁移给hScene.hAlg;
        return hCansets;
    }];
    NSLog(@"第3步 包含HAlg树的rCansetModels数:%ld \n%@",havHAlgRCansetModels.count,CLEANSTR([SMGUtils convertArr:havHAlgRCansetModels convertBlock:^id(TOFoModel *obj) {
        return STRFORMAT(@"F%ld",obj.cansetFo.pointerId);
    }]));
    NSLog(@"第4步 找到hCansets数:%ld",hCansets.count);
    
    //5. 对有解的部分进行竞争;
    
    //6. 将最好的hCanset解返回 (改写H版本的generalSolution());
    return nil;
    
    //7. 返回后,将hCanset打包成foModel,并迁移;
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
        //3. 取出overrideCansets;
        AIFoNodeBase *sceneFo = [SMGUtils searchNode:sceneModel.scene];
        NSArray *cansets = ARRTOOK([TCCanset getOverrideCansets:sceneModel sceneTargetIndex:sceneFo.count]);//127ms
        AIMatchFoModel *pFo = [SMGUtils filterSingleFromArr:demand.validPFos checkValid:^BOOL(AIMatchFoModel *item) {
            return [item.matchFo isEqual:sceneModel.getRoot.scene];
        }];
        NSArray *itemCansetModels = [SMGUtils convertArr:cansets convertBlock:^id(AIKVPointer *canset) {
            //4. cansetModel转换器参数准备;
            NSInteger aleardayCount = sceneModel.cutIndex + 1;
            
            //4. 过滤器 & 转cansetModels候选集 (参考26128-第1步 & 26161-1&2&3);
            return [TCCanset convert2CansetModel:canset sceneFo:sceneModel.scene basePFoOrTargetFoModel:pFo ptAleardayCount:aleardayCount isH:false sceneModel:sceneModel demand:demand];//1200ms/600次执行
        }];
        
        if (Log4GetCansetResult4R && cansets.count > 0) NSLog(@"\t item场景(%@):%@ 取得候选数:%ld 转成候选模型数:%ld",SceneType2Str(sceneModel.type),Pit2FStr(sceneModel.scene),cansets.count,itemCansetModels.count);
        return itemCansetModels;
    }];
    NSLog(@"第2步 转为候选集 总数:%ld",cansetModels.count);

    //5. 竞争求解;
    return [self realTimeRankCansets:demand zonHeScoreBlock:nil];//400ms
}

/**
 *  MARK:--------------------Cansets实时竞争--------------------
 *  @desc 思考求解: 前段匹配,中段加工,后段静默 (参考26127);
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
    NSLog(@"第7步 排除FRSTime来不及的:%ld",cansetModels.count);//测时xx条

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

    //13. 更新状态besting和bested (参考31073-TODO2d);
    [TCSolutionUtil updateCansetStatus:result demand:demand];
    
    //14. 只在初次best时执行一次由用转体,以及因激活更新强度等 (避免每次实时竞争导致重复跑这些);
    if (result && result.cansetStatus == CS_None) {
        AIFoNodeBase *resultFo = [SMGUtils searchNode:result.cansetFo];
        NSLog(@"求解最佳结果:F%ld (前%.2f 中%.2f 后%.2f) %@",result.cansetFo.pointerId,result.frontMatchValue,result.midStableScore,result.backMatchValue,CLEANSTR(resultFo.spDic));
        
        //15. bestResult由用转体迁移;
        [TCTransfer transferForCreate:result];

        //15. 更新其前段帧的con和abs抽具象强度 (参考28086-todo2);
        [AINetUtils updateConAndAbsStrongByIndexDic:result.matchFrontIndexDic matchFo:result.sceneFo cansetFo:result.cansetFo];

        //16. 更新后段的的具象强度 (参考28092-todo4);
        [AINetUtils updateConAndAbsStrongByIndexDic:result.backIndexDic matchFo:result.sceneFo cansetFo:result.cansetFo];

        //17. 更新其前段alg引用value的强度;
        [AINetUtils updateAlgRefStrongByIndexDic:result.protoFrontIndexDic matchFo:result.cansetFo];
    }
    
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
            return maskIndex <= demandBaseFo.cutIndex;
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
