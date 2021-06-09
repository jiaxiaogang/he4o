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

+(void) findConAlg_StableMV:(AIAlgNodeBase*)curAlg curFo:(AIFoNodeBase*)curFo itemBlock:(BOOL(^)(AIAlgNodeBase* validAlg))itemBlock{
    //1. 取概念和时序的具象端口;
    if (!itemBlock) return;
    NSArray *conAlg_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:curAlg]];
    NSArray *conFo_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:curFo]];
    
    //2. 筛选具象概念,将合格的回调返回;
    for (AIKVPointer *conAlg_p in conAlg_ps) {
        //a. 根据具象概念,取被哪些时序引用了;
        AIAlgNodeBase *conAlg = [SMGUtils searchNode:conAlg_p];
        NSArray *conAlgRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Alg:conAlg]];
        
        //b. 被引用的时序是curFo的具象时序,则有效;
        NSArray *validRef_ps = [SMGUtils filterSame_ps:conAlgRef_ps parent_ps:conFo_ps];
        if (validRef_ps.count > 0) {
            BOOL goOn = itemBlock(conAlg);
            if (!goOn) return;
        }
    }
}

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

+(BOOL) mcSameLayer:(AIKVPointer*)m c:(AIKVPointer*)c{
    AINodeBase *mNode = [SMGUtils searchNode:m];
    AINodeBase *cNode = [SMGUtils searchNode:c];
    if (mNode && cNode) {
        //1. 判断0-1级抽象;
        NSArray *mAbs_ps = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:mNode]];
        NSArray *cAbs_ps = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:cNode]];
        
        //2. 判断有无共同抽象;
        return [SMGUtils filterSame_ps:mAbs_ps parent_ps:cAbs_ps].count > 0;
    }
    return false;
}

+(NSArray*) convertValuesFromAlg_ps:(NSArray*)alg_ps{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *algs = [SMGUtils searchNodes:alg_ps];
    for (AIAlgNodeBase *item in algs) [result addObjectsFromArray:item.content_ps];
    return result;
}

//+(NSArray*) collectAbsPs:(AINodeBase*)protoNode type:(AnalogyType)type conLayer:(NSInteger)conLayer absLayer:(NSInteger)absLayer{
//    return [SMGUtils convertPointersFromPorts:[self collectAbsPorts:protoNode type:type conLayer:conLayer absLayer:absLayer]];
//}
//+(NSArray*) collectAbsPorts:(AINodeBase*)protoNode type:(AnalogyType)type conLayer:(NSInteger)conLayer absLayer:(NSInteger)absLayer{
//    //1. 数据准备
//    NSMutableArray *result = [[NSMutableArray alloc] init];
//    if (!protoNode) return result;
//    
//    //2. 收集本层
//    [result addObjectsFromArray:[AINetUtils absPorts_All:protoNode type:type]];
//    
//    //3. 具象所需层循环;
//    [result addObjectsFromArray:[self collectAbsPorts:protoNode type:type nextlayer:conLayer nextBlock:^NSArray *(AINodeBase *curAlg) {
//        return [AINetUtils conPorts_All:curAlg];
//    }]];
//    
//    //4. 抽象所需层循环;
//    [result addObjectsFromArray:[self collectAbsPorts:protoNode type:type nextlayer:absLayer nextBlock:^NSArray *(AINodeBase *curAlg) {
//        return [AINetUtils absPorts_All_Normal:curAlg];
//    }]];
//    return result;
//}
//
///**
// *  MARK:--------------------收集AbsPorts--------------------
// *  @desc 收集后几层 (不含当前层);
// *  @result notnull
// */
//+(NSArray*) collectAbsPorts:(AINodeBase*)protoNode type:(AnalogyType)type nextlayer:(NSInteger)nextlayer nextBlock:(NSArray*(^)(AINodeBase *curAlg))nextBlock{
//    //1. 数据检查;
//    NSMutableArray *result = [[NSMutableArray alloc] init];
//    if (!protoNode || !nextBlock) {
//        return result;
//    }
//    
//    //2. 层数循环
//    NSMutableArray *curNodes = [[NSMutableArray alloc] initWithObjects:protoNode, nil];
//    for (NSInteger i = 0; i < nextlayer; i++) {
//        NSMutableArray *nextNodes = [[NSMutableArray alloc] init];
//        //a. 当前层逐个循环;
//        for (AINodeBase *curNode in curNodes) {
//            //b. 下层逐个收集循环;
//            NSArray *nextPorts = ARRTOOK(nextBlock(curNode));
//            for (AIPort *nextPort in nextPorts) {
//                AINodeBase *nextNode = [SMGUtils searchNode:nextPort.target_p];
//                [result addObjectsFromArray:[AINetUtils absPorts_All:nextNode type:type]];
//                [nextNodes addObject:nextNode];
//            }
//        }
//        //c. 完成一层,将下层变成当前层,将下层清空;
//        [curNodes removeAllObjects];
//        [curNodes addObjectsFromArray:nextNodes];
//        [nextNodes removeAllObjects];
//    }
//    return result;
//}

