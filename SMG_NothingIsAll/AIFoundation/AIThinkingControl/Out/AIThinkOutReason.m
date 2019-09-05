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

+(void) dataOut{
    //can有没有用
    //how怎么用
    //参考n17p1&n17p2
}

+(void) dataOut:(AIKVPointer*)targetAlg_p isNode:(AIAlgNodeBase*)isNode useNode:(AICMVNodeBase*)useNode {
    //1. 数据检查
    AIAlgNodeBase *targetAlg = [SMGUtils searchNode:targetAlg_p];
    if (!ISOK(useNode, AICMVNodeBase.class) || !ISOK(isNode, AIAlgNodeBase.class) || !targetAlg) {
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
    [AIThinkOutReason dataOut];
}

@end
