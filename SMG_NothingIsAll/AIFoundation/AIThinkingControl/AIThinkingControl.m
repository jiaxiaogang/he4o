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
-(void) inputByShallow:(NSObject*)algsModel{
    //1. update Caches;
    NSDictionary *dic = [NSObject getDic:algsModel containParent:true];
    NSString *dataType = NSStringFromClass(algsModel.class);
    [self setObject_Caches:algsModel];
    
    //2. check data hav mv;
    if ([self checkHavMV:dic]) {
        [self inputByDeep:dataType mvDic:dic];
        return;
    }
    
    //3. 构建identModel
    AIActionControl *ac = [AIActionControl shareInstance];
    AIIdentifierModel *identModel = [AIIdentifierModel newWithIdentifier:STRTOOK(dataType)];//AIModel对象
    AINode *identAbsNode = [ac searchNodeForDataType:dataType dataSource:nil autoCreate:identModel];
    AINode *identNode = [ac insertModel:identModel dataSource:nil];
    if (identAbsNode) [ac updateNode:identNode abs:identAbsNode];
    
    //4. 构建propertyModel
    for (NSString *dataSource in dic.allKeys) {
        //4.1 根据类型取aiModel
        id pptObj = [dic objectForKey:dataSource];
        AIModel *pptModel = nil;
        if (pptObj) {
            if([pptObj isKindOfClass:[NSNumber class]]){
                if (strcmp([pptObj objCType], @encode(char)) == 0){
                    AICharModel *charModel = [[AICharModel alloc] init];
                    charModel.c = [(NSNumber*)pptObj charValue];
                    pptModel = charModel;
                }else if (strcmp([pptObj objCType], @encode(int)) == 0 || strcmp([pptObj objCType], @encode(NSInteger)) == 0){
                    int value = [(NSNumber*)pptObj intValue];
                    pptModel = [AIIntModel newWithFrom:value to:value];
                }else if (strcmp([pptObj objCType], @encode(float)) == 0){
                    float value = [(NSNumber*)pptObj floatValue];
                    pptModel = [AIFloatModel newWithFrom:value to:value];
                }
            }
        }
        //4.2 构建网络
        if (pptModel) {
            AINode *pptAbsNode = [ac searchNodeForDataType:NSStringFromClass(pptModel.class) dataSource:dataSource autoCreate:pptModel];
            AINode *pptNode = [ac insertModel:pptModel dataSource:dataSource];
            [ac updateNode:identNode propertyNode:pptNode];
            if (pptAbsNode) [ac updateNode:pptNode abs:pptAbsNode];
        }else{
            NSLog(@"_________输入了其它类型:%s",[pptObj objCType]);
        }
        
        //5. 联想mv
        
    }
}


/**
 *  MARK:--------------------思维发现imv,制定cmv,分析实现cmv;--------------------
 *  参考:n9p20
 */
-(void) inputByDeep:(NSString*)dataType mvDic:(NSDictionary*)mvDic {
    //1. 数据
    AIIdentifierModel *identModel = [AIIdentifierModel newWithIdentifier:STRTOOK(dataType)];//AIModel对象
    CGFloat urgentValue = [NUMTOOK([DICTOOK(mvDic) objectForKey:@"urgentValue"]) floatValue];//取mv
    AITargetType targetType = [NUMTOOK([DICTOOK(mvDic) objectForKey:@"targetType"]) intValue];//取targetType
    AIIntModel *targetTypeModel = [AIIntModel newWithFrom:targetType to:targetType];//targetType属性
    AIFloatModel *urgentValueModel = [AIFloatModel newWithFrom:urgentValue to:urgentValue];//urgentValue属性
    AIActionControl *ac = [AIActionControl shareInstance];
    
    //2. 类比到identAbsNode
    AINode *identAbsNode = [ac searchNodeForDataType:dataType dataSource:nil autoCreate:identModel];
    AINode *targetTypeAbsNode = [ac searchNodeForDataType:@"AIIntModel" dataSource:@"targetType" autoCreate:targetTypeModel];
    AINode *urgentValueAbsNode = [ac searchNodeForDataType:@"AIFloatModel" dataSource:@"urgentValue" autoCreate:urgentValueModel];
    
    //3. 构建对象和属性
    AINode *identNode = [ac insertModel:identModel dataSource:nil];
    AINode *targetTypeNode = [ac insertModel:targetTypeModel dataSource:@"targetType"];
    AINode *urgentValueNode = [ac insertModel:urgentValueModel dataSource:@"urgentValue"];
    
    //4. 指定属性
    [ac updateNode:identNode propertyNode:targetTypeNode];
    [ac updateNode:identNode propertyNode:urgentValueNode];
    
    //5. 指定抽象点
    if (identAbsNode) [ac updateNode:identNode abs:identAbsNode];
    if (targetTypeAbsNode) [ac updateNode:targetTypeNode abs:targetTypeAbsNode];
    if (urgentValueAbsNode) [ac updateNode:urgentValueNode abs:urgentValueAbsNode];
    
    //6. 根据cmv查找结果进行类比解决问题 对 (类比符合度从100%->0%,经验优先,分析+多事务次之,猜测或感觉再次,cachesShort数据瞎想最终)
    [self thinkLoop];
    
    //存change,logic,取change,logic;xxxxxxxxxx
    AIIntModel *changeModel = [AIIntModel newWithFrom:1 to:9];
    AINode *changeNode = [ac insertModel:changeModel dataSource:@"urgentValue"];
    [ac updateNode:identNode changeNode:changeNode];
    
    //对各种dataSource的记录;
    if ([mvDic objectForKey:@""]) {
        //对各种change,用潜意识流logic串起来;
        //对导致cmv变化的change,进行类比缩小范围;
        //对缩小范围的change用显意识流logic串起来;
    }
    
    
    NSLog(@"");
    
    //7. 将类比到的数据构建与关联;
    
    //8. 进行思维mv循环
    
    //9. 进行决策输出
}

/**
 *  MARK:--------------------思维循环--------------------
 *  1. 优化级;(经验->多事务分析->感觉猜测->cacheShort瞎关联)
 *  2. 符合度;(99%->1%)
 */
-(void) thinkLoop {
    //类比原则:先用dataType和dataSource取,后存,再类比后作update结构化;
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