+(NSMutableArray*) collectAbsPorts:(NSArray*)proto_ps singleLimit:(NSInteger)singleLimit havTypes:(NSArray*)havTypes noTypes:(NSArray*)noTypes{
    return [self collectPorts:proto_ps singleLimit:singleLimit havTypes:havTypes noTypes:noTypes isAbs:true];
}
+(NSMutableArray*) collectConPorts:(NSArray*)proto_ps singleLimit:(NSInteger)singleLimit havTypes:(NSArray*)havTypes noTypes:(NSArray*)noTypes{
    return [self collectPorts:proto_ps singleLimit:singleLimit havTypes:havTypes noTypes:noTypes isAbs:false];
}
+(NSMutableArray*) collectPorts:(NSArray*)proto_ps singleLimit:(NSInteger)singleLimit havTypes:(NSArray*)havTypes noTypes:(NSArray*)noTypes isAbs:(BOOL)isAbs{
    //1. 数据准备;
    proto_ps = ARRTOOK(proto_ps);
    
    //2. 非0层时,根据上层获取下层,并收集 (即上层全不应期掉了,向着pAlg抽象方向继续尝试);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (AIKVPointer *item in proto_ps) {
        AINodeBase *protoNode = [SMGUtils searchNode:item];
        NSArray *port_ps = nil;
        if (isAbs) {
            port_ps = Ports2Pits([AINetUtils absPorts_All:protoNode havTypes:havTypes noTypes:noTypes]);;
        }else{
            port_ps = Ports2Pits([AINetUtils conPorts_All:protoNode havTypes:havTypes noTypes:noTypes]);
        }
        
        port_ps = ARR_SUB(port_ps, 0, singleLimit);
        [result addObjectsFromArray:port_ps];
    }
    return result;
}

/**
 *  MARK:--------------------TOP.diff正负两个模式--------------------
 *  @desc 联想方式,参考19192示图 (此行为后补注释);
 *  @bug
 *      1. 查点击马上饿,找不到解决方案的BUG,经查,MatchAlg与解决方案无明确关系,但MatchAlg.conPorts中,有与解决方案有直接关系的,改后解决 (参考20073)
 *      2020.07.09: 修改方向索引的解决方案不应期,解决只持续飞行两次就停住的BUG (参考n20p8-BUG1);
 *  @version
 *      2020.07.23: 迭代至V2_将19192示图的联想方式去掉,仅将方向索引除去不应期的返回,而解决方案到底是否实用,放到行为化中去判断;
 *      2020.09.23: 取消参数matchAlg (最近识别的M),如果今后还要使用短时优先功能,直接从theTC.shortManager取);
 */
