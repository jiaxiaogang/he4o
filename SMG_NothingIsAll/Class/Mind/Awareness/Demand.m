//
//  Demand.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Demand.h"
#import "ThinkHeader.h"

@interface Demand ()

@property (assign, nonatomic) BOOL lock;    //单任务锁;
@property (assign, nonatomic) Aw2DemandStatus status;

@end

@implementation Demand

-(void) runAnalyze:(NSInteger)count{
    //1,加锁
    if (self.lock) {
        return;
    }
    self.lock = true;
    
    //2,状态
    self.status = Aw2DemandStatus_IO;
    
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
            //1,检查类型
            if ([content isKindOfClass:[AIMindValueModel class]]) {
                AIMindValueModel *contentMVM = (AIMindValueModel*)content;
                //2,检查失效性(根据状态)
                if ([self checkTaskValid:contentMVM]) {
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
        }
        
        //5,分析重要性
        self.status = theThink.curDemand ? Aw2DemandStatus_MainCommit : Aw2DemandStatus_NoMain;
        [self checkTaskImportance:mindValueArr];
    });
}

-(BOOL) checkTaskValid:(AIMindValueModel*)model{
    if (model) {
        if (model.type == MindType_Hunger) {
            
            //Awareness->Demand层会将意识流中大多数明显有问题的Demand过滤掉;
            
            if (model.value < 0 && theHunger.getState == HungerState_Charging) {
                return false;
            }
            if (model.value > 0 && theHunger.getState == HungerState_Unplugged) {
                return false;
            }
            
        }
    }
    return true;
}

//分析任务的重要性;
-(void) checkTaskImportance:(NSMutableArray*)models {
    if (self.status != Aw2DemandStatus_Finish && ARRISOK(models)) {
        for (AIMindValueModel *model in models) {
            //1,权重(参考:AI/框架/Understand/Awareness->Demand->ThinkTask任务/注:权重)(经验和习惯的知识表示全了再写这块代码)
            NSArray *weightArr;
            
            //2,"logThink"知道自己联想了什么,并且记录;
            for (AIPointer *pointer in weightArr) {
                //此处多数是读的记忆,所以只是AILine.strong++;并且存到意识流;(参考:AI/框架/神经网络/读写)
            }
            
            //3,取阀值
            CGFloat canValidValue = 0;
            if (theThink.curDemand) {
                canValidValue = theThink.curDemand.value;
            }else{
                CGFloat canBeMainValue = -3;
                canValidValue = canBeMainValue;
            }
            
            //4,生成think.curDemand
            if (model.value < canValidValue) {
                if (self.status == Aw2DemandStatus_NoMain) {
                    self.status = Aw2DemandStatus_MainCommit;
                    
                    //logThink
                    AIDemandModel *demandModel = [[AIDemandModel alloc] initWithAIMindValueModel:model];
                    [AIDemandStore insert:demandModel awareness:true];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [theThink setData:demandModel];
                    });
                }else if(self.status == Aw2DemandStatus_MainCommit){
                    //logThink
                    AIDemandModel *demandModel = [[AIDemandModel alloc] initWithAIMindValueModel:model];
                    [AIDemandStore insert:demandModel awareness:true];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [theThink setData:demandModel];
                    });
                }
            }
        }
        self.lock = false;
        self.status = Aw2DemandStatus_Finish;
    }
}

-(void) stop{
    self.lock = false;
    self.status = Aw2DemandStatus_Finish;
    
}

@end
