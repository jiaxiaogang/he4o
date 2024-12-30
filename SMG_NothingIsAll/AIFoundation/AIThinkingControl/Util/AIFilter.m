//
//  AIFilter.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/2/25.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AIFilter.h"

@implementation AIFilter

/**
 *  MARK:--------------------概念识别过滤器--------------------
 *  @version
 *      2023.03.06: 概念识别过滤器匹配度为主,强度为辅 (参考28152-方案4-todo4);
 *      2023.06.01: BUG_有了识别二次过滤后,过滤太强导致最后的pFos剩下0-2条太少了,所以此处减弱一下过滤力度;
 *      2023.06.01: pAlgs和rAlgs支持传入不同的radio过滤值 (参考29108-2.1);
 *      2024.12.20: 放宽概念识别条数 (参考3313b-方案);
 */
+(NSArray*) recognitionAlgFilter:(NSArray*)matchAlgModels radio:(CGFloat)radio {
    return [self filterTwice:matchAlgModels mainBlock:^double(AIMatchAlgModel *item) {
        return item.matchValue;
    } subBlock:^double(AIMatchAlgModel *item) {
        return item.strongValue;
    } radio:radio min:10 max:100 debugMode:true];
}

/**
 *  MARK:--------------------时序识别过滤器--------------------
 *  @version
 *      2023.03.06: 时序识别过滤器强度为主,匹配度为辅 (参考28152-方案4-todo5);
 *      2023.03.18. 由0.16调整为0.6 (概念已经很准了,时序只要把不准部分切了就行,不需要过滤太多);
 *      2023.06.01: 加上识别二次过滤后,第一次不需要过滤匹配度了,仅排除一下强度太弱的末尾即可 (参考29108-1);
 *      2024.12.19: 时序识别的: 一次过滤的强度太弱,而二次过滤的匹配度太强,所以增高强度,减弱匹配度 (参考3313a-方案);
 */
+(NSArray*) recognitionFoFilter:(NSArray*)matchModels {
    return [self filterOnce:matchModels mainBlock:^double(AIMatchFoModel *item) {
        return item.strongValue;
    } radio:0.5f min:8 max:20 caller:@"时序识别一次"];
}

/**
 *  MARK:--------------------Canset识别过滤器 (参考29042)--------------------
 *  @desc 初版Canset识别因为结果太多再类比时性能差,加过滤器体现竞争 (参考29042);
 *  @version
 *      2023.04.04: 将过滤器由SP主EFF辅,改为映射数为主SP为辅 (参考29055-方案);
 *      2023.10.26: 废弃canset识别 (参考3014c-todo2);
 */
//+(NSArray*) recognitionCansetFilter:(NSArray*)matchModels sceneFo:(AIFoNodeBase*)sceneFo {
//    CGFloat radio = 0.2f;
//    NSArray *result = ARR_SUB([SMGUtils sortBig2Small:matchModels compareBlock:^double(AIMatchCansetModel *obj) {
//        return obj.indexDic.count;
//    }], 0, matchModels.count * radio);
//    NSLog(@"Canset识别过滤器: 总%ld * 需%.0f%% => 剩:%ld",matchModels.count,radio * 100,result.count);
//    return result;
//}

/**
 *  MARK:--------------------Canset求解过滤器 (参考29081-todo41)--------------------
 *  @version
 *      2023.09.04: 加上hStrong做二级排序因子 (参考30125-方案);
 *      2023.12.26: 优化sort性能,把getEffectStrong()提出来提前取好 (参考31025-代码段-问题1) //共三处优化,此乃其一;
 *      2024.05.08: 废弃,因宽入窄出原则,改为100%激活 (参考31175-TODO3);
 */
//+(NSArray*) solutionRCansetFilter:(AIFoNodeBase*)sceneFo targetIndex:(NSInteger)targetIndex {
//    NSArray *protoConCansets = [sceneFo getConCansets:targetIndex];
//
//    //1. canset数组转成mapModel (提前把strong都取出来,避免后面在排序时访问太多次而卡性能);
//    NSArray *mapArr = [SMGUtils convertArr:protoConCansets convertBlock:^id(AIKVPointer *canset) {
//        AIEffectStrong *strong = [TOUtils getEffectStrong:sceneFo effectIndex:targetIndex solutionFo:canset];
//        return [MapModel newWithV1:canset v2:strong];
//    }];
//
//    //2. 对mapModelArr排序;
//    NSArray *sorts = [SMGUtils sortBig2Small:mapArr compareBlock1:^double(MapModel *mapModel) {
//        return [TOUtils getEffectScore:mapModel.v2];
//    } compareBlock2:^double(MapModel *mapModel) {
//        AIEffectStrong *strong = mapModel.v2;
//        return strong.hStrong;
//    }];
//
//    //3. sort再转回canset数组;
//    sorts = [SMGUtils convertArr:sorts convertBlock:^id(MapModel *obj) {
//        return obj.v1;
//    }];
//    NSInteger limit = MAX(3, protoConCansets.count * 0.2f);//取20% & 至少尝试取3条;
//    return ARR_SUB(sorts, 0, limit);
//}

