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
        NSArray *mAbs = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All_Normal:[SMGUtils searchNode:m]]];
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
        NSArray *mAbs = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All_Normal:[SMGUtils searchNode:m]]];
        NSArray *cCon = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:[SMGUtils searchNode:c]]];
        BOOL equ2 = [SMGUtils filterSame_ps:mAbs parent_ps:cCon].count > 0;
        if (equ2) return true;
    }
    return false;
}

+(NSInteger) indexOfAbsItem:(AIKVPointer*)absItem atConContent:(NSArray*)conContent{
    for (AIKVPointer *item_p in ARRTOOK(conContent)) {
        if ([TOUtils mIsC_1:item_p c:absItem]) {
            return [conContent indexOfObject:item_p];
        }
    }
    return -1;
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

+(void) topPerceptMode:(AIAlgNodeBase*)matchAlg demandModel:(DemandModel*)demandModel direction:(MVDirection)direction tryResult:(BOOL(^)(AIFoNodeBase *sameFo))tryResult canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy{
    //1. 数据准备;
    if (!matchAlg || !demandModel || direction == MVDirection_None || !tryResult || !canAssBlock || !updateEnergy) return;
    
    //2. matchAlg可以用来做什么,取A.refPorts
    //P例:土豆,可吃,也可当土豆地雷;
    //S例:打球,导致开心,但也导致累;
    NSArray *algRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Alg:matchAlg]];
    
    //3. 无瞬时指引,单靠内心瞎想,不能解决任何问题;
    if (!ARRISOK(algRef_ps)) return;
    
    //4. 用方向索引找normalFo解决方案
    //P例:饿了,该怎么办;
    //S例:累了,肿么肥事;
    [theNet getNormalFoByDirectionReference:demandModel.algsType direction:direction except_ps:nil tryResult:^BOOL(AIKVPointer *fo_p) {
        //5. 方向索引找到一条normalFo解决方案;
        //P例:吃可以解决饿;
        //S例:运动导致累;
        AIFoNodeBase *foNode = [SMGUtils searchNode:fo_p];
        if (foNode) {
            //6. 再向下取具体解决方案F.conPorts;
            //P例:吃-可以做饭,也可以下馆子;
            //S例:运动-打球是运动,跑步也是;
            NSArray *foCon_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:foNode]];
            
            //6. 取交集
            //P例:炒个土豆丝,吃掉解决饥饿问题;
            //S例:打球导致累,越打越累;
            NSArray *same_ps = [SMGUtils filterSame_ps:algRef_ps parent_ps:foCon_ps];
            
            //7. 依次尝试行为化;
            //P例:取自身,实现吃,则可不饿;
            //S例:取兄弟节点,停止打球,则不再累;
            for (AIKVPointer *same_p in same_ps) {
                AIFoNodeBase *sameFo = [SMGUtils searchNode:same_p];
                BOOL success = tryResult(sameFo);
                
                //8. 只要有一次tryResult成功,中断回调循环;
                if (success) {
                    return true;
                }
                
                //9. 消耗活跃度,只要耗尽,中断回调循环;
                updateEnergy(-1);
                if (!canAssBlock()) {
                    return true;
                }
            }
        }
        return true;//一次无效,则中止方向索引找解决方案;
    }];
}

@end
