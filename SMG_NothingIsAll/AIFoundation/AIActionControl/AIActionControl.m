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
#import "AIImvAlgs.h"
#import "AICustomAlgs.h"
#import "AIStringAlgsModel.h"
#import "ImvAlgsModelBase.h"
#import "AINet.h"
#import "AIModel.h"

@implementation AIActionControl

static AIActionControl *_instance;
+(AIActionControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIActionControl alloc] init];
    }
    return _instance;
}

-(void) commitInput:(id)input{
    if (ISOK(input, [NSString class])) {
        [AIStringAlgs commitInput:input];
    }
}

-(void) commitInputIMV:(IMVType)type value:(NSInteger)value{
    [AIImvAlgs commitInputIMV:type value:value];
}

-(void) commitCustom:(CustomInputType)type value:(NSInteger)value{
    [AICustomAlgs commitCustom:type value:value];
}


//MARK:===============================================================
//MARK:                     < search >
//MARK:===============================================================
//1. 事务控制器负责协调action任务;
//2. 将类比检索数据
-(AINode*) searchNodeForDataType:(NSString*)dataType dataSource:(NSString *)dataSource{
    return [[AINet sharedInstance] searchNodeForDataType:dataType dataSource:dataSource];
}

-(AINode*) searchNodeForDataType:(NSString*)dataType dataSource:(NSString *)dataSource autoCreate:(AIModel*)createModel{
    AINode *absNode = [self searchNodeForDataType:dataType dataSource:dataSource];
    if (absNode && !ARRISOK(absNode.conPorts)) {
        AINode *newAbsNode = [self insertModel:createModel dataSource:nil];//构建抽象点仅指定dataType
        [self updateNode:absNode abs:newAbsNode];
        return newAbsNode;
    }
    return absNode;
}

-(AINode*) searchNodeForDataModel:(AIModel*)model {
    return [[AINet sharedInstance] searchNodeForDataModel:model];
}

-(AINode*) searchNodeForDataObj:(id)obj {
    return [[AINet sharedInstance] searchNodeForDataObj:obj];
}


//MARK:===============================================================
//MARK:                     < insert >
//MARK:===============================================================
-(AINode*) insertModel:(AIModel*)model dataSource:(NSString*)dataSource{
    return [theNet insertModel:model dataSource:dataSource energy:10];
}


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNetModel:(AINode*)model{
    [theNet updateNetModel:model];
}

-(void) updateNode:(AINode*)node abs:(AINode*)abs{
    [[AINet sharedInstance] updateNode:node abs:abs];
}

-(void) updateNode:(AINode *)node propertyNode:(AINode *)propertyNode{
    [[AINet sharedInstance] updateNode:node propertyNode:propertyNode];
}

-(void) updateNode:(AINode *)node changeNode:(AINode *)changeNode{
    [[AINet sharedInstance] updateNode:node changeNode:changeNode];
}

-(void) updateNode:(AINode *)node logicNode:(AINode *)logicNode{
    [[AINet sharedInstance] updateNode:node logicNode:logicNode];
}


//MARK:===============================================================
//MARK:                     < create >
//MARK:===============================================================
-(AIModel*) createPropertyModel:(id)propertyObj{
    AIModel *pptModel = nil;
    if (propertyObj) {
        if([propertyObj isKindOfClass:[NSNumber class]]){
            if (strcmp([propertyObj objCType], @encode(char)) == 0){
                AICharModel *charModel = [[AICharModel alloc] init];
                charModel.c = [(NSNumber*)propertyObj charValue];
                pptModel = charModel;
            }else if (strcmp([propertyObj objCType], @encode(int)) == 0 || strcmp([propertyObj objCType], @encode(NSInteger)) == 0){
                int value = [(NSNumber*)propertyObj intValue];
                pptModel = [AIIntModel newWithFrom:value to:value];
            }else if (strcmp([propertyObj objCType], @encode(float)) == 0){
                float value = [(NSNumber*)propertyObj floatValue];
                pptModel = [AIFloatModel newWithFrom:value to:value];
            }else{
                NSLog(@"_________输入了其它类型:%s",[propertyObj objCType]);
            }
        }
    }
    return pptModel;
}

-(AINode*) createIdentNode:(NSString*)dataType{
    AIIdentifierModel *identModel = [AIIdentifierModel newWithIdentifier:STRTOOK(dataType)];//AIModel对象
    return [self createNode:identModel dataSource:nil];
}

-(AINode*) createPropertyNode:(id)pptObj dataSource:(NSString*)dataSource identNode:(AINode*)identNode{
    if (pptObj && identNode) {
        //1. 转换为aiModel
        AIModel *pptModel = [self createPropertyModel:pptObj];
        //2. 构建节点
        AINode *pptNode = [self createNode:pptModel dataSource:dataSource];
        //3. 指定属性
        [self updateNode:identNode propertyNode:pptNode];
        return pptNode;
    }
    return nil;
}

-(AINode*) createChangeNode:(id)changeObj dataSource:(NSString*)dataSource identNode:(AINode*)identNode{
    if (changeObj && identNode) {
        //1. 转换为aiModel
        AIChangeModel *changeModel = [[AIChangeModel alloc] init];//临时,随后补上;
        //2. 构建节点
        AINode *changeNode = [self createNode:changeModel dataSource:dataSource];
        //3. 指定属性
        [self updateNode:identNode changeNode:changeNode];
        return changeNode;
    }
    return nil;
}

-(AINode*) createNode:(AIModel*)model dataSource:(NSString*)dataSource{
    if (model) {
        //1. 取抽象节点
        AINode *absNode = [self searchNodeForDataType:model.getDataType dataSource:dataSource autoCreate:model];
        //2. 构建节点
        AINode *node = [self insertModel:model dataSource:dataSource];
        //3. 指定抽象
        if (absNode) [self updateNode:node abs:absNode];
        return node;
    }
    return nil;
}

@end

//1. 联想点亮区域
//NSArray *lightAreaArr = [SMGUtils lightArea_LightModels:models];
//[SMGUtils lightArea_AILineTypeIsLaw:thinkModel];
