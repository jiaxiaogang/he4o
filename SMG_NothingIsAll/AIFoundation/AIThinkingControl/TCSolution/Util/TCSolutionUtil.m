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
 *  @desc 用于当前rCanset的下一帧求解，但当前rCanset及其F迁移关联上，H解都很少，所以需要从别的同样在激活中的rCanset池上取H解（但别的rCanset池没有绝对H映射，需要单独判断下mIsC映射符合当前targetAlg）。
 *  @progress 求解是通过左突右进的方式来推进的，流程说明如下：
 *      1. IF树“习得H解”从无到有的流程：
 *          第1步、当前IF树H无解后。
 *          第2步、另一个IF树激活，并且找到H解。
 *          第3步、另一个IF树输出H解并行为化有效后。
 *          第4步、当前IF树也会因此被feedbackTOR反馈有效，学到H解。
 *      2、IF树“使用H解”从无到有的流程：
 *          步骤1、整个工作记忆树该传染就传染，传染后自然能激活别的未传染掉的rCanset（注：这里是指整个工作记忆树的actIndex帧只要匹配就传染掉 参考8.TODO2）。
 *          步骤2、等未传染掉的rCanset推进有效，并且最终实现了当初的h目标时，当时已传染的rCanset们又会被唤醒。
 *          步骤3、这些被唤醒的因此习得新的newHCanset解，从此后它们也从无h解到有h解了。
 *  @version
 *      2023.09.10: 升级v2,支持TCScene和TCCanset (参考30127);
 *      2023.10.04: 测得总是输出无计可施,发现H迁移路径和R是不同的,H经验迁移不过来,所以最终解决如下升级下v3;
 *      2024.02.xx: 升级v3:
 *                  1. HCansetFrom的取值从从pFo下的sceneTree下的rCanset下找 (参考hSolutionV3中筛选出targetPFo,并以此筛选出hSceneFrom);
 *                  2. H与R的迁移路径不同的处理 (H比R的首尾各多一层,参考TCTransferV3);
 */
