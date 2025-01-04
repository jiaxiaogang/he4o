//
//  TOUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/2.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "TOUtils.h"

@implementation TOUtils

+(BOOL) mIsC:(AIKVPointer*)m c:(AIKVPointer*)c layerDiff:(int)layerDiff{
    if (layerDiff == 0) return [self mIsC_0:m c:c];
    if (layerDiff == 1) return [self mIsC_1:m c:c];
    if (layerDiff == 2) return [self mIsC_2:m c:c];
    return false;
}

/**
 *  MARK:--------------------mIsC--------------------
 *  @version
 *      2023.03.11: 兼容mv的判断 (参考28171-todo8);
 *      2023.11.18: mv时也判断抽象关联,而不是直接返回false (修复判断M1{↑饿-16}和A13(饿16,7)的抽具象关系总失败);
 */
+(BOOL) mIsC_0:(AIKVPointer*)m c:(AIKVPointer*)c{
    if (m && c) {
        //0. 判断mv的相等;
        //if (PitIsMv(m) && PitIsMv(c)) return [m.algsType isEqualToString:c.algsType];
        
        //1. 判断本级相等;
        BOOL equ0 = [m isEqual:c];
        if (equ0) return true;
    }
    return false;
}
+(BOOL) mIsC_1:(AIKVPointer*)m c:(AIKVPointer*)c{
    if (m && c) {
        //1. 判断本级相等;
        if ([self mIsC_0:m c:c]) return true;
        
        //1. 在mIsC0判断mv不相等时,还有mv类型直接返回false;
        //if (PitIsMv(m) || PitIsMv(c)) return false;
        
        //2. 判断一级抽象;
        NSArray *mAbs = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:[SMGUtils searchNode:m]]];
        BOOL equ1 = [mAbs containsObject:c];
        if (equ1) return true;
    }
    return false;
}
+(BOOL) mIsC_2:(AIKVPointer*)m c:(AIKVPointer*)c{
    if (m && c) {
        //1. 判断0-1级抽象;
        if ([self mIsC_1:m c:c]) return true;
        
        //1. 在mIsC0判断mv不相等时,还有mv类型直接返回false;
        //if (PitIsMv(m) || PitIsMv(c)) return false;
        
        //2. 判断二级抽象;
        NSArray *mAbs = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:[SMGUtils searchNode:m]]];
        NSArray *cCon = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:[SMGUtils searchNode:c]]];
        BOOL equ2 = [SMGUtils filterArrA:mAbs arrB:cCon].count > 0;
        if (equ2) return true;
    }
    return false;
}

+(BOOL) mIsC_1:(NSArray*)ms cs:(NSArray*)cs{
    ms = ARRTOOK(ms);
    cs = ARRTOOK(cs);
    for (AIKVPointer *c in cs) {
        for (AIKVPointer *m in ms) {
            if ([TOUtils mIsC_1:m c:c]) {
                return true;
            }
        }
    }
    return false;
}

/**
 *  MARK:--------------------判断mc有共同抽象--------------------
 */
+(BOOL) mcIsBro:(AIKVPointer*)m c:(AIKVPointer*)c {
    NSArray *data = [TOUtils dataOfMcIsBro:m c:c];
    return ARRISOK(data);
}

+(BOOL) mcIsBro:(NSArray*)matchAlg_ps cansetA:(AIKVPointer*)cansetA_p {
    //用共同抽象判断cansetA的匹配: 判断新输入的matchAlgs和cansetA的抽象是否有匹配;
    AIAlgNodeBase *cansetAlg = [SMGUtils searchNode:cansetA_p];
    NSMutableArray *cansetAbses = [[NSMutableArray alloc] initWithArray:Ports2Pits([AINetUtils absPorts_All:cansetAlg])];
    [cansetAbses addObject:cansetA_p];
    return ARRISOK([SMGUtils filterArrA:matchAlg_ps arrB:cansetAbses]);
}

+(NSArray*) dataOfMcIsBro:(AIKVPointer*)m c:(AIKVPointer*)c {
    NSMutableArray *mAbs_ps = [[NSMutableArray alloc] initWithArray:Ports2Pits([AINetUtils absPorts_All:[SMGUtils searchNode:m]])];
    [mAbs_ps addObject:m];
    NSMutableArray *cAbs_ps = [[NSMutableArray alloc] initWithArray:Ports2Pits([AINetUtils absPorts_All:[SMGUtils searchNode:c]])];
    [cAbs_ps addObject:c];
    return [SMGUtils filterArrA:mAbs_ps arrB:cAbs_ps];
}

/**
 *  MARK:--------------------判断indexOf (支持本级+一级抽象)--------------------
 *  @bug 2020.06.12 : TOR.R-中firstAt_Plus取值为-1,经查因为mIsC方法取absPorts_Normal,对plus/sub不支持导致,改后好了;
 *  @version
 *      2020.09.10: 支持layerDiff和startIndex;
 *
 */
+(NSInteger) indexOfAbsItem:(AIKVPointer*)absItem atConContent:(NSArray*)conContent{
    return [self indexOfAbsItem:absItem atConContent:conContent layerDiff:1 startIndex:0 endIndex:NSUIntegerMax];
}

//absItem是content中的抽象一员,返回index;
+(NSInteger) indexOfAbsItem:(AIKVPointer*)absItem atConContent:(NSArray*)conContent layerDiff:(int)layerDiff startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex{
    conContent = ARRTOOK(conContent);
    endIndex = MIN(endIndex, conContent.count - 1);
    for (NSInteger i = startIndex; i <= endIndex; i++) {
        AIKVPointer *item_p = ARR_INDEX(conContent, i);
        if ([TOUtils mIsC:item_p c:absItem layerDiff:layerDiff]) {
            return i;
        }
    }
    return -1;
}

//conItem是content中的具象一员,返回index;
+(NSInteger) indexOfConItem:(AIKVPointer*)conItem atAbsContent:(NSArray*)content layerDiff:(int)layerDiff startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex{
    content = ARRTOOK(content);
    endIndex = MIN(endIndex, content.count - 1);
    for (NSInteger i = startIndex; i <= endIndex; i++) {
        AIKVPointer *item_p = ARR_INDEX(content, i);
        if ([TOUtils mIsC:conItem c:item_p layerDiff:layerDiff]) {
            return i;
        }
    }
    return -1;
}

