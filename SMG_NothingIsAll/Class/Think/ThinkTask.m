//
//  ThinkTask.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "ThinkTask.h"

@implementation ThinkTask

//开始异步搜索IO任务;
-(void) runForCreateTask{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //多个覆盖;
        //1,搜索意识流
        //2,搜索习惯
        //3,搜索其它
        
        //一个策略;3短1长;
        //1,搜10条task
        //2,搜10000条task
        dispatch_async(dispatch_get_main_queue(), ^{
            //执行;
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

//执行前分析任务可行性;
-(BOOL) checkTaskCanDecision:(AIMindValueModel*)model{
    if (self.currentTask) {
        //完全使用数据思考的方式来决定下一步;
    }
    return true;
}

@end





@implementation ThinkTaskStrategy : NSObject

+(void) run{
    
}

@end
