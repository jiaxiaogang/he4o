//
//  ThinkingUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/3/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "ThinkingUtils.h"

@implementation ThinkingUtils

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Analogy) >
//MARK:===============================================================
@implementation ThinkingUtils (Analogy)

+(BOOL) analogyCharA:(char)a b:(char)b{
    return a == b;
}

+(void) analogyCMVA:(NSArray*)a b:(NSArray*)b{
    //1. 忽略
    //2. 
}

+(void) test{
    //1. 连续信号中,找重复;(连续也是拆分,多事务处理的)
    //2. 两条信息中,找交集;
    //3. 在连续信号的处理中,实时将拆分单信号存储到内存区,并提供可检索等,其形态与最终存硬盘是一致的;
    
    //类比的处理,是足够细化的,对思维每个信号作类比操作;(而将类比到的最基本的结果,输出给thinking,以供为构建网络的依据,最终是以网络为目的的)
}

@end



//MARK:===============================================================
//MARK:                     < ThinkingUtils (CMV) >
//MARK:===============================================================
@implementation ThinkingUtils (CMV)

+(AITargetType) getTargetType:(MVType)type{
    if(type == MVType_Hunger){
        return AITargetType_Down;
    }else if(type == MVType_Anxious){
        return AITargetType_Down;
    }else{
        return AITargetType_None;
    }
}

@end