/**
 *  MARK:--------------------识别二次过滤器--------------------
 *  @version
 *      2023.05.31: 回测概念识别二次过滤ok,就是保留60%有点多,调成40%;
 *      2023.06.04: BUG_修复时序过滤条数有不确定性 (参考29109-测得4);
 *      2023.06.06: 过滤出20%的结果依然太多,直接改成4条,小于4条时直接return不过滤 (参考30013);
 *      2024.03.30: 现在此方法仅对matchAlgs_PS做过滤,别的暂不予支持 (因为此方法只对matchPFos进行二次过滤了,原来的matchAlgs拆分成了matchAlgs_PS和matchAlgs_RS,RS在概念识别中是关着的,这里只需要支持PS即可);
 *      2024.08.17: BUG-原来仅从似层做二次过滤,导致时序里的交层结果全被过滤掉了,改成从似交层都做过滤后好了 (参考33015-问题);
 */
+(void) secondRecognitionFilter:(AIShortMatchModel*)inModel {
    //0. 现在在时序识别时,仅识别有mv指向的,所以此处仅需要对matchAlgs_PS进行二次过滤即可;
    NSArray *protoMatchAlgs = inModel.matchAlgs_P;
    
    //1. 获取V重要性字典;
    [theTC updateOperCount:kFILENAME];
    //2024.10.26: 二次过滤卡的太严了,改为保留50% (参考33109-方案1);
    //2024.10.28: 转向方案3了,所以改回一些,改成30% (参考33109-方案3);
    //2024.12.19: 时序识别的: 一次过滤的强度太弱,而二次过滤的匹配度太强,所以增高强度,减弱匹配度 (参考3313a-方案);
    NSInteger foLimit = MAX(4, inModel.matchPFos.count * 0.7f);
    if (inModel.matchPFos.count <= foLimit) return;//小于limit条时,不用二次过滤;
    IFTitleLog(@"识别二次过滤",@"\nfrom protoFo:%@",Fo2FStr(inModel.protoFo));
    BOOL debugMode = false;
    NSDictionary *importanceDic = [TCRecognitionUtil getVImportanceDic:inModel];
    
    //2. 根据重要性加权计算二次过滤匹配度 (参考29107-步骤2) (性能: 耗时42ms);
    NSMutableDictionary *secondMatchValueDic = [[NSMutableDictionary alloc] init];
    for (AIMatchAlgModel *item in protoMatchAlgs) {
        double secondMatchValue = 1;
        AIAlgNodeBase *matchAlg = [SMGUtils searchNode:item.matchAlg];
        for (AIKVPointer *protoV_p in inModel.protoAlg.content_ps) {
            for (AIKVPointer *matchV_p in matchAlg.content_ps) {
                if ([protoV_p.identifier isEqualToString:matchV_p.identifier]) {
                    
                    //3. 二次过滤V相近度 = 原V相近度 的 重要性次方 (参考29107-步骤2);
                    CGFloat nearV = [AIAnalyst compareCansetValue:matchV_p protoValue:protoV_p vInfo:nil];
                    double importance = NUMTOOK_DV([importanceDic objectForKey:protoV_p.identifier],1).doubleValue;
                    secondMatchValue *= powf(nearV, importance);
                }
            }
        }
        [secondMatchValueDic setObject:@(secondMatchValue) forKey:@(matchAlg.pId)];
    }
    
    //4. 概念识别的二次排序过滤 (保留60% & 至少保留4条) (参考29107-todo1);
    NSArray *sort = [SMGUtils sortBig2Small:protoMatchAlgs compareBlock:^double(AIMatchAlgModel *obj) {
        return NUMTOOK([secondMatchValueDic objectForKey:@(obj.matchAlg.pointerId)]).doubleValue;
    }];
    if (debugMode) for (AIMatchAlgModel *item in sort) NSLog(@"看不重要的被排到了后面日志: %ld 现匹配度:%.2f (原%.2f) %@",[sort indexOfObject:item],NUMTOOK([secondMatchValueDic objectForKey:@(item.matchAlg.pointerId)]).doubleValue,item.matchValue,Pit2FStr(item.matchAlg));
    
    //5. 保留时序30% & 至少4条;
    [AITest test28:inModel];
    NSMutableArray *filterAlgs = [[NSMutableArray alloc] init];
    NSMutableArray *filterFos = [[NSMutableArray alloc] init];
    for (AIMatchAlgModel *aItem in sort) {
        //6. 将当前aItem收集;
        [filterAlgs addObject:aItem];
        
        //7. 并收集aItem它对应的pFos (收集够foLimit条时break) (参考29107-todo2 & 29109-测得4);
        [filterFos addObjectsFromArray:[SMGUtils filterArr:inModel.matchPFos checkValid:^BOOL(AIMatchFoModel *item) {
            AIFoNodeBase *pFo = [SMGUtils searchNode:item.matchFo];
            AIKVPointer *cutIndexAlg_p = ARR_INDEX(pFo.content_ps, item.cutIndex);//取刚发生的alg;
            return [cutIndexAlg_p isEqual:aItem.matchAlg];
        }]];
        if (filterFos.count >= foLimit) break;
    }
    
    //8. 得出过滤后matchAlgs_PS & PJ;
    NSArray *filterMatchAlgs_PS = [SMGUtils filterArrA:inModel.matchAlgs_PS arrB:filterAlgs];
    NSArray *filterMatchAlgs_PJ = [SMGUtils filterArrA:inModel.matchAlgs_PJ arrB:filterAlgs];
    
    //9. debugLog
    NSLog(@"概念二次过滤后条数: PS(原%ld 剩%ld) PJ(原%ld 剩%ld) >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>",inModel.matchAlgs_PS.count,filterMatchAlgs_PS.count,inModel.matchAlgs_PJ.count,filterMatchAlgs_PJ.count);
    for (AIMatchAlgModel *item in filterAlgs) if (debugMode) NSLog(@"\t%ld. %@ (现匹配度:%.2f 原%.2f)",[filterAlgs indexOfObject:item] + 1,Pit2FStr(item.matchAlg),NUMTOOK([secondMatchValueDic objectForKey:@(item.matchAlg.pointerId)]).doubleValue,item.matchValue);
    NSLog(@"\n时序二次过滤后条数: 原%ld 剩%ld >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>",inModel.matchPFos.count,filterFos.count);
    for (AIMatchFoModel *item in filterFos) NSLog(@"\t%ld. %@",[filterFos indexOfObject:item] + 1,Pit2FStr(item.matchFo));
    
    //10. 存下结果;
    inModel.matchAlgs_PS = filterMatchAlgs_PS;
    inModel.matchAlgs_PJ = filterMatchAlgs_PJ;
    inModel.matchPFos = filterFos;
    [inModel log4HavXianWuJv_AlgPJ:@"fltx3 二次"];
    [inModel log4HavXianWuJv_PFos:@"fltx4 二次"];
}

