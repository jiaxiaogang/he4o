//
//  AITime.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AITime.h"

//@interface AITime ()
//@property (strong,nonatomic) NSTimer *timer;            //计时器
//@end

@implementation AITime

//-(id) init{
//    self = [super init];
//    if (self) {
//        [self initData];
//    }
//    return self;
//}
//
//-(void) initData{
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
//}
//
////MARK:===============================================================
////MARK:                     < privateMethod >
////MARK:===============================================================
//- (void)notificationTimer{
//    NSLog(@"AITime触发器触发");
//}

/**
 *  MARK:--------------------生物钟触发器--------------------
 *  @callers
 *      1. demand.ActYes处 (等待外循环mv抵消);
 *      2. 行为化Hav().HNGL.ActYes处 (等待外循环输入符合HNGL的概念)
 *      3. 行为输出ActYes处 (等待外循环输入推进下一帧概念)
 *
 *  @version
 *      2020.08.14: 支持生物钟触发器;
 *          1. timer计时器触发,取deltaT x 1.3时间;
 *          2. "计时触发"时,对触发者的ActYes状态进行判断,如果还未由外循环实际输入,则"实际触发";
 *          3. 实际触发后,对预想时序fo 与 实际时序fo 进行反省类比;
 *          x. 当outModel中某时序完成时,则追回(销毁)与其对应的触发器 (废弃,不用销毁,改变status状态即可);
 *          x. 直到触发时,还未销毁,则说明实际时序并未完成,此时调用反省类比 (废弃,由tor_OPushM()来做状态改变即可);
 *      2020.08.23: 改为由TOFoModel中setTimeTrigger方法替代;
 *      2020.09.03: 支持不设触发条件时,默认必触发的重载;
 *      2021.03.16: 把triggerTime设为最大20s,以方便训练测试阶段等太慢;
 *
 *  @bug
 *      2020.09.26: 21053BUG-此处将单位s当做ms来计算,结果导致反省类比总是触发不了P,只有S;
 *
 *  @param deltaTime : 原本间隔时长,单位s
 *  _param canTrigger : 触发条件;
 *  @todo
 *      2021.02.05: 换[NSTimer scheduledTimerWithTimeInterval:time repeats:false block:^(NSTimer *timer){}]更准时;
 *      2021.03.16: 把triggerTime最大20s的设定删掉;
 *      2021.10.16: 通过延长触发时间,试图绕过TC卡顿的问题 (参考24058-方案2) (关闭状态,因为优先尝试方案1);
 *      2023.03.04: 将时间x2+1,改成x1.1+2 (参考28151-调试&修复);
 *      2023.07.20: 有时执行trigger时会提前release掉内存,所以由TC线程改为main线程执行;
 *      2023.07.21: 思维部分本来就该在TC线程执行,trigger后也是思维代码,所以改回在TC线程 (为防止提前release,加了_block保留);
 */
+(void) setTimeTrigger:(NSTimeInterval)deltaTime trigger:(void(^)())trigger{
    //1. 数据检查
    if (!trigger) return;
    
    //2. 用after延迟定时deltaT x 1.3触发;
    CGFloat triggerTime = deltaTime * 1.1f + 2.0f;//当24058-方案1不成时,此处方案2再做为备启用,即将1.0调整为3甚至5;
    triggerTime = MIN(triggerTime, 20.0f);
    //NSLog(@"---> 设定生物钟触发器: deltaTime:%.2f triggerTime:%.2f",deltaTime,triggerTime);
    __block Act0 weakTrigger = trigger;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(triggerTime * NSEC_PER_SEC)), theTC.tiQueue, ^{
        //3. 触发时,判断是否还是actYes状态 (在OuterPushMiddleLoop()中,会将ActYes且符合,且PM算法成功的,改为Finish);
        weakTrigger();
    });
}

@end
