//
//  AIThinkInPercept.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/2.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkInPercept.h"
#import "AIFrontOrderNode.h"
#import "AICMVNode.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "AINet.h"
#import "AIAnalogy.h"
#import "AINetIndex.h"
#import "ShortMatchManager.h"
#import "AIShortMatchModel.h"
#import "AIAlgNodeBase.h"
#import "AIScore.h"
#import "AIMatchFoModel.h"
#import "AINetUtils.h"

@implementation AIThinkInPercept

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 认知--------------------
 *  @title 外层输入对In短时记忆的影响处理 (参考22052-2);
 *  @version
 *      2021.01.24: 对多时序识别结果支持,及时全面的改变status为OutBackYes (参考22073-todo5);
 *      2021.02.04: In反省支持虚mv,所以此处也要支持虚mv的OPush判断 (参考22108);
 *  @bug
 *      2021.01.25: 修复witMatchFo.cmvNode_p空判断逻辑反了,导致无法执行修改状态为OutBackYes,从而反省类比永远为"逆";
 */
+(void) tip_OPushM:(AICMVNode*)newMv{
    //1. 数据检查
    NSArray *inModels = theTC.inModelManager.models;
    if (!newMv) return;
    OFTitleLog(@"tip_OPushM", @"\n输入MV:%@",Mv2FStr(newMv));
    
    //3. 判断最近一次input是否与等待中outModel相匹配 (匹配,比如吃,确定自己是否真吃了);
    for (AIShortMatchModel *inModel in inModels) {
        for (AIMatchFoModel *waitModel in inModel.matchPFos) {
            //3. 非等待中的跳过;
            AIFoNodeBase *waitMatchFo = waitModel.matchFo;
            if (Log4OPushM) NSLog(@"==> checkTIModel=MatchFo: %@ (%@)",Fo2FStr(waitMatchFo),TIStatus2Str(waitModel.status));
            if (waitModel.status != TIModelStatus_LastWait || !waitMatchFo.cmvNode_p) continue;
            
            //4. 等待中的inModel_判断hope(wait)和real(new)之间是否相符;
            if ([AINetUtils isVirtualMv:waitMatchFo.cmvNode_p]) {
                //a. 虚mv仅标记同区反向反馈;
                if ([AIScore sameIdenDiffDelta:waitMatchFo.cmvNode_p mv2:newMv.pointer]) {
                    waitModel.status = TIModelStatus_OutBackDiffDelta;
                    NSLog(@"tip_OPushM: 虚MV 反向反馈");
                }
            }else{
                //b. 实mv仅标记同区同向反馈;
                if ([AIScore sameIdenSameScore:waitMatchFo.cmvNode_p mv2:newMv.pointer]) {
                    waitModel.status = TIModelStatus_OutBackSameDelta;
                    NSLog(@"tip_OPushM: 实MV 正向反馈");
                }
            }
        }
    }
}

@end

