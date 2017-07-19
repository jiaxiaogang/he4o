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
        //[theThink commitMindValueChanged:nil withType:0];//@"怼他" withType:MindType_Angry
    }else{
        //[theThink commitMindValueChanged:nil withType:0];//@"大笑" withType:MindType_Happy];
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
        CGFloat mVD = 0;
        if (model.state == HungerState_Unplugged) {
            mVD = (model.level - 10);//mindValue -= x (饿一滴血)
        }else if (model.state == HungerState_Charging) {//充电中
            mVD = (10 - model.level);//mindValue += x (饱一滴血)
        }
        
        //2,分析决策 & 产生需求
        if (model.state == UIDeviceBatteryStateCharging) {
            AIMindValueModel *mindValue = [[AIMindValueModel alloc] init];
            mindValue.type = MindType_Hunger;
            mindValue.value = mVD;
            [AIMindValueStore insert:mindValue awareness:true];//logThink
            [theThink commitMindValueChanged:mindValue];
        }else if (model.state == UIDeviceBatteryStateUnplugged) {
            if (mVD < -3) {
                AIMindValueModel *mindValue = [[AIMindValueModel alloc] init];
                mindValue.type = MindType_Hunger;//产生饥饿感
                mindValue.value = mVD;
                [AIMindValueStore insert:mindValue awareness:true];//logThink
                [theThink commitMindValueChanged:mindValue];
            }
        }
    }
}

-(void) mine_HungerStateChanged:(AIHungerStateChangedModel*)model{
    if (model) {
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
                //1,查询当前未处理的需求;看有没被解决掉;
                //2,思考充电状态与电量增加的逻辑关系;
                
                NSLog(@"_____%f",[UIDevice currentDevice].batteryLevel);
                
            }
        }
    }
}

@end
