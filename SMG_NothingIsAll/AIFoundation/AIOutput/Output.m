//
//  Output.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Output.h"
#import "AIThinkingControl.h"
#import "AINetUtils.h"
#import "NSObject+Extension.h"
#import "AIKVPointer.h"
#import "AIAlgNodeBase.h"
#import "OutputUtils.h"

@implementation Output

+(NSString*) getReactorMethodName{
    return NSStringFromSelector(@selector(output_Reactor:paramNum:));
}

+(void) output_Face:(AIMoodType)type{
    //1. 数据
    const char *chars = nil;
    if (type == AIMoodType_Anxious) {
        chars = [@"T_T" UTF8String];
    }else if(type == AIMoodType_Satisfy){
        chars = [@"^_^" UTF8String];
    }
    if (chars) {
        //2. 将输出入网
        NSMutableArray *valids = [[NSMutableArray alloc] init];
        [valids addObject:@{@"ds":TEXT_RDS,@"at":NSStringFromClass(Output.class),@"data":@(chars[0])}];
        [valids addObject:@{@"ds":TEXT_RDS,@"at":NSStringFromClass(Output.class),@"data":@(chars[1])}];
        [valids addObject:@{@"ds":TEXT_RDS,@"at":NSStringFromClass(Output.class),@"data":@(chars[2])}];
        [[AIThinkingControl shareInstance] commitOutputLog:valids];
        
        //3. 执行输出
        [self output_Reactor:TEXT_RDS paramNum:@(chars[0])];
        [self output_Reactor:TEXT_RDS paramNum:@(chars[1])];
        [self output_Reactor:TEXT_RDS paramNum:@(chars[2])];
    }
}

+(void) output_Reactor:(NSString*)rds paramNum:(NSNumber*)paramNum{
    if (paramNum) {
        //广播执行;
        [[NSNotificationCenter defaultCenter] postNotificationName:kOutputObserver object:@{@"rds":STRTOOK(rds),@"paramNum":NUMTOOK(paramNum)}];
    }
}

/**
 *  MARK:--------------------检查执行微信息的输出--------------------
 */
+(BOOL) checkAndInvoke:(AIKVPointer*)algNode_p{
    //1. 数据
    AIAlgNodeBase *algNode = [SMGUtils searchObjectForPointer:algNode_p fileName:FILENAME_Node time:cRedisNodeTime];
    if (!ISOK(algNode, AIAlgNodeBase.class)) {
        return false;
    }
    
    //2. 循环微信息组
    NSMutableArray *valids = [[NSMutableArray alloc] init];
    for (AIKVPointer *value_p in algNode.value_ps) {
        
        //3. 取dataSource & algsType
        NSString *dataSource = value_p.dataSource;
        if (!value_p.isOut) {
            dataSource = [OutputUtils convertOutType2dataSource:value_p.algsType];
        }
        NSString *algsType = NSStringFromClass(Output.class);
        
        //4. 检查可输出"某数据类型"并收集
        if ([AINetUtils checkCanOutput:algsType dataSource:dataSource]) {
            NSNumber *microData = NUMTOOK([SMGUtils searchObjectForPointer:value_p fileName:FILENAME_Value time:cRedisValueTime]);
            [valids addObject:@{@"ds":STRTOOK(dataSource),@"at":algsType,@"data":microData}];
        }
    }
    
    if (ARRISOK(valids)) {
        //5. 将输出入网
        [[AIThinkingControl shareInstance] commitOutputLog:valids];
        
        //6. 执行输出
        for (NSDictionary *dic in valids) {
            NSString *methodName = [Output getReactorMethodName];
            NSString *algsType = STRTOOK([dic objectForKey:@"at"]);
            NSString *dataSource = STRTOOK([dic objectForKey:@"ds"]);
            NSNumber *data = NUMTOOK([dic objectForKey:@"data"]);
            [NSObject invocationMethodName:methodName className:algsType withObjects:@[dataSource,data]];
        }
        return true;
    }
    
    return false;
}

@end
