//
//  AINetAbsUtils.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/6/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbsFoUtils.h"

@implementation AINetAbsFoUtils

/**
 *  MARK:--------------------从conFos中提取deltaTimes--------------------
 *  @result notnull
 *  @bug
 *      2020.09.01: 返回空result的BUG,发现是数据准备时,检查条件判断错误导致 T;
 *      2020.09.10: findIndex有时会失败 (因为HNGL时,需要index判断两层) T;
 *      2020.09.10: maxDeltaTime在非0位时,有可能取到0的BUG (记录lastIndex,但并未彻底解决) (发现NL时为0正常) T;
 *      2020.09.15: 多个conFos,却只记录了一个lastIndex导致错乱找不到findIndex的bug; T
 *      2023.11.18: 修复判断M1{↑饿-16}和A13(饿16,7)的抽具象关系因mIsC算法BUG导致总失败,导致取deltaTime为0;
 *  @todo
 *      2021.01.21: 当构建SPFo时,conFos中可能不包含所有的deltaTime (比如乌鸦带交警时,车不敢撞,具象时序中是无交警的);
 *      2023.11.18: 随后废弃此方法,改到AIAbsFoManager.create_NoRepeat()中根据indexDic计算deltaTimes (现在这么做也没啥问题,先不改,后需要时再改);
 */
+(NSMutableArray*) getDeltaTimes:(NSArray*)conFos absFo:(AIFoNodeBase*)absFo{
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!ARRISOK(conFos) || !absFo) return result;
    
    //2. 提取 (absFo有可能本来deltaTimes不为空,也要参与到竞争Max(A,B)中来;
    NSMutableDictionary *lastIndexDic = [[NSMutableDictionary alloc] init];
    for (NSInteger i = 0; i < absFo.count; i++) {
        AIKVPointer *absAlg_p = ARR_INDEX(absFo.content_ps, i);
        
        //3. 从每个conFo中找到对应absAlg_p的元素下标;
        double maxDeltaTime = 0;
        for (AIFoNodeBase *conFo in conFos) {
            
            //a. 找到当前所处下标;
            NSData *lastIndexKey = OBJ2DATA(conFo.pointer);
            NSInteger lastIndex = [NUMTOOK_DV([lastIndexDic objectForKey:lastIndexKey], -1) integerValue];
            BOOL isHNGL = [TOUtils isHNGL:absAlg_p];
            NSInteger findIndex = [TOUtils indexOfAbsItem:absAlg_p atConContent:conFo.content_ps layerDiff:isHNGL ? 2 : 1 startIndex:lastIndex + 1 endIndex:NSIntegerMax];
            if (findIndex != -1) {
                //b. 将有效间隔取出,并提取最大的deltaTime;
                double sumDeltaTime = [TOUtils getSumDeltaTime:conFo startIndex:lastIndex endIndex:findIndex];
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
                if (![TOUtils isHNGL:absFo.pointer] && ([absFo.content_ps indexOfObject:absAlg_p] == absFo.count - 1))
                    WLog(@"末帧没找着detailTime AbsA:%@ (%ld,%ld)\n\tAbsF:%@\n\tConF:%@",AlgP2FStr(absAlg_p),(long)findIndex,(long)lastIndex,Fo2FStr(absFo),Fo2FStr(conFo));
            }
        }
        
        //4. 首条时加入0,否则加入maxDeltaTime;
        if (i == 0) {
            [result addObject:@(0.0f)];
        }else{
            [result addObject:@(maxDeltaTime)];
        }
    }
    [AITest test31:result];
    return result;
}

+(NSMutableArray*) convertOrder2Alg_ps:(NSArray*)order{
    //1. 数据准备
    NSMutableArray *result = [[NSMutableArray alloc] init];
    order = ARRTOOK(order);
    
    //2. 提取返回
    for (AIShortMatchModel_Simple *simple in order) {
        if (simple.alg_p) [result addObject:simple.alg_p];
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
            NSTimeInterval deltaTime = simple.isTimestamp ? MAX(simple.inputTime - lastInputTime, 0) : simple.inputTime;
            [result addObject:@(deltaTime)];
        }
        lastInputTime = simple.inputTime;
    }
    
    [AITest test31:result];
    return result;
}

@end
