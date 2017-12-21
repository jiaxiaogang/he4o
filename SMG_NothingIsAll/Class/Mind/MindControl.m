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

@interface MindControl ()

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

//-(AIMindValueModel*) getMindValueWithHungerStateChanged:(AIHungerStateChangedModel*)model{
//    return [MindValueUtils getMindValue_HungerStateChanged:model];
//}

/**
 *  MARK:--------------------MineDelegate--------------------
 */
-(void) mine_HungerLevelChanged:(AIHungerLevelChangedModel*)model{
    if (theMainThread.isBusy)
        return;//意识忙,直接返回;
    else
        [self.awareness commitMindModelToCheck:model];
}

-(void) mine_HungerStateChanged:(AIHungerStateChangedModel*)model{
    if (theMainThread.isBusy)
        return;//意识忙,直接返回;
    else
        [self.awareness commitMindModelToCheck:model];
}

@end
