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
#import "ThinkingUtils.h"
#import "TOFoModel.h"
#import "TOAlgScheme.h"
#import "Output.h"

@implementation AIThinkOutReason

/**
 *  MARK:--------------------TOR主方法--------------------
 *  1. 可以根据此maxMatchValue匹配度,来做感性预测;
 */
-(void) commitFromTIR:(AICMVNodeBase *)useNode
           matchValue:(CGFloat)matchValue
           protoAlg_p:(AIKVPointer *)protoAlg_p
             matchAlg:(AIAlgNodeBase *)matchAlg
              protoFo:(AIFoNodeBase *)protoFo
              matchFo:(AIFoNodeBase *)matchFo {
    
    //1. 把mv加入到demandManager;
    NSInteger urgentTo = 0;
    if (matchFo) {
        //1> 判断matchingFo.mv有值才加入demandManager,同台竞争,执行顺应mv;
        AICMVNodeBase *mvNode = [SMGUtils searchNode:matchFo.cmvNode_p];
        if (mvNode) {
            NSInteger delta = [NUMTOOK([AINetIndex getData:mvNode.delta_p]) integerValue];
            if (delta != 0) {
                NSString *algsType = mvNode.urgentTo_p.algsType;
                
                //2> 判断matchValue的匹配度,对mv的迫切度产生"正相关"影响;
                urgentTo = [NUMTOOK([AINetIndex getData:mvNode.urgentTo_p]) integerValue];
                urgentTo = (int)(urgentTo * matchValue);
                
                //3> 将mv加入demandCache
                [self.delegate aiThinkOutReason_CommitDemand:delta algsType:algsType urgentTo:urgentTo];
                
                //4> RMV无需求时,将其加入到激活缓存;
                BOOL havDemand = [ThinkingUtils getDemand:algsType delta:delta complete:nil];
                if (!havDemand) {
                    [self.delegate aiThinkOutReason_CommitActive:mvNode.pointer];
                }
            }
        }
    }
    
    //2. 将所有TIR的激活节点,添加到activeCache中,供理性(实)使用;
    if (protoAlg_p) [self.delegate aiThinkOutReason_CommitActive:protoAlg_p];
    if (matchAlg) [self.delegate aiThinkOutReason_CommitActive:matchAlg.pointer];
    if (protoFo) [self.delegate aiThinkOutReason_CommitActive:protoFo.pointer];
    if (matchFo) [self.delegate aiThinkOutReason_CommitActive:matchFo.pointer];
    
    //3. 加上活跃度
    [self.delegate aiThinkOutReason_UpdateEnergy:urgentTo];
    
    //4. 对TOP的运作5个scheme做改动,以应用"激活"节点;
    //或者,就在此处重写5个scheme,来做TOR的工作;
    //>1. 取demandManager中,首个任务,看是否与当前mv有匹配,,,并逐步进行匹配,(参考:n17p9/168_TOR代码实践示图);
    
    //参考n17p8 TOR模型; n17p9 代码实践示图;
    //TOR通过,避免需求,找行为化,改变实;
    //>2. 如预测到车将撞到自己,去查避免被撞的方法;如,飞行改变距离,改变方向,改变车的尺寸,改变车的速度,改变红绿灯为红灯等方式;
    //can有没有用 / how怎么用
    
}

//MARK:===============================================================
//MARK:                     < 决策行为化 >
//MARK: 1. 以algScheme开始,优先使用简单的方式,后向fo,mv;
//MARK: 2. 因为TOP已经做了很多工作,此处与TOP协作 (与从左至右的理性向性是相符的);
//MARK:===============================================================

-(void) commitFromTOP_Convert2Actions:(TOFoModel*)foModel{
    if (foModel) {
        //1. 为空,进行行为化_尝试输出"可行性之首"并找到实际操作 (子可行性判定) (algScheme)
        if (!ARRISOK(foModel.actions)) {
            [self dataOut_AlgScheme:foModel];
        }
        
        //2. actionScheme (行为方案输出)
        if (ARRISOK(foModel.actions)) {
            [self dataOut_ActionScheme:foModel.actions];
        }
    }
}

/**
 *  MARK:--------------------algScheme--------------------
 *  1. 对条件概念进行判定 (行为化);
 *  2. 理性判定;
 */
-(void) dataOut_AlgScheme:(TOFoModel*)outFoModel{
    //1. 数据准备
    if (!ISOK(outFoModel, TOFoModel.class)) {
        return;
    }
    AIFoNodeBase *foNode = [SMGUtils searchNode:outFoModel.content_p];
    if (!foNode) {
        return;
    }
    
    //TODOTOMORROW:
    //190725此处,outMvModel取到,解决问题的mvDirection结果,但再往下,仍然是进到反射输出了,,,查为什么行为化失败了,,,
    //191022答: 由此处行为化失败率太高,而引出必须细化TR;
    
    //2. 进行行为化; (通过有无,变化,等方式,将结构中所有条件概念行为化);
    outFoModel.actions = [TOAlgScheme convert2Out:foNode.content_ps];
}


-(void) algScheme:(AIAlgNodeBase*)protoAlg matchAlg:(AIAlgNodeBase*)matchAlg {
    
}

-(void) foScheme:(AIFoNodeBase*)protoFo matchFo:(AIFoNodeBase*)matchFo {
    
}

-(void) mvScheme:(AIKVPointer*)mv_p {
    
}

-(void) actionScheme {
    
}




//MARK:===============================================================
//MARK:                     < FromTOP_反射反应 >
//MARK:===============================================================
-(void) commitFromTOP_ReflexOut{
    [self dataOut_ActionScheme:nil];
}

/**
 *  MARK:--------------------尝试输出信息--------------------
 *  @param outArr : orders里筛选出来的algNode组;
 *
 *  三种输出方式:
 *  1. 反射输出 : reflexOut
 *  2. 激活输出 : absNode信息无conPorts方向的outPointer信息时,将absNode的宏信息尝试输出;
 *  3. 经验输出 : expOut指在absNode或conPort方向有outPointer信息;
 *
 *  功能: 将行为概念组成的长时序,转化为真实输出;
 *  1. 找到行为的具象;
 *  2. 正式执行行为 (小脑);
 */
-(void) dataOut_ActionScheme:(NSArray*)outArr{
    //1. 尝试输出找到解决问题的实际操作 (取到当前cacheModel中的最佳决策,并进行输出;)
    BOOL tryOutSuccess = false;
    if (ARRISOK(outArr)) {
        for (AIKVPointer *algNode_p in outArr) {
            //>1 检查micro_p是否是"输出";
            //>2 假如order_p足够确切,尝试检查并输出;
            BOOL invoked = [Output output_TC:algNode_p];
            [theNV setNodeData:algNode_p lightStr:@"o3"];
            if (invoked) {
                tryOutSuccess = true;
            }
        }
    }
    
    //2. 无法解决时,反射一些情绪变化,并增加额外输出;
    if (!tryOutSuccess) {
        //>1 产生"心急mv";(心急产生只是"urgent.energy x 2")
        //>2 输出反射表情;
        //>3 记录log到foOrders;(记录log应该到output中执行)
        
        //1. 如果未找到复现方式,或解决方式,则产生情绪:急
        //2. 通过急,输出output表情哭
        
        //1. 心急情绪释放,平复思维;
        [self.delegate aiThinkOutReason_UpdateEnergy:-1];
        
        //2. 反射输出
        [Output output_Mood:AIMoodType_Anxious];
    }
}


@end
