//
//  NSLog+Extension.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/9/21.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "NSLog+Extension.h"
#import "ImvAlgsHungerModel.h"
#import "ImvAlgsHurtModel.h"
#import "AINetIndex.h"

@implementation NSLog_Extension

+(NSString*) convertTOStatus2Desc:(TOModelStatus)status{
    if(status == TOModelStatus_Wait){
        return @"Wait";
    }else if(status == TOModelStatus_Runing){
        return @"Runing";
    }else if(status == TOModelStatus_ActYes){
        return @"ActYes";
    }else if(status == TOModelStatus_ActNo){
        return @"ActNo";
    }else if(status == TOModelStatus_ScoreNo){
        return @"ScoreNo";
    }else if(status == TOModelStatus_NoNeedAct){
        return @"NoNeedAct";
    }else if(status == TOModelStatus_OuterBack){
        return @"OuterBack";
    }else if(status == TOModelStatus_Finish){
        return @"Finish";
    }
    return @"None";
}

+(NSString*) convertATType2Desc:(AnalogyType)atType{
    if (atType == ATHav) return @"有";
    if (atType == ATNone) return @"无";
    if (atType == ATGreater) return @"大";
    if (atType == ATLess) return @"小";
    if (atType == ATSub) return @"逆";
    if (atType == ATPlus) return @"顺";
    if (atType == ATDiff) return @"DS";
    return @"普";
}

+(NSString*) convertTIStatus2Desc:(TIModelStatus)status{
    if(status == TIModelStatus_LastWait){
        return @"等待反馈";
    }else if(status == TIModelStatus_OutBackReason){
        return @"理性反馈";
    }else if(status == TIModelStatus_OutBackSameDelta){
        return @"同向反馈";
    }else if(status == TIModelStatus_OutBackDiffDelta){
        return @"反向反馈";
    }else if(status == TIModelStatus_OutBackNone){
        return @"无反馈";
    }
    return @"Default";
}

+(NSString*) convertClass2Desc:(Class)clazz{
    if ([clazz isEqual:ImvAlgsHungerModel.class]) {
        return @"饿";
    }else if ([clazz isEqual:ImvAlgsHurtModel.class]) {
        return @"疼";
    }
    return @"无";
}

+(NSString*) convertMvp2DeltaDesc:(AIKVPointer*)mv_p{
    AICMVNodeBase *mv = [SMGUtils searchNode:mv_p];
    if (mv) {
        NSInteger delta = [NUMTOOK([AINetIndex getData:mv.delta_p]) integerValue];
        if (delta > 0) return @"↑";
        else if(delta < 0) return @"↓";
    }
    return @"⇅";
}

@end
