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
 *      2021.11.28: 时间不急评价,改为: 紧急情况 = 解决方案所需时间 > 父任务能给的时间 (参考24171-7);
 *      2021.12.01: 支持hAction;
 *      2021.12.26: action将foModel执行到spIndex之前一帧 (25032-4);
 *      2021.12.26: hSolution达到目标帧转hActYes的处理 (参考25031-9);
 *      2021.12.26: 下标不急(弄巧成拙)评价,支持isOut=true的情况 (参考25031-10);
 *      2022.05.19: 废弃ARSTime评价 (参考26051);
 *      2022.12.09: 修复少执行了一帧的问题 (后16号又发现多了一帧,把target也执行了,这里9号时的情况已经忘了);
 *      2022.12.16: 修复多执行了一帧的问题 (即target帧不必行为化,自然发生即可);
 *      2023.07.08: 为避免输出行为捡了芝麻丢了西瓜,在行为化之前,先调用一下反思 (参考30054);
 *      2023.08.21: 将反思通过与否保留下来,用于后面决策时激活其子R还是子H任务做判断依据 (参考30114-todo1);
 *      2024.01.25: 把cutIndex++和挂载TOAlgModel前置到构建CansetModel后就执行 (参考31073-TODO2g);
 *  @callers : 可以供_Demand和_Hav等调用;
 */
+(TCResult*) action:(TOFoModel*)foModel{
    //1. 数据准备
    AIFoNodeBase *curFo = [SMGUtils searchNode:foModel.transferSiModel.canset];
    
    //2. 因root状态中断检查;
    ReasonDemandModel *root = (ReasonDemandModel*)[TOUtils getRootDemandModelWithSubOutModel:foModel];
    NSLog(@"action执行中断原因: %@ %d",TOStatus2Str(root.status),root.expired4PInput);
    if (root.status == TOModelStatus_Finish || root.status == TOModelStatus_WithOut || root.expired4PInput) {
        return [[[TCResult new:false] mkMsg:@"action所在的root已经无效,无需执行"] mkStep:30];
    }
    
    //2. 标记cansetActIndex帧已经执行过action();
    foModel.alreadyActionActIndex = foModel.cansetActIndex;
    NSLog(@"set alreadyActionActIndex:%ld from:F%ld.A%ld",foModel.cansetActIndex,foModel.cansetFrom.pointerId,foModel.getCurFrame.content_p.pointerId);
    
    //3. 进行反思识别,如果不通过时,回到TCScore可能会尝试先解决子任务,通过时继续行为化 (参考30054-todo7);
    [TCRegroup actionRegroup:foModel];
    foModel.refrectionNo = ![TCRefrection secondRefrectionForSubR:foModel];
    if (foModel.refrectionNo) {
        [TCPlan planFromIfTCNeed];
        foModel.status = TOModelStatus_ScoreNo;//反思不通过时直接改为ScoreNo (参考31083-TODO5);
        return [[[TCResult new:false] mkMsg:@"action反思不通过"] mkStep:31];
    }
    
    //2. Alg转移 (下帧),每次调用action立马先跳下actionIndex为当前正准备行为化的那一帧;
    NSString *rhLog = foModel.isH ? @"H" : @"R";
    NSString *frameLog = foModel.cansetActIndex < foModel.cansetTargetIndex ? @"中间帧" : @"末帧";
    NSString *fltLog1 = FltLog4AbsHCanset(foModel.isH, 1);
    NSString *fltLog2 = FltLog4HDemandOfWuPiGuo(1);
    NSString *fltLog3 = !foModel.isH ? FltLog4CreateRCanset(1) : @"";
    NSString *fltLog4 = FltLog4CreateHCanset(1);
    NSString *fltLog5 = FltLog4DefaultIf(!foModel.isH, @"2");
    NSString *fromDSC = STRFORMAT(@"FROM<F%ld F%ld F%ld>",Demand2Pit((DemandModel*)foModel.baseOrGroup).pointerId,foModel.sceneFrom.pointerId,foModel.cansetFrom.pointerId);
    OFTitleLog(@"行为化Fo",@"\n%@%@%@%@%@%@行为化%@下标 (%ld/%ld) %@ cansetTo:%@ by:%@",fltLog1,fltLog2,fltLog3,fltLog4,fltLog5,rhLog,frameLog,foModel.cansetActIndex,foModel.cansetTargetIndex,Pit2FStr([foModel getCurFrame].content_p),Fo2FStr(curFo),fromDSC);
    NSLog(@"\t%@sceneTo:%@",fltLog5,Pit2FStr(foModel.sceneTo));
    [theTC updateOperCount:kFILENAME];
    Debug();
    //4. 跳转下帧 (最后一帧为目标,自然发生即可,此前帧则需要行为化实现);
    if (foModel.cansetActIndex < foModel.cansetTargetIndex) {
        
        //@desc: 下标不急评价说明: R模式_Hav首先是为了避免forecastAlg,其次才是为了达成curFo解决方案 (参考22153);
        //5. 下标不急(弄巧成拙)评价_数据准备 (参考24171-12);
        //TODO: 考虑改成,取base最近的一个R任务;
        //6. 只有R类型,才参与下标不急评价;
        //ReasonDemandModel *baseDemand = (ReasonDemandModel*)foModel.baseOrGroup;
        //if(ISOK(baseDemand, ReasonDemandModel.class)){
        //    BOOL arsTime = [AIScore ARS_Time:foModel demand:baseDemand];
        //    if (!arsTime) {
        //        //7. 评价不通过,则直接ActYes,等待其自然出现 (参考22153-A2);
        //        DebugE();
        //        NSLog(@"==> arsTime弄巧成拙评价,子弹再飞一会儿");
        //        moveAlg.status = TOModelStatus_ActYes;
        //        [TCActYes arsTimeActYes:moveAlg];
        //        return;
        //    }
        //}
        
        //7. 构建触发器: 调用frameActYes();
        [TCActYes frameActYes:foModel];
        
        //8. 当前帧是理性帧时: 尝试行为当前帧;
        TOAlgModel *curFrameModel = [foModel getCurFrame];
        DebugE();
        return [TCOut run:curFrameModel];
    }else{
        //8. R成功,转actYes等待反馈 & 触发反省 (原递归参考流程控制Finish的注释version-20200916 / 参考22061-7);
        DebugE();
        
        if (ISOK(foModel.baseOrGroup, ReasonDemandModel.class)) {
            [TCActYes frameActYes:foModel];
            //[TCPlan planFromIfTCNeed];//r输出完成时,继续决策;
        }else if(ISOK(foModel.baseOrGroup, HDemandModel.class)){
            //9. 构建触发器: H目标帧只需要等 (转hActYes) (参考25031-9);
            [TCActYes frameActYes:foModel];//h输出成功时,等待反馈;
        }else if(ISOK(foModel.baseOrGroup, PerceptDemandModel.class)){
            [TCActYes frameActYes:foModel];//p输出成功时,等待反馈;
        }
        return [[[TCResult new:true] mkMsg:@"action finish"] mkStep:32];
    }
}

@end
