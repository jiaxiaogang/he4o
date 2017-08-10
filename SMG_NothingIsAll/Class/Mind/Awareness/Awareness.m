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
                
                //3,分析决策B_(需求分析)
                [theThink commitMindModel:model mindValueModel:mindValue];
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
        weakSelf.count ++;
        NSInteger analyzeCount = (weakSelf.count % 10 == 0) ? 200 : 50;//9短1长;
        [self.demand runAnalyze:analyzeCount];
        [self run];
    });
    
    //2,监听意识流的数据变化
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runByAwarnessModelNotice:) name:ObsKey_AwarenessModelChanged object:nil];
    
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
-(void) runByAwarnessModelNotice:(NSNotification*)notification{
    [self.demand runAnalyze:1];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ObsKey_AwarenessModelChanged object:nil];
}
@end
