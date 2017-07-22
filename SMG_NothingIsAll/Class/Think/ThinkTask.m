//
//  ThinkTask.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "ThinkTask.h"

@interface ThinkTask ()

@property (assign, nonatomic) NSInteger count;

@end

@implementation ThinkTask

//开始异步搜索IO任务;
-(void) run{
    __block ThinkTask *weakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.count ++;
        NSInteger analyzeCount = (weakSelf.count % 10 == 0) ? 1000 : 100;//9短1长;
        [self runAnalyze:analyzeCount];
        [self run];
    });
}

-(void) runAnalyze:(NSInteger)count{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //1,搜索意识流
        NSMutableArray *aws = [AIAwarenessStore searchWhere:nil count:count];
        //2,搜索习惯(略)
        //3,搜索其它(略)
        
        
        //4,处理"因为重要,所以选定"的逻辑;(此处逻辑:参见N3P11)
        AIMindValueModel *mindVM = nil;
        if (ARRISOK(aws)) {
            for (AIAwarenessModel *aw in aws) {
                NSObject *content = [aw.awarenessP content];
                if ([content isKindOfClass:[AIMindValueModel class]]) {
                    AIMindValueModel *contentMVM = (AIMindValueModel*)content;
                    if (mindVM == nil || mindVM.value < contentMVM.value) {
                        mindVM = contentMVM;
                    }
                }
            }
        }
        
        //5,执行;
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
}

//分析任务的重要性;
-(CGFloat) checkTaskImportance:(AIMindValueModel*)model weightArr:(NSArray*)weightArr{
    //1,收集权重
    for (AIPointer *pointer in weightArr) {
        
    }
    return 1000;
}

//数据驱动的递归搜索;
-(AIPointer*) getWeighTask:(AIMindValueModel*)model{
    return nil;
}

@end