+(TOFoModel*) hSolutionV5:(HDemandModel *)hDemand {
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
    AIKVPointer *targetPFo = targetFoM.baseSceneModel.getIScene;
    
    AIMatchFoModel *basePFo = targetFoM.basePFo;
    ReasonDemandModel *baseRDemand = basePFo.baseRDemand;
    
    //2. 数据准备：根据targetAlg及其具象的被引用，取出所有包含targetAlg的时序（后面用于提前判断下hCanset有效性，避免性能问题）（参考33159-TODO4）。
    NSMutableArray *targetAlg_ps = [[NSMutableArray alloc] initWithArray:Ports2Pits([AINetUtils conPorts_All:targetAlg])];
    [targetAlg_ps addObject:targetAlg.p];
    NSArray *allFo4HasTargetAlg_ps = [SMGUtils convertArr:targetAlg_ps convertItemArrBlock:^NSArray *(id obj) {
        return Ports2Pits([AINetUtils refPorts_All:obj]);
    }];
    
    if (targetAlg_ps.count == 1) {
        NSLog(@"具象只有0条");
    }
    
    if (allFo4HasTargetAlg_ps.count == 0) {
        NSLog(@"target被引用只有0条");
    }
    
    //3. 场景树：H场景树其实也是取R场景树，因为二者已经合并了（参考33171-TODO3）。
    NSArray *sceneModels = [TCScene hGetSceneTree:hDemand];
    
    //4. 每个cansetModel转solutionModel;
    //2025.03.01：以下从sceneModel取canset的“SMGUtils.convertArr()“方法，H和R应该是可以复用的，当然为了后续HR各自可以灵活改，也可以先不复用。
    NSArray *allHCansetModels = [SMGUtils convertArr:sceneModels convertItemArrBlock:^NSArray *(AISceneModel *sceneModel) {
        //5. 取所有CansetFroms;
        //2023.12.24: 性能测试记录 (结果: 此方法很卡) (参考31025-代码段-问题1);
        //  a. 记录此处为brother时,   共执行了: 300次 x 每次10ms     = 3s;
        //  b. 记录此处为father时,    共执行了: 16次  x 每次1ms      = 16ms;
        //  c. 记录此处为i时,         共执行了: 16次  x 每次125ms    = 2s;
        AIFoNodeBase *fScene = [SMGUtils searchNode:sceneModel.getFatherScene];
        AIFoNodeBase *iScene = [SMGUtils searchNode:sceneModel.getIScene];
        
        //2024.05.08: 废弃按"有效和强度"过滤,因为新解往往排最后,这会导致它们永远没机会,这违背了宽入原则 (参考31174-问题2-方案1 & 31175-TODO3);
        NSArray *cansetFroms1 = [fScene getConCansetsWithStartIndex:sceneModel.cutIndex + 1];//全激活 (调用rSolution平均耗时700ms)
        
        //7. 转为CansetModel：过滤器 & 转cansetModels候选集 (参考26128-第1步 & 26161-1&2&3);
        NSArray *itemHCansetModels = [self convertHCansetFroms2HCansetModelsV5:cansetFroms1 fScene:fScene iScene:iScene
                                                             sceneFromCutIndex:sceneModel.cutIndex sceneToActIndex:sceneModel.getISceneModel.cutIndex + 1
                                                                       hDemand:hDemand IF_RSceneModel:sceneModel targetFoM:targetFoM
                                                                  targetAlg_ps:targetAlg_ps allFo4HasTargetAlg_ps:allFo4HasTargetAlg_ps];
        
        if (Log4GetCansetResult4H && cansetFroms1.count > 0) NSLog(@"第1步 取HCanset候选集item场景(%@):%@ 第%ld帧开始取得候选数:%ld 转成候选模型数:%ld",SceneType2Str(sceneModel.type),Pit2FStr(sceneModel.scene),sceneModel.cutIndex + 1,cansetFroms1.count,itemHCansetModels.count);
        return itemHCansetModels;
    }];
    
    //11. log
    if (ARRISOK(allHCansetModels)) {
        if (Log4GetCansetResult4H) NSLog(@"第2步 共取得HCanset候选集: \n\t%@",CLEANSTR([SMGUtils convertArr:allHCansetModels convertBlock:^id(TOFoModel *obj) {
            return ShortDesc4Pit(obj.fCanset);
        }]));
    }
    
    //12. 求出匹配度,转为评分模型 (把每个cansetFrom的综合匹配度算出来,用于后面过滤) (参考31121-TODO3 & TODO4);
    //2025.02.04: 修复用共同抽象取匹配度，取得null（0）的问题，经查原因是本来targetAlg和cansetTo的targetIndex就是同一个节点，它们没有共同抽象，本来就是同一个，匹配度为1才对（参考33158）。
    //TODOTEST: 此处为测试代码，如果2025.03前不复现，可删此调试断点日志。
    for (TOFoModel *obj in allHCansetModels) {
        AIShortMatchModel_Simple *cansetToTargetOrder = ARR_INDEX(obj.transferXvModel.cansetToOrders, obj.cansetTargetIndex);
        AIAlgNodeBase *cansetToTargetAlg = [SMGUtils searchNode:cansetToTargetOrder.alg_p];
        BOOL mIsC1 = [TOUtils mIsC_1:cansetToTargetAlg.p c:targetAlg.p];
        BOOL mIsC2 = [TOUtils mIsC_1:targetAlg.p c:cansetToTargetAlg.p];
        CGFloat matchValue1 = [targetAlg getConMatchValue:cansetToTargetAlg.p];
        CGFloat matchValue2 = [cansetToTargetAlg getConMatchValue:targetAlg.p];
        //如果断点，查下这里匹配度为0的原因，查下cansetToTargetAlg和targetAlg不是同一帧的原因。
        
        
        //TODOTOMORROW20250208: 这里把cansetFrom，sceneFrom，sceneTo，cansetTo这一套全打出来看下，看能不能找着线索。
        //targetFo: F9507[M1{↑饿-16},A542(向272,距83,果),A544(向237,距90,果),M1,A544,M1,A544,M1,A544,飞↓,A544] //其中cutIndex=2
        //测到一次：cansetToTargetAlg=A544(向237,距90,果)，targetAlg=M1{↑饿-16}。
        //这就明显的问题了，问题就在convertHCansetModel中，它的cansetTargetIndex取到了3。（因为这个3是果，而targetAlg是M1饥饿）。
        //此处rCansetFromModel=sceneFrom=F2187 hCansetFrom=F8671 rCansetFromModel.cansetCutIndex=hSceneCutIndex=1
        //NSDictionary *indexDic = [F2187 getConIndexDic:F8671];
        //NSInteger hSceneTargetIndex = hSceneCutIndex + 1;//H任务的目标其实就是下一帧;
        //NSInteger hCansetTargetIndex = NUMTOOK([indexDic objectForKey:@(hSceneTargetIndex)]).integerValue;
        //明天把F2187和F8671的映射取出来，看下为什么会映射到这个hCansetTargetIndex=3。
        
        //F2187[M1{↑饿-16},A542(向272,距83,果),A544(向237,距90,果),飞↘,A544]
        //F8671[M1{↑饿-16},A542(向272,距83,果),M1,A544(向237,距90,果)]
        //IndexDic: {0 = 0;1 = 1;2 = 3;}
        //如上日志，看起来二者的映射没什么问题。
        
        //分析：当前rCanset F2187确实cutIndex是1，下一帧是A544果。
        //所以从它下面取到H解后，转成h解模型时，取得的映射目标就是F8671的第3帧，A544果。这没问题。
        //线索：问题出在，targetAlg是M1饿，而另一个解rCanset F2187人家下一帧并不是M1饿。
        
        if (!mIsC1 && !mIsC2) {
            ELog(@"A调试一下，此处只从F迁移了，应该直接可以取到匹配度才对，不能取到null：%d %d %.2f %.2f 测下是不是都是同一个节点:%d",mIsC1,mIsC2,matchValue1,matchValue2,[cansetToTargetAlg.p isEqual:targetAlg.p]);
            NSLog(@"");
        }
        if (matchValue1 == 0 && matchValue2 == 0) {
            ELog(@"B调试一下，此处只从F迁移了，应该直接可以取到匹配度才对，不能取到null：%d %d %.2f %.2f 测下是不是都是同一个节点:%d",mIsC1,mIsC2,matchValue1,matchValue2,[cansetToTargetAlg.p isEqual:targetAlg.p]);
            NSLog(@"");
        }
        if (![cansetToTargetAlg.p isEqual:targetAlg.p]) {
            ELog(@"C调试一下，此处只从F迁移了，应该直接可以取到匹配度才对，不能取到null：%d %d %.2f %.2f 测下是不是都是同一个节点:%d",mIsC1,mIsC2,matchValue1,matchValue2,[cansetToTargetAlg.p isEqual:targetAlg.p]);
            NSLog(@"");
        }
        
        NSArray *cansetFrom4 = [SMGUtils convertArr:allHCansetModels convertBlock:^id(TOFoModel *obj) {
            //a. 取出当前cansetTo的目标帧;
            //2025.02.02: 原来允许从bro迁移过来，所以用isBro来取匹配度，把BF和FI两步迁移分开后，这里只需要从F迁移了，所以直接取抽具象匹配度即可（参考33158）。
            AIShortMatchModel_Simple *cansetToOrder = ARR_INDEX(obj.transferXvModel.cansetToOrders, obj.cansetTargetIndex);
            CGFloat matchValue = [targetAlg getConMatchValue:cansetToOrder.alg_p];
            return [MapModel newWithV1:obj v2:@(matchValue)];
        }];
        
        //8. 过滤掉匹配度为0的 (只要不为0,肯定是有mcIsBro关系的) (参考31103-第2步 & 31121-TODO4);
        NSArray *cansetFrom5 = [SMGUtils filterArr:cansetFrom4 checkValid:^BOOL(MapModel *item) { return NUMTOOK(item.v2).floatValue > 0; }];
        
        //9. 把末尾20%过滤掉 (末尾淘汰制) (参考31121-TODO2);
        NSArray *cansetFrom6 = [SMGUtils sortBig2Small:cansetFrom5 compareBlock:^double(MapModel *obj) { return NUMTOOK(obj.v2).floatValue; }];
        cansetFrom6 = ARR_SUB(cansetFrom6, 0, cansetFrom6.count * 0.8f);
        
        //10. 更新到actionFoModels;
        NSArray *cansetFromFinish = [SMGUtils convertArr:cansetFrom6 convertBlock:^id(MapModel *obj) { return obj.v1; }];
        [hDemand.actionFoModels addObjectsFromArray:cansetFromFinish];
        if (Log4GetCansetResult4H && allHCansetModels.count > 0) NSLog(@"第3步 item场景:%@ 取得候选数:%ld",Pit2FStr(basePFo.matchFo),cansetFromFinish.count);
    }
    
    //11. 在rSolution/hSolution初始化Canset池时,也继用下传染状态 (参考31178-TODO3);
    int initToInfectedNum = [TOUtils initInfectedForCansetPool_Alg:hDemand];
    //NSLog(@"fltx1 此H的sub到root结构: %@",[TOModelVision cur2Root:hDemand]);
    NSLog(@"第2步 H转为候选集:%ld - 中间帧被初始传染:%d = 有效数:%ld",hDemand.actionFoModels.count,initToInfectedNum,hDemand.actionFoModels.count - initToInfectedNum);
    
    //12. 竞争求解: 对hCansets进行实时竞争 (参考31122);
    return [self realTimeRankCansets:hDemand zonHeScoreBlock:nil debugMode:true];//400ms
}

