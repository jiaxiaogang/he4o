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

@end
