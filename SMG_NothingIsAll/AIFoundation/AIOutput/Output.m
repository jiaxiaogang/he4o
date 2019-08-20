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
#import "OutputModel.h"
#import "AINetIndex.h"

@implementation Output

+(void) output_Reactor:(NSArray*)outputModels{
    //1. 将输出入网
    [theTC commitOutputLog:outputModels];
    
    //2. 广播执行输出;
    for (OutputModel *model in ARRTOOK(outputModels)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOutputObserver object:@{@"rds":STRTOOK(model.rds),@"paramNum":NUMTOOK(model.data)}];
    }
}

+(BOOL) output_TC:(AIKVPointer*)algNode_p{
    //1. 数据
    AIAlgNodeBase *algNode = [SMGUtils searchNode:algNode_p];
    if (!ISOK(algNode, AIAlgNodeBase.class)) {
        return false;
    }
    
    //2. 循环微信息组
    NSMutableArray *valids = [[NSMutableArray alloc] init];
    NSArray *mic_ps = [SMGUtils convertValuePs2MicroValuePs:algNode.content_ps];
    for (AIKVPointer *value_p in mic_ps) {
        
        //3. 取dataSource & algsType
        NSString *dataSource = value_p.dataSource;
        if (!value_p.isOut) {
            dataSource = [OutputUtils convertOutType2dataSource:value_p.algsType];
        }
        
        //4. 检查可输出"某数据类型"并收集
        if ([AINetUtils checkCanOutput:dataSource]) {
            OutputModel *model = [[OutputModel alloc] init];
            model.rds = dataSource;
            model.data = NUMTOOK([AINetIndex getData:value_p]);
            [theNV setNodeData:value_p lightStr:@"o4"];
            [valids addObject:model];
        }
    }
    
    //5. 执行输出
    if (ARRISOK(valids)) {
        [self output_Reactor:valids];
        return true;
    }
    
    return false;
}


+(void) output_Mood:(AIMoodType)type{
    if (type == AIMoodType_Anxious) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOutputObserver object:@{@"rds":ANXIOUS_RDS}];
    }else if(type == AIMoodType_Satisfy){
        [[NSNotificationCenter defaultCenter] postNotificationName:kOutputObserver object:@{@"rds":SATISFY_RDS}];
    }
}

@end
