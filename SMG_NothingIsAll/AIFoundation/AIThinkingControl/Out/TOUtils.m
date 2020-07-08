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

/**
 *  MARK:--------------------判断indexOf (支持本级+一级抽象)--------------------
 *  @bug 2020.06.12 : TOR.R-中firstAt_Plus取值为-1,经查因为mIsC方法取absPorts_Normal,对plus/sub不支持导致,改后好了;
 *
 */
+(NSInteger) indexOfAbsItem:(AIKVPointer*)absItem atConContent:(NSArray*)conContent{
    for (AIKVPointer *item_p in ARRTOOK(conContent)) {
        if ([TOUtils mIsC_1:item_p c:absItem]) {
            return [conContent indexOfObject:item_p];
        }
    }
    return -1;
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

+(NSArray*) collectAbsPs:(AINodeBase*)protoNode type:(AnalogyType)type conLayer:(NSInteger)conLayer absLayer:(NSInteger)absLayer{
    return [SMGUtils convertPointersFromPorts:[self collectAbsPorts:protoNode type:type conLayer:conLayer absLayer:absLayer]];
}
+(NSArray*) collectAbsPorts:(AINodeBase*)protoNode type:(AnalogyType)type conLayer:(NSInteger)conLayer absLayer:(NSInteger)absLayer{
    //1. 数据准备
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!protoNode) return result;
    
    //2. 收集本层
    [result addObjectsFromArray:[AINetUtils absPorts_All:protoNode type:type]];
    
    //3. 具象所需层循环;
    [result addObjectsFromArray:[self collectAbsPorts:protoNode type:type nextlayer:conLayer nextBlock:^NSArray *(AINodeBase *curAlg) {
        return [AINetUtils conPorts_All:curAlg];
    }]];
    
    //4. 抽象所需层循环;
    [result addObjectsFromArray:[self collectAbsPorts:protoNode type:type nextlayer:absLayer nextBlock:^NSArray *(AINodeBase *curAlg) {
        return [AINetUtils absPorts_All_Normal:curAlg];
    }]];
    return result;
}

/**
 *  MARK:--------------------收集AbsPorts--------------------
 *  @desc 收集后几层 (不含当前层);
 *  @result notnull
 */
+(NSArray*) collectAbsPorts:(AINodeBase*)protoNode type:(AnalogyType)type nextlayer:(NSInteger)nextlayer nextBlock:(NSArray*(^)(AINodeBase *curAlg))nextBlock{
    //1. 数据检查;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!protoNode || !nextBlock) {
        return result;
    }
    
    //2. 层数循环
    NSMutableArray *curNodes = [[NSMutableArray alloc] initWithObjects:protoNode, nil];
    for (NSInteger i = 0; i < nextlayer; i++) {
        NSMutableArray *nextNodes = [[NSMutableArray alloc] init];
        //a. 当前层逐个循环;
        for (AINodeBase *curNode in curNodes) {
            //b. 下层逐个收集循环;
            NSArray *nextPorts = ARRTOOK(nextBlock(curNode));
            for (AIPort *nextPort in nextPorts) {
                AINodeBase *nextNode = [SMGUtils searchNode:nextPort.target_p];
                [result addObjectsFromArray:[AINetUtils absPorts_All:nextNode type:type]];
                [nextNodes addObject:nextNode];
            }
        }
        //c. 完成一层,将下层变成当前层,将下层清空;
        [curNodes removeAllObjects];
        [curNodes addObjectsFromArray:nextNodes];
        [nextNodes removeAllObjects];
    }
    return result;
}


/**
 *  MARK:--------------------获取兄弟节点(以负取正)--------------------
 *  @desc 防重,防空版;
 */
