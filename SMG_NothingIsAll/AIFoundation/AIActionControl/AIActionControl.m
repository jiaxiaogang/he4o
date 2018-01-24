//
//  AIActionControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIActionControl.h"
#import "AINode.h"
#import "AIStringAlgs.h"
#import "PINCache.h"
#import "AIInputMindValue.h"
#import "AIInputMindValueAlgs.h"
#import "AIStringAlgsModel.h"
#import "AIInputMindValueAlgsModel.h"
#import "AINet.h"

@implementation AIActionControl

static AIActionControl *_instance;
+(AIActionControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIActionControl alloc] init];
    }
    return _instance;
}

-(void) commitInput:(id)input{
    if (input) {
        //1. 调用算法处理
        if (ISOK(input, [NSString class])) {
            [AIStringAlgs commitInput:input];
        }else if(ISOK(input, [AIInputMindValue class])) {
            [AIInputMindValueAlgs commitInput:input];
        }
    }
}

-(void) searchModel_Induction:(id)model block:(void(^)(AINode *result))block {
    //1. 事务控制器负责协调action任务;
    
    //2. 将类比检索数据
    if (ISOK(model, AIStringAlgsModel.class)) {
        AINode *result =  [theNet searchWithModel:model];
        if (block) {
            block(result);
        }
    }
}

-(void) searchModel_Logic:(AIInputMindValueAlgsModel*)model block:(void(^)(AINode *result))block {
    //1. 事务控制器负责协调action任务;
    //2. 将类比检索数据
    AINode *result =  [theNet searchLogic:model];
    if (block) {
        block(result);
    }
}

-(void) updateNetModel:(AINode*)model{
    [theNet updateNetModel:model];
}

-(AINode*) insertModel:(AIModel*)model{
    //[theNet insertObj:@(0)];//测试插入obj;
    return [theNet insertModel:model energy:10];
}

@end

//1. 联想点亮区域
//NSArray *lightAreaArr = [SMGUtils lightArea_LightModels:models];
//[SMGUtils lightArea_AILineTypeIsLaw:thinkModel];