//conItem是content中的具象或抽象一员,返回index;
+(NSInteger) indexOfConOrAbsItem:(AIKVPointer*)item atContent:(NSArray*)content layerDiff:(int)layerDiff startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex{
    NSInteger findIndex = [TOUtils indexOfAbsItem:item atConContent:content layerDiff:layerDiff startIndex:startIndex endIndex:endIndex];
    if (findIndex == -1) {
        findIndex = [TOUtils indexOfConItem:item atAbsContent:content layerDiff:layerDiff startIndex:startIndex endIndex:endIndex];
    }
    return findIndex;
}


//MARK:===============================================================
//MARK:                     < 从TO短时记忆取demand >
//MARK:===============================================================

//获取subOutModel所在的pFo
+(AIMatchFoModel*) getBasePFoWithSubOutModel:(TOModelBase*)subOutModel {
    //1. 最终没找着,返回nil;
    if (!subOutModel) return nil;
    
    //2. 当前是fo且有指向pFo时: 找到了,返回;
    if (ISOK(subOutModel, TOFoModel.class)) {
        TOFoModel *foModel = (TOFoModel*)subOutModel;
        if (ISOK(foModel.basePFoOrTargetFoModel, AIMatchFoModel.class)) {
            return foModel.basePFoOrTargetFoModel;
        }
    }
    
    //3. 当前没找到pFo,则继续顺着base找上去;
    return [self getBasePFoWithSubOutModel:subOutModel.baseOrGroup];
}

/**
 *  MARK:--------------------获取subOutModel的demand--------------------
 */
+(DemandModel*) getRootDemandModelWithSubOutModel:(TOModelBase*)subOutModel{
    NSMutableArray *demands = [self getBaseDemands_AllDeep:subOutModel];
    return ARR_INDEX_REVERSE(demands, 0);
}

/**
 *  MARK:--------------------向着某方向取所有demands--------------------
 *  @version
 *      2021.06.01: 因为R子任务时baseOrGroup为空,导致链条中断获取不全的BUG修复 (参考23094);
 *      2021.06.01: 支持getSubDemands_AllDeep (子方向);
 *  @result 含子任务和root任务 notnull;
 *  @rank : base在后,sub在前;
 */
+(NSMutableArray*) getBaseDemands_AllDeep:(TOModelBase*)subModel{
    return [SMGUtils filterArr:[self getBaseOutModels_AllDeep:subModel] checkValid:^BOOL(id item) {
        return ISOK(item, DemandModel.class);
    }];
}
+(NSInteger) getBaseDemandsDeepCount:(TOModelBase*)subModel{
    return [self getBaseDemands_AllDeep:subModel].count;
}
+(NSMutableArray*) getBaseRDemands_AllDeep:(TOModelBase*)subModel{
    return [SMGUtils filterArr:[self getBaseOutModels_AllDeep:subModel] checkValid:^BOOL(id item) {
        return ISOK(item, ReasonDemandModel.class);
    }];
}

/**
 *  MARK:--------------------获取rDemand的来源同伴--------------------
 *  @version
 *      2022.03.23: 初版 (参考25184-方案2-分析);
 *  @result notnull
 */
//+(NSArray*) getSeemFromIdenRDemands:(ReasonDemandModel*)rDemand{
//    //1. 数据准备;
//    NSString *fromIden = STRTOOK(rDemand.fromIden);
//    NSMutableArray *result = [[NSMutableArray alloc] init];
//
//    //2. 分别从root出发,收集同fromIden的RDemands;
//    for (DemandModel *item in theTC.outModelManager.getAllDemand) {
//        NSArray *subs = [self getSubOutModels_AllDeep:item validStatus:nil cutStopStatus:nil];
//        NSArray *validSubs = [SMGUtils filterArr:subs checkValid:^BOOL(ReasonDemandModel *sub) {
//            return ISOK(sub, ReasonDemandModel.class) && [fromIden isEqualToString:sub.fromIden];
//        }];
//        [result addObjectsFromArray:validSubs];
//    }
//result = [SMGUtils filterArr:result checkValid:^BOOL(ReasonDemandModel *item) {
//    AIFoNodeBase *itemFo = [SMGUtils searchNode:item.mModel.matchFo];
//    AIFoNodeBase *demandFo = [SMGUtils searchNode:demand.mModel.matchFo];
//    return [demandFo.cmvNode_p.identifier isEqualToString:itemFo.cmvNode_p.identifier];
//}];
//    return result;
//}


//MARK:===============================================================
//MARK:                     < 从TO短时记忆取outModel >
//MARK:===============================================================
+(NSArray*) getSubOutModels_AllDeep:(TOModelBase*)outModel validStatus:(NSArray*)validStatus{
    return [self getSubOutModels_AllDeep:outModel validStatus:validStatus cutStopStatus:@[@(TOModelStatus_Finish)]];
}

/**
 *  MARK:--------------------收集base所有的子枝叶返回--------------------
 *  @param validStatus 这些状态才收集 (如果传空,则所有状态都可以收集);
 *  @param cutStopStatus 这些状态时停止向下收集 (如果传空,则全不停止);
 *  @return notnull
 */
+(NSArray*) getSubOutModels_AllDeep:(TOModelBase*)outModel validStatus:(NSArray*)validStatus cutStopStatus:(NSArray*)cutStopStatus{
    //1. 数据准备
    validStatus = ARRTOOK(validStatus);
    cutStopStatus = ARRTOOK(cutStopStatus);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!outModel) return result;
    
    //2. 收集当前 (当valid为空时,全收集);
    if (!ARRISOK(validStatus) || [validStatus containsObject:@(outModel.status)]) {
        [result addObject:outModel];
    }
    
    //3. Finish负责截停递归;
    if (![cutStopStatus containsObject:@(outModel.status)]) {
        
        //3. 找出子集
        NSMutableArray *subs = [self getSubOutModels:outModel];
        
        //4. 递归收集子集;
        for (TOModelBase *sub in subs) {
            [result addObjectsFromArray:[self getSubOutModels_AllDeep:sub validStatus:validStatus cutStopStatus:cutStopStatus]];
        }
    }
    return result;
}

/**
 *  MARK:--------------------获取子models--------------------
 *  @version
 *      2021.06.03: 将实现接口判断,改为使用conformsToProtocol,而非判断类名 (因为类名方式有新的类再实现后,易出bug);
 *  @result notnull
 */
