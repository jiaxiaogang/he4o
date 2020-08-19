//
//  AINetAbsUtils.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/6/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbsFoUtils.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "TOUtils.h"

@implementation AINetAbsFoUtils

+(AIPort*) searchPortWithTargetP:(AIKVPointer*)target_p fromPorts:(NSArray*)ports{
    for (AIPort *checkPort in ARRTOOK(ports)) {
        if (ISOK(checkPort, AIPort.class) && ISOK(checkPort.target_p, AIKVPointer.class)) {
            if ([checkPort.target_p isEqual:target_p]) {
                return checkPort;
            }
        }
    }
    return nil;
}

/**
 *  MARK:--------------------从conFos中提取deltaTimes--------------------
 *  @result notnull
 */
+(NSMutableArray*) getDeltaTimes:(NSArray*)conFos absFo:(AIFoNodeBase*)absFo{
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSMutableDictionary *recordIndexs = [[NSMutableDictionary alloc] init];
    if (!ARRISOK(conFos) || absFo) return result;
    
    //2. 提取 (absFo有可能本来deltaTimes不为空,也要参与到竞争Max(A,B)中来;
    for (AIKVPointer *absAlg_p in absFo.content_ps) {
        
        //3. 从每个conFo中找到对应absAlg_p的元素下标;
        NSInteger maxDeltaTime = 0;
        for (AIFoNodeBase *conFo in conFos) {
            
            //a. 找到当前所处下标;
            NSInteger findIndex = [TOUtils indexOfAbsItem:absAlg_p atConContent:conFo.content_ps];
            if (findIndex != -1) {
                
                //b. 取出旧下标,存下新下标;
                NSString *key = STRFORMAT(@"%@_%ld",conFo.pointer.identifier,conFo.pointer.pointerId);
                NSInteger startIndex = [NUMTOOK([recordIndexs objectForKey:key]) integerValue];
                [recordIndexs setObject:@(findIndex) forKey:key];
                
                //c. 将有效间隔取出,并提取最大的deltaTime;
                NSInteger sumDeltaTime = [AINetAbsFoUtils sumDeltaTime:conFo startIndex:startIndex endIndex:findIndex];
                maxDeltaTime = MAX(maxDeltaTime, sumDeltaTime);
            }else{
                WLog(@"getDetailTimes findIndex失败 (抽象必然可从具象时序中发现index才对,查下为何未发现)");
            }
        }
        [result addObject:@(maxDeltaTime)];
    }
    NSLog(@"getDetailTimes Finish:%@",result);
    return result;
}

/**
 *  MARK:--------------------获取指定获取的deltaTime之和--------------------
 */
+(NSInteger) sumDeltaTime:(AIFoNodeBase*)fo startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex{
    NSInteger result = 0;
    if (fo) {
        NSArray *valids = ARR_SUB(fo.deltaTimes, startIndex, endIndex - startIndex);
        for (NSNumber *valid in valids) {
            result += [valid integerValue];
        }
    }
    return result;
}

@end
