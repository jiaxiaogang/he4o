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
+(BOOL) mIsC_0:(AIKVPointer*)m c:(AIKVPointer*)c{
    if (m && c) {
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
        
        //2. 判断二级抽象;
        NSArray *mAbs = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:[SMGUtils searchNode:m]]];
        NSArray *cCon = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:[SMGUtils searchNode:c]]];
        BOOL equ2 = [SMGUtils filterSame_ps:mAbs parent_ps:cCon].count > 0;
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
        [result addObjectsFromArray:tryActionObj.actionFoModels];
    }
    if ([outModel conformsToProtocol:@protocol(ISubModelsDelegate)]) {
        id<ISubModelsDelegate> subModelsObj = (id<ISubModelsDelegate>)outModel;
        [result addObjectsFromArray:subModelsObj.subModels];
    }
    if ([outModel conformsToProtocol:@protocol(ISubDemandDelegate)]) {
        id<ISubDemandDelegate> subDemandsObj = (id<ISubDemandDelegate>)outModel;
        [result addObjectsFromArray:subDemandsObj.subDemands];
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
 *  @version
 *      2022.05.23: 初版 (参考26096-BUG1);
 *      2022.06.02: 每一帧的稳定性默认为0.5,而不是1 (参考26191);
 *  @result 1. 负价值时序时返回多坏(0-1);
 *          2. 正价值时序时返回多好(0-1);
 *          3. 无价值时序时返回多顺(0-1);
 */
+(CGFloat) getStableScore:(AIFoNodeBase*)fo startSPIndex:(NSInteger)startSPIndex endSPIndex:(NSInteger)endSPIndex{
    //1. 数据检查 & 稳定性默认为1分 & 正负mv的公式是不同的 (参考25122-公式);
    if (!fo) return 0;
    CGFloat totalSPScore = 1.0f;
    BOOL isBadMv = [ThinkingUtils havDemand:fo.cmvNode_p];
    
    //2. 从start到end各计算spScore;
    for (NSInteger i = startSPIndex; i <= endSPIndex; i++) {
        AISPStrong *spStrong = [fo.spDic objectForKey:@(i)];
        
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
    }
    
    //9. 返回SP评分 (多坏或多好);
    return totalSPScore;
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
    CGFloat stableScore = [self getStableScore:fo startSPIndex:startSPIndex endSPIndex:endSPIndex];
    
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
    //1. 取有效率解决方案数组;
    NSArray *strongs = ARRTOOK([demandFo.effectDic objectForKey:@(effectIndex)]);
    
    //2. 取得匹配的strong;
    AIEffectStrong *strong = [SMGUtils filterSingleFromArr:strongs checkValid:^BOOL(AIEffectStrong *item) {
        return [item.solutionFo isEqual:solutionFo];
    }];
    
    //3. 返回有效率;
    return strong;
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
    CGFloat stableScore = [TOUtils getStableScore:fo startSPIndex:startSPIndex endSPIndex:endSPIndex];
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
 *  MARK:--------------------S综合排名--------------------
 *  @desc 对前中后段分别排名,然后综合排名 (参考26222-TODO2);
 *  @param needBack : 是否排后段: H传true需要,R传false不需要;
 *  @param fromSlow : 是否源于慢思考: 慢思考传true中段用stable排,快思考传false中段用effect排;
 */
+(NSArray*) solutionTotalRanking:(NSArray*)solutionModels needBack:(BOOL)needBack fromSlow:(BOOL)fromSlow{
    //1. 三段分开排;
    NSArray *backSorts = needBack ? [SMGUtils sortBig2Small:solutionModels compareBlock:^double(AISolutionModel *obj) {
        return obj.backMatchValue;
    }] : nil;
    NSArray *midSorts = [SMGUtils sortBig2Small:solutionModels compareBlock:^double(AISolutionModel *obj) {
        return fromSlow ? obj.stableScore : obj.effectScore;
    }];
    NSArray *frontSorts = [SMGUtils sortBig2Small:solutionModels compareBlock:^double(AISolutionModel *obj) {
        return obj.frontMatchValue;
    }];
    
    //2. 综合排名
    NSArray *ranking = [SMGUtils sortSmall2Big:solutionModels compareBlock:^double(AISolutionModel *obj) {
        NSInteger backIndex = needBack ? [backSorts indexOfObject:obj] : 0;
        NSInteger midIndex = [midSorts indexOfObject:obj];
        NSInteger frontIndex = [frontSorts indexOfObject:obj];
        return backIndex + midIndex + frontIndex;
    }];
    
    //3. 返回;
    return ranking;
}

/**
 *  MARK:--------------------检查某toModel的末枝有没有ActYes状态--------------------
 *  @desc 因为actYes向上传染,不向下,所以末枝有actYes,即当前curModel也不应响应 (参考26184-原则);
 */
+(BOOL) endHavActYes:(TOModelBase*)curModel{
    NSArray *allSubModels = [TOUtils getSubOutModels_AllDeep:curModel validStatus:nil];
    BOOL endHavActYes = [SMGUtils filterSingleFromArr:allSubModels checkValid:^BOOL(TOModelBase *item) {
        return item.status == TOModelStatus_ActYes && [TOUtils getSubOutModels:item].count == 0;
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


@end