+(NSMutableArray*) getSubOutModels:(TOModelBase*)outModel {
    //1. 数据准备
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!outModel) return result;
    
    //2. 找出子集 (Finish负责截停递归);
    if ([outModel conformsToProtocol:@protocol(ITryActionFoDelegate)]) {
        id<ITryActionFoDelegate> tryActionObj = (id<ITryActionFoDelegate>)outModel;
        NSArray *actionFoModels = [tryActionObj.actionFoModels copy];
        [result addObjectsFromArray:[SMGUtils filterArr:actionFoModels checkValid:^BOOL(TOFoModel *item) {
            return item.cansetStatus != CS_None;
        }]];
    }
    if ([outModel conformsToProtocol:@protocol(ISubModelsDelegate)]) {
        NSArray *subModels = [((id<ISubModelsDelegate>)outModel).subModels copy];
        [result addObjectsFromArray:subModels];
    }
    if ([outModel conformsToProtocol:@protocol(ISubDemandDelegate)]) {
        NSArray *subDemands = ((id<ISubDemandDelegate>)outModel).subDemands;
        [result addObjectsFromArray:subDemands];
    }
    return result;
}

+(NSMutableArray*) getBaseOutModels_AllDeep:(TOModelBase*)subModel{
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!subModel) return result;
    
    //2. 向base取;
    TOModelBase *checkModel = subModel;
    while (checkModel) {
        [result addObject:checkModel];
        checkModel = checkModel.baseOrGroup;
    }
    return result;
}

//MARK:===============================================================
//MARK:                 < 从整个工作记忆中取枝叶数据 >
//MARK:===============================================================

/**
 *  MARK:--------------------取整个工作记中所有的subModels--------------------
 */
+(NSArray*) getSubOutModels_AllDeep_AllRoots {
    NSArray *roots = [theTC.outModelManager.getAllDemand copy];
    return [SMGUtils convertArr:roots convertItemArrBlock:^NSArray *(ReasonDemandModel *root) {
        return [TOUtils getSubOutModels_AllDeep:root validStatus:nil cutStopStatus:nil];
    }];
}

/**
 *  MARK:--------------------取整个工作记中所有的cansets--------------------
 */
+(NSArray*) getSubCansets_AllDeep_AllRoots {
    return [SMGUtils filterArr:[self getSubOutModels_AllDeep_AllRoots] checkValid:^BOOL(TOModelBase *item) {
        return ISOK(item, TOFoModel.class);
    }];
}

//MARK:===============================================================
//MARK:                     < convert >
//MARK:===============================================================

/**
 *  MARK:--------------------将TOModels转为Pointers--------------------
 *  @result notnull
 */
+(NSMutableArray*) convertPointersFromTOModels:(NSArray*)toModels{
    //1. 收集返回 (不收集content_p为空的部分,如:TOValueModel的目标pValue有时为空);
    return [SMGUtils convertArr:toModels convertBlock:^id(TOModelBase *obj) {
        return obj.content_p;
    }];
}

//R时返回pFo.matchFo,H时返回targetFo;
+(AIKVPointer*) convertBaseFoFromBasePFoOrTargetFoModel:(id)basePFoOrTargetFoModel {
    if (ISOK(basePFoOrTargetFoModel, AIMatchFoModel.class)) {
        AIMatchFoModel *pFo = (AIMatchFoModel*)basePFoOrTargetFoModel;
        return pFo.matchFo;
    } else if(ISOK(basePFoOrTargetFoModel, TOFoModel.class)){
        TOFoModel *targetFo = (TOFoModel*)basePFoOrTargetFoModel;
        return targetFo.content_p;
    }
    return nil;
}

/**
 *  MARK:--------------------是否HNGL节点--------------------
 *  @version
 *      2020.12.16: 增加toAlgModel判断的重载 (因为21115的改动,hngl并不直接由alg判断,而是由fo来判断);
 *  @bug
 *      2020.12.24: isL写成了isN,导致L节点无法判定为HNGL,也导致无法ActYes并触发反省类比;
 */
+(BOOL) isHNGL:(AIKVPointer*)p{
    return [self isH:p] || [self isN:p] || [self isG:p] || [self isL:p];
}
+(BOOL) isHNGLSP:(AIKVPointer*)p{
    return [self isH:p] || [self isN:p] || [self isG:p] || [self isL:p] || [self isS:p] || [self isP:p];
}
+(BOOL) isH:(AIKVPointer*)p{
    return p && p.type == ATHav;
}
+(BOOL) isN:(AIKVPointer*)p{
    return p && p.type == ATNone;
}
+(BOOL) isG:(AIKVPointer*)p{
    return p && p.type == ATGreater;
}
+(BOOL) isL:(AIKVPointer*)p{
    return p && p.type == ATLess;
}
+(BOOL) isS:(AIKVPointer*)p{
    return p && p.type == ATSub;
}
+(BOOL) isP:(AIKVPointer*)p{
    return p && p.type == ATPlus;
}

/**
 *  MARK:--------------------求fo的deltaTime之和--------------------
 */
//从cutIndex取到mvDeltaTime;
+(double) getSumDeltaTime2Mv:(AIFoNodeBase*)fo cutIndex:(NSInteger)cutIndex{
    return [self getSumDeltaTime:fo startIndex:cutIndex endIndex:fo.count];
}

/**
 *  MARK:--------------------获取指定获取的deltaTime之和--------------------
 *  _param startIndex   : 下标(不含);
 *  _param endIndex     : 下标(含);
 *  @templete : 如[0,1,2,3],因不含s和含e,取1到3位时,得出结果应该是2+3=5,即range应该是(2到4),所以range=(s+1,e-s);
 *  @bug
 *      2020.09.10: 原来取range(s,e-s)不对,更正为:range(s+1,e-s);
 */
+(double) getSumDeltaTime:(AIFoNodeBase*)fo startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex{
    double result = 0;
    if (fo) {
        //1. 累计deltaTimes中值;
        NSArray *valids = ARR_SUB(fo.deltaTimes, startIndex + 1, endIndex - startIndex);
        for (NSNumber *valid in valids) {
            result += [valid doubleValue];
        }
        
        //2. 累计mvDeltaTime值;
        if (endIndex >= fo.count) {
            result += fo.mvDeltaTime;
        }
    }
    return result;
}

+(NSString*) toModel2Key:(TOModelBase*)toModel{
    return STRFORMAT(@"%p_%@",toModel,Pit2FStr(toModel.content_p));
}

/**
 *  MARK:--------------------effectDic的HN求和--------------------
 */
