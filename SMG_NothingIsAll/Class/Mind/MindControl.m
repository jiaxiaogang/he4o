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
        if (self.delegate && [self.delegate respondsToSelector:@selector(mindControl_CommitDecisionByDemand:withType:)]) {
            [self.delegate mindControl_CommitDecisionByDemand:@"怼他" withType:MindType_Angry];
        }
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(mindControl_CommitDecisionByDemand:withType:)]) {
            [self.delegate mindControl_CommitDecisionByDemand:@"大笑" withType:MindType_Happy];
        }
    }
    
    //*  value:数据类型未定;
    //*      1,从经验和长期记忆搜索有改变mindValue的记录;
    //*      2,根据当前自己的状态;
    //*      3,计算出一个值;并返回;
    return nil;
}

-(NSString*) turnDownDemand:(id)demand type:(MindType)type{
    CGFloat mindValueDelta = [NUMTOOK(demand) floatValue];
    if (mindValueDelta > 1) {
        return @"😃";
    }else if(mindValueDelta < -1){
        return @"😭";
    }
    return nil;
}

/**
 *  MARK:--------------------MineDelegate--------------------
 */
-(void)mine_HungerStateChanged:(HungerStatus)status{
    NSLog(@"Mind_产生充电需求");
    id demand;
    if (status == HungerStatus_LitterHunger) {
        demand = [DemandFactory createDemand];
    }else if (status == HungerStatus_Hunger) {
        demand = [DemandFactory createDemand];
    }else if (status == HungerStatus_VeryHunger) {
        demand = [DemandFactory createDemand];
    }else if (status == HungerStatus_VeryVeryHunger) {
        demand = [DemandFactory createDemand];
    }
    //执行任务分析决策
    if (demand) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mindControl_CommitDecisionByDemand:withType:)]) {
            [self.delegate mindControl_CommitDecisionByDemand:demand withType:MindType_Hunger];
        }
    }
    
    
    //思考2:当A在偷吃你的苹果时;你理解的重点是;他是不是吃的你的苹果;吃了多少;等相关信息;
    //注意力,
    //但Input输入A吃苹果时,Understand先理解并分析出苹果的归属及整个事件;然后交由Mind决定是不是打死他;(Mind需要的信息:A是谁,在作什么,吃了谁的什么);
    //假如是其它事情呢;我需要找到一种万能的方式去解决Mind的控制流程;而不是把数据全部传过来作处理;Mind从职责上;只负责送出自己的精神层面的值;分析结果应该是Think层的事;
    
    //思考3:
    //接上疑问;有别人吃你的水果;
    //影响反应结果的因素:
    //1,不同的人吃,影响结果;(亲朋吃则无所谓)__对人的hobby
    //2,我对此水果的喜好,影响结果;(吃我的苹果可以,香蕉不行!)__对物的hobby
    //3,我对此水果的来源,影响结果;(有些来之不易,有些来自平安夜的礼物)__对物关联(附加价值)的hobby
    //4,我自己饥饿程度,影响结果;(我饱着,你随便吃,我饿着,不行!)__物对已的需求程度
    //总结:各种Mind中因素相互博弈的结果;(有一个策略影响着整个过程)
    
    
}

-(void) mine_HungerLevelChanged:(CGFloat)level State:(UIDeviceBatteryState)state mindValueDelta:(CGFloat)mVD{
    //1,记忆引起变化的原因;
    //2,分析决策 & 产生需求
    if (state == UIDeviceBatteryStateCharging) {
        [MBProgressHUD showSuccess:@"饱一滴血!" toView:nil withHideDelay:1];
    }else if (state == UIDeviceBatteryStateUnplugged) {
        [MBProgressHUD showSuccess:@"饿一滴血!" toView:nil withHideDelay:1];
        if (level < 0.3f) {
            [self.delegate mindControl_CommitDecisionByDemand:@(mVD) withType:MindType_Hunger];//不能过度依赖noLogThink来执行,应更依赖logThink;
        }
    }
}

-(void) mine_HungerStateChanged:(UIDeviceBatteryState)state level:(CGFloat)level mindValueDelta:(CGFloat)mVD{
    //1,记忆引起变化的原因;
    //2,分析决策 & 产生需求
    if (state == UIDeviceBatteryStateUnplugged) {//未充电
        if (level == 1.0f) {
            [MBProgressHUD showSuccess:@"饱了..." toView:nil withHideDelay:1];
        }else if(level > 0.7f){
            [MBProgressHUD showSuccess:@"好吧,下次再充..." toView:nil withHideDelay:1];
        }else if(level < 0.7f){
            [MBProgressHUD showSuccess:@"还没饱呢" toView:nil withHideDelay:1];
        }
    }else if (state == UIDeviceBatteryStateCharging) {//充电中
        if (level == 1.0f) {
            [MBProgressHUD showSuccess:@"饱了..." toView:nil withHideDelay:1];
        }else if(level > 0.7f){
            [MBProgressHUD showSuccess:@"好吧,再充些..." toView:nil withHideDelay:1];
        }else if(level < 0.7f){
            [MBProgressHUD showSuccess:@"谢谢呢!" toView:nil withHideDelay:1];
        }
    }else if (state == UIDeviceBatteryStateFull) {//满电
        [MBProgressHUD showSuccess:@"满了,帮我拔下电线" toView:nil withHideDelay:1];
    }
}


-(void) tmpTest_Add{
    CGFloat level = 0.23f;
    CGFloat mVD = (level - 1) * 10.0f;
    [self mine_HungerLevelChanged:level State:UIDeviceBatteryStateCharging mindValueDelta:mVD];
}

-(void) tmpTest_Sub{
    CGFloat level = 0.23f;
    CGFloat mVD = (level - 1) * 10.0f;
    [self mine_HungerLevelChanged:level State:UIDeviceBatteryStateUnplugged mindValueDelta:mVD];
}

-(void) tmpTest_Start{
    CGFloat level = [UIDevice currentDevice].batteryLevel;
    CGFloat mvD = 0;
    if (level == 1.0f) {
        mvD = -1;//mindValue -= 1 (饱了)
    }else if(level > 0.7f){
        mvD = 0;//mindValue == (再充饱点)
    }else if(level < 0.7f){
        mvD = (1 - level) * 10.0f;//mindValue += x (未饱再吃点)
    }
    
    [self mine_HungerStateChanged:UIDeviceBatteryStateCharging level:0 mindValueDelta:0];
}

-(void) tmpTest_Stop {
    CGFloat level = [UIDevice currentDevice].batteryLevel;
    CGFloat mvD = 0;
    if (level == 1.0f) {
        mvD = 1;//mindValue += 1 (饱了停充)
    }else if(level > 0.7f){
        mvD = 0;//mindValue == (7成饱停充)
    }else if(level < 0.7f){
        mvD = (level - 1) * 10.0f;//mindValue -= x (没饱停充)
    }
    [self mine_HungerStateChanged:UIDeviceBatteryStateUnplugged level:0 mindValueDelta:0];
}

@end
