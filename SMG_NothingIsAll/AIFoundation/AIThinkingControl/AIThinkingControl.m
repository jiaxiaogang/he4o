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
#import "NSObject+Extension.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "ImvAlgsModelBase.h"
#import "AINetCMV.h"
#import "AINetAbs.h"
#import "ThinkingUtils.h"
#import "OutputUtils.h"
#import "Output.h"
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
 *  @param dataSource    : 输出算法函数(如output_Text:)
 *  @param outputObj : 输出内容(如:饿死爹了)
 */
-(void) commitOutputLog:(NSString*)algsType dataSource:(NSString*)dataSource outputObj:(NSNumber*)outputObj{
    //1. 装箱
    AIKVPointer *output_p = [theNet getOutputIndex:algsType dataSource:dataSource outputObj:outputObj];
    
    //2. 记录可输出reference
    [theNet setNetNodePointerToOutputReference:output_p algsType:algsType dataSource:dataSource difStrong:1];
    
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
        //4. 输入新的cmvAlgsArr(下面已有assExp中,有mv方向的添加mvCache代码,此处去掉)
        //[self.mvCacheManager dataIn_CmvAlgsArr:algsArr];
        
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
                        [self.mvCacheManager updateCMVCache:algsType urgentTo:urgentTo delta:delta order:urgentTo];
                        
                        //5. 形成循环,根据当前最前排mv和energy,再进行思维;
                        //[self dataIn_AssociativeData:nil];//TODO(将联想到的foOrder时序列,再进行二次联想)
                        [self dataOut_AssociativeExperience];
                        
                        //6. log
                        NSLog(@"____联想结果:%@ delta:%ld urgentTo:%ld",cmvNode.pointer.algsType,(long)delta,(long)urgentTo);
                    }else if(ISOK(referNode, AINetAbsNode.class)){
                        //联想到数据网络节点
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
            NSInteger delta = [NUMTOOK(deltaNum) integerValue];
            
            //3. 思考mv
            //BOOL havDemand = [ThinkingUtils getDemand:cmvNode.urgentTo_p.algsType delta:delta complete:nil];
            //TODO:>>>>判断需求;(如饿,主动取当前状态,是否饿)
            if (delta != 0) {
                [self dataIn_AssExp_ToOutLoop:cmvNode];
            }
            
            //4. 思考数据
            [self dataIn_AssExp_ToLawAbsData:cmvModel cmvNode:cmvNode];
        }
    }
    //5. 消耗energy
    [self updateEnergy:-1];
}

/**
 *  MARK:--------------------对输入的mv更新mvCache并进入outLoop--------------------
 *  1. 有需求时,找出imv解决经验,尝试决策并解决;
 *  2. TODO:明天扩展对out_p的支持
 *  3. TODO:>>>>>此处,不应直接交由decision,而是交给mvCache序列,并由loop决定是否优先执行此mv;
 */