/**
 *  MARK:--------------------行为化前反思识别过滤器 (参考30059)--------------------
 *  @desc 根据mv类型分组,然后过滤出每组迫切度最强的一条 (参考30059-方案);
 *  @version
 *      2023.07.13: 改成matchPFos默认排序方式不变,仅截取每种mv类型的前3条 (参考30059-方案2);
 */
+(void) secondActionRecognitionFilter:(AIShortMatchModel*)inModel {  
    //1. 按照mv分组,每组按pFos默认的强度排序;
    NSMutableDictionary *groupDic = [[NSMutableDictionary alloc] init];
    for (AIMatchFoModel *pFo in inModel.matchPFos) {
        AIFoNodeBase *fo = [SMGUtils searchNode:pFo.matchFo];
        
        //2. 取分组;
        NSMutableArray *itemArr = [groupDic objectForKey:fo.cmvNode_p.algsType];
        if (!itemArr) itemArr = [[NSMutableArray alloc] init];
        
        //3. 收集到分组;
        [itemArr addObject:pFo];
        [groupDic setObject:itemArr forKey:fo.cmvNode_p.algsType];
    }
    
    //4. 清空matchPFos,然后重新收集过滤后部分;
    [inModel.matchPFos removeAllObjects];
    
    //5. 把每组最迫切的一条收集起来 (过滤仅保留每组最迫切的一条);
    for (NSArray *groupPFos in groupDic.allValues) {
        NSArray *mostPFo = ARR_SUB(groupPFos, 0, 3);
        if (ARRISOK(mostPFo)) [inModel.matchPFos addObjectsFromArray:mostPFo];
    }
    NSLog(@"\n时序二次过滤后条数: 剩%ld >>>>>>>>>>>>>>>>>>>>>",inModel.matchPFos.count);
    for (AIMatchFoModel *item in inModel.matchPFos) NSLog(@"\t%ld. %@",[inModel.matchPFos indexOfObject:item] + 1,Pit2FStr(item.matchFo));
}

