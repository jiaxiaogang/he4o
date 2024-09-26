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
    
    //6. 支持下R子任务,有R子任务时,优先推进解决R子任务 (参考33075-TODO1);
    NSArray *sortSubRDemands = [SMGUtils sortBig2Small:bestCanset.subDemands compareBlock:^double(ReasonDemandModel *obj) {
        return [AIScore progressScore4Demand_Out:obj];
    }];
    for (ReasonDemandModel *subRDemand in sortSubRDemands) {
        if (subRDemand.status == TOModelStatus_Finish) continue;
        
        //7. 把第一个,执行:plan4Cansets(subRDemand);
        [self plan4Cansets:subRDemand complate:complate prefixNum:prefixNum + 2];
    }
    
    //6. 三种情况,分别走三块不同逻辑;
    AIFoNodeBase *bestCansetFo = [SMGUtils searchNode:bestCanset.cansetFrom];
    BOOL actYes4Mv = bestCanset.cansetActIndex >= bestCansetFo.count;
    TOAlgModel *frameAlg = bestCanset.getCurFrame;
    BOOL havIndexDic = [bestCanset.transferXvModel.sceneToCansetToIndexDic.allValues containsObject:@(bestCanset.cansetActIndex)];//当前帧在canset与scene有映射;
    if (actYes4Mv) {
        //TODOTOMORROW20240830: 明天继续测下这里:
        //1. 像这种 "flt2 R行为化末帧下标 (4/4)  from时序:F6341[M1{↑饿-16},A51(,果),飞↑,A51(,果)] fromDemand:F9107"
        //2. 到了末帧的,看有没等待反馈,然后有没因反馈的顺利与否,有没有对末帧计SPEFF;
        //3. 看这个日志应该是有计: "flt4b spIndex:4 -> (好) S1P0->S1P1 F6341[M1{↑饿-16},A51(,果),飞↑,A51(,果)]"
        //4. 再往后,测下别的...看有没啥问题;
        
        
        //一. ================================ 末帧 ================================
        
        //说明: bestCanset已经执行完,它只是在等待看baseRDemand的末帧mv是否会反馈;
        if (bestCanset.feedbackMvAndPlus) {
            //11. 好的mv反馈,说明当前rRootDemand被解决了,不需要再决策 => 继续尝试下一root;
            return false;
        } else if (bestCanset.feedbackMvAndSub) {
            //12. 坏的mv反馈: 如果是持续性任务,则该canset失败,继续尝试下一canset;
            if ([ThinkingUtils isContinuousWithAT:baseDemand.algsType]) {
                bestCanset.status = TOModelStatus_ActNo;
                return [self plan4Cansets:baseDemand complate:complate prefixNum:prefixNum];
            }
            //13. 坏的mv反馈: 如果非持续性任务,则该root失败 => 继续尝试下一root;
            else {
                return false;
            }
        } else if (!bestCanset.actYesed && !bestCanset.feedbackMv) {
            //14. 还在等待mv反馈中 => 则继续等待即可;
            return true;
        } else if (bestCanset.actYesed && !bestCanset.feedbackMv) {
            //15. 等待结束,避免负mv成功,则该任务完成 => 继续尝试下一root;
            return false;
        }
    } else if (havIndexDic) {
        //二. ================================ 中间帧_避免弄巧成拙 (参考33075-TODO3) ================================
        //21. 避免弄巧成拙: 判断当前帧 与 场景 = 有映射;
        //  a. 有映射时: 避免行为化转H任务;
        //  b. 有映射时: 避免行为化输出行为;
        //  c. 有映射时: 不构建actYes触发器 (不接S反馈,但在feedbackTOR里也会接P反馈);
        //2024.09.26: 说明: 相当于把过去的弄巧成拙代码,挪到此处来执行,好处是避免一轮轮TO去action里去试,不通过的在这里就过滤掉了;
        
        //22. 有映射时-继续静默等待即可 (参考33075-TODO3 & 回顾);
        return true;
    } else if (frameAlg.content_p.isOut) {
        
        //二. ================================ 中间帧_Out ================================
        
        //21. actYesed && !feedbackAlg -> 当前行为输出到期也没等到反馈: 把当前bestCanset否掉,重新找出下一个bestCanset,转下一个canset;
        if (frameAlg.actYesed && !frameAlg.feedbackAlg) {
            bestCanset.status = TOModelStatus_ActNo;
            return [self plan4Cansets:baseDemand complate:complate prefixNum:prefixNum];
        }
        
        //22. feedbackAlg -> 则应该在feedbackTOR()中已经转了下一帧,但如果这里如果取curFrame,发现有反馈,还没转,则先不管它,啥不也不执行吧,等它自己转下一帧 (不管什么状态,只要已经反馈了,就都走这里);
        if (frameAlg.feedbackAlg) {
            ELog(@"查下,为什么这里algModel已经有了反馈,但却没转下一帧,curFrame仍然是它");
            return true;
        }
        
        //23. 等待中的isOut帧,没有subH,只需要等肢体动作执行完成再转输入rInput后,会反馈成功,还在等待说明还没触发,继续等着即可 (行为输出也是需要时间的,比如飞要0.2s,再静默等等) (参考3301a-调试情况2);
        if (!frameAlg.actYesed) {
            return true;
        }
        
    } else {
        //三. ================================ 中间帧_非Out ================================
        
        //31. actYesed && !feedbackAlg -> 当前行为输出到期也没等到反馈: 把当前bestCanset否掉,重新找出下一个bestCanset,转下一个canset;
        if (frameAlg.actYesed && !frameAlg.feedbackAlg) {
            bestCanset.status = TOModelStatus_ActNo;
            return [self plan4Cansets:baseDemand complate:complate prefixNum:prefixNum];
        }
        
        //32. feedbackAlg -> 则应该在feedbackTOR()中已经转了下一帧,但如果这里如果取curFrame,发现有反馈,还没转,则先不管它,啥不也不执行吧,等它自己转下一帧 (不管什么状态,只要已经反馈了,就都走这里);
        if (frameAlg.feedbackAlg) {
            ELog(@"查下,为什么这里algModel已经有了反馈,但却没转下一帧,curFrame仍然是它");
            return true;
        }
        
        //33. 非Out帧等待中,则尝试subH求解 -> 防空检查 (非输出帧的subH不应该为空,没有hDemand是BUG,因为algModel初始时,就有hDemand了) (subH为空时,那这条Canset失败,继续尝试baseDemand的下一条 (逐条尝试))
        HDemandModel *subHDemand = ARR_INDEX(frameAlg.subDemands, 0);
        if (!subHDemand) {
            bestCanset.status = TOModelStatus_WithOut;
            return [self plan4Cansets:baseDemand complate:complate prefixNum:prefixNum];//返回失败: 继续尝试下一个demand;
        }
        
        //34. subH没求解过,则尝试对subH求解: 成功: 当前条 -> hDemand没初始化过,直接return转hSolution为它求解;
        if (Log4Plan) NSLog(@"%@itemHDemand -> 执行:%@",[HeLogUtil getPrefixStr:prefixNum + 1],ShortDesc4Pit([HeLogUtil demandLogPointer:subHDemand]));
        if (!subHDemand.alreadyInitCansetModels) {
            if (Log4Plan) NSLog(@"planV2 success3 执行subHDemand的求解:%@",ShortDesc4Pit(subHDemand.baseOrGroup.content_p));
            [self printFinishLog:subHDemand];
            TCResult *re = [TCSolution solutionV2:subHDemand];
            complate(re);
            return true;
        }
        
        //35. subH求解过,则subH继续深入下一层: 继续: 下一层 -> 当前条继续向枝叶规划;
        BOOL success = [self plan4Cansets:subHDemand complate:complate prefixNum:prefixNum + 2];
        
        //36. 如果subH求解全失败了,则咱不解了,咱等着即可,看它能不能自行反馈到,则继续等 -> 如果bestCanset枝叶全失败了,还是静默等等状态,直接返回成功,啥也不用干 (比如: 等饭熟,有苹果也会先吃一个垫垫);
        if (!success && !frameAlg.actYesed) {
            if (Log4Plan) NSLog(@"planV2 success4 继续bestCanset的静默等待:%@",ShortDesc4Pit(bestCanset.cansetFrom));
            [self printFinishLog:bestCanset];
            complate([[[TCResult new:true] mkMsg:@"TCPlan规划: 静默等待状态,继续等即可"] mkStep:11]);
            return true;
        }
        
        //37. 如果subH求解全失败了,它的等待时间也结束了,则当前bestCanset计为失败: 驳回: 下一条 -> 当前hDemand的枝叶全失败了,继续尝试baseDemand的下一条 (逐条尝试);
        if (!success && frameAlg.actYesed) {
            bestCanset.status = TOModelStatus_ActNo;
            return [self plan4Cansets:baseDemand complate:complate prefixNum:prefixNum];
        }
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
    NSLog(@"一. planfinish %@工作记忆活跃线: %@",FltLog4YonBanYun(0),ARRTOSTR(rootToSub, @"", @" -> "));
    
    if (!Log4Plan) return;
    NSLog(@"---------------------------------------------------------- FINISH\n");
    NSLog(@"二. 取得最终胜利的sub到root结构: %@",endBranch ? [TOModelVision cur2Root:endBranch] : nil);
    DemandModel *root = [TOUtils getRootDemandModelWithSubOutModel:endBranch];
    NSLog(@"三. 结果所在ROOT:%@ (%@) %@",Pit2FStr([HeLogUtil demandLogPointer:root]),[SMGUtils date2Str:kHHmmss timeInterval:root.initTime],[TOModelVision cur2Sub:root]);
}

@end
