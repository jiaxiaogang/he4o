//
//  TOUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/2.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "TOUtils.h"
#import "AIAlgNodeBase.h"
#import "NVHeUtil.h"
#import "AINetUtils.h"
#import "AIPort.h"
#import "DemandModel.h"
#import "TOFoModel.h"
#import "TOAlgModel.h"
#import "TOValueModel.h"
#import "AIShortMatchModel.h"
#import "ThinkingUtils.h"
#import "AINetIndex.h"
#import "ReasonDemandModel.h"
#import "AIMatchFoModel.h"

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
    //1. 数据准备
    double deltaTime = 0;
    if (!fo) return deltaTime;
    
    //2. 取cutIndex后的所有deltaTime;
    deltaTime += [self getSumDeltaTime:fo startIndex:cutIndex endIndex:fo.count];
    
    //3. 取mvDeltaTime;
    deltaTime += fo.mvDeltaTime;
    return deltaTime;
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
        NSArray *valids = ARR_SUB(fo.deltaTimes, startIndex + 1, endIndex - startIndex);
        for (NSNumber *valid in valids) {
            result += [valid doubleValue];
        }
    }
    return result;
}

@end