/**
 *  MARK:--------------------Scene求解过滤器 (参考2908a-todo2)--------------------
 *  @param type : protoScene的类型,i时向抽象取ports,father时向具象取ports;
 *  @version
 *      2023.05.08: BUG_father没conCanset被过滤,导致它的brother全没机会激活 (改为仅brother时才要求必须有cansets指向);
 *      2023.05.15: 改为强度为主,匹配度为辅进行过滤 (参考29094-BUG3-方案2);
 */
+(NSArray*) rSolutionSceneFilter:(AIFoNodeBase*)protoScene type:(SceneType)type {
    //1. 数据准备: 向着isAbs方向取得抽具关联场景;
    BOOL toAbs = type != SceneTypeFather;
    NSArray *otherScenePorts = toAbs ? [AINetUtils absPorts_All:protoScene] : [AINetUtils conPorts_All:protoScene];
    
    //2. 根据是否有conCanset过滤 (目前仅支持R任务,所以直接用fo.count做targetIndex) (参考29089-解答1-补充 & 2908a-todo5);
    otherScenePorts = [SMGUtils filterArr:otherScenePorts checkValid:^BOOL(AIPort *item) {
        AIFoNodeBase *fo = [SMGUtils searchNode:item.target_p];//500ms R90 3455次
        BOOL mvIdenOK = [fo.cmvNode_p.identifier isEqualToString:protoScene.cmvNode_p.identifier];//mv要求必须同区; //77ms 3455次
        BOOL havCansetsOK = type != SceneTypeBrother || ARRISOK([fo getConCansets:fo.count]);//非brother时要求必须有cansets; //43ms 3455次
        return mvIdenOK && havCansetsOK; //43ms 3455次
    }];
    
    //3. 根据强度为主,匹配度为辅进行过滤: 取20% & 至少尝试取3条 (参考29094-BUG3-方案2);
    otherScenePorts = [self filterTwice:otherScenePorts mainBlock:^double(AIPort *item) {
        //4. 根据强度,进行主要过滤 (参考29094-BUG3-方案2);
        return item.strong.value;//mainBlock 135ms 11540次
    } subBlock:^double(AIPort *item) {
        //5. 根据indexDic复用匹配度进行辅助过滤 (参考2908a-todo2);
        if (toAbs) {
            return [AINetUtils getMatchByIndexDic:[protoScene getAbsIndexDic:item.target_p] absFo:item.target_p conFo:protoScene.pointer callerIsAbs:false];//113ms 4038次
        }
        return [AINetUtils getMatchByIndexDic:[protoScene getConIndexDic:item.target_p] absFo:protoScene.pointer conFo:item.target_p callerIsAbs:true];//1436ms 3878次
    } radio:0.2f min:4 max:20 debugMode:false];
    return Ports2Pits(otherScenePorts);
}

/**
 *  MARK:--------------------hScene求解过滤器 (参考2908a-todo2 & 30127)--------------------
 *  _param type : protoScene的类型,i时向抽象取ports,father时向具象取ports;
 *  _param protoTargetIndex : H任务时的targetIndex不是fo.count,所以传入其对应的值 (后发现,其实就是protoScene.cutIndex+1);
 *  @version
 *      2023.09.09: 初版,hDemand支持TCScene (参考30127);
 */
