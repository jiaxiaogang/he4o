//
//  TCAction.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCAction.h"
#import "TOFoModel.h"

@implementation TCAction

/**
 *  MARK:--------------------新螺旋架构action--------------------
 *  @desc 解决方案fo即(加工目标),转_Fo()行为化 (参考24132-行为化1);
 *  @param foModel : notnull
 *  @version
 *      2021.11.17: 需调用者自行对foModel进行FRS稳定性竞争评价,本方法不再进行 (因为fo间的竞争,需由外界,fo内部问题在此方法内解决);
 *      2021.11.25: 迭代为功能架构 (参考24154-单轮示图);
 *      2021.11.25: H类型在Action后,最终行为化完毕后,调用hActYes后,在feedbackTOR反馈,并重组反思,下轮循环;
 *      2021.11.xx: 废弃outReflect反思功能 (全部待到inReflect统一再反思);
 *      2021.11.28: 时间紧急评价,改为: 紧急情况 = 解决方案所需时间 > 父任务能给的时间 (参考24171-7);
 *      2021.12.01: 支持hAction;
 *      2021.12.26: action将foModel执行到spIndex之前一帧 (25032-4);
 *      2021.12.26: hSolution达到目标帧转hActYes的处理 (参考25031-9);
 *  @callers : 可以供_Demand和_Hav等调用;
 */
+(void) action:(TOFoModel*)foModel{
    
    //1. 时间紧急评价: 紧急情况 = 解决方案所需时间 > 父任务能给的时间 (参考:24057-方案3,24171-7);
    BOOL rIsTooLate = false;
    ReasonDemandModel *rDemand = (ReasonDemandModel*)foModel.baseOrGroup;
    if (ISOK(rDemand, ReasonDemandModel.class)) {
        //a. 取解决方案所需时间;
        AIFoNodeBase *solutionFo = [SMGUtils searchNode:foModel.content_p];
        double needTime = [TOUtils getSumDeltaTime2Mv:solutionFo cutIndex:foModel.actionIndex];
        
        //b. 取父任务能给的时间;
        double giveTime = [TOUtils getSumDeltaTime2Mv:rDemand.mModel.matchFo cutIndex:rDemand.mModel.cutIndex2];
        
        //c. 判断是否时间紧急;
        rIsTooLate = needTime > giveTime;
        NSLog(@"紧急状态 (%d) = 方案所需要时间:%f > 任务能给时间:%f",rIsTooLate,needTime,giveTime);
    }
    
    //2. 时间紧急的结果 (当前解决方案直接论为失败);
    if (rIsTooLate) {
        foModel.status = TOModelStatus_ActNo;
        [TCScore score];//决策受阻且无输出时,直接下轮循环跳到决策之始;
        return;
    }
    
    //1. 数据准备
    AIFoNodeBase *curFo = [SMGUtils searchNode:foModel.content_p];
    OFTitleLog(@"行为化Fo", @"\n时序:%@->%@ 类型:(%@)",Fo2FStr(curFo),Mvp2Str(curFo.cmvNode_p),curFo.pointer.typeStr);
    
    //4. 跳转下帧,
    if (foModel.actionIndex < foModel.targetSPIndex - 1) {
        //a. Alg转移 (下帧)
        foModel.actionIndex ++;
        AIKVPointer *move_p = ARR_INDEX(curFo.content_ps, foModel.actionIndex);
        TOAlgModel *moveAlg = [TOAlgModel newWithAlg_p:move_p group:foModel];
        NSLog(@"_Fo行为化第 %ld/%ld 个: %@",(long)foModel.actionIndex,(long)curFo.count,Fo2FStr(curFo));
        [TCOut out:moveAlg];
    }else{
        //c. 成功,递归 (参考流程控制Finish的注释version-20200916 / 参考22061-7);
        foModel.status = TOModelStatus_ActYes;
        NSLog(@"_Fo行为化: Finish %ld/%ld 到ActYes",(long)foModel.actionIndex,(long)curFo.count);
        if (ISOK(foModel.baseOrGroup, ReasonDemandModel.class)) {
            [TCActYes rActYes:foModel];
        }else if(ISOK(foModel.baseOrGroup, HDemandModel.class)){
            //d. h目标帧只需要等 (转hActYes) (参考25031-9);
            foModel.actionIndex ++;
            AIKVPointer *hTarget_p = ARR_INDEX(curFo.content_ps, foModel.actionIndex);
            TOAlgModel *hTargetAlg = [TOAlgModel newWithAlg_p:hTarget_p group:foModel];
            hTargetAlg.status = TOModelStatus_ActYes;
            [TCActYes hActYes:hTargetAlg];
        }
    }
}

@end
