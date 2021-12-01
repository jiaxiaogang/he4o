//
//  AIThinkOut.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/31.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AIThinkOut.h"
#import "DemandModel.h"
#import "DemandManager.h"
#import "ShortMatchManager.h"
#import "ReasonDemandModel.h"
#import "PerceptDemandModel.h"
#import "AIShortMatchModel.h"
#import "AIThinkOutReason.h"
#import "AIThinkOutPercept.h"
#import "AIAlgNodeBase.h"

@interface AIThinkOut () <AIThinkOutPerceptDelegate,AIThinkOutReasonDelegate>
@end

@implementation AIThinkOut


static AIThinkOut *_instance;
+(AIThinkOut*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIThinkOut alloc] init];
    }
    return _instance;
}

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.tOP = [[AIThinkOutPercept alloc] init];
    self.tOP.delegate = self;
    self.tOR = [[AIThinkOutReason alloc] init];
    self.tOR.delegate = self;
}

/**
 *  MARK:--------------------TOR中Demand方案失败,尝试转移--------------------
 *  @desc 当demand一轮失败时,进行P+递归;
 *  @version
 *      2021.01.21: 支持R-模式;
 */
-(void) commitFromTOR_MoveForDemand:(DemandModel*)demand{
    //1. 识别有效性判断 (转至P-/R-);
    if (ISOK(demand, PerceptDemandModel.class)) {
        [TOSolution pSolution:demand];
    }else if (ISOK(demand, ReasonDemandModel.class)) {
        [self.tOR reasonSubV4:(ReasonDemandModel*)demand];
    }
}

/**
 *  MARK:--------------------AIThinkOutPerceptDelegate--------------------
 */
-(BOOL) aiTOP_2TOR_PerceptPlus:(AIFoNodeBase *)matchFo plusFo:(AIFoNodeBase*)plusFo subFo:(AIFoNodeBase*)subFo checkFo:(AIFoNodeBase*)checkFo{
    //1. 行为化;
    __block BOOL success = false;
    [self.tOR commitPerceptPlus:matchFo plusFo:plusFo subFo:subFo checkFo:checkFo complete:^(BOOL actSuccess, NSArray *acts) {
        success = actSuccess;
        
        //2. 更新到outModel;
        if (actSuccess) {
            //[self.demandManager add]; status为尝试输出,事实input发生后,才会移动到下帧;
        }
        
        //3. 输出行为;
        [self.tOR dataOut_ActionScheme:acts];
    }];
    return success;
}

/**
 *  MARK:--------------------AIThinkOutReasonDelegate--------------------
 */
-(void) aiTOR_MoveForDemand:(DemandModel*)demand{
    [self commitFromTOR_MoveForDemand:demand];
}

@end