+(void) getPlusBrotherBySubProtoFo_NoRepeatNotNull:(AIFoNodeBase*)subProtoFo tryResult:(BOOL(^)(AIFoNodeBase *checkFo,AIFoNodeBase *subNode,AIFoNodeBase *plusNode))tryResult{
    //1. 去重功能;
    NSMutableArray *except_ps = [[NSMutableArray alloc] init];
    
    //2. 用负取正;
    [TOUtils getPlusBrotherBySubProtoFo:subProtoFo tryResult:^BOOL(AIKVPointer *checkFo_p, AIFoNodeBase *subNode, AIFoNodeBase *plusNode) {
        //a. 重复,直接返回继续 (一个checkFo只行为化一次);
        if (![except_ps containsObject:checkFo_p]) {
            //b. 行为化失败,则收集不应期;
            [except_ps addObject:checkFo_p];
            
            //c. 有效判断
            AIFoNodeBase *checkFo = [SMGUtils searchNode:checkFo_p];
            if (checkFo) {
                return tryResult(checkFo,subNode,plusNode);
            }
        }
        return false;
    }];
}
+(void) getPlusBrotherBySubProtoFo:(AIFoNodeBase*)subProtoFo tryResult:(BOOL(^)(AIKVPointer *checkFo_p,AIFoNodeBase *subNode,AIFoNodeBase *plusNode))tryResult{
    //1. 数据检查
    if (!tryResult) return;
    
    //2. 取matchFo的负节点;
    NSArray *subs = [TOUtils collectAbsPs:subProtoFo type:ATSub conLayer:0 absLayer:0];
    for (AIKVPointer *sub_p in subs) {
        
        //3. 根据负取正节点 (兄弟节点);
        AIFoNodeBase *subNode = [SMGUtils searchNode:sub_p];
        AIFoNodeBase *plusNode = [SMGUtils searchNode:subNode.brother_p];
        
        //4. 根据正节点,取到matchFo的对立节点checkFo;
        AIPort *checkPort = ARR_INDEX([AINetUtils conPorts_All:plusNode], 0);
        
        //5. 尝试返回,判断中止;
        BOOL stop = tryResult(checkPort.target_p,subNode,plusNode);
        if (stop) return;
    }
}

/**
 *  MARK:--------------------TOP.diff正负两个模式--------------------
 *  @desc 联想方式,参考19192示图 (此行为后补注释);
 *  @bug
 *      1. 查点击马上饿,找不到解决方案的BUG,经查,MatchAlg与解决方案无明确关系,但MatchAlg.conPorts中,有与解决方案有直接关系的,改后解决 (参考20073)
 *      2020.07.09: 修改方向索引的解决方案不应期,解决只持续飞行两次就停住的BUG (参考n20p8-BUG1);
 */
+(void) topPerceptMode:(AIAlgNodeBase*)matchAlg demandModel:(DemandModel*)demandModel direction:(MVDirection)direction tryResult:(BOOL(^)(AIFoNodeBase *sameFo))tryResult canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy{
    //1. 数据准备;
    if (!matchAlg || !demandModel || direction == MVDirection_None || !tryResult || !canAssBlock || !canAssBlock() || !updateEnergy) return;
    
    //2. matchAlg可以用来做什么,取A.refPorts
    //P例:土豆,可吃,也可当土豆地雷;
    //S例:打球,导致开心,但也导致累;
    NSMutableArray *mRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Alg:matchAlg]];
    NSArray *mCon_ps = [SMGUtils convertPointersFromPorts:ARR_SUB([AINetUtils conPorts_All:matchAlg], 0, cTOPPModeConAssLimit)];
    for (AIKVPointer *mCon_p in mCon_ps) {
        AIAlgNodeBase *mCon = [SMGUtils searchNode:mCon_p];
        [mRef_ps addObjectsFromArray:[SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Alg:mCon]]];
    }
    
    //3. 无瞬时指引,单靠内心瞎想,不能解决任何问题;
    if (!ARRISOK(mRef_ps)) return;
    
    //3. 不应期
    NSArray *exceptFoModels = [SMGUtils filterArr:demandModel.actionFoModels checkValid:^BOOL(TOModelBase *item) {
        return item.status == TOModelStatus_ActNo || item.status == TOModelStatus_ScoreNo;
    }];
    NSArray *except_ps = [TOUtils convertPointersFromTOModels:exceptFoModels];
    if (Log4DirecRef) NSLog(@"Fo不应期数:%ld",except_ps.count);
    
    //4. 用方向索引找normalFo解决方案
    //P例:饿了,该怎么办;
    //S例:累了,肿么肥事;
    [theNet getNormalFoByDirectionReference:demandModel.algsType direction:direction tryResult:^BOOL(AIKVPointer *fo_p) {
        //5. 方向索引找到一条normalFo解决方案;
        //P例:吃可以解决饿;
        //S例:运动导致累;
        AIFoNodeBase *foNode = [SMGUtils searchNode:fo_p];
        if (foNode) {
            //6. 再向下取具体解决方案F.conPorts;
            //P例:吃-可以做饭,也可以下馆子;
            //S例:运动-打球是运动,跑步也是;
            NSMutableArray *foCon_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:foNode]];
            [foCon_ps insertObject:foNode.pointer atIndex:0];
            
            //6. 移除不应期
            foCon_ps = [SMGUtils removeSub_ps:except_ps parent_ps:foCon_ps];
            if (Log4DirecRef) NSLog(@"方向索引到-有效Fo数:%ld",foCon_ps.count);
            
            //6. 取交集
            //P例:炒个土豆丝,吃掉解决饥饿问题;
            //S例:打球导致累,越打越累;
            NSArray *same_ps = [SMGUtils filterSame_ps:mRef_ps parent_ps:foCon_ps];
            
            //7. 依次尝试行为化;
            //P例:取自身,实现吃,则可不饿;
            //S例:取兄弟节点,停止打球,则不再累;
            for (AIKVPointer *same_p in same_ps) {
                //8. 消耗活跃度;
                updateEnergy(-1);
                AIFoNodeBase *sameFo = [SMGUtils searchNode:same_p];
                BOOL stop = tryResult(sameFo);
                
                //8. 只要有一次tryResult成功,中断回调循环;
                if (stop) {
                    return true;
                }
                
                //9. 只要耗尽,中断回调循环;
                if (!canAssBlock()) {
                    return true;
                }
            }
        }
        return false;//fo解决方案无效,继续找下个;
    }];
}

