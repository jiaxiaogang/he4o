//
//  TCPlan.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/15.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCPlan.h"

@implementation TCPlan

+(void) planFromIfTCNeed {}

+(TCResult*) planFromTOQueue {
    return [self planV2];
}

//MARK:===============================================================
//MARK:                     < TCPlanV2 >
//MARK:===============================================================

/**
 *  MARK:--------------------新螺旋架构TCPlan规划算法 (参考32072-模型图)--------------------
 *  @desc
 *      1. 如果单条失败就尝试下一条,找下一个baseDemand.bestCanset (重新实时竞争,得出最佳解);
 *      2. 如果单条成功就继续下一层,找下一个subDemand.bestCanset (继续实时竞争,得出最佳解);
 *      3. 如果全部失败就退至上一层,找上一个otherBaseDemand (重新实时竞争,得出另一个最佳解);
 */
+(TCResult*) planV2{
    //1. 取当前任务 (参考24195-1);
    [theTC updateOperCount:kFILENAME min:1200];
    Debug();
    //OSTitleLog(@"TCPlan");
    __block TCResult *result = nil;
    [self plan4RDemands:^(TCResult *_result) {
        result = _result;
    }];
    if (!result) result = [[[TCResult new:false] mkMsg:@"TCPlanV2返回了nil"] mkStep:10];
    
    //3. 转给TCPlan取最优路径;
    DebugE();
    return result;
}

/**
 *  MARK:--------------------Roots竞争排序 & 逐条尝试 (参考32072-模型图)--------------------
 *  @param complate 把result传回来;
 */
+(BOOL) plan4RDemands:(void(^)(TCResult*))complate {
    //1. Roots竞争排序;
    NSArray *roots = [theTC.outModelManager getCanDecisionDemandV3];
    if (Log4Plan && ARRISOK(roots)) NSLog(@"\n---------------------------------------------------------- START");
    
    //2. 逐条尝试: 依次对root向下尝试或淘汰;
    for (ReasonDemandModel *root in roots) {
        //3. 驳回: 下一条 -> 已完成 或 已无解,则尝试下一条Root;
        if (root.status == TOModelStatus_Finish || root.status == TOModelStatus_WithOut || root.expired4PInput) continue;
        NSLog(@"%@itemRoot -> 执行:%@",[HeLogUtil getPrefixStr:0],ShortDesc4Pit([HeLogUtil demandLogPointer:root]));
        
        //4. 成功: 当前条 -> 未初始化过,则直接进行solution;
        if (!root.alreadyInitCansetModels) {
            //> rDemand没初始化过,直接return转rSolultion为它求解;
            if (Log4Plan) NSLog(@"planV2 sucess1 执行rootRDemand求解:%@",ShortDesc4Pit(root.protoOrRegroupFo));
            [self printFinishLog:root];
            TCResult *re = [TCSolution solutionV2:root];
            complate(re);
            return true;
        }
        
        //5. 继续: 下一层 -> 当前条继续向枝叶规划;
        BOOL success = [self plan4Cansets:root complate:complate prefixNum:1];
        if (success) {
            return true;
        }
        
        //6. 未成功,则继续尝试下一条;
    }
    
    //7. 全未成功,则返回false;
    if (Log4Plan && ARRISOK(roots)) NSLog(@"planV2 final failure");
    return false;
}

/**
 *  MARK:--------------------Cansets竞争排序 & 逐条尝试 (参考32072-模型图)--------------------
 *  @result 返回false则会继续尝试下一个root,返回true则中断尝试(要么已经成功执行了,要么就是这一轮啥也不必执行);
 */
