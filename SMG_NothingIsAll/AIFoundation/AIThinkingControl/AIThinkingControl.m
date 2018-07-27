//
//  AIThinkingControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIThinkingControl.h"
#import "AINet.h"
#import "ImvAlgsModelBase.h"
#import "AIActionControl.h"
#import "AINode.h"
#import "AIModel.h"
#import "NSObject+Extension.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "ImvAlgsModelBase.h"
#import "AINetCMV.h"
#import "AINetAbs.h"
#import "ThinkingUtils.h"
#import "OutputUtils.h"
#import "Output.h"
#import "AIOutputKVPointer.h"
#import "AIFrontOrderNode.h"
#import "AINetAbsNode.h"
#import "AICMVNode.h"
#import "AIAbsCMVNode.h"

@interface AIThinkingControl()

@property (strong,nonatomic) NSMutableArray *shortCache;        //瞬时记忆_存AIModel(从Algs传入,待Thinking取用分析)(容量8);
@property (strong,nonatomic) NSMutableArray *thinkFeedCache;    //短时记忆_思维流(包括shortCache和cmvCache,10分钟内都会存在此处(人类可能一天或几小时))
@property (strong,nonatomic) NSMutableArray *cmvCache;          //思维因子_当前cmv序列(注:所有cmv只与cacheImv中作匹配)(正序,urgent越大,排越前)
@property (assign, nonatomic) NSInteger energy;                 //当前能量值;(在循环中动态更新)(0-2)

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
    self.shortCache = [[NSMutableArray alloc] init];
    self.thinkFeedCache = [[NSMutableArray alloc] init];
    self.cmvCache = [[NSMutableArray alloc] init];
}

-(void) initRun{
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) commitInput:(NSObject*)algsModel{
    //[self dataIn_V1:algsModel];
    [self dataIn:algsModel];
}

-(void) dataIn_V1:(NSObject*)algsModel{
    //1. 数据
    NSDictionary *algsDic = [NSObject getDic:algsModel containParent:true];
    NSMutableDictionary *nodeDic = [[NSMutableDictionary alloc] init];
    AIActionControl *ac = [[AIActionControl alloc] init];
    
    //2. 构建algsModel并收集node;
    if (algsDic) {
        //3. 构建key节点
        NSString *dataType = NSStringFromClass(algsModel.class);
        AINode *identNode = [ac createIdentNode:dataType];
        if (identNode) [nodeDic setObject:identNode forKey:@"identNode"];
        
        //4. 取energy
        int energy = 0;
        for (NSString *dataSource in algsDic.allKeys) {
            if ([@"urgentValue" isEqualToString:dataSource]) {//imv检查
                NSInteger urgentValue = [NUMTOOK([algsDic objectForKey:@"urgentValue"]) integerValue];
                energy = 10;
            }else if([@"targetType" isEqualToString:dataSource]) {
                AITargetType targetType = [NUMTOOK([algsDic objectForKey:@"targetType"]) intValue];
                energy = 20;
            }
        }
        
        //5. 构建key属性
        NSMutableArray *pptNodes = [[NSMutableArray alloc] init];
        for (NSString *dataSource in algsDic.allKeys) {
            id propertyObj = [algsDic objectForKey:dataSource];
            
            //6. value为数组时,转换为node数组;
            if ([propertyObj isKindOfClass:NSArray.class]) {
                NSArray *items = [ac createPropertyNodes:propertyObj dataSource:dataSource identNode:identNode];
                propertyObj = items;
            }
            
            //7. 构建属性node;
            AINode *pptNode = [ac createPropertyNode:propertyObj dataSource:dataSource identNode:identNode];
            if (pptNode) [pptNodes addObject:pptNode];
        }
        [nodeDic setObject:pptNodes forKey:@"pptNodes"];
        
        //8. 构建change和logic链 (对各种change,用潜意识流logic串起来)
        
        
        //因algsDic定义只是存储结构,并非归纳结构,所以应类比Law,并thinkingRIN后,再产生归纳结构网络;//xxx
        //shortCaches和longCaches中存储的也是RIN后的数据,而非algsDic;//xxx
        
        //1. 对比value并找到规律,生成第一个RIN;参考n11p9(生成第一个RIN-代码例)
        //2. 完全以类比的结果为依据创建结构化网络;
        [ac searchNodeForDataObj:nil];
        
        for (NSDictionary *pptNode in pptNodes) {
            NSLog(@"");
            //逐个类比input中的信息单元(如char)等;找出law;
        }
    }
    
    //3. 存shortCache
    //[self setObject_Caches:nodeDic];
    
    //4. 提交思维循环
    [self thinkLoop:nodeDic];
}


