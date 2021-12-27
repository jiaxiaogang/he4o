//
//  Output.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Output.h"
#import "AINetUtils.h"
#import "NSObject+Extension.h"
#import "AIKVPointer.h"
#import "AIAlgNodeBase.h"
#import "OutputUtils.h"
#import "OutputModel.h"
#import "AINetIndex.h"

@implementation Output

/**
 *  MARK:--------------------思维行为输出--------------------
 *  @version
 *      2021.02.05: 将概念嵌套的代码注掉,因为概念嵌套早已废弃;
 */
+(BOOL) output_FromTC:(AIKVPointer*)algNode_p {
    //1. 数据
    AIAlgNodeBase *algNode = [SMGUtils searchNode:algNode_p];
    if (!ISOK(algNode, AIAlgNodeBase.class)) {
        return false;
    }
    
    //2. 循环微信息组
    NSMutableArray *valids = [[NSMutableArray alloc] init];
    for (AIKVPointer *value_p in algNode.content_ps) {
        
        //3. 取dataSource & algsType
        NSString *identify = value_p.algsType;
        if (!value_p.isOut) {
            identify = [OutputUtils convertOutType2dataSource:value_p.algsType];
            WLog(@"调试下,何时会输出isOut=false的内容");
        }
        
        //4. 检查可输出"某数据类型"并收集
        if ([AINetUtils checkCanOutput:identify]) {
            OutputModel *model = [[OutputModel alloc] init];
            model.identify = identify;
            model.data = NUMTOOK([AINetIndex getData:value_p]);
            [valids addObject:model];
        }
    }
    
    //5. 执行输出
    if (ARRISOK(valids)) {
        [self output_General:valids logBlock:^{
            //6. 将输出入网
            [theTC commitOutputLog:valids];
        }];
        return true;
    }
    
    return false;
}

+(void) output_FromReactor:(NSString*)identify datas:(NSArray*)datas{
    //1. 转为outModel
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NSNumber *data in ARRTOOK(datas)) {
        OutputModel *model = [[OutputModel alloc] init];
        model.identify = STRTOOK(identify);
        model.data = NUMTOOK(data);
        [models addObject:model];
    }
    
    //2. 传递到output执行
    if (ARRISOK(models)) {
        [Output output_General:models logBlock:^{
            //3. 将输出入网
            [theTC commitOutputLog:models];
        }];
    }
}

/**
 *  MARK:--------------------情绪反射--------------------
 *  @todo
 *      2021.02.05: 将AIMoodType_Satisfy改为调用output_General()输出;
 */
+(void) output_FromMood:(AIMoodType)type{
    if (type == AIMoodType_Anxious) {
        //1. 生成outputModel
        OutputModel *model = [[OutputModel alloc] init];
        model.identify = ANXIOUS_RDS;
        model.data = @(1);
        
        //2. 输出
        [self output_General:@[model] logBlock:^{
            //3. 将输出mood提交给tc
            [AIInput commitIMV:MVType_Anxious from:10 to:3];
        }];
    }else if(type == AIMoodType_Satisfy){
        OutputModel *model = [[OutputModel alloc] init];
        model.identify = SATISFY_RDS;
        [[NSNotificationCenter defaultCenter] postNotificationName:kOutputObserver object:model];
    }
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------actions输出--------------------
 *  @desc 含: 反射被动输出 和 TC主动输出
 *  @param outputModels : OutputModel数组;
 *  如: 吸吮,抓握
 *  注: 先天,被动
 *  @version
 *      2021.02.05: 改为front取回useTime触发行为开始,到back再执行行为后视觉等触发 (参考22117);
 *      2021.02.26: 将timer改为SEL方式,因为block方式在模拟器运行会闪退;
 */
+(void) output_General:(NSArray*)outputModels logBlock:(void(^)())logBlock{
    //0. 输出行为输出到UI时,重新调用回主线程;
    dispatch_async(dispatch_get_main_queue(), ^{
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //1. 广播执行行为开始 (执行行为动画,返回执行用时);
        double useTime = 0;
        for (OutputModel *model in ARRTOOK(outputModels)) {
            model.type = OutputObserverType_Front;
            [[NSNotificationCenter defaultCenter] postNotificationName:kOutputObserver object:model];
            useTime = MAX(model.useTime, useTime);
        }
        
        //2. 行为输出完成后;
        [NSTimer scheduledTimerWithTimeInterval:useTime target:self selector:@selector(notificationTimer:) userInfo:^(){
            //3. 将输出入网
            logBlock();
            
            //4. 广播执行输出后 (现实世界处理 & 飞后视觉 & 价值触发等);
            for (OutputModel *model in ARRTOOK(outputModels)) {
                model.type = OutputObserverType_Back;
                [[NSNotificationCenter defaultCenter] postNotificationName:kOutputObserver object:model];
            }
        } repeats:false];
    });
}

+(void)notificationTimer:(NSTimer*)timer{
    Act0 invokeBlock = timer.userInfo;
    invokeBlock();
}

@end