+(BOOL) plan4Cansets:(DemandModel*)baseDemand complate:(void(^)(TCResult*))complate prefixNum:(int)prefixNum {
    //说明: 现在Cansets在实时竞争后,转实,以及反思,可行性检查,等都封装在实时竞争算法中了 (所以这里不是for循环的写法,当逐条尝试不通过时,重新调用下实时竞争算法吧);
    //1. ========== 先实时竞争 ==========
    TOFoModel *bestCanset = [TCSolutionUtil realTimeRankCansets:baseDemand zonHeScoreBlock:nil debugMode:false];
    if (Log4Plan) NSLog(@"%@item评分cansets竞争 -> 胜者:%@",[HeLogUtil getPrefixStr:prefixNum],Pit2FStr(bestCanset.cansetFrom));
    
    //2. ========== 依次对canset向下尝试或淘汰 ==========
    //3. 驳回: 上一层 -> 发现无解,所有Cansts全失败了,退回上一层,重新实时竞争,继续尝试下一条;
    if (!bestCanset) {
        //> 一个值都没了,则WithOut失败了 (改为WithOut继续尝试下一个rDemand);
        baseDemand.status = TOModelStatus_WithOut;
        return false;//返回失败: 继续尝试下一个demand;
    }
    
    //5. 成功: 当前条 -> 当前Canset战胜了,不过还没行为化过,所以直接调用行为化action();
    if (bestCanset.alreadyActionActIndex < bestCanset.cansetActIndex) {
        //> 这里bestCanset的actIndex还没行为化过,所以不可能有subHDemand,此时可以先调用下[TCAction action:];
        if (Log4Plan) NSLog(@"planV2 success2 执行bestCanset的求解:%@ %ld %ld",ShortDesc4Pit(bestCanset.cansetFrom),bestCanset.alreadyActionActIndex,bestCanset.cansetActIndex);
        [self printFinishLog:bestCanset];
        TCResult *re = [TCSolution solutionV2:bestCanset];
        complate(re);
        return true;
    }
    
    //TODOTOMORROW20240827: 如果bestCanset已经执行完了呢?它只是在等待看baseRDemand的末帧mv是否会反馈;
    
    
    
    //11. actYesed && !feedbackAlg -> 当前bestCanset最后也没等到反馈,计为失败,转下一个canset;
    //11. 不管是不是行为输出,只要到期还没收到反馈,都算失败了: 把当前bestCanset否掉,重新找出下一个bestCanset;
    TOAlgModel *frameAlg = bestCanset.getCurFrame;
    if (frameAlg.actYesed && !frameAlg.feedbackAlg) {
        bestCanset.status = TOModelStatus_ActNo;
        return [self plan4Cansets:baseDemand complate:complate prefixNum:prefixNum];
    }
    
    //12. feedbackAlg -> 则应该在feedbackTOR()中已经转了下一帧,但如果这里如果取curFrame,发现有反馈,还没转,则先不管它,啥不也不执行吧,等它自己转下一帧;
    //12. 不管是不是还在静默等待,只要已经反馈了,就都走这里;
    if (frameAlg.feedbackAlg) {
        ELog(@"查下,为什么这里algModel已经有了反馈,但却没转下一帧,curFrame仍然是它");
        return true;
    }
    
    //13. ================ isOut等待中,则继续等待即可 ================
    //13. isOut && actYesing -> 行为输出还没收到反馈,并且还在等待中,说明还没触发,则继续等待反馈即可 (行为输出也是需要时间的,比如飞要0.2s,再静默等等);
    //13. 当是行为输出帧时,它没有subH,此时只需静等,等肢体动作执行完成,并在commitOutputLog()后,成功反馈即可,而不必再执行solution() (参考3301a-调试情况2);
    if (frameAlg.content_p.isOut && !frameAlg.actYesed) {
        return true;
    }
    
    //21. ================ 非Out等待中,则尝试subH求解 ================
    //21. !isOut && actYesing -> 继续执行subH求解;
    //22. ===> 防空检查: 非输出帧的subH不应该为空: 驳回: 下一条 -> H异常为空?那这条Canset失败,继续尝试baseDemand的下一条 (逐条尝试);
    HDemandModel *subHDemand = ARR_INDEX(frameAlg.subDemands, 0);
    if (!subHDemand) {
        //> 没有hDemand,则应该是BUG,因为algModel初始时,就有hDemand了;
        bestCanset.status = TOModelStatus_WithOut;
        return [self plan4Cansets:baseDemand complate:complate prefixNum:prefixNum];//返回失败: 继续尝试下一个demand;
    }
    
    //23. ===> subH没求解过,则尝试对subH求解: 成功: 当前条 -> 未初始化过,则直接进行solution;
    if (Log4Plan) NSLog(@"%@itemHDemand -> 执行:%@",[HeLogUtil getPrefixStr:prefixNum + 1],ShortDesc4Pit([HeLogUtil demandLogPointer:subHDemand]));
    if (!subHDemand.alreadyInitCansetModels) {
        //> hDemand没初始化过,直接return转hSolution为它求解;
        if (Log4Plan) NSLog(@"planV2 success3 执行subHDemand的求解:%@",ShortDesc4Pit(subHDemand.baseOrGroup.content_p));
        [self printFinishLog:subHDemand];
        TCResult *re = [TCSolution solutionV2:subHDemand];
        complate(re);
        return true;
    }
    
    //24. ===> subH求解过,则subH继续深入下一层: 继续: 下一层 -> 当前条继续向枝叶规划;
    BOOL success = [self plan4Cansets:subHDemand complate:complate prefixNum:prefixNum + 2];
    
    //25. ===> 如果subH求解全失败了,则咱不解了,咱等着即可,看它能不能自行反馈到: 等待: 继续等 -> 如果bestCanset枝叶全失败了,而bestCanset自己是ActYes状态,直接返回成功,啥也不用干;
    //说明: 此处应该是actYes状态,且子全无解时,再选择等待? (比如: 等饭熟,有苹果也会先吃一个垫垫);
    if (!success && !frameAlg.actYesed) {
        if (Log4Plan) NSLog(@"planV2 success4 继续bestCanset的静默等待:%@",ShortDesc4Pit(bestCanset.cansetFrom));
        [self printFinishLog:bestCanset];
        complate([[[TCResult new:true] mkMsg:@"TCPlan规划: 静默等待状态,继续等即可"] mkStep:11]);
        return true;
    }
    
    //26. ===> 如果subH求解全失败了,它的等待时间也结束了,则当前bestCanset计为失败: 驳回: 下一条 -> 当前hDemand的枝叶全失败了,继续尝试baseDemand的下一条 (逐条尝试);
    if (!success && frameAlg.actYesed) {
        bestCanset.status = TOModelStatus_ActNo;
        return [self plan4Cansets:baseDemand complate:complate prefixNum:prefixNum];
    }
    return true;
}