+(BOOL) filter1ForCheckHCansetFromIsInvalid:(NSArray*)allFo4HasTargetAlg_ps iScene:(AIFoNodeBase*)iScene hCansetFrom_p:(AIKVPointer*)hCansetFrom_p {
    //11. 迁移前过滤器A：先判断下hCansetFrom在迁移后，有没有可能包涵taretAlg的解，有才进行迁移，否则直接跳过，以节约性能（因为有映射取sceneTo，没映射取cansetFrom，所以二者有一个包含，就有可能该H解对targetAlg有效）。
    //另外：但这里无法保证hCansetFrom绝对有效，也许迁移后，才发现orders其实不行，无法解H，所以到迁移后，取到targetIndex后，再加个判断是否有效的过滤器。
    return ![allFo4HasTargetAlg_ps containsObject:iScene.p] && ![allFo4HasTargetAlg_ps containsObject:hCansetFrom_p];
}

+(NSInteger) getHCansetCutIndex:(AIFoNodeBase*)fScene hCansetFrom_p:(AIKVPointer*)hCansetFrom_p hSceneFromCutIndex:(NSInteger)hSceneFromCutIndex {
    //13. 判断orders已发生截点，根据hSceneFrom和hCansetFrom的映射来取。
    NSDictionary *hSceneFromCansetFromIndexDic = [fScene getConIndexDic:hCansetFrom_p];
    NSInteger hCansetCutIndex = [TOUtils goBackToFindConIndexByAbsIndex:hSceneFromCansetFromIndexDic absIndex:hSceneFromCutIndex];
    return hCansetCutIndex;
}

