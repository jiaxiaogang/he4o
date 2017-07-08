//
//  Decision.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Decision.h"
#import "MindHeader.h"

@interface Decision ()

@property (strong,nonatomic) NSMutableDictionary *mDic; //数据;

@end


@implementation Decision


/**
 *  MARK:--------------------Mind引擎的需求 分析 & 决策--------------------
 *  Mind->Decision->FeelOut->Output
 */
-(void) commitDemand:(id)demand withType:(MindType)type{
    if (type == MindType_Angry)
        NSLog(@"我很生气!...我要:%@",demand);
    else if (type == MindType_Happy)
        NSLog(@"我很开心!...我要:%@",demand);
    
    //?解决饿的问题
    if (type == MindType_Hunger) {
        //xxxx
        CGFloat mindValueDelta = [NUMTOOK(demand) floatValue];
        if (fabsf(mindValueDelta) > 1) {
            AIMindValue *mindValue = [[AIMindValue alloc] init];
            mindValue.type = type;
            mindValue.value = mindValueDelta;
            [AIMindValue ai_insertToDB:mindValue];//logThink
            
            //1,搜索强化经验(经验表)
            BOOL experienceValue = true;
            if (experienceValue) {
                
                //1),参照解决方式,
                //2),类比其常识,
                //3),制定新的解决方式,
                //4),并分析其可行性, & 修正
                //5),预测其结果;(经验中上次的步骤对比)
                //6),执行输出;
            }else{
                //2,搜索未强化经历(意识流)
                BOOL memValue = true;
                if (memValue) {
                    //1),参照记忆,
                    //2),尝试执行输出;
                    //3),反馈(观察整个执行过程)
                    //4),强化(哪些步骤是必须,哪些步骤是有关,哪些步骤是无关)
                    //5),转移到经验表;
                }else{
                    //1),取原始情绪表达方式(哭,笑)
                    //2),执行输出;
                    //3),记忆(观察整个执行过程)
                }
            }
            //注:执行输出并非执行结束,任务达成才是结果;(输出只是执行的一部分)
            //注:当下AI只能输出文字;
        }
    }
}

-(void) tryDecisionByExperience{
    
}

@end