+(NSArray*) hSolutionSceneFilter:(AISceneModel*)protoScene {
    //1. 数据准备: 向着isAbs方向取得抽具关联场景;
    NSInteger protoTargetIndex = protoScene.cutIndex + 1;
    BOOL toAbs = protoScene.type != SceneTypeFather;
    AIFoNodeBase *sceneFo = [SMGUtils searchNode:protoScene.scene];
    NSArray *otherScenePorts = toAbs ? [AINetUtils absPorts_All:sceneFo] : [AINetUtils conPorts_All:sceneFo];
    
    //2. 根据是否有conCanset过滤 (目前仅支持R任务,所以直接用fo.count做targetIndex) (参考29089-解答1-补充 & 2908a-todo5);
    otherScenePorts = [SMGUtils filterArr:otherScenePorts checkValid:^BOOL(AIPort *item) {
        //a. 取联想到的assScene对应的targetIndex;
        NSDictionary *indexDic = toAbs ? [sceneFo getAbsIndexDic:item.target_p] : [sceneFo getConIndexDic:item.target_p];
        NSNumber *assSceneTargetIndex = nil;
        if (toAbs) {
            assSceneTargetIndex = ARR_INDEX([indexDic allKeysForObject:@(protoTargetIndex)], 0);
        } else {
            assSceneTargetIndex = [indexDic objectForKey:@(protoTargetIndex)];
        }
        
        //b. 要求必须有联想到的scene必须包含对应protoTargetIndex的帧;
        if (!assSceneTargetIndex) {
            return false;
        }
        
        //c. 要求联想到的scene必须有cansets;
        AIFoNodeBase *assScene = [SMGUtils searchNode:item.target_p];//500ms R90 3455次
        BOOL havCansetsOK = protoScene.type != SceneTypeBrother || ARRISOK([assScene getConCansets:assSceneTargetIndex.integerValue]);//非brother时要求必须有cansets; //43ms 3455次
        return havCansetsOK; //43ms 3455次
    }];
    
    //3. 根据强度为主,匹配度为辅进行过滤: 取20% & 至少尝试取3条 (参考29094-BUG3-方案2);
    otherScenePorts = [self filterTwice:otherScenePorts mainBlock:^double(AIPort *item) {
        //4. 根据强度,进行主要过滤 (参考29094-BUG3-方案2);
        return item.strong.value;//mainBlock 135ms 11540次
    } subBlock:^double(AIPort *item) {
        //5. 仅截出前段参与匹配度计算 (不含targetIndex的indexDic部分);
        NSDictionary *indexDic = toAbs ? [sceneFo getAbsIndexDic:item.target_p] : [sceneFo getConIndexDic:item.target_p];
        indexDic = [SMGUtils filterDic:indexDic checkValid:^BOOL(NSNumber *key, NSNumber *value) {
            return (toAbs ? value.integerValue : key.integerValue) < protoTargetIndex;
        }];
        
        //6. 根据indexDic复用匹配度进行辅助过滤 (参考2908a-todo2);
        if (toAbs) {
            return [AINetUtils getMatchByIndexDic:indexDic absFo:item.target_p conFo:sceneFo.p callerIsAbs:false];//113ms 4038次
        }
        return [AINetUtils getMatchByIndexDic:indexDic absFo:sceneFo.p conFo:item.target_p callerIsAbs:true];//1436ms 3878次
    } radio:0.2f min:4 max:20 debugMode:false];
    return Ports2Pits(otherScenePorts);
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------同时符合两项过滤器的前xx% (参考28152-方案3)--------------------
 *  @desc 公式说明:
 *      1. 要求: 总过滤数20 = 总数30 - 结果数10;
 *      2. 主辅任务力度: 等于4:1时: 主过滤掉16条,辅过滤掉4条 即可;
 *      3. 主辅过滤条数: 主过滤后,剩下14(30-16)条; 辅过滤后剩下10(14-4)条;
 *      4. 主辅过滤率: "主过滤率 = 剩下14 / 总数30","辅过滤率 = 剩下10 / 剩下14";
 *      5. 最终成功留下结果10条;
 *  @desc 可配置项 (注:每项数字可调):
 *      1. 结果数: 越大返回越多;
 *      2. 主辅任务比例: 越大主过滤器作用越大;
 *      3. 最小条数百分比: 值越小越准;
 *  @desc 现配置: 结果数为16%,主辅过滤力度20:1,即主过滤掉80%,辅再过滤掉剩下的20%;
 *  @param radio : 过滤率 (传值范围0-1),越小越精准,但剩余结果越少,反之其效亦反;
 *  @param min : 最小返回条数;
 *
 *  @version
 *      2023.03.06: 过滤前20%改为35% (参考28152-方案3-todo2);
 *      2023.03.07: 减少过滤结果条数(从10到3),避免过滤器久久不生效 (参考28152b-todo1);
 *      2023.03.07: 过滤率改成动态计算,使其条数少时,两个过滤器也都能生效 (参考28152b-todo2);
 *      2023.03.07: 修改主辅过滤器为嵌套执行 (参考28152b-todo3);
 *      2023.03.07: 结果保留改为16%,将主辅力度调整为20:1 (因为实测4:1时,真实主过滤率=37%左右,太高了);
 *      2023.03.18: 加上radio参数,方便对概念和时序的过滤器分别指定不同的过滤度 (参考28186-方案1-结果);
 *      2023.06.12: 加上max条件上限 (避免结果过多,导致性能问题) (参考30022-优化2);
 */
+(NSArray*) filterTwice:(NSArray*)protoArr mainBlock:(double(^)(id item))mainBlock subBlock:(double(^)(id item))subBlock radio:(CGFloat)radio min:(NSInteger)min max:(NSInteger)max debugMode:(BOOL)debugMode {
    //0. 数据准备;
    if (!ARRISOK(protoArr)) return protoArr;
    
    //1. 条数 (参考注释公式说明-1);
    NSInteger resultNum = [self getResultNum:protoArr.count radio:radio min:min max:max];
    
    //2. 过滤任务和力度 (参考注释公式说明-2);
    NSInteger filterNum = protoArr.count - resultNum;               //总过滤任务 (比如共30条,剩10条,过滤任务就是20条);
    CGFloat zuFilterForce = 20, fuFilterForce = 1;                  //主辅两过滤器的力度权重 (一般主力度要大于辅力度多倍);
    CGFloat totalForce = zuFilterForce + fuFilterForce;             //总过滤力量份数 (比如: 主4 + 辅1 = 总力5份);
    
    //3. 主辅过滤条数 (参考注释公式说明-3);
    CGFloat fuFilterNum = filterNum / totalForce * fuFilterForce;   //辅过滤条数;
    CGFloat zuFilterNum = filterNum - fuFilterNum;                  //主过滤条数;
    
    //4. 主辅过滤率 (参考注释公式说明-4);
    CGFloat zuRate = (protoArr.count - zuFilterNum) / protoArr.count;   //主过滤率;
    CGFloat fuRate = resultNum / (protoArr.count - zuFilterNum);        //辅过滤率;
    
    //5. 主中辅,嵌套过滤 (参考28152b-todo3);
    NSArray *filter1 = ARR_SUB([SMGUtils sortBig2Small:protoArr compareBlock:mainBlock], 0, protoArr.count * zuRate);
    NSArray *filter2 = ARR_SUB([SMGUtils sortBig2Small:filter1 compareBlock:subBlock], 0, filter1.count * fuRate);
    if (debugMode) NSLog(@"过滤器: 总%ld需%ld 主:%.2f => 剩:%ld 辅:%.2f => 剩:%ld",protoArr.count,resultNum,zuRate,filter1.count,fuRate,filter2.count);
    
    //6. 返回结果 (参考注释公式说明-5);
    return filter2;
}

+(NSArray*) filterOnce:(NSArray*)protoArr mainBlock:(double(^)(id item))mainBlock radio:(CGFloat)radio min:(NSInteger)min max:(NSInteger)max caller:(NSString*)caller {
    //0. 数据准备;
    if (!ARRISOK(protoArr)) return protoArr;
    NSInteger resultNum = [self getResultNum:protoArr.count radio:radio min:min max:max];
    CGFloat realRate = (float)resultNum / protoArr.count;       //实际过滤率;
    
    //2. 过滤并返回结果;
    NSArray *filter = ARR_SUB([SMGUtils sortBig2Small:protoArr compareBlock:mainBlock], 0, protoArr.count * realRate);
    NSLog(@"%@过滤器: 总%ld需%ld 主:%.2f => 剩:%ld",caller,protoArr.count,resultNum,realRate,filter.count);
    return filter;
}

/**
 *  MARK:--------------------算出过滤器保留结果数--------------------
 */
+(NSInteger) getResultNum:(NSInteger)protoNum radio:(CGFloat)radio min:(NSInteger)min max:(NSInteger)max {
    NSInteger resultNum = (NSInteger)(radio * protoNum);  //建议条数 (建议16%,值越小越准);
    resultNum = MIN(max, MAX(min, resultNum));            //结果需 >=min && <=max;
    resultNum = MIN(protoNum, MAX(0, resultNum));         //结果需 >=0 && <= protoCount;
    return resultNum;
}

@end
