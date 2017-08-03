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

@property (strong,nonatomic) Awareness *awareness;

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
    self.awareness = [[Awareness alloc] init];
}

-(void) initRun{
    self.mine.delegate = self;
    [self.awareness run];
}

/**
 *  MARK:--------------------method--------------------
 */
-(id) getMindValue:(AIPointer*)pointer{
    //xxx这个值还没存;
    int moodValue = (random() % 2) - 1;//所有demand只是简单规则;即将value++;
    if (moodValue < 0) {
        //[theThink commitMindValueNotice:nil withType:0];//@"怼他" withType:MindType_Angry
    }else{
        //[theThink commitMindValueNotice:nil withType:0];//@"大笑" withType:MindType_Happy];
    }
    
    //*  value:数据类型未定;
    //*      1,从经验和长期记忆搜索有改变mindValue的记录;
    //*      2,根据当前自己的状态;
    //*      3,计算出一个值;并返回;
    return nil;
}

-(void) turnDownDemand:(AIDemandModel*)model{
    if (model) {
        [theMood setData:model.value type:MoodType_Irritably2Calm rateBlock:^(Mood *mood) {
            [theOutput output_Face:MoodType_Irritably2Calm value:mood.value];
        }];
    }
}

-(AIMindValueModel*) getMindValueWithHungerLevelChanged:(AIHungerLevelChangedModel*)model{
    return [MindValueUtils getMindValue_HungerLevelChanged:model];
}

-(AIMindValueModel*) getMindValueWithHungerStateChanged:(AIHungerStateChangedModel*)model{
    return [MindValueUtils getMindValue_HungerStateChanged:model];
}

/**
 *  MARK:--------------------MineDelegate--------------------
 */
-(void) mine_HungerLevelChanged:(AIHungerLevelChangedModel*)model{
    if (theMainThread.isBusy) return;//主线程忙,直接返回;
    //1,取数据
    AIMindValueModel *mindValue = [theMind getMindValueWithHungerLevelChanged:model];//(参考N3P18)
    //2,分析决策 & 产生需求
    if (model.state == UIDeviceBatteryStateCharging || (model.state == UIDeviceBatteryStateUnplugged && model.level < 7)) {
        if ([self.awareness tmpCheck:mindValue]) {
            [AIHungerLevelChangedStore insert:model awareness:true];//logThink记忆饿的意识流
            [AIMindValueStore insert:mindValue awareness:true];
            [theThink commitMindModel:model];
        }
    }
}

-(void) mine_HungerStateChanged:(AIHungerStateChangedModel*)model{
    if (theMainThread.isBusy) return;//主线程忙,直接返回;
    
    //1,取数据
    AIMindValueModel *mindValue = [theMind getMindValueWithHungerStateChanged:model];//(参考N3P18)
    if ([self.awareness tmpCheck:mindValue]) {
        //2,分析决策 & 产生需求
        [AIHungerLevelChangedStore insert:model awareness:true];//logThink记忆充电状态变化的意识流;
        [AIMindValueStore insert:mindValue awareness:true];
        //1,查询当前未处理的需求;看有没被解决掉;
        //2,思考充电状态与电量增加的逻辑关系;
        //3,充上电,只会记录状态变化;而充上电加电后,才会真正知道充上电与充电的逻辑关系;
        
        [theThink commitMindModel:model];
    }
    
    
}

@end