+(NSRange) getSumEffectHN:(NSDictionary*)effectDic{
    int sumH = 0,sumN = 0;
    for (NSArray *value in effectDic.allValues) {
        for (AIEffectStrong *strong in value) {
            sumH += strong.hStrong;
            sumN += strong.nStrong;
        }
    }
    return NSMakeRange(sumH, sumN);
}

/**
 *  MARK:--------------------稳定性评分--------------------
 *  @desc 根据SP计算"稳定性"分 (稳定性指顺,就是能顺利发生的率);
 *  @desc 含startSPIndex & 也含endSPIndex;
 *  @version
 *      2022.05.23: 初版 (参考26096-BUG1);
 *      2022.06.02: 每一帧的稳定性默认为0.5,而不是1 (参考26191);
 *      2024.06.21: 支持OutSPDic,在Canset竞争时由_Out()来计算 (参考32012-TODO8);
 *      2024.11.21: 稳定性In和Out都支持下父非子综合评分 (参考
 *  @param fo : In时传sceneFo & Out时传cansetFo;
 *  @result 1. 负价值时序时返回多坏(0-1);
 *          2. 正价值时序时返回多好(0-1);
 *          3. 无价值时序时返回多顺(0-1);
 */
//In针对Scene稳定性;
+(CGFloat) getStableScore_In:(AIFoNodeBase*)iScene startSPIndex:(NSInteger)startSPIndex endSPIndex:(NSInteger)endSPIndex {
    //1. 取出I层spDic;
    //2024.12.03: 避免iSPDic被更新值后,如果node被保存,就被持久化了 (此问题未证实,只是这么猜想,就调用下copy预防一下);
    NSMutableDictionary *iSPDic = [ThinkingUtils copySPDic:iScene.spDic];
    NSString *protoSPDicStr = CLEANSTR(iSPDic);
    
    //2. 取出F层 (参考33114-TODO3-用I/F综合起来决定最终spDic及稳定性);
    NSArray *fPorts = [AINetUtils absPorts_All:iScene];
    for (AIPort *fPort in fPorts) {
        
        //3. 计算I/F两层的场景时序匹配度 (参考33116-方案1-采用时序匹配度做为抽象程度,计算冷却值);
        AIFoNodeBase *fScene = [SMGUtils searchNode:fPort.target_p];
        //2024.11.29: 性能优化: 单次已从0.66优化至0.03ms (性能说明: 用alg实时计算要0.66ms,直接用fo复用取要0.03ms);
        CGFloat foMatchValue = [iScene getAbsMatchValue:fScene.p];//[AINetUtils getMatchByIndexDic:fScene.p conFo:iScene.p callerIsAbs:false];
        CGFloat cooledValue = [MathUtils getCooledValue_28:foMatchValue];//算出当前匹配度,应该冷却到什么比例;
        
        //4. 把F层的SPDic冷却后,累计到I层 (环境作用于个体) (参考33115-方案2-累计spStrong);
        NSDictionary *indexDic = [iScene getAbsIndexDic:fScene.p];
        for (NSInteger i = startSPIndex; i <= endSPIndex; i++) {
            
            //5. 注意: 此处iScene和fScene的下标是不同的,要从映射取得;
            NSNumber *key = ARR_INDEX([indexDic allKeysForObject:@(i)], 0);
            if (!key) continue;
            AISPStrong *fSPStrong = [fScene.spDic objectForKey:key];
            AISPStrong *iSPStrong = [iSPDic objectForKey:@(i)];
            //6. 防空,如果为空,新建上壳子;
            if (!fSPStrong) continue;
            if (!iSPStrong) {
                iSPStrong = [AISPStrong new];
                [iSPDic setObject:iSPStrong forKey:@(i)];
            }
            iSPStrong.sStrong += (fSPStrong.sStrong * cooledValue);
            iSPStrong.pStrong += (fSPStrong.pStrong * cooledValue);
        }
    }
    
    //6. 算出最终综合spDic的稳定性;
    //NSString *sumSPDicStr = CLEANSTR(iSPDic);
    //if (![protoSPDicStr isEqualToString:sumSPDicStr]) NSLog(@"In父非子: proto:%@ -> sum:%@",protoSPDicStr,sumSPDicStr);
    HEResult *result = [TOUtils getStableScore_General:iScene startSPIndex:startSPIndex endSPIndex:endSPIndex spDic:iSPDic];
    return result.spScore;
}
//Out针对Canset稳定性;
+(HEResult*) getStableScore_Out:(TOFoModel*)canset startSPIndex:(NSInteger)startSPIndex endSPIndex:(NSInteger)endSPIndex {
    //1. 取出I层spDic;
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:canset.cansetFrom];//本来应该传cansetTo,不过cansetTo可能未转实,并且cansetFrom效果也一致;
    //2024.12.03: 避免iSPDic被更新值后,如果node被保存,就被持久化了 (此问题未证实,只是这么猜想,就调用下copy预防一下);
    NSMutableDictionary *iSPDic = [ThinkingUtils copySPDic:[canset getItemOutSPDic]];
    NSString *protoSPDicStr = CLEANSTR(iSPDic);
    
    //2. 取出F层 (参考33114-TODO3-用I/F综合起来决定最终spDic及稳定性);
    AIFoNodeBase *iScene = [SMGUtils searchNode:canset.sceneTo];
    NSArray *iCansetContent_ps = Simples2Pits(canset.transferXvModel.cansetToOrders);
    //2024.11.29: 性能优化: 单次已从6.99优化至0.08ms;
    NSArray *fPorts = [AINetUtils transferPorts_4Father:iScene iCansetContent_ps:iCansetContent_ps];
    for (AITransferPort *fPort in fPorts) {
        
        //3. 计算I/F两层的场景时序匹配度 (参考33116-方案1-采用时序匹配度做为抽象程度,计算冷却值);
        AIFoNodeBase *fScene = [SMGUtils searchNode:fPort.fScene];
        
        //2024.11.29: 性能优化: 单次已从0.66优化至0.03ms (性能说明: 用alg实时计算要0.66ms,直接用fo复用取要0.03ms);
        CGFloat foMatchValue = 0;
        if (canset.isH) {
            //3a. H时,以RScene场景树,去取匹配度 (参考33144-TODO2);
            AITransferPort_H *fPort_H = (AITransferPort_H*)fPort;
            AIFoNodeBase *iRScene = [SMGUtils searchNode:fPort_H.iRScene];
            foMatchValue = [iRScene getAbsMatchValue:fPort_H.fRScene];
            [AITest test33:iRScene fScene:fPort_H.fRScene];
        } else {
            //3b. R时,fScene就是fRScene,直接取匹配度即可;
            foMatchValue = [iScene getAbsMatchValue:fScene.p];
            [AITest test33:iScene fScene:fScene.p];
        }
        //2025.01.04: 提升环境作用力: 28原则太激烈了,匹配度0.7时就只剩10%的作用力了,增加环境温度为0.01 (当匹配度0.7时作用力为25%);
        CGFloat cooledValue = [MathUtils getCooledValue:1 - foMatchValue finishValue:0.01f];//算出当前匹配度,应该冷却到什么比例;
        
        //4. 把F层的SPDic冷却后,累计到I层 (环境作用于个体) (参考33115-方案2-累计spStrong);
        //2024.11.30: 性能优化: 单次已从1.14优化至0.02ms;
        NSDictionary *fSPDic = [fScene getItemOutSPDic:fPort.fCansetHeader];
        
        //debugLog: 调试"有向无距场景"的竞争浮现 (参考33141-观察);
        //if ([NVHeUtil foHavXianWuJv:fScene.p] && foMatchValue > 0 && DICISOK(fSPDic)) {
        //    NSLog(@"flt8a 父非子算法: (父F%ld,子F%ld,匹配度:%.2f 作用力:%.3f) 打出有向无距果场景的SP字典%@",fScene.pId,iScene.pId,foMatchValue,cooledValue,CLEANSTR([SMGUtils filterDic:fSPDic checkValid:^BOOL(NSNumber *key, id value) {
        //        return key.integerValue >= startSPIndex && key.integerValue <= endSPIndex;
        //    }]));
        //}
        
        for (NSInteger i = startSPIndex; i <= endSPIndex; i++) {
            
            //5. 注意: 此处iCanset和fCanset是等长的;
            AISPStrong *fSPStrong = [fSPDic objectForKey:@(i)];
            AISPStrong *iSPStrong = [iSPDic objectForKey:@(i)];
            
            //6. 防空,如果为空,新建上壳子;
            if (!fSPStrong) continue;
            if (!iSPStrong) {
                iSPStrong = [AISPStrong new];
                [iSPDic setObject:iSPStrong forKey:@(i)];
            }
            
            //7. 把F层的outSPStrong冷却后的值累计到I层;
            iSPStrong.sStrong += (fSPStrong.sStrong * cooledValue);
            iSPStrong.pStrong += (fSPStrong.pStrong * cooledValue);
        }
    }
    
    //8. 算出最终综合spDic的稳定性;
    //NSString *sumSPDicStr = CLEANSTR(iSPDic);
    //if (![protoSPDicStr isEqualToString:sumSPDicStr]) NSLog(@"Out父非子: proto:%@ -> sum:%@",protoSPDicStr,sumSPDicStr);
    return [TOUtils getStableScore_General:cansetFrom startSPIndex:startSPIndex endSPIndex:endSPIndex spDic:iSPDic];
}

