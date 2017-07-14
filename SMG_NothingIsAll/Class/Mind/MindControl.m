//
//  MindControll.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MindControl.h"
#import "MindHeader.h"
#import "ThinkHeader.h"
#import "MBProgressHUD+Add.h"
#import "OutputHeader.h"

@interface MindControl ()<MineDelegate>

@end

@implementation MindControl

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
        [self initRun];
    }
    return self;
}

-(void) initData{
    self.mine = [[Mine alloc] init];
}

-(void) initRun{
    self.mine.delegate = self;
}


/**
 *  MARK:--------------------method--------------------
 */
-(id) getMindValue:(AIPointer*)pointer{
    //xxx这个值还没存;
    int moodValue = (random() % 2) - 1;//所有demand只是简单规则;即将value++;
    if (moodValue < 0) {
        //[theThink commitDemand:nil withType:0];//@"怼他" withType:MindType_Angry
    }else{
        //[theThink commitDemand:nil withType:0];//@"大笑" withType:MindType_Happy];
    }
    
    //*  value:数据类型未定;
    //*      1,从经验和长期记忆搜索有改变mindValue的记录;
    //*      2,根据当前自己的状态;
    //*      3,计算出一个值;并返回;
    return nil;
}

-(void) turnDownDemand:(AIMindValueModel*)model{
    if (model) {
        [theMood setData:model.value type:MoodType_Irritably2Calm rateBlock:^(Mood *mood) {
            [theOutput output_Face:MoodType_Irritably2Calm value:mood.value];
        }];
    }
}

/**
 *  MARK:--------------------MineDelegate--------------------
 */
-(void) mine_HungerLevelChanged:(AIHungerLevelChangedModel*)model{
    if (model) {
        //1,取值
        CGFloat mVD;
        if (model.state == HungerState_Unplugged) {
            mVD = (model.level - 10);//mindValue -= x (饿一滴血)
        }else if (model.state == HungerState_Charging) {//充电中
            mVD = (10 - model.level);//mindValue += x (饱一滴血)
        }
        
        //2,LogThink
        AIMindValueModel *mindValue = [[AIMindValueModel alloc] init];
        mindValue.type = MindType_Hunger;
        mindValue.value = mVD;
        [AIMindValueStore insert:mindValue];//logThink
        
        AIAwarenessModel *awareness = [[AIAwarenessModel alloc] init];
        awareness.awarenessP = mindValue.pointer;
        [AIAwarenessStore insert:awareness];
        
        //2,分析决策 & 产生需求
        if (model.state == UIDeviceBatteryStateCharging) {
            [MBProgressHUD showSuccess:@"饱一滴血!" toView:nil withHideDelay:1];
        }else if (model.state == UIDeviceBatteryStateUnplugged) {
            if (mVD < 3) {
                [self.delegate mindControl_CommitDecisionByDemand:mindValue];//不能过度依赖noLogThink来执行,应更依赖logThink;
            }
        }
    }
}

-(void) mine_HungerStateChanged:(AIHungerStateChangedModel*)model{
    if (model) {
        //2,LogThink
        //        AIMindValueModel *mindValue = [[AIMindValueModel alloc] init];
        //        mindValue.type = MindType_Hunger;
        //        mindValue.value = mVD;
        //        [AIMindValueStore insert:mindValue];//logThink
        //
        //        AIAwarenessModel *awareness = [[AIAwarenessModel alloc] init];
        //        awareness.awarenessP = mindValue.pointer;
        //        [AIAwarenessStore insert:awareness];
        
        //2,分析决策 & 产生需求
        if (model.state == HungerState_Unplugged) {
            if (model.level > 9.5) {
                [MBProgressHUD showSuccess:@"饱了..." toView:nil withHideDelay:1];
            }else if(model.level > 7){
                [MBProgressHUD showSuccess:@"好吧,下次再充..." toView:nil withHideDelay:1];
            }else if(model.level < 7){
                [MBProgressHUD showSuccess:@"还没饱呢" toView:nil withHideDelay:1];
            }
        }else if (model.state == HungerState_Charging) {
            if (model.level > 9.5) {
                [MBProgressHUD showSuccess:@"饱了..." toView:nil withHideDelay:1];
            }else if(model.level > 7){
                [MBProgressHUD showSuccess:@"好吧,再充些..." toView:nil withHideDelay:1];
            }else if(model.level < 7){
                [MBProgressHUD showSuccess:@"谢谢呢!" toView:nil withHideDelay:1];
            }
        }
    }
}

@end