+(NSInteger) getHCansetToTargetIndex:(TCTransferXvModel*)xvModel hCansetCutIndex:(NSInteger)hCansetCutIndex targetAlg_ps:(NSArray*)targetAlg_ps {
    //14. 判断orders未发生部分，是否确实对targetAlg有解：得到hCansetTo.TargetIndex（参考33159-TODO4）。
    NSInteger hCansetToTargetIndex = -1;
    for (NSInteger i = hCansetCutIndex; i < xvModel.cansetToOrders.count; i++) {
        AIShortMatchModel_Simple *order = ARR_INDEX(xvModel.cansetToOrders, i);
        if ([targetAlg_ps containsObject:order.alg_p]) {
            hCansetToTargetIndex = i;
            break;
        }
    }
    return hCansetToTargetIndex;
}

+(BOOL) filter2ForCheckHCansetToTargetIndexIsInvalid:(NSInteger)hCansetToTargetIndex hCansetCutIndex:(NSInteger)hCansetCutIndex {
    //15. 迁移后过滤器B：并加上迁移后无效的过滤器。
    //2025.02.21: 它必须有中间帧（即目标-已发生截点必须>1，参考33159-思路1）。
    return hCansetToTargetIndex == -1 || hCansetToTargetIndex - hCansetCutIndex < 2;
}

