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
#import "MVCacheModel.h"
#import "MVCacheManager.h"
#import "ExpCacheModel.h"

/**
 *  MARK:--------------------思维控制器--------------------
 *
 *  >> dataIn
 *  1.
 *  2.
 *
 *  >> assExp
 *  1. 在联想中,遇到的数据,都存到thinkFeedCache;
 *  2. 在联想中,遇到的mv,都叠加到当前demand下;
 *
 *  >> decisionOut
 *  1.
 *  2.
 *
 */
@interface AIThinkingControl()

@property (strong,nonatomic) NSMutableArray *shortCache;        //瞬时记忆_存AIModel(从Algs传入,待Thinking取用分析)(容量8);
@property (strong,nonatomic) NSMutableArray *thinkFeedCache;    //短时记忆_思维流(包括shortCache和cmvCache,10分钟内都会存在此处(人类可能一天或几小时))
@property (strong, nonatomic) MVCacheManager *mvCacheManager;
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
    self.mvCacheManager = [[MVCacheManager alloc] init];
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) commitInput:(NSObject*)algsModel{
    [self dataIn:algsModel];
}

/**
 *  MARK:--------------------更新energy--------------------
 */
-(void) updateEnergy:(NSInteger)delta{
    self.energy = [ThinkingUtils updateEnergy:self.energy delta:delta];
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
    [self.mvCacheManager dataIn_CmvAlgsArr:algsArr];
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

//联想到mv时,构建cmv模型;
-(AINetCMVModel*) dataIn_CreateNetCMVModel:(NSArray*)algsArr {
    AINetCMVModel *cmvModel = [[AINet sharedInstance] createCMV:algsArr order:self.shortCache];
    [self.shortCache removeAllObjects];
    //TODO:>>>>>将shortCache销毁时也放到thinkFeedCache;
    return cmvModel;
}

//MARK:===============================================================
//MARK:                     < dataIn_Ass >
//MARK:===============================================================

/**
 *  MARK:--------------------联想相关数据(看到西瓜会开心)--------------------
 *  1. 注:直至desicionOut前,assCmv都会真实作用于thinkingControl
 *  2. assCmv首先会通过energy和cmvCache表现在thinkingControl中,影响思维循环;
 *  3. dataIn负责护送一次指定信息的ass(随后进入递归循环)
 */
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
                        
                        //4. 将联想到的cmv更新energy和cmvCache
                        NSString *algsType = cmvNode.urgentTo_p.algsType;
                        NSInteger urgentTo = [NUMTOOK([SMGUtils searchObjectForPointer:cmvNode.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
                        NSInteger delta = [NUMTOOK([SMGUtils searchObjectForPointer:cmvNode.delta_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
                        [self updateEnergy:(urgentTo + 9)/10];
                        [self.mvCacheManager addToCMVCache:algsType urgentTo:urgentTo delta:delta order:urgentTo];
                        
                        //5. 形成循环,根据当前最前排mv和energy,再进行思维;
                        [self dataIn_AssociativeData:nil];//TODO(将联想到的foOrder时序列,再进行二次联想)
                        
                        //6. log
                        NSLog(@"____联想结果:%@ delta:%ld urgentTo:%ld",cmvNode.pointer.algsType,(long)delta,(long)urgentTo);
                    }else if(ISOK(referNode, AINode.class)){
                        //联想到数据网络节点
                        AINode *node = (AINode*)referNode;
                        //TODO>>>>将结果存到shortCache或thinkFeedCache//或先不添加,随后有需要时,再说;
                    }else if(ISOK(referNode, AINetAbsNode.class)){
                        //TODO>>>>将结果存到shortCache或thinkFeedCache//或先不添加,随后有需要时,再说;
                    }
                    
                    //1. foNode.cmvModel_kvp为空  (bug)
                    //2. reference到底是指向foNode还是指向cmvModel.orders_kvp
                    //3. 
                    
                    
                }
            }
        }
    }
}

/**
 *  MARK:--------------------dataIn潜意识assExp--------------------
 *  1. 无条件
 *  2. 有尝(energy-1)
 *  3. 指定model
 *  注: dataIn负责护送一次指定信息的ass(随后进入dataOut递归循环)
 *  注: dataIn_assExp可直接跳过检查点一次;
 */
-(void) dataIn_AssociativeExperience:(AINetCMVModel*)cmvModel {
    if (ISOK(cmvModel, AINetCMVModel.class)) {
        //1. 取cmvNode
        AICMVNode *cmvNode = [SMGUtils searchObjectForPointer:cmvModel.cmvNode_p fileName:FILENAME_Node];
        
        if (ISOK(cmvNode, AICMVNode.class)) {
            //2. 根据cmv模型,取cmv的迫切度值和欲望方向;求出需求
            NSNumber *deltaNum = [SMGUtils searchObjectForPointer:cmvNode.delta_p fileName:FILENAME_Value time:cRedisValueTime];
            NSNumber *urgentToNum = [SMGUtils searchObjectForPointer:cmvNode.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime];
            NSInteger delta = [NUMTOOK(deltaNum) integerValue];
            
            //TODO:>>>>判断需求;(如饿,主动取当前状态,是否饿)
            //3. 有需求思考解决
            BOOL havDemand = [ThinkingUtils getDemand:cmvNode.urgentTo_p.algsType delta:delta complete:nil];
            if (havDemand) {
                [self dataIn_AssExp_HavDemand:cmvNode];
            }
            //4. 无需求经验思考
            else{
                [self dataIn_AssExp_NoDemand:cmvModel cmvNode:cmvNode];
            }
        }
    }
    //5. 消耗energy
    [self updateEnergy:-1];
}

/**
 *  MARK:--------------------有需求思考解决--------------------
 *  1. 有需求时,找出imv解决经验,尝试决策并解决;
 *  2. TODO:明天扩展对out_p的支持
 *  3. TODO:>>>>>此处,不应直接交由decision,而是交给mvCache序列,并由loop决定是否优先执行此mv;
 */
-(void) dataIn_AssExp_HavDemand:(AICMVNode*)cmvNode {
    //1. 数据检查
    if (cmvNode == nil) {
        return;
    }
    
    //2. 将联想到的cmv更新energy和cmvCache
    NSString *algsType = cmvNode.urgentTo_p.algsType;
    NSInteger urgentTo = [NUMTOOK([SMGUtils searchObjectForPointer:cmvNode.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
    NSInteger delta = [NUMTOOK([SMGUtils searchObjectForPointer:cmvNode.delta_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
    [self updateEnergy:(urgentTo + 9)/10];
    [self.mvCacheManager addToCMVCache:algsType urgentTo:urgentTo delta:delta order:urgentTo];
    
    //3. 形成循环,根据当前最前排mv和energy,再进行思维;
    [self dataOut_AssociativeExperience];
}


/**
 *  MARK:--------------------无需求经验思考--------------------
 *  1. 无需求时,找出以往同样经历,类比规律,抽象出更确切的意义;
 *  2. 注:此方法为abs方向的思维方法总入口;(与其相对的决策处
 */
-(void) dataIn_AssExp_NoDemand:(AINetCMVModel*)cmvModel cmvNode:(AICMVNode*)cmvNode {
    //1. 数据检查
    if (cmvModel == nil || cmvNode == nil) {
        return;
    }
    
    //2. 联想相关数据
    NSMutableArray *assDirectionPorts = [NSMutableArray new];
    NSArray *assDirectionPorts_Nag = [[AINet sharedInstance] getNetNodePointersFromDirectionReference:cmvNode.pointer.algsType direction:MVDirection_Negative limit:2];
    NSArray *assDirectionPorts_Pos = [[AINet sharedInstance] getNetNodePointersFromDirectionReference:cmvNode.pointer.algsType direction:MVDirection_Positive limit:2];
    [assDirectionPorts addObjectsFromArray:ARRTOOK(assDirectionPorts_Nag)];
    [assDirectionPorts addObjectsFromArray:ARRTOOK(assDirectionPorts_Pos)];
    
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
                    AIAbsCMVNode *absCmvNode = [theNet createAbsCMVNode:absNode.pointer aMv_p:cmvModel.cmvNode_p bMv_p:assCmvModel.cmvNode_p];
                    
                    //11. cmv模型连接;
                    if (ISOK(absCmvNode, AIAbsCMVNode.class)) {
                        absNode.absCmvNode_p = absCmvNode.pointer;
                        [SMGUtils insertObject:absNode rootPath:absNode.pointer.filePath fileName:FILENAME_Node];
                    }
                    
                    NSLog(@"____类比到规律 >> 进行抽象;——————————START\n");
                    [absNode print];
                    NSLog(@"____类比到规律 >> 进行抽象;——————————END\n");
                    
                    //TODO:>>>>>将absNode和absCmvNode存到thinkFeedCache;
                }
            }
        }else if(ISOK(assDirectionPort, AINode.class)){
            AINode *node = (AINode*)assDirectionPort;
        }
    }
}


//MARK:===============================================================
//MARK:                     < dataOut (回归具象之旅) >
//MARK:===============================================================

/**
 *  MARK:--------------------尝试输出信息--------------------
 *  三种输出方式:
 *  1. 反射输出 : reflexOut
 *  2. 激活输出 : absNode信息无conPorts方向的outPointer信息时,将absNode的宏信息尝试输出;
 *  3. 经验输出 : expOut指在absNode或conPort方向有outPointer信息;
 */
-(void) dataOut_TryOut:(ExpCacheModel*)expModel outArr:(NSArray*)outArr{
    //1. 尝试输出找到解决问题的实际操作 (取到当前cacheModel中的最佳决策,并进行输出;)
    BOOL tryOutSuccess = false;
    if (expModel && ARRISOK(outArr)) {
        for (AIKVPointer *micro_p in outArr) {
            //xxxxxxxx联想以往解决时,都发生了什么,尝试复现;
            
            //>1 检查micro_p是否是"输出";
            
            //>2 假如order_p足够确切,尝试检查并输出;
            BOOL invoked = [OutputUtils checkAndInvoke:micro_p];
            if (invoked) {
                tryOutSuccess = true;
            }
        }
    }
    
    //2. 无法解决时,反射一些情绪变化,并增加额外输出;
    if (!tryOutSuccess) {
        //>1 产生"心急mv";(心急产生只是"urgent.energy x 2")
        //>2 输出反射表情;
        //>3 记录log到foOrders;(记录log应该到output中执行)
        
        //1. 如果未找到复现方式,或解决方式,则产生情绪:急
        //2. 通过急,输出output表情哭
        NSLog(@"反射输出 >>");
        [self dataOut_Reflex:AIMoodType_Anxious];
    }
}


/**
 *  MARK:--------------------反射输出--------------------
 */
-(void) dataOut_Reflex:(AIMoodType)moodType{
    [Output output_Face:moodType];
}


/**
 *  MARK:--------------------dataLoop联想(每次循环的检查执行点)--------------------
 *  注:assExp联想经验(饿了找瓜)(递归)
 *  注:loopAssExp中本身已经是内心活动联想到的mv
 *  1. 有条件(energy>0)
 *  2. 有尝(energy-1)
 *  3. 不指定model (从cmvCache取)
 *  4. 每一轮循环不仅是想下一个singleMvPort;也有可能在当前port上,进行二次思考;
 *  5. 从expCache下,根据可行性,选定一个解决方案;
 *
 */
-(void) dataOut_AssociativeExperience {
    //1. 重排序 & 取当前序列最前;
    MVCacheModel *mvCacheModel = [self.mvCacheManager getCurrentDemand];
    if (mvCacheModel == nil) {
        return;
    }
    
    //2. 从expCache中,排序并取到首个值得思考的expModel;
    ExpCacheModel *expModel = [mvCacheModel getCurrentExpCacheModel];
    
    //3. energy判断;
    if (self.energy > 0) {
        
        //4. 如果expModel可行性善可,则执行; (将执行方案部分放到assConData()中了...)
        if (expModel && expModel.score > 0) {
            [self dataOut_TryOut:expModel outArr:nil];//TODO:输出信息...
            return;
        }
        
        //5. 如果,没有一个想可行的,则再联想一个新的相关"解决经验";并重新循环下去;
        [ThinkingUtils getDemand:mvCacheModel.algsType delta:mvCacheModel.delta complete:^(BOOL upDemand, BOOL downDemand) {
            MVDirection direction = downDemand ? MVDirection_Negative : MVDirection_Positive;
            
            //6. filter筛选器取曾经历的除已有expModels之外的最强解决;
            NSArray *mvRefs = [theNet getNetNodePointersFromDirectionReference:mvCacheModel.algsType direction:direction filter:^NSArray *(NSArray *protoArr) {
                for (AIPort *port in ARRTOOK(protoArr)) {
                    BOOL cacheContains = false;
                    for (ExpCacheModel *expCacheItem in mvCacheModel.expCache) {
                        if (port.target_p && [port.target_p isEqual:expCacheItem.exp_p]) {
                            cacheContains = true;
                            break;
                        }
                    }
                    if (!cacheContains) {
                        return @[port];
                    }
                }
                return nil;
            }];
            AIPort *referenceMvPort = ARR_INDEX(mvRefs, 0);
            if (referenceMvPort) {
                //7. 取"解决经验"对应的cmvNode;
                NSObject *expMvNode = [SMGUtils searchObjectForPointer:referenceMvPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];
                if (expMvNode == nil) {
                    return;
                }
                
                //8. 加入待判断区;
                ExpCacheModel *expModel = [ExpCacheModel newWithExp_p:referenceMvPort.target_p];
                [mvCacheModel.expCache addObject:expModel];
                
                //8. 联想具象数据,并取到决策关键信息;(可行性判定)
                AIFrontOrderNode *foNode = [self dataOut_AssociativeConcreteData_ExpOut:expMvNode except_ps:expModel.exceptExpOut_ps];
                
                //9. 没有执行方案,则对抽象宏节点进行尝试输出;
                if (foNode == nil) {
                    AINetAbsNode *absNode = [self dataOut_AssociativeConcreteData_TryOut:expMvNode exceptTryOut_ps:expModel.exceptTryOut_ps];
                }
                //10. 有执行方案,则对执行方案进行反思检查;
                else{
                    [self dataOut_CheckScore_ExpOut:foNode];
                }
                BOOL foCanDo = [self dataOut_CheckScore_ExpOut:foNode];
                
                if (foCanDo) {
                    //尝试执行;
                }else{
                    
                    //递归到最初;(中止,并进入下一决策)
                    [self dataOut_AssociativeExperience];
                    
                    //如果最终全都不行,则反射输出;
                    
                    
                }
                
                    
            }else{
                //9. 无解决经验,反射输出;//V2TODO:此处不应放弃联想,应该先看下当前有哪些信息,是可以联想分析出解决方案的; (跳出递归)
                [self dataOut_Reflex:AIMoodType_Anxious];
            }
        }];
        
        //10. 思考与决策消耗能量;
        [self updateEnergy:-1];
    }else{
        //11. 如果energy<=0,尝试输出"可行性之首" 并 找到实际操作 (跳出递归)
        [self dataOut_TryOut:expModel outArr:nil];//TODO:输出信息...
    }
}


/**
 *  MARK:--------------------联想具象 (从上往下找foNode)--------------------
 *  @param expMvNode : mv节点经验(有可能是AICMVNode也有可能是AIAbsCMVNode)
 *  功能 : 找到曾输出经验;
 *  TODO:加上预测功能
 *  TODO:加上联想到mv时,传回给mvCacheManager;
 *  注:每一次输出,只是决策与预测上的一环;并不意味着结束;
 *  //1. 记录思考mv结果到叠加mvCacheModel.order;
 *  //2. 记录思考data结果到thinkFeedCache;
 *  //3. 如果mindHappy_No,可以再尝试下一个getNetNodePointersFromDirectionReference_Single;找到更好的解决方法;
 *  //4. 最终更好的解决方法被输出,并且解决问题后,被加强;
 *  //5. 是数据决定了下一轮循环思维想什么,但数据仅能通过mv来决定,无论是思考的方向,还是思考的能量,还是思考的目标,都是以mv为准的;而mv的一切关联,又是以数据为规律进行关联的;
 *
 */
-(AIFrontOrderNode*) dataOut_AssociativeConcreteData_ExpOut:(NSObject*)expMvNode except_ps:(nonnull NSMutableArray*)except_ps {
    //1. 判断具象
    if (ISOK(expMvNode, AICMVNode.class)) {
        //2. 具象mv
        AIFrontOrderNode *foNode = [ThinkingUtils getFoNodeFromCmvNode:(AICMVNode*)expMvNode];
        return foNode;
    }else if(ISOK(expMvNode, AIAbsCMVNode.class)){
        //3. 抽象mv
        AIAbsCMVNode *expAbsCmvNode = (AIAbsCMVNode*)expMvNode;
        AIPort *findConPort = [expAbsCmvNode getConPortWithExcept:except_ps];
        if (!findConPort) {
            //4. 所有conPort都已排除,则expAbsCmvNode本身也被排除;并递归;
            [except_ps addObject:expAbsCmvNode.pointer];
            return [self dataOut_AssociativeConcreteData_ExpOut:expMvNode except_ps:except_ps];
        }else{
            //5. 找到conPort,则递归判断类型是否foNode;
            NSObject *findConNode = [SMGUtils searchObjectForPointer:findConPort.target_p fileName:FILENAME_Node];
            return [self dataOut_AssociativeConcreteData_ExpOut:findConNode except_ps:except_ps];
        }
    }
    
    return nil;
}


/**
 *  MARK:--------------------联想具象 (从下往上找absNode)--------------------
 *  @param expMvNode :  当前在判断的mv节点经验(有可能是AICMVNode也有可能是AIAbsCMVNode)
 *  @result : 返回前因节点地址(仅absNode_p,不要foNode_p)
 *  功能 : 找可尝试输出 (激活输出);
 *  1. 从上至下的联想absNode;
 *  注:目前仅支持每层1个,与最分支向下联想,即abs的最强关联的下层前1;
 */
-(AINetAbsNode*) dataOut_AssociativeConcreteData_TryOut:(NSObject*)expMvNode exceptTryOut_ps:(nonnull NSMutableArray*)exceptTryOut_ps{
    if(ISOK(expMvNode, AIAbsCMVNode.class)){
        //1. 判断是否已排除
        AIAbsCMVNode *expAbsCmvNode = (AIAbsCMVNode*)expMvNode;
        BOOL excepted = false;
        for (AIPointer *except_p in exceptTryOut_ps) {
            if ([except_p isEqual:expAbsCmvNode.pointer]) {
                excepted = true;
                break;
            }
        }
        
        //2. 未排除,返回;
        if (!excepted) {
            [exceptTryOut_ps addObject:expAbsCmvNode.absNode_p];
            AINetAbsNode *result = [SMGUtils searchObjectForPointer:expAbsCmvNode.absNode_p fileName:FILENAME_Node time:cRedisNodeTime];
            return result;
        }else{
            //3. 已排除,递归下一层;
            AIPort *firstConPort = [expAbsCmvNode getConPort:0];
            if (firstConPort != nil) {
                NSObject *firstConNode = [SMGUtils searchObjectForPointer:firstConPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];
                return [self dataOut_AssociativeConcreteData_TryOut:firstConNode exceptTryOut_ps:exceptTryOut_ps];
            }
        }
    }
    return nil;
}

/**
 *  MARK:--------------------foNode的可行性判定--------------------
 */
-(BOOL) dataOut_CheckScore_ExpOut:(AIFrontOrderNode*)foNode{
    if (!foNode) {
        return false;
    }
    return true;
    
    //抽象cmv节点 并 收集可输出的信息
    NSMutableArray *outMArr = [[NSMutableArray alloc] init];
    
    //
    NSArray *out_ps = [ThinkingUtils filterOutPointers:foNode.orders_kvp];
    

    
    
    //>1 取"解决经验"的前因抽象节点
    AINetAbsNode *expFoAbsNode = [SMGUtils searchObjectForPointer:expAbsCmvNode.absNode_p fileName:FILENAME_Node time:cRedisNodeTime];

    //>2 取宏信息指向的"微信息"数组
    NSArray *microArr_p = ARRTOOK([SMGUtils searchObjectForPointer:expFoAbsNode.absValue_p fileName:FILENAME_AbsValue]);


    //为absNode添加outPointer;
    //1. 从sames开始,增加outPointer的(微信息组)


    //>3 收集
    for (AIKVPointer *micro_p in microArr_p) {
        if (ISOK(micro_p, AIKVPointer.class)) {
            [outMArr addObject:micro_p];
        }
    }
    
    
//    //4. 在输出前,联想一下将要输出的outMArr,看是否有导致mv-的情况;
//    AIKVPointer *absValue_p = [theNet getNetAbsIndex_AbsPointer:outMArr];
//    AIKVPointer *absNode_p = [theNet getItemAbsNodePointer:absValue_p];
//    AINetAbsNode *absNode = [SMGUtils searchObjectForPointer:absNode_p fileName:FILENAME_Node time:cRedisNodeTime];
//
//
//
//    //TMRTODO:判定执行方案可行性
//    //1). expModelscore>0时,分析具象方向的outLog的可行性,然后再输出;...
//
//    NSArray *out_ps = [ThinkingUtils filterOutPointers:outMArr];
//    //A:根据out_ps联想(分析可行性)
//    // >assHavResult : 其有没有导致mv-和mv+;
//    //  > mv-则:联想conPort,思考具象;
//    //  > mv+则:score+分;
//    // >assNoResult :
//
//
//
//
//
//
//    //1. mv-时,根据横向找foOrder来找outLog
//    //2. 或mv-时,根据纵向找conMvNode来找它的foOrder中的outLog;
//
//    //3. 给找到的outLog来评定可行性;
//    //4. 如果找不到,就把最absNode.foOrder.outArr去tryOut();
//    //5. 如果找到,且具有非常好的可执行性,
//
//    //6. 此方法可能对应1个expModel;并对每个con方向的outLog进行综合评分score,并将最佳的outArr和score传出去;
//
//
//
//
//
//    //5. 取absCmvNode & 并取到mindHappy影响决策cacheModel;
//    MindHappyType type = MindHappyType_None;
//    NSInteger urgentTo = 0;
//    if (ISOK(absNode, AINetAbsNode.class)) {
//        AIAbsCMVNode *absCmvNode = [SMGUtils searchObjectForPointer:absNode.absCmvNode_p fileName:FILENAME_Node time:cRedisNodeTime];
//        if (ISOK(absCmvNode, AIAbsCMVNode.class)) {
//            //6. 检查absCmvNode是否顺心
//            NSString *algsType = absCmvNode.pointer.algsType;
//            urgentTo = [NUMTOOK([SMGUtils searchObjectForPointer:absCmvNode.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
//            NSInteger delta = [NUMTOOK([SMGUtils searchObjectForPointer:absCmvNode.delta_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
//            type = [ThinkingUtils checkMindHappy:algsType delta:delta];
//        }
//    }
//
//    //7. 消耗energy
//    [self updateEnergy:-1];
//
//    //8. 联想判断具象完成;
//    if (complete) {
//        complete(type,urgentTo,outMArr);
//    }
}

@end