/**
 *  MARK:--------------------思维循环--------------------
 *  1. 优化级;(经验->多事务分析->感觉猜测->shortCache瞎关联)
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


//MARK:===============================================================
//MARK:                     < dataIn >
//MARK:===============================================================
-(void) dataIn:(NSObject*)algsModel{
    //1. 装箱(除mv有两个元素外一般仅有一个元素)
    NSArray *algsArr = [self dataIn_ConvertPointer:algsModel];
    
    //2. 检测imv
    BOOL findMV = [self dataIn_CheckMV:algsArr];
    
    //3. 分流
    AINetCMVModel *cmvModel;
    if (findMV) {
        //4. 输入新的cmvAlgsArr
        [self dataIn_CMVAlgsArr:algsArr];
        
        //5. 创建NetCmvModel;
        cmvModel = [self dataIn_CreateNetCMVModel:algsArr];
    }else{
        //6. 加入瞬时记忆
        for (AIKVPointer *algs_p in ARRTOOK(algsArr)) {
            [self dataIn_ToShortCache:algs_p];
        }
    }
    
    //4. 联想
    if (findMV) {
        [self dataIn_AssociativeExperience:cmvModel];
    }else{
        [self dataIn_AssociativeData:algsArr];
    }
}

//转为指针数组(每个值都是指针)(在dataIn后第一件事就是装箱)
-(NSArray*) dataIn_ConvertPointer:(NSObject*)algsModel{
    NSArray *algsArr = [[AINet sharedInstance] getAlgsArr:algsModel];
    return algsArr;
    //1. 将索引的第二序列,提交给actionControl联想 (1. 作匹配测试  2. 只从强度最强往下);
}

//输入时,检测是否mv输入(饿或不饿)
-(BOOL) dataIn_CheckMV:(NSArray*)algsArr{
    for (AIKVPointer *pointer in algsArr) {
        if ([NSClassFromString(pointer.algsType) isSubclassOfClass:ImvAlgsModelBase.class]) {
            return true;
        }
    }
    return false;
}

//输入新的cmvAlgsArr
-(void) dataIn_CMVAlgsArr:(NSArray*)algsArr{
    //1. 抵消 | 合并
    [ThinkingUtils parserAlgsMVArr:algsArr success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p, NSInteger delta, NSInteger urgentTo, NSString *algsType) {
        __block BOOL findSeemType = false;
        for (NSArray *item in self.cmvCache) {
            [ThinkingUtils parserAlgsMVArr:item success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p,NSInteger itemDelta, NSInteger itemUrgentTo, NSString *itemAlgsType) {
                if ([STRTOOK(algsType) isEqualToString:itemAlgsType]) {
                    //2. 同向且更迫切时,替换到合适位置
                    if ((itemDelta > 0) == (delta > 0)) {
                        if (labs(delta) > labs(itemDelta)) {
                            [self.cmvCache removeObject:item];
                            [self dataIn_ToCMVCache:algsArr delta:delta];
                        }
                    }else{//3. 异向抵消
                        [self.cmvCache removeObject:item];
                    }
                    findSeemType = true;
                }
            }];
            if (findSeemType) {
                break;
            }
        }
        
        //4. 未找到相同类型,加到cmvCache中
        if (!findSeemType) {
            [self dataIn_ToCMVCache:algsArr delta:delta];
        }
    }];
}

/**
 *  MARK:--------------------shortCache瞬时记忆--------------------
 *  1. 存algsDic中的每个inputIndexPointer;
 *  2. 存absNode指向的absIndexPointer;
 */
-(void) dataIn_ToShortCache:(AIPointer*)pointer{
    if (ISOK(pointer, AIPointer.class)) {
        [self.shortCache addObject:pointer];
        if (self.shortCache.count > 8) {
            [self.shortCache removeObjectAtIndex:0];
        }
    }
}