+(HEResult*) getStableScore_General:(AIFoNodeBase*)fo startSPIndex:(NSInteger)startSPIndex endSPIndex:(NSInteger)endSPIndex spDic:(NSDictionary*)spDic {
    //1. 数据检查 & 稳定性默认为1分 & 正负mv的公式是不同的 (参考25122-公式);
    if (!fo) return 0;
    CGFloat totalSPScore = 1.0f;
    NSInteger sumPStong = 0;
    BOOL isBadMv = [ThinkingUtils havDemand:fo.cmvNode_p];
    
    //2. 从start到end各计算spScore;
    for (NSInteger i = startSPIndex; i <= endSPIndex; i++) {
        AISPStrong *spStrong = [spDic objectForKey:@(i)];
        
        //3. 当sp经历都为0条时 (正mv时,表示多好评分 | 负mv时,表示多坏评分) 默认评分都为0.5;
        CGFloat itemSPScore = 0.5f;
        
        //4. SP有效且其中之一不为0时,计算稳定性评分;
        if (spStrong && spStrong.pStrong + spStrong.sStrong > 0) {
            
            //4. 取"多好"程度;
            CGFloat pRate = spStrong.pStrong / (float)(spStrong.sStrong + spStrong.pStrong);
            
            //5.1 在感性的负mv时,itemSPScore = 1 - pRate (参考25122-负公式);
            if (i == fo.count && isBadMv) {
                itemSPScore = 1 - pRate;
            }else{
                
                //5.2 在理性评分中,pStrong表示顺利程度,与mv正负成正比;
                //5.3 在感性正mv时,pRate与它的稳定性评分一致;
                itemSPScore = pRate;
            }
        }
        
        //6. 将itemSPScore计入综合评分 (参考25114 & 25122-公式);
        totalSPScore *= itemSPScore;
        if (spStrong) sumPStong += spStrong.pStrong;
    }
    
    //9. 返回SP评分 (多坏或多好);
    return [[[HEResult newSuccess] mk:@"spScore" v:@(totalSPScore)] mk:@"pStrong" v:@(sumPStong)];
}

/**
 *  MARK:--------------------SP好坏评分--------------------
 *  @desc 根据综合稳定性计算"多好"评分 (参考25114 & 25122-负公式);
 *  @version
 *      2022.02.20: 改为综合评分,替代掉RSResultModelBase;
 *      2022.02.22: 修复明明S有值,P为0,但综评为1分的问题 (||写成了&&导致的);
 *      2022.02.24: 支持负mv时序的稳定性评分公式 (参考25122-负公式);
 *      2022.02.24: 修复因代码逻辑错误,导致负mv在全顺状态下,评为1分的BUG (修复: 明确itemSPScore的定义,整理代码后ok);
 *      2022.05.02: 修复因Int值类型,导致返回result只可能是0或1的问题;
 *      2022.05.14: 当SP全为0时,默认返回0.5 (参考26026-BUG2);
 *  @result 返回spScore稳定性综合评分: 越接近1分越好,越接近0分越差;
 */
+(CGFloat) getSPScore:(AIFoNodeBase*)fo startSPIndex:(NSInteger)startSPIndex endSPIndex:(NSInteger)endSPIndex{
    //1. 获取稳定性评分;
    CGFloat stableScore = [self getStableScore_In:fo startSPIndex:startSPIndex endSPIndex:endSPIndex];
    
    //2. 负mv的公式是: 1-stableScore (参考25122-公式&负公式);
    BOOL isBadMv = [ThinkingUtils havDemand:fo.cmvNode_p];
    if (isBadMv) {
        stableScore = 1 - stableScore;
    }
    
    //3. 返回好坏评分;
    return stableScore;
}