/**
 *  MARK:--------------------转hCansetFroms为候选模型--------------------
 *  @TODO废弃
 */
+(NSArray*) convertHCansetFroms2HCansetModelsV5:(NSArray*)hCansetFrom_ps fScene:(AIFoNodeBase*)fScene iScene:(AIFoNodeBase*)iScene
                             sceneFromCutIndex:(NSInteger)sceneFromCutIndex sceneToActIndex:(NSInteger)sceneToActIndex//from截点和to目标
                                      hDemand:(HDemandModel*)hDemand IF_RSceneModel:(AISceneModel*)IF_RSceneModel targetFoM:(TOFoModel*)targetFoM
                                   targetAlg_ps:(NSArray*)targetAlg_ps allFo4HasTargetAlg_ps:(NSArray*)allFo4HasTargetAlg_ps {//从hDemand->scene树->行为化中canset->targetAlg相关
    //1. 数据准备
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (AIKVPointer *hCansetFrom_p in hCansetFrom_ps) {
        //11. 前过滤器
        if ([self filter1ForCheckHCansetFromIsInvalid:allFo4HasTargetAlg_ps iScene:iScene hCansetFrom_p:hCansetFrom_p]) continue;
        //12. 虚迁移
        TCTransferXvModel *xvModel = [TCTransfer transferJiCen_RH_V3:hCansetFrom_p fScene:fScene iScene:iScene sceneToActIndex:sceneToActIndex];
        //13. 取hCansetCutIndex
        NSInteger hCansetCutIndex = [self getHCansetCutIndex:fScene hCansetFrom_p:hCansetFrom_p hSceneFromCutIndex:sceneFromCutIndex];
        //14. 取hCansetToTargetIndex
        NSInteger hCansetToTargetIndex = [self getHCansetToTargetIndex:xvModel hCansetCutIndex:hCansetCutIndex targetAlg_ps:targetAlg_ps];
        //15. 后过滤器
        if ([self filter2ForCheckHCansetToTargetIndexIsInvalid:hCansetToTargetIndex hCansetCutIndex:hCansetCutIndex]) continue;
        //16. 转为TOFoModel;
        TOFoModel *hModel = [TCCanset convert2HCansetModelV2:hCansetFrom_p fScene:fScene hDemand:hDemand hCansetCutIndex:hCansetCutIndex targetFoM:targetFoM hCansetToTargetIndex:hCansetToTargetIndex IF_RSceneModel:IF_RSceneModel xvModel:xvModel];
        if (hModel) [result addObject:hModel];
    }
    return result;
}

/**
 *  MARK:--------------------R求解--------------------
 *  @version
 *      2023.12.26: 提前在for之前取scene所在的pFo,以优化其性能 (参考31025-代码段-问题1) //共三处优化,此乃其一;
 *      2024.01.24: 只初始化一次,避免重唤醒成actionFoModels (参考31073-TODO2f);
 */