+(void) printFinishLog:(TOModelBase*)endBranch {
    //把每一次TCPlan完成后的: root->sub打印出来 (参考32114-方案3);
    NSArray *subToRoot = [SMGUtils convertArr:[TOUtils getBaseOutModels_AllDeep:endBranch] convertBlock:^id(TOModelBase *obj) {
        if (ISOK(obj, TOFoModel.class)) {
            return STRFORMAT(@"F%ld",((TOFoModel*)obj).cansetFrom.pointerId);
        } else if (ISOK(obj, TOAlgModel.class)) {
            return STRFORMAT(@"A%ld",((TOAlgModel*)obj).content_p.pointerId);
        } else if (ISOK(obj, ReasonDemandModel.class)) {
            return STRFORMAT(@"(R)F%ld",((ReasonDemandModel*)obj).protoOrRegroupFo.pointerId);
        }
        return nil;
    }];
    NSArray *rootToSub = [SMGUtils reverseArr:subToRoot];
    NSLog(@"planfinish %@工作记忆活跃线: %@",FltLog4YonBanYun(0),ARRTOSTR(rootToSub, @"", @" -> "));
    
    if (!Log4Plan) return;
    NSLog(@"---------------------------------------------------------- FINISH\n");
    NSLog(@"fltx1 取得最终胜利的sub到root结构: %@",endBranch ? [TOModelVision cur2Root:endBranch] : nil);
    DemandModel *root = [TOUtils getRootDemandModelWithSubOutModel:endBranch];
    NSLog(@"fltx2 TCPlan结果所在ROOT:%@ (%@) %@",Pit2FStr([HeLogUtil demandLogPointer:root]),[SMGUtils date2Str:kHHmmss timeInterval:root.initTime],[TOModelVision cur2Sub:root]);
}

@end