//+(void) topPerceptMode:(AIAlgNodeBase*)matchAlg demandModel:(DemandModel*)demandModel direction:(MVDirection)direction tryResult:(BOOL(^)(AIFoNodeBase *sameFo))tryResult canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy{
//    //1. 数据准备;
//    if (!matchAlg || !demandModel || direction == MVDirection_None || !tryResult || !canAssBlock || !canAssBlock() || !updateEnergy) return;
//
//    //2. matchAlg可以用来做什么,取A.refPorts
//    //P例:土豆,可吃,也可当土豆地雷;
//    //S例:打球,导致开心,但也导致累;
//    NSArray *mIndexes = [ThinkingUtils collectionNodes:matchAlg.pointer absLimit:0 conLimit:cTOPPModeConAssLimit];
//    NSMutableArray *mRef_ps = [ThinkingUtils collectionAlgRefs:mIndexes itemRefLimit:NSIntegerMax except_p:nil];
//
//    //3. 无瞬时指引,单靠内心瞎想,不能解决任何问题;
//    if (!ARRISOK(mRef_ps)) return;
//
//    //3. 不应期
//    NSArray *exceptFoModels = [SMGUtils filterArr:demandModel.actionFoModels checkValid:^BOOL(TOModelBase *item) {
//        return item.status == TOModelStatus_ActNo || item.status == TOModelStatus_ScoreNo;
//    }];
//    NSArray *except_ps = [TOUtils convertPointersFromTOModels:exceptFoModels];
//    if (Log4DirecRef) NSLog(@"Fo不应期数:%ld",except_ps.count);
//
//    //4. 用方向索引找normalFo解决方案
//    //P例:饿了,该怎么办;
//    //S例:累了,肿么肥事;
//    [theNet getNormalFoByDirectionReference:demandModel.algsType direction:direction tryResult:^BOOL(AIKVPointer *fo_p) {
//        //5. 方向索引找到一条normalFo解决方案;
//        //P例:吃可以解决饿;
//        //S例:运动导致累;
//        AIFoNodeBase *foNode = [SMGUtils searchNode:fo_p];
//        if (foNode) {
//            //6. 再向下取具体解决方案F.conPorts;
//            //P例:吃-可以做饭,也可以下馆子;
//            //S例:运动-打球是运动,跑步也是;
//            NSMutableArray *foCon_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:foNode]];
//            [foCon_ps insertObject:foNode.pointer atIndex:0];
//
//            //6. 移除不应期
//            foCon_ps = [SMGUtils removeSub_ps:except_ps parent_ps:foCon_ps];
//
//            //6. 取交集
//            //P例:炒个土豆丝,吃掉解决饥饿问题;
//            //S例:打球导致累,越打越累;
//            NSArray *same_ps = [SMGUtils filterSame_ps:mRef_ps parent_ps:foCon_ps];
//            if (Log4DirecRef) NSLog(@"方向索引到-有效Fo数:%ld 瞬时match用途:%ld 交集有效:%ld",foCon_ps.count,mRef_ps.count,same_ps.count);
//
//            //7. 依次尝试行为化;
//            //P例:取自身,实现吃,则可不饿;
//            //S例:取兄弟节点,停止打球,则不再累;
//            for (AIKVPointer *same_p in same_ps) {
//                //8. 消耗活跃度;
//                updateEnergy(-1);
//                AIFoNodeBase *sameFo = [SMGUtils searchNode:same_p];
//                BOOL stop = tryResult(sameFo);
//
//                //8. 只要有一次tryResult成功,中断回调循环;
//                if (stop) {
//                    return true;
//                }
//
//                //9. 只要耗尽,中断回调循环;
//                if (!canAssBlock()) {
//                    return true;
//                }
//            }
//        }
//        return false;//fo解决方案无效,继续找下个;
//    }];
//}
+(void) topPerceptModeV2:(DemandModel*)demandModel direction:(MVDirection)direction tryResult:(BOOL(^)(AIFoNodeBase *sameFo))tryResult canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy{
    //1. 数据准备;
    if (!demandModel || direction == MVDirection_None || !tryResult || !canAssBlock || !canAssBlock() || !updateEnergy) return;
    
    //2. 逐个对mModels短时记忆进行尝试使用 (关闭);
    //NSArray *mModels = [self.delegate aiTOP_GetShortMatchModel];
    
    //3. 不应期
    NSArray *exceptFoModels = [SMGUtils filterArr:demandModel.actionFoModels checkValid:^BOOL(TOModelBase *item) {
        return item.status == TOModelStatus_ActNo || item.status == TOModelStatus_ScoreNo || item.status == TOModelStatus_ActYes;
    }];
    NSArray *except_ps = [TOUtils convertPointersFromTOModels:exceptFoModels];
    if (Log4DirecRef) NSLog(@"------->>>>>> Fo已有方案数:%lu 不应期数:%lu",(long)demandModel.actionFoModels.count,(long)except_ps.count);
    
    //4. 用方向索引找normalFo解决方案
    //P例:饿了,该怎么办;
    //S例:累了,肿么肥事;
    [theNet getNormalFoByDirectionReference:demandModel.algsType direction:direction tryResult:^BOOL(AIKVPointer *fo_p) {
        //5. 方向索引找到一条normalFo解决方案;
        //P例:吃可以解决饿;
        //S例:运动导致累;
        if (![except_ps containsObject:fo_p]) {
            //8. 消耗活跃度;
            updateEnergy(-2);
            AIFoNodeBase *fo = [SMGUtils searchNode:fo_p];
            BOOL stop = tryResult(fo);
            
            //8. 只要有一次tryResult成功,中断回调循环;
            if (stop) {
                return true;
            }
            
            //9. 只要耗尽,中断回调循环;
            if (!canAssBlock()) {
                return true;
            }
        }
        return false;//fo解决方案无效,继续找下个;
    }];
}