/**
 *  MARK:--------------------有效率评分--------------------
 *  @desc 计算有效率性评分 (参考26095-8);
 *  @param demandFo     : R任务时传pFo即可, H任务时传hDemand.base.baseFo;
 *  @param effectIndex  : R任务时传demandFo.count, H任务时传hDemand.base.baseFo.actionIndex;
 *  @param solutionFo   : 用于检查有效率的solutionFo;
 *  @version
 *      2022.05.22: 初版,可返回解决方案的有效率 (参考26095-8);
 */
+(CGFloat) getEffectScore:(AIFoNodeBase*)demandFo effectIndex:(NSInteger)effectIndex solutionFo:(AIKVPointer*)solutionFo{
    AIEffectStrong *strong = [self getEffectStrong:demandFo effectIndex:effectIndex solutionFo:solutionFo];
    return [self getEffectScore:strong];
}
+(CGFloat) getEffectScore:(AIEffectStrong*)strong{
    if (strong) {
        if (strong.hStrong + strong.nStrong > 0) {
            return (float)strong.hStrong / (strong.hStrong + strong.nStrong);
        }else{
            return 0.0f;
        }
    }
    return 0;
}
+(AIEffectStrong*) getEffectStrong:(AIFoNodeBase*)demandFo effectIndex:(NSInteger)effectIndex solutionFo:(AIKVPointer*)solutionFo{
    return [demandFo getEffectStrong:effectIndex solutionFo:solutionFo];
}
+(NSString*) getEffectDesc:(AIFoNodeBase*)demandFo effectIndex:(NSInteger)effectIndex solutionFo:(AIKVPointer*)solutionFo{
    AIEffectStrong *strong = [self getEffectStrong:demandFo effectIndex:effectIndex solutionFo:solutionFo];
    return STRFORMAT(@"%ld/%ld",strong.hStrong,strong.hStrong + strong.nStrong);
}

//MARK:===============================================================
//MARK:                     < 衰减曲线 >
//MARK:===============================================================

/**
 *  MARK:--------------------获取fo衰减后的值--------------------
 *  @param fo_p         : 计算fo的衰减后的值;
 *  @param outOfFo_ps   : fo的竞争者 (包含fo);
 *  @desc 使用牛顿冷却函数,步骤说明:
 *      1. 根据F指针地址排序,比如(F1,F3,F5,F7,F9)
 *      2. 默认衰减时间为F总数,即5;
 *      3. 当sp强度都为1时,最新的F9为热度为1,最旧的F1热度为minValue;
 *      4. 当sp强度>1时,衰减时长 = 默认时长5 * 根号sp强度;
 *  @version
 *      2022.05.24: 初版,用于解决fo的衰减,避免时序识别时,明明fo很老且SP都是0,却可以排在很前面 (参考26104-方案);
 */
+(double) getColValue:(AIKVPointer*)fo_p outOfFos:(NSArray*)outOfFo_ps {
    //0. 数据检查;
    if (!fo_p || ![outOfFo_ps containsObject:fo_p]) {
        return 1.0f;
    }
    
    //1. 对fos排序 & 计算衰减区 (从1到minValue的默认区间: 即每强度系数单位可支撑区间);
    outOfFo_ps = [SMGUtils sortBig2Small:outOfFo_ps compareBlock:^double(AIKVPointer *obj) {
        return obj.pointerId;
    }];
    float defaultColSpace = outOfFo_ps.count;
    
    //2. 计算fo的sp强度系数 (总强度 + 1,然后开根号);
    AIFoNodeBase *fo = [SMGUtils searchNode:fo_p];
    int sumSPStrong = 1;
    for (AISPStrong *item in fo.spDic.allValues) sumSPStrong += (item.sStrong + item.pStrong);
    float strongXiSu = sqrtf(sumSPStrong);
    
    //3. fo的实际衰减区间 (默认区间 x 强度系数);
    float colSpace = defaultColSpace * strongXiSu;
    
    //4. 衰减系数 (在colTime结束后,衰减到最小值);
    float minValue = 0.1f;
    double colXiSu = log(minValue) / colSpace;
    
    //5. 取当前fo的age & 计算牛顿衰减后的值;
    NSInteger foAge = [outOfFo_ps indexOfObject:fo_p];
    double result = exp(colXiSu * foAge);
    return result;
}

/**
 *  MARK:--------------------获取衰减后的稳定性--------------------
 */
+(CGFloat) getColStableScore:(AIFoNodeBase*)fo outOfFos:(NSArray*)outOfFo_ps startSPIndex:(NSInteger)startSPIndex endSPIndex:(NSInteger)endSPIndex {
    double colValue = [TOUtils getColValue:fo.pointer outOfFos:outOfFo_ps];
    CGFloat stableScore = [TOUtils getStableScore_In:fo startSPIndex:startSPIndex endSPIndex:endSPIndex];
    return colValue * stableScore;
}

/**
 *  MARK:--------------------获取衰减后的SP好坏评分--------------------
 */
+(CGFloat) getColSPScore:(AIFoNodeBase*)fo outOfFos:(NSArray*)outOfFo_ps startSPIndex:(NSInteger)startSPIndex endSPIndex:(NSInteger)endSPIndex{
    CGFloat stableScore = [self getColStableScore:fo outOfFos:outOfFo_ps startSPIndex:startSPIndex endSPIndex:endSPIndex];
    return [ThinkingUtils havDemand:fo.cmvNode_p] ? 1 - stableScore : stableScore;
}

/**
 *  MARK:--------------------检查某toModel的末枝有没有ActYes状态--------------------
 *  @desc 因为actYes向上传染,不向下,所以末枝有actYes,即当前curModel也不应响应 (参考26184-原则);
 *  @version
 *      2023.03.04: 判断末枝要排除subDemand的影响 (参考28143-回测 & 修复);
 *      2023.08.19: 末枝不排除hDemandModel (参考30113-todo1);
 */
+(BOOL) endHavActYes:(TOModelBase*)curModel{
    NSArray *allSubModels = [TOUtils getSubOutModels_AllDeep:curModel validStatus:nil];
    BOOL endHavActYes = [SMGUtils filterSingleFromArr:allSubModels checkValid:^BOOL(TOModelBase *item) {
        //1. 判断是ActYes状态;
        if (item.status == TOModelStatus_ActYes) {
            //2. 判断是末枝 (其下有Demand不算) (参考28143-修复);
            NSArray *subModels = [TOUtils getSubOutModels:item];
            subModels = [SMGUtils filterArr:subModels checkValid:^BOOL(id item) {
                return !ISOK(item, ReasonDemandModel.class);
            }];
            return subModels.count == 0;
        }
        return false;
    }];
    return endHavActYes;
}

