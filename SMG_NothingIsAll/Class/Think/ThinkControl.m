//
//  ThinkControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "ThinkControl.h"
#import "ThinkHeader.h"

@interface ThinkControl ()
@property (strong,nonatomic) AIMindValueModel *currentTask;//当前任务;
@end

@implementation ThinkControl

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
        [self initRun];
    }
    return self;
}

-(void) initData{
    
}

-(void) initRun{
    
}

/**
 *  MARK:--------------------Understand(Input->Think)--------------------
 *  副引擎
 *  浅理解/无意分析");//只取obj,char不存;
 *  与预测作比较;
 */
-(void) commitUnderstandByShallow:(id)data{
    if (STRISOK(data)) {
        [self commitUnderstandByDeep:data];//1,字符串每次都给予注意力;
    }else if(true){
        
    }else{
        
    }
}

-(void) commitUnderstandByDeep:(id)data{
    if (STRISOK(data)) {
        //收集charArr
        NSString *str = (NSString*)data;
        NSMutableArray *charArr = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < str.length; i++) {
            AIChar *c = AIMakeChar([str characterAtIndex:i]);
            [charArr addObject:c];
        }
        
        //记录规律
        AILawModel *law = AIMakeLawByArr(charArr);
        
        //问mind有没意见
        if (self.delegate && [self.delegate respondsToSelector:@selector(thinkControl_GetMindValue:)]) {
            id mindValue = [self.delegate thinkControl_GetMindValue:law.pointer];
            NSLog(@"%@",mindValue);
        }
        
        
        //1,理解data
            //1.1,通过关联网络取
            //1.2,尝试理解;(return "理解结果",1+1=1+1 || 1+1=2)
        //2,预测比较 || 经验比较
            //2.1,比较"理解结果"
        //3,mind界入干预
            //3.1,先不考虑
        
        
    }else{
        
    }
}

/**
 *  MARK:--------------------Demand(Mind->Think)--------------------
 */
-(void) commitMindValueNotice:(AIMindValueModel*)model{
    //1,数据检查
    if (model == nil) {
        return;
    }
    //2,通知时相应处理....(先不写)
}

/**
 *  MARK:--------------------Task--------------------
 */
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

//执行前分析任务可行性;
-(BOOL) checkTaskCanDecision:(AIMindValueModel*)model{
    if (self.currentTask) {
        //完全使用数据思考的方式来决定下一步;
    }
    return true;
}

/**
 *  MARK:--------------------Decision--------------------
 */
-(void) decisionWithTask:(AIMindValueModel*)model{
    //1,记录正在执行的任务;
    self.currentTask = model;
    //2,数据检查
    if (model == nil) {
        return;
    }
    
    //3,分析问题;
    if (model.type == MindType_Hunger) {//解决饿的问题
        CGFloat mindValueDelta = model.value;
        
        if (fabsf(mindValueDelta) > 1) {
            
            //LogThink开始思考问题;...........
            
            
            //1,搜索强化经验(经验表)
            BOOL experienceValue = [self decisionByExperience];
            if (experienceValue) {
                
                //1),参照解决方式,
                //2),类比其常识,
                //3),制定新的解决方式,
                //4),并分析其可行性, & 修正
                //5),预测其结果;(经验中上次的步骤对比)
                //6),执行输出;
            }else{
                //2,搜索未强化经历(意识流)
                BOOL memValue = [self decisionByMemory];
                if (memValue) {
                    //1),参照记忆,
                    //2),尝试执行输出;
                    //3),反馈(观察整个执行过程)
                    //4),强化(哪些步骤是必须,哪些步骤是有关,哪些步骤是无关)
                    //5),转移到经验表;
                }else{
                    //1),取原始情绪表达方式(哭,笑)(是急哭的吗?)
                    if ([self.delegate respondsToSelector:@selector(thinkControl_TurnDownDemand:)]) {
                        [self.delegate thinkControl_TurnDownDemand:model];//2),执行输出;
                    }
                    //3),记忆(观察整个执行过程)
                }
            }
            //注:执行输出并非执行结束,任务达成才是结果;(输出只是执行的一部分)
            //注:当下AI只能输出文字;
        }
    }
}

-(BOOL) decisionByExperience{
    AIExperienceModel *value = [AIExperienceStore search];
    return value != nil;
}

-(BOOL) decisionByCommonSense{
    AICommonSenseModel *value = [AICommonSenseStore search];
    return value != nil;
}

-(BOOL) decisionByAwareness{
    AIAwarenessModel *value = [AIAwarenessStore search];
    return value != nil;
}

-(BOOL) decisionByMemory{
    AIMemoryModel *value = [AIMemoryStore search];
    return value != nil;
}

@end
