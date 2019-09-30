//
//  AIThinkOutReason.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkOutReason.h"
#import "AIAlgNodeBase.h"
#import "AICMVNodeBase.h"
#import "AINetIndex.h"
#import "AIKVPointer.h"

@implementation AIThinkOutReason

/**
 *  MARK:--------------------TOR主方法--------------------
 *  1. 可以根据此maxMatchValue匹配度,来做感性预测;
 */
+(void) dataOut:(AIKVPointer *)targetAlg_p matchingAlg:(AIAlgNodeBase *)matchingAlg useNode:(AICMVNodeBase *)useNode matchingFo:(AIFoNodeBase *)matchingFo shortMemFo:(AIFoNodeBase *)shortMemFo {
    
    
    
    //TODOTOMORROW:
    //1. 把mv预测,加入到reasonDemandManager中,同台竞争,而执行是为了避免;
    //2. 判断matchValue的匹配度,对mv的迫切度产生"正相关"影响;
    //3. 判断matchingFo.mv是否有值,如果无值,则仅需要对matchingFo和matchingAlg做理性使用;
    
    
    //参考n17p8 TOR模型;
    //1. 比如预测到车将撞到自己,那么我们可以去查看避免被撞的方法;
    //  * 比如,飞行改变距离,改变方向,改变车的尺寸,改变车的速度,改变红绿灯为红灯等方式;
    //2. 预测[alg(车) -> fo(车变近) -> mv(疼痛)]
    //TOP通过,满足需求,找行为化,达成实;
    //TOR通过,避免需求,找行为化,改变实;
    
    
    
    
    //1. 数据检查
    AIAlgNodeBase *targetAlg = [SMGUtils searchNode:targetAlg_p];
    if (!ISOK(useNode, AICMVNodeBase.class) || !ISOK(matchingAlg, AIAlgNodeBase.class) || !targetAlg) {
        return;
    }
    
    //比对mv匹配;
    NSInteger delta = [NUMTOOK([AINetIndex getData:useNode.delta_p]) integerValue];
    if (delta == 0) {
        return;
    }
    //NSString *algsType = cmvNode.urgentTo_p.algsType;
    //NSInteger urgentTo = [NUMTOOK([AINetIndex getData:cmvNode.urgentTo_p]) integerValue];
    //[self.demandManager updateCMVCache:algsType urgentTo:urgentTo delta:delta order:urgentTo];
    
    //加上活跃度
    //[self updateEnergy:urgentTo];//190730前:((urgentTo + 9)/10) 190730:urgentTo
    
    
    
    //走ThinkOutReason进行行为化
    //can有没有用
    //how怎么用
    //参考n17p1&n17p2
}

@end