/**
 *  MARK:--------------------将cansets中同fo的strong合并--------------------
 */
+(NSArray*) mergeCansets:(NSArray*)protoCansets{
    NSMutableDictionary *cansetsDic = [[NSMutableDictionary alloc] init];
    for (AIEffectStrong *item in protoCansets) {
        //a. 取旧;
        id key = @(item.solutionFo.pointerId);
        AIEffectStrong *old = [cansetsDic objectForKey:key];
        if (!old) old = [AIEffectStrong newWithSolutionFo:item.solutionFo];
        
        //b. 更新;
        old.hStrong += item.hStrong;
        old.nStrong += item.nStrong;
        [cansetsDic setObject:old forKey:key];
    }
    return cansetsDic.allValues;
}

/**
 *  MARK:--------------------从absIndex向前找,直到找到有conIndex映射的那一条返回--------------------
 */
+(NSInteger) goBackToFindConIndexByAbsIndex:(NSDictionary*)indexDic absIndex:(NSInteger)absIndex {
    indexDic = DICTOOK(indexDic);
    //1. 从absIndex向前找,找到有映射的一条;
    for (NSInteger i = absIndex; i >= 0; i--) {
        NSNumber *conIndex = [indexDic objectForKey:@(i)];
        if (conIndex) {
            //2. 如果找到一条有映射的,就直接返回;
            return conIndex.integerValue;
        }
    }
    //3. 如果直至第一条,最终也没找到,就返回-1;
    return -1;
}

/**
 *  MARK:--------------------indexDic综合计算--------------------
 *  @result 返回结果中,默认首个dic的边缘端口为key,最后一个dic的边缘端口为value;
 *  @version
 *      2024.02.29: 支持各种转向,传入的参数也是带方向的 (参考31113-TODO9-方案2);
 *      2024.05.30: 修复此处取toAbs: 错误取成上一step的toAbs了,应该取当前item的,而不是lastItem的 (会导致返回indexDic错误);
 *  @result notnull
 */
+(NSDictionary*) zonHeIndexDic:(NSArray*)directDics {
    //1. 数据准备;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    //2. 取第一条的边缘posts,然后依次往下一层层检查链条是否连着;
    DirectIndexDic *firstDirectDic = ARR_INDEX(directDics, 0);
    NSDictionary *firstDic = firstDirectDic.indexDic;
    NSArray *firstPosts = firstDirectDic.toAbs ? firstDic.allValues : firstDic.allKeys;//如果向上con是边缘,向下就abs是边缘;
    
    //3. 对第一个边缘,逐个对它的元素找链条;
    for (NSNumber *startPost in firstPosts) {
        id lastPost = startPost;//默认从第一个indexDic的边缘端口开始查起;
        for (DirectIndexDic *stepDirectDic in directDics) {
            NSDictionary *stepDic = stepDirectDic.indexDic;
            
            //4. 更新stepToAbs (本次循环中下一步要用);
            BOOL stepToAbs = stepDirectDic.toAbs;
            
            //5. 如果上一条是被向上找来的,就用con(values)对接它,如果上一条是向下找来的,就用abs(keys)对接它;
            if (stepToAbs) {
                lastPost = ARR_INDEX([stepDic allKeysForObject:lastPost], 0);
            } else {
                lastPost = [stepDic objectForKey:lastPost];
            }
            
            //6. 如果有一层衔接不上断了,那这一整个链条计为不通;
            if (!lastPost) break;
        }
        
        //7. 最后一层的边缘端口 = 最后得出的post;
        id endPost = lastPost;
        
        //8. 直到这条链的最后还有值,说明它全通过,收集到结果Dic中;
        if (endPost) [result setObject:endPost forKey:startPost];
    }
    return result;
}

//MARK:===============================================================
//MARK:                     < infected >
//MARK:===============================================================

/**
 *  MARK:--------------------设置传染状态: 将infectedAlg传染到工作记忆 (参考31178-TODO1)--------------------
 *  @desc 作用: 从new传染的alg,传染到所有roots树;
 *  @desc 白话: 当frameActYes因canset中间帧无反馈,调用此方法 => 将工作记忆中所有同质中间帧cansetAlg都infect下,标记它已条件不满足;
 *  @desc frameActYes反馈失败时: 传染到整个工作记忆树 (所有此处新传染的,都尝试向整树传播) (参考31178-TODO1);
 */
+(int) infectToAllRootsTree_Alg:(TOFoModel*)infectedCanset infectedAlg:(AIKVPointer*)infectedAlg except4SP2F:(NSMutableArray*)except4SP2F {
    //1. SP计数之四(R负): 当前传染的canset计S+1 (参考33031b-BUG5-协作);
    //2024.09.17: 只有转实的,才更新outSP值 (参考33062-TODO6);
    //2024.09.21: 去掉best过状态要求 (参考33065-TODO3);
    [infectedCanset checkAndUpdateOutSPStrong_Reason:1 type:ATSub debugMode:true caller:@"" except4SP2F:except4SP2F];
    
    //2. 当前传染的alg,传到整个roots;
    int infectNum = 0;
    NSArray *allCanset = [TOUtils getSubCansets_AllDeep_AllRoots];
    for (TOFoModel *canset in allCanset) {
         TOAlgModel *waitAlg = [canset getCurFrame];
        if (!canset.isInfected && waitAlg && [waitAlg.content_p isEqual:infectedAlg]) {
            //1. 全树同waitAlg全传染掉;
            canset.isInfected = true;
            
            //2. 所有传染的都计SP- (参考32012-TODO4);
            //[canset checkAndUpdateOutSPStrong_Reason:1 type:ATSub debugMode:true caller:@"alg传染整树"];
            infectNum++;
        }
    }
    return infectNum;//将传染数返回;
}

/**
 *  MARK:--------------------将被解决的rDemand在工作记忆的同质解都唤醒 (参考31179-TODO2)--------------------
 *  @desc 白话: 当frameActYes因canset有效而解决了rDemand时,调用此方法 => 将工作记忆中所有同质末帧canset都rewake下,使之可再次尝试它有效;
 *  @rDemand 将frameActYes中被解决的rDemand传进来 (用于到工作记忆中判断同质r任务);
 *  @version
 *      2024.09.06: 全唤醒,但只有当前计P+1 (参考33031b-BUG5-协作);
 */