/**
 *  MARK:--------------------获取subOutModel的demand--------------------
 */
+(DemandModel*) getDemandModelWithSubOutModel:(TOModelBase*)subOutModel{
    NSMutableArray *demands = [self getBaseDemands_AllDeep:subOutModel];
    return ARR_INDEX(demands, 0);
}
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
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!subModel) return result;
    
    //2. 向base取 (是Demand则收集);
    TOModelBase *checkModel = subModel;
    while (checkModel) {
        if (ISOK(checkModel, DemandModel.class)) [result addObject:checkModel];
        checkModel = checkModel.baseOrGroup;
    }
    return result;
}
+(NSMutableArray*) getSubDemands_AllDeep:(DemandModel*)root validStatus:(NSArray*)validStatus{
    NSArray *subModels = [self getSubOutModels_AllDeep:root validStatus:validStatus];
    return [SMGUtils filterArr:subModels checkValid:^BOOL(TOModelBase *item) {
        return ISOK(item, DemandModel.class);
    }];
}

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

/**
 *  MARK:--------------------将rDemands转为pointers--------------------
 *  @result notnull
 */
+(NSMutableArray*) convertPointersFromRDemands:(NSArray*)rDemands{
    //2. 收集actionFos;
    return [SMGUtils convertArr:rDemands convertBlock:^id(ReasonDemandModel *item) {
        if (ISOK(item, ReasonDemandModel.class)) {
            return item.mModel.matchFo.pointer;
        }
        return nil;
    }];
}

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
 *  MARK:--------------------将TOModels中TOValue部分的sValue_p收集返回--------------------
 *  @version
 *      2020.08.27: 支持validStatus,有效status才收集 (默认nil时,全收集);
 *
 */
