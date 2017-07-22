//
//  Demand.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Demand.h"

@implementation Demand

-(void) runAnalyze:(NSInteger)count{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //1,搜索意识流
        NSMutableArray *aws = [AIAwarenessStore searchWhere:nil count:count];//(此处应搜索更简单的AIMindValue数据)
        //2,搜索习惯(略)
        //3,搜索其它(略)
        
        //4,处理"因为重要,所以选定"的逻辑;(此处逻辑:参见N3P11)
        AIMindValueModel *mindVM = nil;
        if (ARRISOK(aws)) {
            for (AIAwarenessModel *aw in aws) {
                NSObject *content = [aw.awarenessP content];
                if ([content isKindOfClass:[AIMindValueModel class]]) {
                    AIMindValueModel *contentMVM = (AIMindValueModel*)content;
                    //1,根据value排序
                    
                    //2,权重计算
                    CGFloat mindVMImportance = [self checkTaskImportance:mindVM];
                    CGFloat contentMVMImportance = [self checkTaskImportance:contentMVM];
                    if (mindVM == nil || mindVMImportance < contentMVMImportance) {
                        mindVM = contentMVM;
                    }
                    
                }
            }
        }
        
        //5,执行;
        dispatch_async(dispatch_get_main_queue(), ^{
            //4,...交给think;结束流程;
        });
    });
}

//分析任务的重要性;
-(CGFloat) checkTaskImportance:(AIMindValueModel*)model {
    //2,再联想其权重(联想过程很主观,与"mind偏好"与"mind权重表"有很大影响;
    
    
    //1,收集权重(马太效应,mindValue.value绝对值越大,则权重影响越大)
    //2,"mindValue权重表"取mind偏好;
    NSArray *weightArr;
    for (AIPointer *pointer in weightArr) {
        
    }
    //3,"logThink"知道自己联想了什么,并且记录;
    return 1000;
}

//数据驱动的递归搜索;
-(AIPointer*) getWeighTask:(AIMindValueModel*)model{
    return nil;
}

@end