//添加到cmvCache;
-(void) dataIn_ToCMVCache:(NSArray*)algsArr delta:(NSInteger)delta{
    __block BOOL success = false;
    for (NSInteger i = 0; i < self.cmvCache.count; i++) {
        NSArray *checkItem = self.cmvCache[i];
        [ThinkingUtils parserAlgsMVArr:checkItem success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p,NSInteger checkDelta, NSInteger checkUrgentTo, NSString *checkAlgsType) {
            if (labs(delta) > labs(checkDelta)) {
                [self.cmvCache insertObject:algsArr atIndex:i];
                success = true;
            }
        }];
        if (success) {
            break;
        }
    }
    if (!success) {
        [self.cmvCache addObject:algsArr];
    }
}

//联想到mv时,构建cmv模型;
-(AINetCMVModel*) dataIn_CreateNetCMVModel:(NSArray*)algsArr {
    AINetCMVModel *cmvModel = [[AINet sharedInstance] createCMV:algsArr order:self.shortCache];
    [self.shortCache removeAllObjects];
    return cmvModel;
}

//联想相关数据(看到西瓜会开心)
-(void) dataIn_AssociativeData:(NSArray*)algsArr {
    if (ISOK(algsArr, NSArray.class)) {
        //1. noMv信号已输入完毕,联想
        for (AIKVPointer *algs_kvp in algsArr) {
            //2. 在第二序列指向节点的端口;
            NSArray *referPorts = [[AINet sharedInstance] getItemAlgsReference:algs_kvp limit:cAssDataLimit];
            for (AIPort *referPort in referPorts) {
                if (ISOK(referPort, AIPort.class)) {
                    id referNode = [SMGUtils searchObjectForPointer:referPort.target_p fileName:FILENAME_Node];
                    if (ISOK(referNode, AIFrontOrderNode.class)) {
                        //3. 联想到cmv模型前因
                        AIFrontOrderNode *foNode = (AIFrontOrderNode*)referNode;
                        AINetCMVModel *cmvModel = [SMGUtils searchObjectForPointer:foNode.cmvModel_kvp fileName:FILENAME_CMVModel];
                        AICMVNode *cmvNode = [SMGUtils searchObjectForPointer:cmvModel.cmvNode_p fileName:FILENAME_Node];
                        
                        //4. 联想到cmv (根据urgentTo更新energy)
                        NSInteger urgentTo = [NUMTOOK([SMGUtils searchObjectForPointer:cmvNode.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
                        self.energy = [ThinkingUtils updateEnergy:self.energy delta:urgentTo/10];
                        
                        //5. 判断需求;(如饿,主动取当前状态,是否饿)
                        
                        
                        NSLog(@"____联想结果:%@",cmvNode.pointer.algsType);
                        
                        
                        
                    }else if(ISOK(referNode, AINode.class)){
                        //联想到数据网络节点
                        AINode *node = (AINode*)referNode;
                        NSLog(@"");
                    }else if(ISOK(referNode, AINetAbsNode.class)){
                        NSLog(@"");
                        
                        //将结果存到thinkFeedCache;
                    }
                    
                    NSLog(@"");
                    
                    //1. foNode.cmvModel_kvp为空  (bug)
                    //2. reference到底是指向foNode还是指向cmvModel.orders_kvp
                    //3. 
                    
                    
                    
                    
                }
            }
        }
    }
}

//从网络中找已有cmv经验(饿了找瓜)
-(void) dataIn_AssociativeExperience:(AINetCMVModel*)cmvModel {
    if (ISOK(cmvModel, AINetCMVModel.class)) {
        //1. 取cmvNode
        AICMVNode *cmvNode = [SMGUtils searchObjectForPointer:cmvModel.cmvNode_p fileName:FILENAME_Node];
        
        if (ISOK(cmvNode, AICMVNode.class)) {
            //2. 根据cmv模型,取cmv的迫切度值和欲望方向;求出需求
            NSNumber *deltaNum = [SMGUtils searchObjectForPointer:cmvNode.delta_p fileName:FILENAME_Value time:cRedisValueTime];
            NSNumber *urgentToNum = [SMGUtils searchObjectForPointer:cmvNode.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime];
            AITargetType targetType = [ThinkingUtils getTargetTypeWithAlgsType:cmvNode.urgentTo_p.algsType];
            NSInteger delta = [NUMTOOK(deltaNum) integerValue];
            BOOL downDemand = targetType == AITargetType_Down && delta > 0;
            BOOL upDemand = targetType == AITargetType_Up && delta < 0;
            
            //3. 有需求思考解决
            if (downDemand || upDemand ) {
                MVDirection direction = downDemand ? MVDirection_Negative : MVDirection_Positive;
                [self dataIn_AssExp_HavDemand:cmvNode direction:direction];
            }
            //4. 无需求经验思考
            else{
                MVDirection direction = downDemand ? MVDirection_Positive : MVDirection_Negative;
                [self dataIn_AssExp_NoDemand:cmvModel cmvNode:cmvNode direction:direction];
            }
        }
    }
    //[[AINet sharedInstance] searchNodeForDataType:nil dataSource:@"urgentValue"];
}

/**
 *  MARK:--------------------有需求思考解决--------------------
 *  1. 有需求时,找出imv解决经验,尝试决策并解决;
 */
-(void) dataIn_AssExp_HavDemand:(AICMVNode*)cmvNode direction:(MVDirection)direction{
    //1. 数据检查
    if (cmvNode == nil) {
        return;
    }
    
    //2. 联想相关"解决经验";(取曾经历的最强解决;)
    AIPort *mvPort = [[AINet sharedInstance] getNetNodePointersFromDirectionReference_Single:cmvNode.pointer.algsType direction:direction];
    if (mvPort) {
        
        //2.1 取"解决经验"对应的cmvNode;
        AICMVNode *expMvNode = [SMGUtils searchObjectForPointer:mvPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];
        
        //2.2 取"解决经验"对应的cmv基本模型;
        AINetCMVModel *expCmvModel = [SMGUtils searchObjectForPointer:expMvNode.cmvModel_p fileName:FILENAME_CMVModel time:cRedisNodeTime];
        
        //2.3 取"解决经验"对应的前因时序列;
        AIFrontOrderNode *expFoNode = [SMGUtils searchObjectForPointer:expCmvModel.foNode_p fileName:FILENAME_Node time:cRedisNodeTime];
        
        //3. 尝试找到解决问题的实际操作
        //>>>此处需要得到的最好是absNode;但目前"抽象cmv基本模型"善未重构,所以只好先取foNode.orders;
        BOOL tryOutSuccess = false;
        if (expFoNode) {
            for (AIKVPointer *order_p in expFoNode.orders_kvp) {
                //xxxxxxxx联想以往解决时,都发生了什么,尝试复现;
                
                //1. 检查order_p是否是"输出";
                
                //2. 假如order_p足够确切,尝试检查并输出;
                BOOL invoked = [OutputUtils checkAndInvoke:order_p];
                if (invoked) {
                    tryOutSuccess = true;
                }
                
            }
        }
        
        if (!tryOutSuccess) {
            
            //3. 产生"心急mv";(心急产生只是"urgent.energy x 2")
            //4. 输出反射表情;
            //5. 记录log到foOrders;(记录log应该到output中执行)
            
            
            NSLog(@"1. 如果未找到复现方式,或解决方式,则产生情绪:急");
            
            NSLog(@"2. 通过急,输出output表情哭");
            
            [Output output_Face:AIMoodType_Anxious];
        }
    }
}


/**
 *  MARK:--------------------无需求经验思考--------------------
 *  1. 无需求时,找出以往同样经历,类比规律,抽象出更确切的意义;
 */
-(void) dataIn_AssExp_NoDemand:(AINetCMVModel*)cmvModel cmvNode:(AICMVNode*)cmvNode direction:(MVDirection)direction {
    //1. 数据检查
    if (cmvModel == nil || cmvNode == nil) {
        return;
    }
    
    //2. 联想相关数据
    NSArray *mvPorts = [[AINet sharedInstance] getNetNodePointersFromDirectionReference:cmvNode.pointer.algsType direction:direction limit:2];
    AIFrontOrderNode *foNode = [SMGUtils searchObjectForPointer:cmvModel.foNode_p fileName:FILENAME_Node];
    
    //3. 联想cmv模型
    for (AIPort *port in mvPorts) {
        id referNode = [SMGUtils searchObjectForPointer:port.target_p fileName:FILENAME_Node];
        if (ISOK(referNode, AICMVNode.class)) {
            AICMVNode *assCmvNode = (AICMVNode*)referNode;
            
            //4. 排除联想自己(随后写到reference中)
            if (![cmvNode.pointer isEqual:assCmvNode.pointer]) {
                AINetCMVModel *assCmvModel = [SMGUtils searchObjectForPointer:assCmvNode.cmvModel_p fileName:FILENAME_CMVModel];
                AIFrontOrderNode *assFoNode = [SMGUtils searchObjectForPointer:assCmvModel.foNode_p fileName:FILENAME_Node];
                
                NSLog(@"____联想到cmv模型>>>\ncmvModel:%ld,%@ \n assCmvModel:%ld,%@",(long)cmvModel.pointer.pointerId,cmvModel.pointer.params,(long)assCmvModel.pointer.pointerId,assCmvModel.pointer.params);
                
                
                
                //xxxxxxxx联想到同样经历的mv时,尝试抽象出absCMVNode;
                
                
                
                //5. 类比orders的规律,并abs;
                NSMutableArray *sames = [[NSMutableArray alloc] init];
                if (ISOK(foNode, AIFrontOrderNode.class) && ISOK(assFoNode, AIFrontOrderNode.class)) {
                    for (AIKVPointer *data_p in foNode.orders_kvp) {
                        //6. 是否已收集
                        BOOL already = false;
                        for (AIKVPointer *same_p in sames) {
                            if ([same_p isEqual:data_p]) {
                                already = true;
                                break;
                            }
                        }
                        //7. 未收集过,则查找是否有一致微信息(有则收集)
                        if (!already) {
                            for (AIKVPointer *assData_p in assFoNode.orders_kvp) {
                                if ([data_p isEqual:assData_p]) {
                                    [sames addObject:assData_p];
                                    break;
                                }
                            }
                        }
                        
                    }
                    
                    //8. 构建absNode & 并把absValue添加到瞬时记忆
                    if (ARRISOK(sames)) {
                        NSLog(@"____类比到规律——————————");
                        for (AIKVPointer *same in sames) {
                            NSLog(@"\n____>%ld",(long)same.pointerId);
                        }
                        AINetAbsNode *absNode = [[AINet sharedInstance] createAbs:@[foNode,assFoNode] refs_p:sames];
                        [self dataIn_ToShortCache:absNode.absValue_p];
                        [absNode print];
                        //>>>此处改为抽象整个cmv基本模型,
                        NSLog(@"构建抽象节点成功.....");
                        
                        
                        
//                        AIAbsCMVNode *absCmvNode =
                        
                        
                    }
                }
            }
        }else if(ISOK(referNode, AINode.class)){
            AINode *node = (AINode*)referNode;
        }
    }
}

//类比处理(瓜是瓜)
-(void) dataIn_AnalogyData:(NSDictionary*)algsDic dataType:(NSString*)dataType{
    if (DICISOK(algsDic) && dataType) {
        
    }
}

//构建(想啥存啥)
-(void) dataIn_BuildNet{
    
}


//MARK:===============================================================
//MARK:                     < decision >
//MARK:===============================================================

//输出front的入网;
-(void) decision_InNet{
    
}

//输出
-(void) decision_Out{
    
}

/**
 *  MARK:--------------------输出的日志入网(输入小脑)--------------------
 *  @param algsType  : 输出算法分区(目前仅有Output)
 *  @param dataTo    : 输出算法函数(如output_Text:)
 *  @param outputObj : 输出内容(如:饿死爹了)
 */
-(void) commitOutputLog:(NSString*)algsType dataTo:(NSString*)dataTo outputObj:(NSNumber*)outputObj{
    //1. 装箱
    AIOutputKVPointer *output_p = [theNet getOutputIndex:algsType dataTo:dataTo outputObj:outputObj];
    
    //2. 记录可输出reference
    [theNet setNetNodePointerToOutputReference:output_p algsType:algsType dataTo:dataTo difStrong:1];
    
    //3. 加瞬时记忆
    [self dataIn_ToShortCache:output_p];
}

@end