+(NSArray*) convertPointersFromTOValueModelSValue:(NSArray*)toModels validStatus:(NSArray*)validStatus{
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    validStatus = ARRTOOK(validStatus);
    
    //2. 收集返回
    [SMGUtils filterArr:toModels checkValid:^BOOL(TOValueModel *model) {
        if (ISOK(model, TOValueModel.class) && model.sValue_p) {
            //3. 不要求validStatus时,全收集;
            if (!ARRISOK(validStatus)) {
                [result addObject:model.sValue_p];
            }else if ([validStatus containsObject:@(model.status)]) {
                //4. 要求validStatus时,有效才收集;
                [result addObject:model.sValue_p];
            }
        }
        return false;
    }];
    return result;
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
    return p && [p.dataSource isEqualToString:[ThinkingUtils getAnalogyTypeDS:ATHav]];
}
+(BOOL) isN:(AIKVPointer*)p{
    return p && [p.dataSource isEqualToString:[ThinkingUtils getAnalogyTypeDS:ATNone]];
}
+(BOOL) isG:(AIKVPointer*)p{
    return p && [p.dataSource isEqualToString:[ThinkingUtils getAnalogyTypeDS:ATGreater]];
}
+(BOOL) isL:(AIKVPointer*)p{
    return p && [p.dataSource isEqualToString:[ThinkingUtils getAnalogyTypeDS:ATLess]];
}
+(BOOL) isS:(AIKVPointer*)p{
    return p && [p.dataSource isEqualToString:[ThinkingUtils getAnalogyTypeDS:ATSub]];
}
+(BOOL) isP:(AIKVPointer*)p{
    return p && [p.dataSource isEqualToString:[ThinkingUtils getAnalogyTypeDS:ATPlus]];
}

/**
 *  MARK:--------------------是否HNGL的TOModel--------------------
 */
+(BOOL) isHNGL_toModel:(TOModelBase*)toModel{
    return [self isHNGL:[self convertLastAlg2FoModel:toModel].content_p];
}
+(BOOL) isH_toModel:(TOModelBase*)toModel{
    return [self isH:[self convertLastAlg2FoModel:toModel].content_p];
}
+(BOOL) isN_toModel:(TOModelBase*)toModel{
    return [self isN:[self convertLastAlg2FoModel:toModel].content_p];
}
+(BOOL) isG_toModel:(TOModelBase*)toModel{
    return [self isG:[self convertLastAlg2FoModel:toModel].content_p];
}
+(BOOL) isL_toModel:(TOModelBase*)toModel{
    return [self isL:[self convertLastAlg2FoModel:toModel].content_p];
}
+(TOModelBase*) convertLastAlg2FoModel:(TOModelBase*)toModel{
    //当alg所处的fo是末位节点,则返回所处的foModel;
    if (!ISOK(toModel, TOFoModel.class) && ISOK(toModel.baseOrGroup, TOFoModel.class)) {
        AIFoNodeBase *baseFo = [SMGUtils searchNode:toModel.baseOrGroup.content_p];
        if ([toModel.content_p isEqual:[baseFo.content_ps lastObject]]) {
            return toModel.baseOrGroup;
        }
    }
    return toModel;
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
    deltaTime += [self getSumDeltaTime:fo fromCutIndex:cutIndex toEndIndex:fo.count];
    
    //3. 取mvDeltaTime;
    deltaTime += fo.mvDeltaTime;
    return deltaTime;
}
//从cutIndex取到endIndex;
+(double) getSumDeltaTime:(AIFoNodeBase*)fo fromCutIndex:(NSInteger)cutIndex toEndIndex:(NSInteger)endIndex{
    //1. 数据准备
    double deltaTime = 0;
    if (!fo) return deltaTime;
    
    //2. 取 "cutIndex后deltaTime" 与 "mvDeltaTime" 之和,并返回;
    for (NSInteger i = cutIndex; i < endIndex; i++) {
        deltaTime += [NUMTOOK(ARR_INDEX(fo.deltaTimes, i)) doubleValue];
    }
    return deltaTime;
}

@end