-(void) dataIn_AssExp_ToOutLoop:(AICMVNode*)cmvNode {
    //1. 数据检查
    if (cmvNode == nil) {
        return;
    }
    
    //2. 将联想到的cmv更新energy和cmvCache
    NSString *algsType = cmvNode.urgentTo_p.algsType;
    NSInteger urgentTo = [NUMTOOK([SMGUtils searchObjectForPointer:cmvNode.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
    NSInteger delta = [NUMTOOK([SMGUtils searchObjectForPointer:cmvNode.delta_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
    [self updateEnergy:(urgentTo + 9)/10];
    [self.mvCacheManager updateCMVCache:algsType urgentTo:urgentTo delta:delta order:urgentTo];
    
    //3. 形成循环,根据当前最前排mv和energy,再进行思维;
    [self dataOut_AssociativeExperience];
}


/**
 *  MARK:--------------------输出数据的规律和抽象方向思考--------------------
 *  1. 无需求时,找出以往同样经历,类比规律,抽象出更确切的意义;
 *  2. 注:此方法为abs方向的思维方法总入口;(与其相对的决策处
 */
-(void) dataIn_AssExp_ToLawAbsData:(AINetCMVModel*)cmvModel cmvNode:(AICMVNode*)cmvNode {
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
                
                NSLog(@"____absData1 > 联想到cmv模型>>>\ncmvModel:%ld,%@ \n assCmvModel:%ld,%@",(long)cmvModel.pointer.pointerId,cmvModel.pointer.params,(long)assCmvModel.pointer.pointerId,assCmvModel.pointer.params);
                
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
                    
                    NSLog(@"____absData > 类比到规律 >> 进行抽象;——————————START\n");
                    [absNode print];
                    
                    //TODO:>>>>>将absNode和absCmvNode存到thinkFeedCache;
                }
            }
        }else if(ISOK(assDirectionNode, AIAbsCMVNode.class)){
            AIAbsCMVNode *assAbsCmvNode = (AIAbsCMVNode*)assDirectionNode;
            //4. 排除联想自己(随后写到reference中)
            if (![cmvNode.pointer isEqual:assAbsCmvNode.pointer]) {
                AINetAbsNode *ass_an = [SMGUtils searchObjectForPointer:assAbsCmvNode.absNode_p fileName:FILENAME_Node time:cRedisNodeTime];
                if (ass_an) {
                    NSArray *absValues = [SMGUtils searchObjectForPointer:ass_an.absValue_p fileName:FILENAME_AbsValue time:cRedisValueTime];
                    
                    //5. 类比orders的规律,并abs;
                    NSArray *sames = [ThinkingUtils analogyOrdersA:foNode.orders_kvp ordersB:absValues];
                    
                    //6. 构建absNode & 并把absValue添加到瞬时记忆
                    if (ARRISOK(sames) && ARRISOK(absValues) && sames.count != absValues.count) {
                        
                        //9. createAbsNode
                        AINetAbsNode *create_an = [[AINet sharedInstance] createAbs:@[foNode,ass_an] refs_p:sames];
                        [self dataIn_ToShortCache:create_an.absValue_p];
                        
                        //10. createAbsCmvNode //扩展支持absCmvNode...
                        AIAbsCMVNode *absCmvNode = [theNet createAbsCMVNode:create_an.pointer aMv_p:cmvModel.cmvNode_p bMv_p:ass_an.absCmvNode_p];
                        
                        //11. cmv模型连接;
                        if (ISOK(absCmvNode, AIAbsCMVNode.class)) {
                            create_an.absCmvNode_p = absCmvNode.pointer;
                            [SMGUtils insertObject:create_an rootPath:create_an.pointer.filePath fileName:FILENAME_Node];
                        }
                        
                        NSLog(@"____absData > 类比到规律 >> 进行抽象;——————————START\n");
                        [create_an print];
                    }
                    
                    //(对assAbsNode 和 foNode) 找sames;
                    
                    //考虑删掉,cmvModel;直接类似abs这种,互相指向...(更简单)
                    
                }
            }
        }
    }
}


//MARK:===============================================================
//MARK:                     < dataOut (回归具象之旅) >
//MARK:===============================================================


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
    
    //2. energy判断;
    if (self.energy > 0) {
        
        //3. 从expCache中,排序并取到首个值得思考的expModel;
        __block ExpCacheModel *expModel = [mvCacheModel getCurrentExpCacheModel];
        
        //4. 如果,没有一个想可行的,则再联想一个新的相关"解决经验";并重新循环下去;
        if (!expModel) {
            [ThinkingUtils getDemand:mvCacheModel.algsType delta:mvCacheModel.delta complete:^(BOOL upDemand, BOOL downDemand) {
                MVDirection direction = downDemand ? MVDirection_Negative : MVDirection_Positive;
                
                //5. filter筛选器取曾经历的除已有expModels之外的最强解决;
                NSArray *mvRefs = [theNet getNetNodePointersFromDirectionReference:mvCacheModel.algsType direction:direction filter:^NSArray *(NSArray *protoArr) {
                    protoArr = ARRTOOK(protoArr);
                    for (NSInteger i = 0; i < protoArr.count; i++) {
                        AIPort *port = ARR_INDEX(protoArr, protoArr.count - i - 1);
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
                
                //6. 加入待判断区;
                AIPort *referenceMvPort = ARR_INDEX(mvRefs, 0);
                if (referenceMvPort) {
                    expModel = [ExpCacheModel newWithExp_p:referenceMvPort.target_p];
                    [mvCacheModel addToExpCache:expModel];
                }
            }];
        }
        
        //7. 有可具象思考的expModel则执行;
        if (expModel) {
            [self updateEnergy:-1]; //思考与决策消耗能量;
            [self dataOut_AssociativeConcreteData:expModel complete:^(BOOL canOut, NSArray *out_ps,BOOL expModelInvalid) {
                if (canOut) {
                    [self dataOut_TryOut:expModel outArr:out_ps];
                }else{
                    if (expModelInvalid) {
                        [mvCacheModel.exceptExpModels addObject:expModel];  //排除无效的expModel;(一次无效,不表示永远无效,所以彻底无效时,再排除)
                    }
                    [self dataOut_AssociativeExperience];               //并递归到最初;
                }
            }];
        }else{
            //8. 无解决经验,反射输出;//V2TODO:此处不应放弃联想,应该先看下当前有哪些信息,是可以联想分析出解决方案的; (跳出递归)
            [self dataOut_Reflex:AIMoodType_Anxious];
        }
    }else{
        //9. 如果energy<=0,(未找到可行性,直接反射输出 || 尝试输出"可行性之首"并找到实际操作)
        [self dataOut_Reflex:AIMoodType_Anxious];
    }
}


/**
 *  MARK:--------------------联想具象 (从上往下找foNode)--------------------
 *  @param expModel : 从expModel下查找具象可输出;
 */
-(void) dataOut_AssociativeConcreteData:(ExpCacheModel*)expModel complete:(void(^)(BOOL canOut,NSArray *out_ps,BOOL expModelInvalid))complete{
    __block BOOL invokedComplete = false;
    __block BOOL expModelInvalid = false;
    if (expModel) {
        //1. 联想"解决经验"对应的cmvNode & 联想具象数据,并取到决策关键信息;(可行性判定)
        NSObject *expMvNode = [SMGUtils searchObjectForPointer:expModel.exp_p fileName:FILENAME_Node time:cRedisNodeTime];
        AIFrontOrderNode *expOutFoNode = [self dataOut_AssociativeConcreteData_ExpOut:expMvNode except_ps:expModel.exceptExpOut_ps];
        
        //2. 有执行方案,则对执行方案进行反思检查;
        if (expOutFoNode != nil) {
            [self dataOut_CheckScore_ExpOut:expOutFoNode complete:^(CGFloat score, NSArray *out_ps) {
                expModel.order += score;//联想对当前expModel的order影响;
                if (score >= 3) {
                    NSLog(@" >> 执行经验输出");
                    complete(true,out_ps,expModelInvalid);
                    invokedComplete = true;
                }
            }];
        }else{
            //4. 没有执行方案,转向对抽象宏节点进行尝试输出;
            AINetAbsNode *tryOutAbsNode = [self dataOut_AssociativeConcreteData_TryOut:expMvNode exceptTryOut_ps:expModel.exceptTryOut_ps];
            if (tryOutAbsNode != nil) {
                [self dataOut_CheckScore_TryOut:tryOutAbsNode complete:^(CGFloat score, NSArray *out_ps) {
                    expModel.order += score;//联想对当前expModel的order影响;
                    if (score > 10) {
                        NSLog(@" >> 执行尝试输出");
                        complete(true,out_ps,expModelInvalid);
                        invokedComplete = true;
                    }
                }];
            }else{
                //5. 本expModel彻底无效,
                expModelInvalid = true;
            }
        }
    }
    
    if (!invokedComplete) {
        NSLog(@" >> 本次输出不过关,toLoop...");
        complete(false,nil,expModelInvalid);
    }
}


/**
 *  MARK:--------------------联想具象 (从上往下找foNode)--------------------
 *  @param baseMvNode : mv节点经验(有可能是AICMVNode也有可能是AIAbsCMVNode)
 *  @param checkMvNode : 当前正在检查的节点 (初始状态下=baseMvNode)
 *  @param checkMvNode_p : 当前正在检查的节点地址 (初始状态下=nil,然后=checkMvNode.pointer) (用于当网络中mv或mv指向foNode为null的情况下,能够继续执行下去)
 *  @param except_ps : 当前已排除的;
 *  功能 : 找到曾输出经验;
 *  TODO:加上预测功能
 *  TODO:加上联想到mv时,传回给mvCacheManager;
 *  注:每一次输出,只是决策与预测上的一环;并不意味着结束;
 *  //1. 记录思考mv结果到叠加mvCacheModel.order;
 *  //2. 记录思考data结果到thinkFeedCache;
 *  //3. 如果mindHappy_No,可以再尝试下一个getNetNodePointersFromDirectionReference_Single;找到更好的解决方法;
 *  //4. 最终更好的解决方法被输出,并且解决问题后,被加强;
 *  //5. 是数据决定了下一轮循环思维想什么,但数据仅能通过mv来决定,无论是思考的方向,还是思考的能量,还是思考的目标,都是以mv为准的;而mv的一切关联,又是以数据为规律进行关联的;
 *  注: 先从最强关联的最底层foNode开始,逐个取用;直到energy<=0,或其它原因中止;
 *
 */
-(AIFrontOrderNode*) dataOut_AssociativeConcreteData_ExpOut:(NSObject*)baseMvNode except_ps:(nonnull NSMutableArray*)except_ps{
    return [self dataOut_AssociativeConcreteData_ExpOut:baseMvNode checkMvNode:baseMvNode checkMvNode_p:nil except_ps:except_ps];
}
-(AIFrontOrderNode*) dataOut_AssociativeConcreteData_ExpOut:(NSObject*)baseMvNode checkMvNode:(NSObject*)checkMvNode checkMvNode_p:(AIPointer*)checkMvNode_p except_ps:(nonnull NSMutableArray*)except_ps {
    
    //1. 当前神经元异常时,回归到checkBase; 注:(异常判定: <(类型无效 | null) & checkMvNode!=nil>);
    __block AIFrontOrderNode *foNode = nil;
    AIFrontOrderNode* (^ CheckIsNullOrException)() = ^{
        BOOL nullOrException = (checkMvNode_p != nil);
        if (nullOrException) {
            [except_ps addObject:checkMvNode_p];
            foNode = [self dataOut_AssociativeConcreteData_ExpOut:baseMvNode except_ps:except_ps];
        }
        return foNode;
    };
    
    //2. 具象mv
    if (ISOK(checkMvNode, AICMVNode.class)) {
        AICMVNode *cmvNode = (AICMVNode*)checkMvNode;
        AIFrontOrderNode *foNode = [ThinkingUtils getFoNodeFromCmvNode:cmvNode];
        if (foNode) {
            [except_ps addObject:cmvNode.pointer];
            NSLog(@"dataOut_AssConData_ExpOut找到: %ld_%ld",(long)cmvNode.pointer.pointerId,foNode.pointer.pointerId);
            return foNode;
        }else{
            //3. 前因时序列为null的异常;
            return CheckIsNullOrException();
        }
    }else if(ISOK(checkMvNode, AIAbsCMVNode.class)){
        //4. 抽象mv
        AIAbsCMVNode *checkAbsMvNode = (AIAbsCMVNode*)checkMvNode;
        AIPort *findConPort = [checkAbsMvNode getConPortWithExcept:except_ps];
        if (!findConPort) {
            //5. 没找到conPort,说明checkMvNode的所有conPort都已排除,则checkMvNode本身也被排除;
            [except_ps addObject:checkAbsMvNode.pointer];
            
            //6. 被排除的不是base才可以递归回checkBase;
            if (![baseMvNode isEqual:checkMvNode]) {
                return [self dataOut_AssociativeConcreteData_ExpOut:baseMvNode except_ps:except_ps];
            }
        }else{
            //7. 找到conPort,则递归判断类型是否foNode;
            NSObject *findConNode = [SMGUtils searchObjectForPointer:findConPort.target_p fileName:FILENAME_Node];
            return [self dataOut_AssociativeConcreteData_ExpOut:baseMvNode checkMvNode:findConNode checkMvNode_p:findConPort.target_p except_ps:except_ps];
        }
    }else{
        //8. 类型异常
        return CheckIsNullOrException();
    }
    
    //9. 连base自己也被排除了,还未找到foNode,就只能返回nil了;
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
 *  MARK:--------------------可行性判定 (经验执行方案)--------------------
 *  注:目前outLog在absNode和index中,无法区分,所以此方法仅对foNode的foNode.out_ps直接抽象部分进行联想,作为可行性判定原由;
 *  注:TODO:后续可以增加energy的值,并在此方法中每一次scoreForce就energy--;以达到更加精细的思维控制;
 *
 *  A:根据out_ps联想(分析可行性)
 *  >assHavResult : 其有没有导致mv-和mv+;
 *    > mv-则:联想conPort,思考具象;
 *    > mv+则:score+分;
 *  >assNoResult :
 *
 */
-(void) dataOut_CheckScore_ExpOut:(AIFrontOrderNode*)foNode complete:(void(^)(CGFloat score,NSArray *out_ps))complete{
    if (!foNode) {
        complete(0,nil);
    }
    CGFloat score = 0;
    
    //1. 取出outLog;
    NSArray *out_ps = [ThinkingUtils filterOutPointers:foNode.orders_kvp];
    
    //2. 判断out_ps本身有没有宏节点; (目前对output_p不做absIndex)
    //AIKVPointer *absValue_p = [theNet getNetAbsIndex_AbsPointer:out_ps];
    //AIKVPointer *absNode_p = [theNet getItemAbsNodePointer:absValue_p];
    //AINetAbsNode *assOutAbsNode = [SMGUtils searchObjectForPointer:absNode_p fileName:FILENAME_Node time:cRedisNodeTime];

    //3. 检查assOutAbsNode对应的mv & 处理absCmvNode评价影响力;(系数0.5) (目前对output_p不做absIndex)
    //if (assOutAbsNode) {
    //    CGFloat scoreForce = [ThinkingUtils getScoreForce:assOutAbsNode.absCmvNode_p ratio:0.5f];
    //    score += scoreForce;
    //}
    
    //4. 取foNode的抽象节点absNodes;
    for (AIPort *absPort in ARRTOOK(foNode.absPorts)) {
        
        //5. 判断absNode是否是由out_ps抽象的 (根据"微信息"组)
        AINetAbsNode *absNode = [SMGUtils searchObjectForPointer:absPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];
        if (absNode) {
            NSArray *microArr_p = ARRTOOK([SMGUtils searchObjectForPointer:absNode.absValue_p fileName:FILENAME_AbsValue]);
            BOOL fromOut_ps = [SMGUtils containsSub_ps:microArr_p parent_ps:out_ps];
            
            //6. 根据当前absNode的mv果,处理absCmvNode评价影响力;(系数0.2)
            if (fromOut_ps) {
                CGFloat scoreForce = [ThinkingUtils getScoreForce:absNode.absCmvNode_p ratio:0.2f];
                score += scoreForce;
            }
        }
    }
    
    complete(score,out_ps);
}

/**
 *  MARK:--------------------可行性判定 (尝试激活执行方案)--------------------
 */
-(void) dataOut_CheckScore_TryOut:(AINetAbsNode*)absNode complete:(void(^)(CGFloat score,NSArray *out_ps))complete{
    CGFloat score = 0;
    if (!absNode) {
        complete(0,nil);
    }
    //1. 取宏信息指向的"微信息"数组
    NSArray *microArr_p = ARRTOOK([SMGUtils searchObjectForPointer:absNode.absValue_p fileName:FILENAME_AbsValue]);
    
    //2. 根据microArr_p联想到对应的assAbsCmvNode;
    AIKVPointer *absValue_p = [theNet getNetAbsIndex_AbsPointer:microArr_p];
    AIKVPointer *absNode_p = [theNet getItemAbsNodePointer:absValue_p];
    AINetAbsNode *assAbsNode = [SMGUtils searchObjectForPointer:absNode_p fileName:FILENAME_Node time:cRedisNodeTime];
    
    //3. 处理assAbsNode评价影响力;(系数0.8)
    CGFloat scoreForce = [ThinkingUtils getScoreForce:assAbsNode.absCmvNode_p ratio:0.8f];
    score += scoreForce;
    complete(score,microArr_p);
}


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

@end
