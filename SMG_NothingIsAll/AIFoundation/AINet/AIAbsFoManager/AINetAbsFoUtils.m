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
 *  @todo
 *      2021.01.21: 当构建SPFo时,conFos中可能不包含所有的deltaTime (比如乌鸦带交警时,车不敢撞,具象时序中是无交警的);
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
        if ([absFo.content_ps indexOfObject:absAlg_p] == 0) {
            [result addObject:@(0.0f)];
        }else{
            [result addObject:@(maxDeltaTime)];
            if (maxDeltaTime <= 0) {
                NSLog(@"TODOTOMORROW20231117: 跑步骤4时,这里有可能为0");
                [self getDeltaTimes:conFos absFo:absFo];//重新跑下,调试下原因;
                [self getDeltaTimes:conFos absFo:absFo];//重新跑下,调试下原因;
                [self getDeltaTimes:conFos absFo:absFo];//重新跑下,调试下原因;
                [self getDeltaTimes:conFos absFo:absFo];//重新跑下,调试下原因;
                [self getDeltaTimes:conFos absFo:absFo];//重新跑下,调试下原因;
                
                //输入ProtoFo:F9352[A9339(向347,距131,果),M1{↑饿-16},A9347(距43,向300,棒),A9339(向347,距131,果)]->M1{↑饿-16}
                //然后在以下两个conFos中找A13(饿16,7);
                //con1: F9352[A9339(向347,距131,果),M1{↑饿-16},A9347(距43,向300,棒),A9339(向347,距131,果)]->M1{↑饿-16}
                //con2: F4152[A4137(向348,距114,果),M1{↑饿-16},A4147(向289,距27,棒),A4137(向348,距114,果)]
                
                /*
                 130593 [10:06:49:193 TI           TCInput.m 102] #########################################################################################################
                 130594 [10:06:49:193 TI           TCInput.m 102]                                                 <input P>
                 130595 [10:06:49:193 TI           TCInput.m 102] #########################################################################################################
                 130596 [10:06:49:194 TI           TCDebug.m 117] 循环计数更新:1353 用时:7570 ========================================
                 130597 [10:06:49:194 TI           TCDebug.m  61] [TCPlan.m => TCInput.m] 操作计数:22905 用时:******* (721) (读:0 写:0)
                 130598 [10:06:49:211 TI     TCRecognition.m  35]
                 130599 [10:06:49:211 TI     TCRecognition.m  35]
                 130600 [10:06:49:211 TI     TCRecognition.m  35] =============================== 1353 时序识别 ===============================
                 130601 [10:06:49:211 TI     TCRecognition.m  35] protoFo4PInput:F9353[M1{↑饿-16},A9347(距43,向300,棒),A9339(向347,距131,果),M1{↑饿-16}]
                 130602 [10:06:49:384 TI           TIUtils.m 445]
                 130603 [10:06:49:384 TI           TIUtils.m 445] 时序识别结果 P(0条) R(0条)
                 130604 [10:06:49:386 TI        TCLearning.m  35]
                 130605 [10:06:49:386 TI        TCLearning.m  35]
                 130606 [10:06:49:386 TI        TCLearning.m  35] =============================== 1353 pLearning ===============================
                 130607 [10:06:49:386 TI        TCLearning.m  35] 输入ProtoFo:F9352[A9339(向347,距131,果),M1{↑饿-16},A9347(距43,向300,棒),A9339(向347,距131,果)]->M1{↑饿-16}
                 130608 [10:06:49:387 TI         AIAnalogy.m 191] > 当前A9339<>比A1642<>的缺口:1.00 / 总缺口1.00 = 当前责任1.00
                 130609 [10:06:49:391 TI         AIAnalogy.m 137] 偏移mvDeltaTime (从7.08到7.08) (总强度:14 con1:7.57 con2:6.59)
                 130610 [10:06:49:395 TI         AIAnalogy.m 149] 1. 新proto: F9352[A9339(向347,距131,果),M1{↑饿-16},A9347(距43,向300,棒),A9339(向347,距131,果)]
                 130611 [10:06:49:395 TI         AIAnalogy.m 149] 2. 与ass: F1645[M1{↑饿-16},A1642(向13,距162,皮果)]
                 130612 [10:06:49:395 TI         AIAnalogy.m 149] 3. 外类比构建时序: F8460[A13(饿16,7),A8459(向13,距162,果)]->{M4{↑饿-16}} from: (protoFo(1):assFo(7))
                 130613 [10:06:49:396 TI         AIAnalogy.m 191] > 当前A9339<>比A1529<>的缺口:1.00 / 总缺口1.00 = 当前责任1.00
                 130614 [10:06:49:401 TI         AIAnalogy.m 137] 偏移mvDeltaTime (从7.15到7.15) (总强度:4 con1:7.57 con2:6.72)
                 130615 [10:06:49:404 TI         AIAnalogy.m 149] 1. 新proto: F9352[A9339(向347,距131,果),M1{↑饿-16},A9347(距43,向300,棒),A9339(向347,距131,果)]
                 130616 [10:06:49:404 TI         AIAnalogy.m 149] 2. 与ass: F1532[M1{↑饿-16},A1529(距92,向107,皮果)]
                 130617 [10:06:49:404 TI         AIAnalogy.m 149] 3. 外类比构建时序: F8756[A13(饿16,7),A8755(距92,向107,果)]->{M4{↑饿-16}} from: (protoFo(1):assFo(2))
                 130618 [10:06:49:405 TI         AIAnalogy.m 191] > 当前A9339<距131>比A4137<距114>的缺口:0.06 / 总缺口0.06 = 当前责任0.91
                 130619 [10:06:49:412 TI  AIAlgNodeManager.m  92] 构建新概念:A9354 fromConAlgs:(A9339,A4137)
                 130620 [10:06:49:415 TI         AIAnalogy.m 191] > 当前A9347<向300>比A4147<向289>的缺口:0.06 / 总缺口0.11 = 当前责任0.53
                 130621 [10:06:49:423 TI  AIAlgNodeManager.m  92] 构建新概念:A9355 fromConAlgs:(A9347,A4147)
                 130622 [10:06:49:427 TI         AIAnalogy.m 191] > 当前A9339<距131>比A4137<距114>的缺口:0.06 / 总缺口0.06 = 当前责任0.91
                 130623 [10:16:32:848 TI   AINetAbsFoUtils.m  68] TODOTOMORROW20231117: 跑步骤4时,这里有可能为0
                 130624 [10:16:32:849 MA           RTModel.m 215] ----> 强化训练_思维负载(96) -> 等待
                 */
                
                /*
                 //在A13(饿16,7)fo和assFo的第二帧,都与A13匹配不上...导致的;
                 //> 经调试,如果用indexDic的话,四帧是全能匹配上的,并且没有deltaTime为0的情况;
                 //> 回头可以查一下,如果像这种mvAlg的抽象的情况,是否抽具象是取不到mIsC的...
                 
                 
                 
                 ----------- 外类比(普) -----------
                 fo:F10103[A10090(向21,距85,果),M1{↑饿-16},A10098(向72,距30,棒),A10090(向21,距85,果)]
                 assFo:F8455[A8442(向14,距162,果),M1{↑饿-16},A8450(向24,距88,棒),A8442(向14,距162,果)]
                 proto的第3: A10090 类比 ass的第3: A8442 (成功)
                 > 当前A10090<距85>比A8442<距162>的缺口:0.26 / 总缺口0.30 = 当前责任0.87
                 构建新概念:A10105 fromConAlgs:(A10090,A8442)
                 proto的第2: A10098 类比 ass的第2: A8450 (成功)
                 > 当前A10098<向72>比A8450<向24>的缺口:0.27 / 总缺口0.46 = 当前责任0.58
                 构建新概念:A10106 fromConAlgs:(A10098,A8450)
                 proto的第1: A1 类比 ass的第1: A1 (成功)
                 proto的第0: A10090 类比 ass的第0: A8442 (成功)
                 > 当前A10090<距85>比A8442<距162>的缺口:0.26 / 总缺口0.30 = 当前责任0.87
                 
                 
                 
                 */
            }
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
