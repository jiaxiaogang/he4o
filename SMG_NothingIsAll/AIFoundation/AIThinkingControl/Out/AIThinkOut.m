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
 *  MARK:--------------------topV2--------------------
 *  @desc
 *      1. 四种(2x2)TOP模式 (优先取同区工作模式,不行再以不同区工作模式);
 *      2. 调用者只管调用触发,模型生成,参数保留;
 *  @version
 *      20200430 : v2,四种工作模式版;
 *      20200824 : 将外循环输入推进中循环,改到上一步aiThinkIn_Commit2TC()中;
 *  @todo
 *      1. 集成活跃度的判断和消耗;
 *      2. 集成outModel;
 *      3. TODOTOMORROW: 下面传给四模式的代码,用bool方式直接返回finish的判断不妥,改之;
 *      2021.01.22: 对ActYes或者OutBack的Demand进行不应期处理 (未完成);
 */
-(void) dataOut{
    //1. 数据准备
    DemandModel *demand = [theTC.outModelManager getCanDecisionDemand];
    NSArray *mModels = theTC.inModelManager.models;
    if (!demand || !ARRISOK(mModels)) return;
    
    //2. 同区两个模式之R-;
    if (ISOK(demand, ReasonDemandModel.class)) {
        //a. R-
        [self.tOR reasonSubV3:(ReasonDemandModel*)demand];
        
        //b. R+
        ////3. 同区两个模式之R+ (以最近的预测为准);
        //for (NSInteger i = 0; i < mModels.count; i++) {
        //    AIShortMatchModel *mModel = ARR_INDEX_REVERSE(mModels, i);
        //    AIFoNodeBase *matchFo = mModel.matchFo;
        //
        //    //a.预测有效性判断和同区判断 (以预测的正负为准);
        //    if (matchFo && matchFo.cmvNode_p && [demand.algsType isEqualToString:matchFo.cmvNode_p.algsType]) {
        //        CGFloat score = [AIScore score4MV:mModel.matchFo.cmvNode_p ratio:mModel.matchFoValue];
        //        //b. R+
        //        if (score > 0) {
        //            BOOL success = [self reasonPlus:mModel demandModel:demand];
        //            NSLog(@"topV2_R+ : %@",success ? @"成功":@"失败");
        //            if (success) return;
        //        }
        //    }
        //}
    }else{
        //3. 不同区两个模式 (以最近的识别优先);
        for (NSInteger i = 0; i < mModels.count; i++) {
            AIShortMatchModel *mModel = ARR_INDEX_REVERSE(mModels, i);
            AIAlgNodeBase *matchAlg = mModel.matchAlg;
            
            //a. 识别有效性判断 (优先直接mv+,不行再mv-迂回);
            if (matchAlg) {
                //b. P-
                BOOL pSuccess = [self.tOP perceptSub:demand];
                NSLog(@"topV2_P+ => %@ => %@",Alg2FStr(matchAlg),pSuccess ? @"成功":@"失败");
                if (pSuccess) return;
                
                //c. P+
                BOOL sSuccess = [self.tOP perceptPlus:matchAlg demandModel:demand];
                NSLog(@"topV2_P- => %@ => %@",Alg2FStr(matchAlg),sSuccess ? @"成功":@"失败");
                if (sSuccess) return;
            }
        }
    }
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
        [self.tOP perceptSub:demand];
    }else if (ISOK(demand, ReasonDemandModel.class)) {
        [self.tOR reasonSubV3:(ReasonDemandModel*)demand];
    }
}

/**
 *  MARK:--------------------AIThinkOutPerceptDelegate--------------------
 */
-(void) aiTOP_2TOR_PerceptSub:(TOFoModel *)outModel{
    //1. 行为化;
    [self.tOR commitPerceptSub:outModel];
}

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
-(AIShortMatchModel*) aiTOR_RethinkInnerFo:(AIFoNodeBase*)fo{
    return [self.delegate aiTO_RethinkInnerFo:fo];
}
-(void) aiTOR_MoveForDemand:(DemandModel*)demand{
    [self commitFromTOR_MoveForDemand:demand];
}

@end
