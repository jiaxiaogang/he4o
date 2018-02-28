//
//  AIThinkingControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIThinkingControl.h"
#import "AINet.h"
#import "AIStringAlgsModel.h"
#import "ImvAlgsModelBase.h"
#import "AIActionControl.h"
#import "AINode.h"
#import "AIModel.h"
#import "NSObject+Extension.h"

@interface AIThinkingControl()

@property (strong,nonatomic) NSMutableArray *cacheShort;//存AIModel(从Algs传入,待Thinking取用分析)(容量8);
@property (strong,nonatomic) NSMutableArray *cacheLong;//存AINode(相当于Net的缓存区)(容量10000);

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
    self.cacheShort = [[NSMutableArray alloc] init];
    self.cacheLong = [[NSMutableArray alloc] init];
}

-(void) initRun{
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) commitInput:(NSObject*)algsModel{
    //1. 数据
    NSDictionary *algsDic = [NSObject getDic:algsModel containParent:true];
    NSMutableDictionary *nodeDic = [[NSMutableDictionary alloc] init];
    
    //2. 构建algsModel并收集node;
    if (algsDic) {
        //2.1 构建节点
        NSString *dataType = NSStringFromClass(algsModel.class);
        AINode *identNode = [self createIdentNode:dataType];
        if (identNode) [nodeDic setObject:identNode forKey:@"identNode"];
        
        //2.2 构建属性
        NSMutableArray *pptNodes = [[NSMutableArray alloc] init];
        int energy = 0;
        for (NSString *dataSource in algsDic.allKeys) {
            if ([@"urgentValue" isEqualToString:dataSource]) {//imv检查
                NSInteger urgentValue = [NUMTOOK([algsDic objectForKey:@"urgentValue"]) integerValue];
                energy = 10;
            }else if([@"targetType" isEqualToString:dataSource]) {
                AITargetType targetType = [NUMTOOK([algsDic objectForKey:@"targetType"]) intValue];
                energy = 20;
            }
            
            AINode *pptNode = [self createPropertyNode:[algsDic objectForKey:dataSource] dataSource:dataSource identNode:identNode];
            if (pptNode) [pptNodes addObject:pptNode];
        }
        [nodeDic setObject:pptNodes forKey:@"pptNodes"];
        
        //2.3 构建change和logic链 (对各种change,用潜意识流logic串起来)
        
    }
    
    
    //因algsDic定义只是存储结构,并非归纳结构,所以应类比Law,并thinkingRIN后,再产生归纳结构网络;//xxx
    //shortCaches和longCaches中存储的也是RIN后的数据,而非algsDic;//xxx
    
    
    //3. 存cacheShort
    [self setObject_Caches:nodeDic];
    
    //4. 提交思维循环
    [self thinkLoop:nodeDic];
}


/**
 *  MARK:--------------------思维循环--------------------
 *  1. 优化级;(经验->多事务分析->感觉猜测->cacheShort瞎关联)
 *  2. 符合度;(99%->1%)
 *  3. 类比原则:先用dataType和dataSource取,后存,再类比后作update结构化;
 */
-(void) thinkLoop:(NSDictionary*)nodeDic {
    if (nodeDic) {
        //1. 取mv
        
        //2. 联想mv
        
        //3. 根据cmv查找结果进行类比解决问题 (对导致cmv变化的change,进行类比缩小范围)
        
        //4. 对缩小范围的change用显意识流logic串起来;
        
        //5. 将类比到的数据构建与关联;
        
        //6. 进行思维mv循环
        
        //7. 进行决策输出
        
        
    }
}

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
        AIActionControl *ac = [AIActionControl shareInstance];
        //1. 转换为aiModel
        AIModel *pptModel = [self createPropertyModel:pptObj];
        //2. 构建节点
        AINode *pptNode = [self createNode:pptModel dataSource:dataSource];
        //3. 指定属性
        [ac updateNode:identNode propertyNode:pptNode];
        return pptNode;
    }
    return nil;
}

-(AINode*) createChangeNode:(id)changeObj dataSource:(NSString*)dataSource identNode:(AINode*)identNode{
    if (changeObj && identNode) {
        AIActionControl *ac = [AIActionControl shareInstance];
        //1. 转换为aiModel
        AIChangeModel *changeModel = [[AIChangeModel alloc] init];//临时,随后补上;
        //2. 构建节点
        AINode *changeNode = [self createNode:changeModel dataSource:dataSource];
        //3. 指定属性
        [ac updateNode:identNode changeNode:changeNode];
        return changeNode;
    }
    return nil;
}

-(AINode*) createNode:(AIModel*)model dataSource:(NSString*)dataSource{
    if (model) {
        AIActionControl *ac = [AIActionControl shareInstance];
        //1. 取抽象节点
        AINode *absNode = [ac searchNodeForDataType:model.getDataType dataSource:dataSource autoCreate:model];
        //2. 构建节点
        AINode *node = [ac insertModel:model dataSource:dataSource];
        //3. 指定抽象
        if (absNode) [ac updateNode:node abs:absNode];
        return node;
    }
    return nil;
}

//MARK:===============================================================
//MARK:                     < caches >
//MARK:===============================================================
-(void) setObject_Caches:(NSObject*)algsModel {
    [self.cacheShort addObject:algsModel];
    
    if (self.cacheShort.count > 8) {
        [self.cacheShort subarrayWithRange:NSMakeRange(self.cacheShort.count - 8, 8)];
    }
}

//found mv;
-(BOOL) checkHavMV:(NSDictionary*)dic{
    return [STRTOOK([DICTOOK(dic) objectForKey:@"urgentValue"]) floatValue] > 0;
}

@end


//3. ThinkDemand的解;
//1,依赖于经验等数据;
//2,依赖与常识的简单解决方案;(类比)
//3,复杂的问题分析(多事务,加缓存,加分析)


//4. 老旧思维解决问题方式
//A. 搜索强化经验(经验表)
    //1),参照解决方式,
    //2),类比其常识,
    //3),制定新的解决方式,
    //4),并分析其可行性, & 修正
    //5),预测其结果;(经验中上次的步骤对比)
    //6),执行输出;
//B. 搜索未强化经历(意识流)
    //1),参照记忆,
    //2),尝试执行输出;
    //3),反馈(观察整个执行过程)
    //4),强化(哪些步骤是必须,哪些步骤是有关,哪些步骤是无关)
    //5),转移到经验表;
//C. 无
    //1),取原始情绪表达方式(哭,笑)(是急哭的吗?)
    //3),记忆(观察整个执行过程)


//5. 忙碌状态;
//-(BOOL) isBusy{return false;}

//6. 单次为比的结果;
//@property (assign, nonatomic) ComparisonType comparisonType;    //比较结果(toFeelId/fromFeelId)