+(BOOL) toAction_RethinkScore:(TOFoModel*)outModel rtBlock:(AIShortMatchModel*(^)(void))rtBlock{
    if (!outModel || !rtBlock) {
        return true;
    }
    //6. MC反思: 回归tir反思,重新识别理性预测时序,预测价值; (预测到鸡蛋变脏,或者cpu损坏) (理性预测影响评价即理性评价)
    AIShortMatchModel *rtModel = rtBlock();
    
    //7. MC反思: 对mModel进行评价;
    AIKVPointer *rtMv_p = rtModel.matchFo.cmvNode_p;
    CGFloat rtScore = [ThinkingUtils getScoreForce:rtMv_p ratio:rtModel.matchFoValue];
    
    //8. 对原fo进行评价
    DemandModel *demand = [self getDemandModelWithFoOutModel:outModel];
    CGFloat curScore = [ThinkingUtils getScoreForce:demand.algsType urgentTo:demand.urgentTo delta:demand.delta ratio:1.0f];
    
    //10. 如果mv同区,只要为负则失败;
    //if ([rtMv_p.algsType isEqualToString:demand.algsType] && [mMv_p.dataSource isEqualToString:cMv_p.dataSource] && mcScore < 0) { return false; }
    
    //11. 如果不同区,对mcScore和curScore返回评价值进行类比 (如宁饿死不吃屎);
    return rtScore > curScore * 0.5f;
}

+(DemandModel*) getDemandModelWithFoOutModel:(TOModelBase*)foOutModel{
    if (foOutModel) {
        if (ISOK(foOutModel.baseOrGroup, DemandModel.class)) {
            return (DemandModel*)foOutModel.baseOrGroup;
        }else{
            return [self getDemandModelWithFoOutModel:foOutModel.baseOrGroup];
        }
    }
    return nil;
}

+(NSArray*) getSubOutModels_AllDeep:(TOModelBase*)outModel validStatus:(NSArray*)validStatus {
    //1. 数据准备
    validStatus = ARRTOOK(validStatus);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!outModel) return result;
    
    //2. 收集当前
    if ([validStatus containsObject:@(outModel.status)]) {
        [result addObject:outModel];
    }
    
    //3. 找出子集 (Finish负责截停递归);
    if (outModel.status != TOModelStatus_Finish) {
        NSMutableArray *subModels = [[NSMutableArray alloc] init];
        if (ISOK(outModel, DemandModel.class) || ISOK(outModel, TOAlgModel.class) || ISOK(outModel, TOValueModel.class)) {
            id<ITryActionFoDelegate> tryActionObj = (id<ITryActionFoDelegate>)outModel;
            [subModels addObjectsFromArray:tryActionObj.actionFoModels];
        }
        if (ISOK(outModel, TOFoModel.class) || ISOK(outModel, TOAlgModel.class)) {
            id<ISubModelsDelegate> subModelsObj = (id<ISubModelsDelegate>)outModel;
            [subModels addObjectsFromArray:subModelsObj.subModels];
        }
        
        //4. 递归收集子集;
        for (TOModelBase *subModel in subModels) {
            [result addObjectsFromArray:[self getSubOutModels_AllDeep:subModel validStatus:validStatus]];
        }
    }
    return result;
}

+(NSArray*) convertPointersFromTOModels:(NSArray*)toModels{
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    toModels = ARRTOOK(toModels);
    
    //2. 收集返回
    for (TOModelBase *model in toModels) {
        [result addObject:model.content_p];
    }
    return result;
}

@end
