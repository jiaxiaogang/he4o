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
#import "AIShortMatchModel_Simple.h"

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
 *  @bug
 *      2020.09.01: 返回空result的BUG,发现是数据准备时,检查条件判断错误导致 T;
 *      2020.09.10: findIndex有时会失败 T (因为HNGL时,需要index判断两层);
 *      2020.09.10: maxDeltaTime在非0位时,有可能取到0的BUG (记录lastIndex,但并未彻底解决);
 */
+(NSMutableArray*) getDeltaTimes:(NSArray*)conFos absFo:(AIFoNodeBase*)absFo{
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSMutableDictionary *recordIndexs = [[NSMutableDictionary alloc] init];
    if (!ARRISOK(conFos) || !absFo) return result;
    
    //2. 提取 (absFo有可能本来deltaTimes不为空,也要参与到竞争Max(A,B)中来;
    NSInteger nextStartIndex = 0;
    for (AIKVPointer *absAlg_p in absFo.content_ps) {
        
        //3. 从每个conFo中找到对应absAlg_p的元素下标;
        double maxDeltaTime = 0;
        for (AIFoNodeBase *conFo in conFos) {
            
            //a. 找到当前所处下标;
            BOOL isHNGL = [TOUtils isHNGL:absAlg_p];
            NSInteger findIndex = [TOUtils indexOfAbsItem:absAlg_p atConContent:conFo.content_ps layerDiff:isHNGL ? 2 : 1 startIndex:nextStartIndex];
            if (findIndex != -1) {
                //a. 将新发现的下标记录,lastIndex+1作为下次循环的开始点;
                nextStartIndex = findIndex + 1;
                
                //b. 取出旧下标,存下新下标;
                NSString *key = STRFORMAT(@"%@_%ld",conFo.pointer.identifier,conFo.pointer.pointerId);
                NSInteger startIndex = [NUMTOOK([recordIndexs objectForKey:key]) integerValue];
                [recordIndexs setObject:@(findIndex) forKey:key];
                
                //c. 将有效间隔取出,并提取最大的deltaTime;
                double sumDeltaTime = [AINetAbsFoUtils sumDeltaTime:conFo startIndex:startIndex endIndex:findIndex];
                maxDeltaTime = MAX(maxDeltaTime, sumDeltaTime);
                
                //deltaTime为0的BUG测试;
                if (findIndex != 0 && sumDeltaTime == 0) {
                    [AINetAbsFoUtils sumDeltaTime:conFo startIndex:startIndex endIndex:findIndex];
                    NSLog(@"");
                }
                if (sumDeltaTime == 0 && [absFo.content_ps indexOfObject:absAlg_p] > 0) {
                    NSLog(@"-----------21022BUG: maxDeltaTime无效");
                }
            }else{
                [SMGUtils insertNode:absFo];//absFo未存过,先存下,否则日志打不出其内容;
                WLog(@"getDetailTimes\nAbsA:%@\nAbsF:%@\nConF:%@,%ld,%ld",AlgP2FStr(absAlg_p),Fo2FStr(absFo),Fo2FStr(conFo),(long)findIndex,(long)nextStartIndex);
            }
        }
        [result addObject:@(maxDeltaTime)];
    }
    NSLog(@"getDetailTimes Finish:%@",result);
    return result;
}

/**
 *  MARK:--------------------获取指定获取的deltaTime之和--------------------
 *  _param startIndex   : 下标(不含);
 *  _param endIndex     : 下标(含);
 *  @templete : 如[0,1,2,3],因不含s和含e,取1到3位时,得出结果应该是2+3=5,即range应该是(2到4),所以range=(s+1,e-s);
 *  @bug
 *      2020.09.10: 原来取range(s,e-s)不对,更正为:range(s+1,e-s);
 */
+(double) sumDeltaTime:(AIFoNodeBase*)fo startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex{
    double result = 0;
    if (fo) {
        NSArray *valids = ARR_SUB(fo.deltaTimes, startIndex + 1, endIndex - startIndex);
        for (NSNumber *valid in valids) {
            result += [valid doubleValue];
        }
    }
    return result;
}

+(NSMutableArray*) convertOrder2Alg_ps:(NSArray*)order{
    //1. 数据准备
    NSMutableArray *result = [[NSMutableArray alloc] init];
    order = ARRTOOK(order);
    
    //2. 提取返回
    for (AIShortMatchModel_Simple *simple in order) {
        [result addObject:simple.alg_p];
    }
    return result;
}

/**
 *  MARK:--------------------将order转成deltaTimes--------------------
 *  @bug
 *      2020.08.21: 将收集inputTime修正成收集deltaTime;
 */
+(NSMutableArray*) convertOrder2DeltaTimes:(NSArray*)order{
    //1. 数据准备
    NSMutableArray *result = [[NSMutableArray alloc] init];
    order = ARRTOOK(order);
    
    //2. 提取返回
    NSTimeInterval lastInputTime = 0;
    for (NSInteger i = 0; i < order.count; i++) {
        AIShortMatchModel_Simple *simple = ARR_INDEX(order, i);
        if (i == 0) {
            [result addObject:@(0)];
        }else{
            NSTimeInterval deltaTime = MAX(simple.inputTime - lastInputTime, 0);
            [result addObject:@(deltaTime)];
        }
        lastInputTime = simple.inputTime;
    }
    return result;
}

@end
