//
//  AIThinkingControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIThinkingControl.h"
#import "AINet.h"
#import "AIHungerLevelChangedModel.h"
#import "AIHungerStateChangedModel.h"
#import "AIMindValue.h"
#import "AIStringAlgsModel.h"
#import "AIInputMindValueAlgsModel.h"
#import "AIActionControl.h"
#import "AINetModel.h"
#import "AIModel.h"

@interface AIThinkingControl()

@property (strong,nonatomic) NSMutableArray *caches;

@end

@implementation AIThinkingControl

static AIThinkingControl *_instance;
+(AIThinkingControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIThinkingControl alloc] init];
    }
    return _instance;
}

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
        [self initRun];
    }
    return self;
}

-(void) initData{
    self.caches = [[NSMutableArray alloc] init];
}

-(void) initRun{
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) activityByShallow:(id)data{
    //1. update Caches;
    [self addObjectToCaches:data];
    
    //2. check data hav mv;
    if ([self objectHavMV:data]) { //hav mv
        [self activityByDeep:nil mvData:data];
        return;
    }
    
    //3. no mv,try find mindValue from caches;
    for (id cache in self.caches) {
        if ([self objectHavMV:cache]) {
            [self activityByDeep:nil mvData:cache];
            return;
        }
    }
    
    //4. if not find mv from caches,then try find actionControl;
    [[AIActionControl shareInstance] searchModel:data type:MultiNetType_Unknown block:^(AINetModel *result) {
        id mvResult = [self objectForNetModelConvertToMV:result];
        if (mvResult) {
            [self activityByDeep:result mvData:mvResult];
        }
    }];
}


/**
 *  MARK:--------------------思维发现imv,制定cmv,分析实现cmv;--------------------
 *  参考:n9p20
 */
-(void) activityByDeep:(AINetModel*)netModel mvData:(id)mvData{
    //1. check mvData;
    if (mvData == nil) {
        return;
    }
    
    //2. 制定cmv目标;
    
    
    //3. updateModel
    [[AIActionControl shareInstance] insertModel:mvData];
    
    //3. 查找其cmv经验;
    [[AIActionControl shareInstance] searchModel:mvData type:MultiNetType_Experience block:^(AINetModel *result) {
        if (result) {
            
        }else{
            
        }
    }];
    
    //4. 关联分析caches和netModel等当前数据;
    
}


-(void) activityByNone:(id)data{
    NSLog(@"创建后台任务");
}

//MARK:===============================================================
//MARK:                     < caches >
//MARK:===============================================================
-(void) addObjectToCaches:(id)data{
    if (data) {
        [self.caches addObject:data];
    }
    if (self.caches.count > 4) {
        [self.caches removeObjectAtIndex:0];
    }
}

//found mv;
-(BOOL) objectHavMV:(id)data{
    return data && (ISOK(data, AIInputMindValueAlgsModel.class));//||MindValue.class
}

-(id) objectForNetModelConvertToMV:(AINetModel*)model{
    if (model) {
        return model;
    }
    return nil;
}

@end
