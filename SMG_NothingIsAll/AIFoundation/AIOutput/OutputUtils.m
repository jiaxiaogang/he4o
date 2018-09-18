//
//  OutputUtils.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/20.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "OutputUtils.h"
#import "AIOutputReference.h"
#import "Output.h"
#import "NSObject+Extension.h"
#import "AIKVPointer.h"

@implementation OutputUtils


/**
 *  MARK:--------------------转换数据类型为"输出算法标识"--------------------
 *  注:目前仅支持一一对应,随后支持多个后,return改为Array;
 */
+(NSString*) convertOutType2dataSource:(NSString*)algsType {
    if ([@"AICharAlgsModel" isEqualToString:algsType]) {
        return @"output_Text:";
    }else{
        return nil;//暂不支持其它类型输出;
    }
}


/**
 *  MARK:--------------------检查执行微信息的输出--------------------
 */
+(BOOL) checkAndInvoke:(AIKVPointer*)micro_p{
    //1. 数据
    if (!ISOK(micro_p, AIKVPointer.class)) {
        return false;
    }
    
    NSString *dataSource = micro_p.dataSource;
    if (!micro_p.isOut) {
        dataSource = [self convertOutType2dataSource:micro_p.algsType];
    }
    NSString *algsType = NSStringFromClass(Output.class);
    
    //2. 检查是否可输出"某数据类型"
    if ([AIOutputReference checkCanOutput:algsType dataSource:dataSource]) {
        id microData = [SMGUtils searchObjectForPointer:micro_p fileName:FILENAME_Value time:cRedisValueTime];
        [NSObject invocationMethodName:dataSource className:algsType withObjects:@[microData]];
        return true;
    }
    return false;
}

@end
