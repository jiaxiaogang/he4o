//
//  AIActionControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIActionControl.h"
#import "AINetModel.h"
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

-(void) searchModel:(id)model block:(void(^)(AINetModel *result))block {
    //1. 事务控制器负责协调action任务;
    
    //2. 将类比检索数据
    if (ISOK(model, AIStringAlgsModel.class)) {
        AINetModel *result =  [theNet searchWithModel:model];
        if (block) {
            block(result);
        }
    }else if(ISOK(model, AIInputMindValueAlgsModel.class)) {
        AINetModel *result =  [theNet searchWithModel:model];
        if (block) {
            block(result);
        }
    }
}

-(void) updateNetModel:(AINetModel*)model{
    [theNet updateNetModel:model];
}

-(void) insertModel:(AIModel*)model{
    [theNet insertModel:model];
}

@end
