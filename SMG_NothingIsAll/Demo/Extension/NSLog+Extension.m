//
//  NSLog+Extension.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/9/21.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "NSLog+Extension.h"

@implementation NSLog_Extension

+(NSString*) convertStatus2Desc:(TOModelStatus)status{
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
    if (atType == ATSub) return @"负";
    if (atType == ATPlus) return @"正";
    return @"普";
}

@end
