//
//  TOAction.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TOAction.h"
#import "TOFoModel.h"

@implementation TOAction

/**
 *  MARK:--------------------out行为化--------------------
 *  @desc 解决方案fo即(加工目标),转_Fo()行为化 (参考24132-行为化1);
 *  @param foModel : notnull
 *  @version
 *      2021.11.17: 需调用者自行对foModel进行FRS稳定性竞争评价,本方法不再进行 (因为fo间的竞争,需由外界,fo内部问题在此方法内解决);
 *      2021.11.25: 迭代为功能架构 (参考24154-单轮示图);
 *      2021.11.xx: 废弃outReflect反思功能 (全部待到inReflect统一再反思);
 *  @callers : 可以供_Demand和_Hav等调用;
 */
+(void) rAction:(TOFoModel*)foModel{
    
    
    
    //TODOTOMORROW20211128: 紧急情况迭代 (参考24171-7);
    //2. 紧急状态判断 (当R模式在3s以内会触发-mv时,属于紧急状态) (参考24057-方案3);
    BOOL rIsTooLate = false;
    ReasonDemandModel *rDemand = (ReasonDemandModel*)foModel.baseOrGroup;
    double deltaTime = [TOUtils getSumDeltaTime2Mv:rDemand.mModel.matchFo cutIndex:rDemand.mModel.cutIndex2];
    rIsTooLate = deltaTime < 30;
    NSLog(@"紧急状态 (%d) 预计-mv时间:%f",rIsTooLate,deltaTime);
    
    //1. 数据准备
    AIFoNodeBase *curFo = [SMGUtils searchNode:foModel.content_p];
    OFTitleLog(@"行为化Fo", @"\n时序:%@->%@ 类型:(%@)",Fo2FStr(curFo),Mvp2Str(curFo.cmvNode_p),curFo.pointer.typeStr);
    
    
    //4. 跳转下帧,
    if (foModel.actionIndex < curFo.count - 1) {
        //a. Alg转移 (下帧)
        foModel.actionIndex ++;
        AIKVPointer *move_p = ARR_INDEX(curFo.content_ps, foModel.actionIndex);
        TOAlgModel *moveAlg = [TOAlgModel newWithAlg_p:move_p group:foModel];
        NSLog(@"_Fo行为化第 %ld/%ld 个: %@",(long)foModel.actionIndex,(long)curFo.count,Fo2FStr(curFo));
        [TOOut out:moveAlg];
    }else{
        //c. 成功,递归 (参考流程控制Finish的注释version-20200916 / 参考22061-7);
        foModel.status = TOModelStatus_ActYes;
        NSLog(@"_Fo行为化: Finish %ld/%ld 到ActYes",(long)foModel.actionIndex,(long)curFo.count);
        [TOOut rActYes:foModel];
    }
}

+(void) hAction:(TOFoModel*)foModel{
    
    //TODOTOMORROW20211125:
    //1. hAction执行到regroup时,要代入jump重组,并进行识别in反思;
    
    //TODOTOMORROW20211201: 代码规划;
    //1. 做紧急状态,来的及评价,来不及的算失败 (参考24171-7);
    //2. 逐帧试输出;
    
    
}

@end