+(TOFoModel*) rSolution:(ReasonDemandModel *)demand {
    //0. 初始化一次,后面只执行generalSolution部分;
    if (demand.alreadyInitCansetModels) {
        ELog(@"solution()应该只执行一次,别的全从TCPlan来分发和实时竞争,此处如果重复执行,查下原因");
        return nil;
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
        AIFoNodeBase *fScene = [SMGUtils searchNode:sceneModel.getFatherScene];
        AIFoNodeBase *iScene = [SMGUtils searchNode:sceneModel.getIScene];
        
        //2024.05.08: 废弃按"有效和强度"过滤,因为新解往往排最后,这会导致它们永远没机会,这违背了宽入原则 (参考31174-问题2-方案1 & 31175-TODO3);
        NSArray *cansetFroms1 = [fScene getConCansets:fScene.count];//全激活 (调用rSolution平均耗时700ms)
        //NSArray *cansetFroms1 = [AIFilter solutionRCansetFilter:sceneFrom targetIndex:sceneFrom.count];//只激活前20% (调用rSolution平均耗时600ms)
        
        //6. 转为CansetModel;
        AIMatchFoModel *pFo = [SMGUtils filterSingleFromArr:demand.validPFos checkValid:^BOOL(AIMatchFoModel *item) {
            return [item.matchFo isEqual:sceneModel.getRoot.scene];
        }];
        NSArray *itemCansetModels = [SMGUtils convertArr:cansetFroms1 convertBlock:^id(AIKVPointer *fCanset) {
            //4. 过滤器 & 转cansetModels候选集 (参考26128-第1步 & 26161-1&2&3);
            return [TCCanset convert2RCansetModel:fCanset fScene:fScene iScene:iScene basePFoOrTargetFoModel:pFo sceneModel:sceneModel demand:demand];//1200ms/600次执行
        }];
        if (Log4GetCansetResult4R && cansetFroms1.count > 0) NSLog(@"\t item场景(%@):%@ 取得候选数:%ld 转成候选模型数:%ld",SceneType2Str(sceneModel.type),Pit2FStr(sceneModel.scene),cansetFroms1.count,itemCansetModels.count);
        return itemCansetModels;
    }];
    
    //9. 在rSolution/hSolution初始化Canset池时,也继用下传染状态 (参考31178-TODO3);
    int initToInfectedNum = [TOUtils initInfectedForCansetPool_Alg:demand];
    int initToInfectedNum_Mv = [TOUtils initInfectedForCansetPool_Mv:demand];
    NSLog(@"第2步 R转为候选集:%ld - 中间帧被初始传染:%d - 末帧被初始传染:%d = 有效数:%ld",cansetModels.count,initToInfectedNum,initToInfectedNum_Mv,cansetModels.count - initToInfectedNum - initToInfectedNum_Mv);

    //10. 竞争求解;
    return [self realTimeRankCansets:demand zonHeScoreBlock:nil debugMode:true];//400ms
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
+(TOFoModel*) realTimeRankCansets:(DemandModel *)demand zonHeScoreBlock:(double(^)(TOFoModel *obj))zonHeScoreBlock debugMode:(BOOL)debugMode{
    //1. 数据准备;
    NSString *rhLog = ISOK(demand, HDemandModel.class)?@"H":@"R";
    [AITest test13:demand.actionFoModels];
    TOFoModel *result = nil;
    if (debugMode) NSLog(@"第5步 %@Anaylst匹配成功:%ld",rhLog,demand.actionFoModels.count);//测时94条

    //2. 不应期 (可以考虑) (源于:反思且子任务失败的 或 fo行为化最终失败的,参考24135);
    //8. 排除不应期: 无计可施的失败TOFoModel计为不应期 (参考31073-TODO8);
    //1. 过滤掉actNo,withOut,scoreNo,finish这些状态的;
    NSArray *cansetModels = [SMGUtils filterArr:demand.actionFoModels checkValid:^BOOL(TOFoModel *item) {
        return item.status != TOModelStatus_ActNo && item.status != TOModelStatus_ScoreNo && item.status != TOModelStatus_WithOut && item.status != TOModelStatus_Finish;
    }];
    if (debugMode) NSLog(@"第6步 %@排除Status无效的:%ld",rhLog,cansetModels.count);//测时xx条
    
    //3. 2024.05.19: 已被传染的Canset不会激活,直接计为不可行 (参考31178-TODO4);
    cansetModels = [SMGUtils filterArr:cansetModels checkValid:^BOOL(TOFoModel *item) {
        return !item.isInfected;
    }];
    if (debugMode) NSLog(@"第7步 %@排除Infected传染掉的:%ld",rhLog,cansetModels.count);

    //9. 对下一帧做时间不急评价: 不急 = 解决方案所需时间 <= 父任务能给的时间 (参考:24057-方案3,24171-7);
    //2. 最近的R任务 (R任务时取自身,H任务时取最近的baseRDemand);
    //2024.07.09: 只有非持续性r任务,才限时间,像持续饿感这种不限时间;
    if (![ThinkingUtils baseRDemandIsContinuousWithAT:demand]) {
        cansetModels = [SMGUtils filterArr:cansetModels checkValid:^BOOL(TOFoModel *item) {
            return [AIScore FRS_Time:demand solutionModel:item];
        }];
        if (debugMode) NSLog(@"第8步 %@排除FRSTime来不及的:%ld",rhLog,cansetModels.count);//测时xx条
    }
    
    //10. 避免工作记忆纵向同枝上的HDemand重复,导致重复H求解 (参考32084-3-实践);
    NSArray *baseHAlgs = [SMGUtils convertArr:[TOUtils getBaseDemands_AllDeep:demand] convertBlock:^id(HDemandModel *obj) {
        return (ISOK(obj, HDemandModel.class)) ? Demand2Pit(obj) : nil;
    }];
    cansetModels = [SMGUtils filterArr:cansetModels checkValid:^BOOL(TOFoModel *item) {
        return ![baseHAlgs containsObject:item.getCurFrame.content_p];
    }];
    if (debugMode) NSLog(@"第9步 %@避免hDemand纵向重复:%ld",rhLog,cansetModels.count);//测时xx条

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
    NSArray *sortModels = [AIRank cansetsRankingV4:cansetModels zonHeScoreBlock:zonHeScoreBlock debugMode:debugMode];
    if (debugMode) NSLog(@"任务%@的实时竞争Top10: %@",ShortDesc4Pit([HeLogUtil demandLogPointer:demand]),CLEANSTR([SMGUtils convertArr:ARR_SUB(sortModels, 0, 10) convertBlock:^id(TOFoModel *obj) {return STRFORMAT(@"F%ld",obj.fCanset.pointerId);}]));
    
    //13. 取通过S反思的最佳S;
    for (TOFoModel *item in sortModels) {
        BOOL score = [TCRefrection firstRefrectionForSelf:item demand:demand debugMode:debugMode];
        if (!score) {
            //13. 不通过时,将状态及时改为ScoreNo (参考31083-TODO5);
            item.status = TOModelStatus_ScoreNo;
            continue;
        }

        //14. 闯关成功,取出最佳,跳出循环;
        result = item;
        break;
    }
    
    //14. 只在初次best时执行一次由虚转实,以及因激活更新强度等 (避免每次实时竞争导致重复跑这些);
    if (result && result.cansetStatus == CS_None) {
        AIFoNodeBase *fCanset = [SMGUtils searchNode:result.fCanset];
        if (debugMode) NSLog(@"第10步 %@求解最佳结果:F%ld %@",rhLog,result.fCanset.pointerId,CLEANSTR(fCanset.spDic));
        
        //16. 更新前中后段con和abs的抽具象强度 (参考28086-todo2 & 28092-todo4);
        [AINetUtils updateConAndAbsStrongByIndexDic:result.transferXvModel.sceneToCansetToIndexDic matchFo:result.iScene cansetFo:result.transferXvModel.cansetToOrders];

        //17. 更新其前段alg引用value的强度;
        NSArray *frontCansetToIndexArr = [SMGUtils filterArr:result.transferXvModel.sceneToCansetToIndexDic.allValues checkValid:^BOOL(NSNumber *item) {
            return item.intValue <= result.cansetCutIndex;
        }];
        [AINetUtils updateAlgRefStrongByIndexArr:frontCansetToIndexArr foContent_ps:Simples2Pits(result.transferXvModel.cansetToOrders)];
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
        //b. R子任务时 (参考26232-TODO6);
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