+(int) rewakeToAllRootsTree_Mv:(TOFoModel*)rewakeFromRCanset except4SP2F:(NSMutableArray*)except4SP2F {
    //1. SP计数之一(P正): 只自己,不唤醒 => 把成功rCanset时,不再唤醒别的rCanset (参考33031b-BUG5-TODO2);
    [rewakeFromRCanset checkAndUpdateOutSPStrong_Percept:1 type:ATPlus debugMode:true caller:@"末帧未发生负mv" except4SP2F:except4SP2F];//有效:P+1;
    
    //2. 把所有工作记忆树等mv反馈的全唤醒;
    ReasonDemandModel *rewakeByRDemand = (ReasonDemandModel*)rewakeFromRCanset.baseOrGroup;
    int rewakeNum = 0;
    NSArray *allCanset = [TOUtils getSubCansets_AllDeep_AllRoots];
    for (TOFoModel *canset in allCanset) {
        //1. 非RDemand的解不唤醒;
        if (!ISOK(canset.baseOrGroup, ReasonDemandModel.class)) continue;
        //2. 未到末尾不唤醒;
        if (canset.cansetActIndex < canset.transferXvModel.cansetToOrders.count) continue;
        //3. 非同区不唤醒;
        DemandModel *otherDemand = (DemandModel*)canset.baseOrGroup;
        if (![rewakeByRDemand.algsType isEqualToString:otherDemand.algsType]) continue;
        //4. 可以考虑,只唤醒besting的,因为bested的已经过去了;
        //if (canset.cansetStatus != CS_Besting) continue;
    
        //4. 末帧超时未反馈负价值的,更新outSPDic (参考32012-TODO6);
        //[canset checkAndUpdateOutSPStrong_Percept:1 type:ATPlus debugMode:true caller:@"末帧未发生负mv"];//有效:P+1;
    
        //5. 传染的唤醒下;
        if (canset.isInfected) {
            canset.isInfected = false;
            rewakeNum++;
        }
    }
    NSLog(@"frameActYes触发后,发现:%@ 自然未发生负价值,将已末帧传染的mv同区canset唤醒:%d",rewakeByRDemand.algsType,rewakeNum);
    return rewakeNum;//将唤醒数返回;
}

/**
 *  MARK:--------------------在rSolution/hSolution初始化Canset池时,中间帧继用下传染状态 (参考31178-TODO3)--------------------
 *  @desc 作用: 从roots树,传染到newDemand.actionFoModels;
 */
+(int) initInfectedForCansetPool_Alg:(DemandModel*)demand {
    int initToInfectedNum = 0;
    //1. 取出工作记忆中所有传染状态的alg_p;
    NSArray *allCanset = [TOUtils getSubCansets_AllDeep_AllRoots];
    allCanset = [SMGUtils filterArr:allCanset checkValid:^BOOL(TOFoModel *item) {
        return item.isInfected;
    }];
    NSArray *isInfectedAlgs = [SMGUtils convertArr:allCanset convertBlock:^id(TOFoModel *obj) {
        TOAlgModel *alg = [obj getCurFrame];
        return alg ? alg.content_p : nil;
    }];
    
    //2. 在rSolution/hSolution初始化Canset池时,也继用下传染状态 (参考31178-TODO3);
    NSLog(@"初始时,发现整树已传染:%@",CLEANSTR([SMGUtils convertArr:isInfectedAlgs convertBlock:^id(AIKVPointer *obj) {
        return STRFORMAT(@"A%ld",obj.pointerId);
    }]));
    for (TOFoModel *canset in demand.actionFoModels) {
        TOAlgModel *alg = [canset getCurFrame];
        if (alg && [isInfectedAlgs containsObject:alg.content_p]) {
            canset.isInfected = true;
            initToInfectedNum++;
            
            //3. 初始即传染的中间帧也计SP- (参考32012-TODO4);
            //2024.09.06: 初始化传染alg时,不计S+1 (参考33031b-BUG5-协作);
            //[canset checkAndUpdateOutSPStrong_Reason:1 type:ATSub debugMode:false caller:@"初始化canset中间帧传染"];
        }
    }
    return initToInfectedNum;
}

/**
 *  MARK:--------------------在rSolution初始化Canset池时,末帧继用下传染状态 (参考31179-TODO3)--------------------
 */
+(int) initInfectedForCansetPool_Mv:(ReasonDemandModel*)newRDemand {
    int initToInfectedNum = 0;
    //1. 取出工作记忆中所有传染状态的alg_p;
    NSArray *allCanset = [TOUtils getSubCansets_AllDeep_AllRoots];
    
    //log
    NSArray *infectedCansets = [SMGUtils filterArr:allCanset checkValid:^BOOL(TOFoModel *item) {
        return item.isInfected;
    }];
    NSLog(@"root数:%ld 总方案数:%ld 已传染数:%ld",theTC.outModelManager.getAllDemand.count,allCanset.count,infectedCansets.count);
    
    for (TOFoModel *item in allCanset) {
        //a. 过滤1
        if (!ISOK(item.baseOrGroup, ReasonDemandModel.class)) continue;
        ReasonDemandModel *itemRDemand = (ReasonDemandModel*)item.baseOrGroup;
        
        //b. 过滤2
        BOOL sameDemandAtAndEndFrameAndInfected = item.isInfected && item.cansetActIndex >= item.transferXvModel.cansetToOrders.count && [itemRDemand.algsType isEqual:newRDemand.algsType];
        if (!sameDemandAtAndEndFrameAndInfected) continue;
           
        //c. 在rSolution/hSolution初始化Canset池时,也继用下传染状态 (参考31178-TODO3);
        for (TOFoModel *newCanset in newRDemand.actionFoModels) {
            if (newCanset.cansetActIndex >= newCanset.transferXvModel.cansetToOrders.count) {
                newCanset.isInfected = true;
                initToInfectedNum++;
                
                //2. 初始即传染的末帧也计SP- (参考32012-TODO4);
                //2024.09.05: 传染就行了,但不应该计S+1 (因为思维要快速响应,但SP不应该一杆子打死) (参考33031b-BUG5-TODO3);
                //[newCanset checkAndUpdateOutSPStrong_Percept:1 type:ATSub debugMode:false caller:@"初始化canset末帧传染"];
            }
        }
        
        //d. 全闯过,并处理完,则退出循环;
        break;
    }
    return initToInfectedNum;
}

@end
