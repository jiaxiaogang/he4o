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
 *      2020.09.10: findIndex有时会失败 (因为HNGL时,需要index判断两层) T;
 *      2020.09.10: maxDeltaTime在非0位时,有可能取到0的BUG (记录lastIndex,但并未彻底解决) (发现NL时为0正常) T;
 *      2020.09.15: 多个conFos,却只记录了一个lastIndex导致错乱找不到findIndex的bug; T
 */
+(NSMutableArray*) getDeltaTimes:(NSArray*)conFos absFo:(AIFoNodeBase*)absFo{
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!ARRISOK(conFos) || !absFo) return result;
    
    //2. 提取 (absFo有可能本来deltaTimes不为空,也要参与到竞争Max(A,B)中来;
    NSMutableDictionary *lastIndexDic = [[NSMutableDictionary alloc] init];
    for (AIKVPointer *absAlg_p in absFo.content_ps) {
        
        //3. 从每个conFo中找到对应absAlg_p的元素下标;
        double maxDeltaTime = 0;
        for (AIFoNodeBase *conFo in conFos) {
            
            //a. 找到当前所处下标;
            NSData *lastIndexKey = OBJ2DATA(conFo.pointer);
            NSInteger lastIndex = [NUMTOOK_DV([lastIndexDic objectForKey:lastIndexKey], -1) integerValue];
            BOOL isHNGL = [TOUtils isHNGL:absAlg_p];
            NSInteger findIndex = [TOUtils indexOfAbsItem:absAlg_p atConContent:conFo.content_ps layerDiff:isHNGL ? 2 : 1 startIndex:lastIndex + 1];
            if (findIndex != -1) {
                //b. 将有效间隔取出,并提取最大的deltaTime;
                double sumDeltaTime = [AINetAbsFoUtils sumDeltaTime:conFo startIndex:lastIndex endIndex:findIndex];
                maxDeltaTime = MAX(maxDeltaTime, sumDeltaTime);
                
                //c. 将新发现的下标记录 (1. lastIndex+1用于indexOfAbsItem 2. lastIndex用于sumDeltaTime);
                [lastIndexDic setObject:@(findIndex) forKey:lastIndexKey];
                
                //deltaTime为0的BUG测试;
                //BOOL nOk = [absFo.content_ps indexOfObject:absAlg_p] == absFo.content_ps.count - 1 && [TOUtils isN:conFo.pointer];
                //if (findIndex != 0 && sumDeltaTime == 0 && !nOk) {
                //    NSLog(@"%@",Fo2FStr(conFo));
                //}
            }else if(![TOUtils isN:absAlg_p] && ![TOUtils isL:absAlg_p]){
                //NL找不到,是正常的,因为"内类比无/小"时,本身具象只是frontConAlg,并且本来就是瞬间变"无/小"的;
                WLog(@"getDetailTimes\nAbsA:%@\nAbsF:%@\nConF:%@,%ld,%ld",AlgP2FStr(absAlg_p),Fo2FStr(absFo),Fo2FStr(conFo),(long)findIndex,(long)lastIndex);
            }
        }
        
        //4. 首条时加入0,否则加入maxDeltaTime;
        if ([absFo.content_ps indexOfObject:absAlg_p] == 0) {
            [result addObject:@(0.0f)];
        }else{
            [result addObject:@(maxDeltaTime)];
        }
    }
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
