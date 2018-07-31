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
#import "AINetAbsCMV.h"

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
    }
    return self;
}

-(void) initData{
    self.shortCache = [[NSMutableArray alloc] init];
    self.thinkFeedCache = [[NSMutableArray alloc] init];
    self.cmvCache = [[NSMutableArray alloc] init];
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) commitInput:(NSObject*)algsModel{
    [self dataIn:algsModel];
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
    
    //7. 联想
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
                        self.energy = [ThinkingUtils updateEnergy:self.energy delta:(urgentTo + 9)/10];
                        
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
 *  2. TODO:明天扩展对out_p的支持
 */
-(void) dataIn_AssExp_HavDemand:(AICMVNode*)cmvNode direction:(MVDirection)direction{
    //1. 数据检查
    if (cmvNode == nil) {
        return;
    }
    
    //2. 联想相关"解决经验";(取曾经历的最强解决;)
    AIPort *mvPort = [[AINet sharedInstance] getNetNodePointersFromDirectionReference_Single:cmvNode.pointer.algsType direction:direction];
    if (mvPort) {
        //3. 取"解决经验"对应的cmvNode;
        NSObject *expMvNode = [SMGUtils searchObjectForPointer:mvPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];

        //4. 决策输出
        [self decision_Out:expMvNode];
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
    NSArray *assDirectionPorts = [[AINet sharedInstance] getNetNodePointersFromDirectionReference:cmvNode.pointer.algsType direction:direction limit:2];
    AIFrontOrderNode *foNode = [SMGUtils searchObjectForPointer:cmvModel.foNode_p fileName:FILENAME_Node];
    
    //3. 联想cmv模型
    for (AIPort *assDirectionPort in assDirectionPorts) {
        id assDirectionNode = [SMGUtils searchObjectForPointer:assDirectionPort.target_p fileName:FILENAME_Node];
        if (ISOK(assDirectionNode, AICMVNode.class)) {
            AICMVNode *assCmvNode = (AICMVNode*)assDirectionNode;
            
            //4. 排除联想自己(随后写到reference中)
            if (![cmvNode.pointer isEqual:assCmvNode.pointer]) {
                AINetCMVModel *assCmvModel = [SMGUtils searchObjectForPointer:assCmvNode.cmvModel_p fileName:FILENAME_CMVModel];
                AIFrontOrderNode *assFoNode = [SMGUtils searchObjectForPointer:assCmvModel.foNode_p fileName:FILENAME_Node];
                
                NSLog(@"____联想到cmv模型>>>\ncmvModel:%ld,%@ \n assCmvModel:%ld,%@",(long)cmvModel.pointer.pointerId,cmvModel.pointer.params,(long)assCmvModel.pointer.pointerId,assCmvModel.pointer.params);
                
                //5. 类比orders的规律,并abs;
                NSArray *sames = [ThinkingUtils analogyFoNode_A:foNode foNode_B:assFoNode];
                    
                //6. 构建absNode & 并把absValue添加到瞬时记忆
                if (ARRISOK(sames)) {
                    
                    //9. createAbsNode
                    AINetAbsNode *absNode = [[AINet sharedInstance] createAbs:@[foNode,assFoNode] refs_p:sames];
                    [self dataIn_ToShortCache:absNode.absValue_p];
                    
                    //10. createAbsCmvNode
                    [theNet createAbsCMVNode:absNode.pointer aMv_p:cmvModel.cmvNode_p bMv_p:assCmvModel.cmvNode_p];
                    
                    NSLog(@"____类比到规律 >> 进行抽象;——————————START\n");
                    [absNode print];
                    NSLog(@"____类比到规律 >> 进行抽象;——————————END\n");
                }
            }
        }else if(ISOK(assDirectionPort, AINode.class)){
            AINode *node = (AINode*)assDirectionPort;
        }
    }
}


//MARK:===============================================================
//MARK:                     < decision >
//MARK:===============================================================


/**
 *  MARK:--------------------决策输出--------------------
 *  @param expMvNode : mv节点经验(有可能是AICMVNode也有可能是AIAbsCMVNode)
 */
-(void) decision_Out:(NSObject*)expMvNode{
    //1. 判断具象 | 抽象cmv节点 并 收集可输出的信息
    NSMutableArray *outMArr = [[NSMutableArray alloc] init];
    if (ISOK(expMvNode, AICMVNode.class)) {
        //2. 具象mv
        AICMVNode *expConCmvNode = (AICMVNode*)expMvNode;
        
        //>1 取"解决经验"对应的cmv基本模型;
        AINetCMVModel *expCmvModel = [SMGUtils searchObjectForPointer:expConCmvNode.cmvModel_p fileName:FILENAME_CMVModel time:cRedisNodeTime];
        
        //>2 取"解决经验"对应的前因时序列;
        AIFrontOrderNode *expFoNode = [SMGUtils searchObjectForPointer:expCmvModel.foNode_p fileName:FILENAME_Node time:cRedisNodeTime];
        
        //>3 收集
        [outMArr addObjectsFromArray:expFoNode.orders_kvp];//out是不能以数组处理foNode.orders_p的,下版本改)
    }else if(ISOK(expMvNode, AIAbsCMVNode.class)){
        //3. 抽象mv
        AIAbsCMVNode *expAbsCmvNode = (AIAbsCMVNode*)expMvNode;
        
        //>1 取"解决经验"的前因抽象节点
        AINetAbsNode *expFoAbsNode = [SMGUtils searchObjectForPointer:expAbsCmvNode.absNode_p fileName:FILENAME_Node time:cRedisNodeTime];
        
        //>2 取宏信息指向的"微信息"数组
        NSArray *microArr_p = ARRTOOK([SMGUtils searchObjectForPointer:expFoAbsNode.absValue_p fileName:FILENAME_AbsValue]);
        
        //>3 收集
        for (AIKVPointer *micro_p in microArr_p) {
            if (ISOK(micro_p, AIKVPointer.class)) {
                [outMArr addObject:micro_p];
            }
        }
    }
    
    //4. 尝试输出找到解决问题的实际操作
    BOOL tryOutSuccess = false;
    if (ARRISOK(outMArr)) {
        for (AIKVPointer *micro_p in outMArr) {
            //xxxxxxxx联想以往解决时,都发生了什么,尝试复现;
            
            //>1 检查micro_p是否是"输出";
            
            //>2 假如order_p足够确切,尝试检查并输出;
            BOOL invoked = [OutputUtils checkAndInvoke:micro_p];
            if (invoked) {
                tryOutSuccess = true;
            }
        }
    }
    
    //5. 无法解决时,反射一些情绪变化,并增加额外输出;
    if (!tryOutSuccess) {
        //>1 产生"心急mv";(心急产生只是"urgent.energy x 2")
        //>2 输出反射表情;
        //>3 记录log到foOrders;(记录log应该到output中执行)
        
        NSLog(@"1. 如果未找到复现方式,或解决方式,则产生情绪:急");
        NSLog(@"2. 通过急,输出output表情哭");
        
        [Output output_Face:AIMoodType_Anxious];
    }
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
