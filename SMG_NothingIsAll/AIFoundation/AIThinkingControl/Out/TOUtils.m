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

+(BOOL) mIsC:(AIAlgNodeBase*)m c:(AIAlgNodeBase*)c{
    if (m && c) {
        //1. 判断本级相等;
        BOOL equ0 = [m.pointer isEqual:c.pointer];
        if (equ0) return true;
        
        //2. 判断一级抽象;
        NSArray *mAbs = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All_Normal:m]];
        BOOL equ1 = [mAbs containsObject:c.pointer];
        if (equ1) return true;
        
        //3. 判断二级抽象;
        NSArray *cCon = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:c]];
        BOOL equ2 = [SMGUtils filterSame_ps:mAbs parent_ps:cCon].count > 0;
        if (equ2) return true;
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

@end
