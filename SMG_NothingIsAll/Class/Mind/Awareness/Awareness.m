//
//  Awareness.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Awareness.h"
#import "ThinkHeader.h"

@interface Awareness ()

@property (strong,nonatomic) Demand *demand;
@property (assign, nonatomic) NSInteger count;

@end

@implementation Awareness

-(void) commitMindModelToCheck:(id)model{
    if (model) {
        if ([model isKindOfClass:[AIHungerLevelChangedModel class]]) {
            AIHungerLevelChangedModel *lModel = (AIHungerLevelChangedModel*)model;
            //1,取数据
            AIMindValueModel *mindValue = [theMind getMindValueWithHungerLevelChanged:lModel];//(参考N3P18)
            //2,分析决策A_(可产生需求)
            if (lModel.state == UIDeviceBatteryStateCharging || (lModel.state == UIDeviceBatteryStateUnplugged && lModel.level < 7)) {
                [AIHungerLevelChangedStore insert:model awareness:true];//logThink记忆饿的意识流
                [AIMindValueStore insert:mindValue awareness:true];
            }
        }else if([model isKindOfClass:[AIHungerStateChangedModel class]]){
            //1,取数据
            AIHungerStateChangedModel *sModel = (AIHungerStateChangedModel*)model;
            
            //2,分析决策A_(是否产生需求)
            [AIHungerLevelChangedStore insert:sModel awareness:true];//logThink记忆充电状态变化的意识流;
            
            //3,分析决策B_(是否执行需求)
            /**
             *  //1,查询当前未处理的需求;看有没被解决掉;
             *  //2,思考充电状态与电量增加的逻辑关系;
             *  //3,充上电,只会记录状态变化;而充上电加电后,才会真正知道充上电与充电的逻辑关系;
             *  //4,充上电后,到commitMindModel根据AILine查找关联的MindValueModel;如果找到,再计算AIMindValueModel.value产生需求;;
             *
             *  //AIMindValueModel *mindValue = [theMind getMindValueWithHungerStateChanged:sModel];//(参考N3P18)
             *  //[AIMindValueStore insert:mindValue awareness:true];
             */
            [theThink commitMindModel:model mindValueModel:nil];
            
        }
    }
}

-(void) run{
    //1,开始异步搜索IO任务;(xx秒一次的内省)
    __block Awareness *weakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(600.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runByHeartbeat];
        [self run];
    });
    
    //2,监听意识流的数据变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runByAwarnessModelNotice:) name:ObsKey_AwarenessModelChanged object:nil];
    
}

/**
 *  MARK:--------------------property--------------------
 */
- (Demand *)demand{
    if (_demand == nil) {
        _demand = [[Demand alloc] init];
    }
    return _demand;
}


/**
 *  MARK:--------------------method--------------------
 */
//600s/"意识心跳" 1,需求分析 2,整理抽象???
-(void) runByHeartbeat{
    self.count ++;
    NSInteger analyzeCount = (self.count % 10 == 0) ? 200 : 50;//9短1长;
    
    if (theMainThread.isBusy == false) {//意识线程处理;
        [theMainThread setIsBusy:true];
        [self.demand runAnalyze:analyzeCount];
        [theMainThread setIsBusy:false];
    }
}

//意识流数据变化时"区域点亮"
-(void) runByAwarnessModelNotice:(NSNotification*)notification{
    //1. 区域点亮(根据不同IO性能点亮区域大小自定)
    //2. 预测与真实的变化引发的注意力;
    //3. 引起变化后的索引生成;
    //4. 索引的搜索;
    //5. 搜索结果的数据处理(类比分析与抽象等);
    //6. "数据处理结果"的AILine生成与AILine.Strong;
    //7.
    [self.demand runAnalyze:1];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ObsKey_AwarenessModelChanged object:nil];
}
@end
