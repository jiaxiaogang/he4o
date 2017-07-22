//
//  Demand.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Demand.h"

@interface Demand ()

@property (assign, nonatomic) BOOL lock;    //单任务锁;
@property (assign, nonatomic) DemandStatus status;

@end

@implementation Demand

-(void) runAnalyze:(NSInteger)count{
    //1,加锁
    if (self.lock) {
        return;
    }
    self.lock = true;
    
    //2,状态
    self.status = DemandStatus_IO;
    
    //3,异步执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //1,搜索意识流
        NSMutableArray *aws = [AIAwarenessStore searchWhere:nil count:count];
        //2,搜索习惯(略)(带排序)
        //3,搜索其它(略)(带排序)
        
        //4,value筛选 & 排序
        NSMutableArray *mindValueArr = [[NSMutableArray alloc] init];
        for (AIAwarenessModel *aw in ARRTOOK(aws)) {
            NSObject *content = [aw.awarenessP content];
            if ([content isKindOfClass:[AIMindValueModel class]]) {
                AIMindValueModel *contentMVM = (AIMindValueModel*)content;
                [mindValueArr addObject:contentMVM];
                for (NSInteger i = 0; i < mindValueArr.count; i++) {
                    AIMindValueModel *itemModel = mindValueArr[i];
                    if (itemModel.value < contentMVM.value) {
                        [mindValueArr insertObject:contentMVM atIndex:i];
                        break;
                    }
                }
            }
        }
        
        //5,分析重要性
        [self checkTaskImportance:mindValueArr];
    });
}

//分析任务的重要性;
-(void) checkTaskImportance:(NSMutableArray*)modelArr {
    if (self.status != DemandStatus_Finish) {
        //2,再联想其权重(联想过程很主观,与"mind偏好"与"mind权重表"有很大影响;
        
        
        //1,收集权重(马太效应,mindValue.value绝对值越大,则权重影响越大)
        //2,"mindValue权重表"取mind偏好;
        NSArray *weightArr;
        for (AIPointer *pointer in weightArr) {
            
        }
        //3,"logThink"知道自己联想了什么,并且记录;
        
        
        //5,执行;
        dispatch_async(dispatch_get_main_queue(), ^{
            //4,...交给think;结束流程;
        });
    }
}

//数据驱动的递归搜索;
-(AIPointer*) getWeighTask:(AIMindValueModel*)model{
    return nil;
}

-(void) stop{
    self.lock = false;
    self.status = DemandStatus_Finish;
    
}

@end
