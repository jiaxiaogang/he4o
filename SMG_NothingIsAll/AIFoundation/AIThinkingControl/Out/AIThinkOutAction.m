//
//  AIThinkOutAction.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/5/20.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "AIThinkOutAction.h"
#import "AIAbsAlgNode.h"
#import "ThinkingUtils.h"

@implementation AIThinkOutAction

/**
 *  MARK:--------------------SP行为化--------------------
 *  @desc 参考:MC_V3;
 *  @desc 工作模式:
 *      1. 将S加工成P;
 *      2. 满足P;
 *  @param complete : 必然执行,且仅执行一次;
 */
-(void) convert2Out_SP:(AIKVPointer*)sAlg_p pAlg_p:(AIKVPointer*)pAlg_p complete:(void(^)(BOOL success,NSArray *acts))complete {
    //1. 结果数据准备
    NSMutableArray *acts = [[NSMutableArray alloc] init];
    AIAlgNodeBase *sAlg = [SMGUtils searchNode:sAlg_p];
    AIAlgNodeBase *pAlg = [SMGUtils searchNode:pAlg_p];
    if (!pAlg) {
        complete(false,acts);//p为空直接失败;
        return;
    }
    NSLog(@"STEPKEY==========================SP START==========================\nSTEPKEYS:%@\nSTEPKEYP:%@",Alg2FStr(sAlg),Alg2FStr(pAlg));
    
    //2. 满足P: GL部分;
    NSDictionary *cGLDic = [SMGUtils filterPointers:sAlg.content_ps b_ps:pAlg.content_ps checkItemValid:^BOOL(AIKVPointer *a_p, AIKVPointer *b_p) {
        return [a_p.identifier isEqualToString:b_p.identifier];
    }];
    
    //3. 满足P: H部分;
    NSArray *cHavArr = [SMGUtils removeSub_ps:cGLDic.allValues parent_ps:pAlg.content_ps];
    
    //4. GL行为化;
    __block BOOL failure = false;
    for (NSData *key in cGLDic) {
        //a. 对比大小
        AIKVPointer *sValue_p = DATA2OBJ(key);
        AIKVPointer *pValue_p = [cGLDic objectForKey:key];
        AnalogyType type = [ThinkingUtils compare:sValue_p valueB_p:pValue_p];
        //b. 行为化
        NSLog(@"------SP_GL行为化:%@ -> %@",[NVHeUtil getLightStr:sValue_p],[NVHeUtil getLightStr:pValue_p]);
        [self convert2Out_RelativeValue:pValue_p.algsType ds:pValue_p.dataSource type:type vSuccess:^(AIFoNodeBase *glFo, NSArray *itemActs) {
            [acts addObjectsFromArray:itemActs];
        } vFailure:^{
            failure = true;
        }];
        if (failure) break;
    }
    
    //5. H行为化;
    for (AIKVPointer *pValue_p in cHavArr) {
        //a. 将pValue_p独立找到概念,并找cHav;
        AIAbsAlgNode *soloAlg = [theNet createAbsAlg_NoRepeat:@[pValue_p] conAlgs:nil isMem:false];
        [self convert2Out_SP_Hav:soloAlg.pointer complete:complete checkScore:^BOOL(AIAlgNodeBase *mAlg) {
            return true;
        }];
        
        
        //TODOTOMORROW:
        //1. 将具象节点checkAlg找出来,并与pValue_p组成概念节点,并找cHav;
        //2. 对cHav和GL的调用,转移,做检查,不应走向MC,这个要改掉;
        //3. 补全score评价;
        
        
        //[self convert2Out_Alg:csAlg.pointer curFo:curFo type:ATHav success:^(NSArray *acts) {
        //    [allActs addObjectsFromArray:acts];
        //} failure:^{
        //    failured = true;
        //} checkScore:checkScore];
    }
    
    complete(!failure,acts);
}

/**
 *  MARK:--------------------单个概念的行为化--------------------
 *  第1级: 直接判定curAlg_p为输出则收集;
 *  第2级: LongNet长短时网络行为化
 *  @param curAlg_p : 来源: TOR.R-;
 */
-(void) convert2Out_SP_Hav:(AIKVPointer*)curAlg_p complete:(void(^)(BOOL itemSuccess,NSArray *actions))complete checkScore:(BOOL(^)(AIAlgNodeBase *mAlg))checkScore{
    //1. 数据准备;
    if (!curAlg_p) {
        complete(false,nil);
        return;
    }
    
    //2. 本身即是isOut时,直接行为化返回;
    if (curAlg_p.isOut) {
        complete(true,@[curAlg_p]);
        NSLog(@"-> SP_Hav_isOut为TRUE: %@",AlgP2FStr(curAlg_p));
        return;
    }else{
        NSMutableArray *result = [[NSMutableArray alloc] init];
        __block BOOL success = false;
        AIAlgNodeBase *curAlg = [SMGUtils searchNode:curAlg_p];
        if (curAlg) {
            //4. mc行为化失败,则联想长时行为化;
            [self convert2Out_Long_NET:ATHav at:curAlg_p.algsType ds:curAlg_p.dataSource success:^(AIFoNodeBase *havFo, NSArray *actions) {
                //4. hnAlg行为化成功;
                [result addObjectsFromArray:actions];
                NSLog(@"---> HN_行为化成功: 长度:%lu 行为:[%@]",(unsigned long)actions.count,[NVHeUtil getLightStr4Ps:actions]);
                success = true;
            } failure:^{
                //8. 未联想到hnAlg,失败;
                WLog(@"长时_行为化失败");
            }];
        }
        complete(success,result);
    }
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
/**
 *  MARK:--------------------"相对概念"的行为化--------------------
 *  1. 先根据havAlg取到havFo;
 *  2. 再判断havFo中的rangeOrder的行为化;
 *  3. 思考: 是否做alg局部匹配,递归取3个左右,逐个取并取其ATHav (并类比缺失部分,循环); (191120废弃,不做)
 *  @param success : 行为化成功则返回(havFo + 行为序列); (havFo notnull, actions notnull)
 */
-(void) convert2Out_Long_NET:(AnalogyType)type at:(NSString*)at ds:(NSString*)ds success:(void(^)(AIFoNodeBase *havFo,NSArray *actions))success failure:(void(^)())failure {
    //1. 数据准备
    AIAlgNodeBase *hnAlg = [ThinkingUtils dataOut_GetAlgNodeWithInnerType:type algsType:at dataSource:ds];
    if (!hnAlg) {
        //2. 未联想到hnAlg,失败;
        failure();
        return;
    }
    
    //2. 找引用"相对概念"的内存中"相对时序",并行为化; (注: 一般不存在内存相对概念,此处代码应该不会执行);
    NSArray *memRefPorts = [SMGUtils searchObjectForPointer:hnAlg.pointer fileName:kFNMemRefPorts time:cRTMemPort];
    __block BOOL successed = false;
    [self convert2Out_RelativeFo_ps:[SMGUtils convertPointersFromPorts:memRefPorts] success:^(AIFoNodeBase *havFo, NSArray *actions) {
        successed = true;
        success(havFo,actions);
    } failure:^{
        WLog(@"相对概念,行为化失败");
    }];
    
    //3. 根据havAlg联想时序,并找出新的解决方案,与新的行为化的概念,与新的条件概念;
    if (!successed) {
        NSArray *hdRefPorts = ARR_SUB(hnAlg.refPorts, 0, cHavNoneAssFoCount);
        [self convert2Out_RelativeFo_ps:[SMGUtils convertPointersFromPorts:hdRefPorts] success:^(AIFoNodeBase *havFo, NSArray *actions) {
            successed = true;
            success(havFo,actions);
        } failure:^{
            WLog(@"相对概念,行为化失败");
        }];
        
        //4. 行为化失败;
        if (!successed) {
            failure();
        }
    }
}

//MARK:===============================================================
//MARK:                     < Fo&Alg >
//MARK:===============================================================
/**
 *  MARK:--------------------对一个rangeOrder进行行为化;--------------------
 *  @desc 一些记录:
 *      1. 191105总结下,此处有多少处,使用短时,长时,在前面插入瞬时;
 *      2. 191105针对概念嵌套的代码,先去掉;
 *      3. 191107考虑将foScheme也搬过来,优先使用matchFo做第一解决方案;
 *  @TODO_TEST_HERE: 测试下阈值-3,是否合理;
 */
-(void) convert2Out_Fo:(NSArray*)curAlg_ps curFo:(AIFoNodeBase*)curFo success:(void(^)(NSArray *acts))success failure:(void(^)())failure {
    //1. 数据准备
    NSLog(@"STEPKEY============================== 行为化 START ==================== \nSTEPKEY时序:%@->%@\nSTEPKEY需要:[%@]",Fo2FStr(curFo),Mvp2Str(curFo.cmvNode_p),Pits2FStr(curAlg_ps));
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!ARRISOK(curAlg_ps) || curFo == nil) {
        failure();
        WLog(@"fo行为化失败,参数无效");
    }
    if (![self.delegate toAction_EnergyValid]) {
        failure();
        WLog(@"思维活跃度耗尽,无法决策行为化");
    }
    
    //2. 依次单个概念行为化
    for (AIKVPointer *curAlg_p in curAlg_ps) {
        __block BOOL successed = false;
        [self convert2Out_Alg:curAlg_p curFo:curFo type:ATHav success:^(NSArray *actions) {
            //3. 行为化成功,则收集;
            successed = true;
            [result addObjectsFromArray:actions];
        } failure:^{
            WLog(@"行为化失败");
        } checkScore:^BOOL(AIAlgNodeBase *mAlg) {
            if (mAlg) {
                //将此处反思功能去掉 (原方法,太繁琐,评价应该基于SP反思解决);
            }
            //11. 默认返回可行;
            return true;
        }];
        
        //4. 有一个失败,则整个rangeOrder失败;)
        if (!successed) {
            [theNV setNodeData:curAlg_p lightStr:@"行为化失败"];
            failure();
            return;
        }
        [theNV setNodeData:curAlg_p lightStr:@"行为化成功"];
    }
    
    //5. 成功回调,每成功一次fo,消耗1格活跃值;
    [self.delegate toAction_updateEnergy:-1];
    NSLog(@"----> 输出行为:[%@]",[NVHeUtil getLightStr4Ps:result]);
    success(result);
}

/**
 *  MARK:--------------------单个概念的行为化--------------------
 *  第1级: 直接判定curAlg_p为输出则收集;
 *  第2级: MC匹配行为化
 *  第3级: LongNet长短时网络行为化
 *  @param type : ATHav或ATNone
 *  @param curAlg_p : 三个来源: 1.Fo的元素A;  2.Range的元素A; 3.Alg的嵌套A;
 */
-(void) convert2Out_Alg:(AIKVPointer*)curAlg_p curFo:(AIFoNodeBase*)curFo type:(AnalogyType)type success:(void(^)(NSArray *actions))success failure:(void(^)())failure checkScore:(BOOL(^)(AIAlgNodeBase *mAlg))checkScore{
    //1. 数据准备;
    if (!curAlg_p) {
        failure();
    }
    if (type != ATHav && type != ATNone) {
        WLog(@"SingleAlg_行为化类参数type错误");
        failure();
    }
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //2. 本身即是isOut时,直接行为化返回;
    if (curAlg_p.isOut) {
        [result addObject:curAlg_p];
        NSLog(@"-> isOut为TRUE: %@",[NVHeUtil getLightStr:curAlg_p]);
        success(result);
        return;
    }else{
        AIAlgNodeBase *curAlg = [SMGUtils searchNode:curAlg_p];
        if (curAlg) {
            //3. 单ATHav时,直接从瞬时做MC匹配行为化;
            __block BOOL successed = false;
            //4. mc行为化失败,则联想长时行为化;
            [self convert2Out_Long_NET:type at:curAlg_p.algsType ds:curAlg_p.dataSource success:^(AIFoNodeBase *havFo, NSArray *actions) {
                //4. hnAlg行为化成功;
                [result addObjectsFromArray:actions];
                NSLog(@"---> HN_行为化成功: 长度:%lu 行为:[%@]",(unsigned long)actions.count,[NVHeUtil getLightStr4Ps:actions]);
                success(result);
                successed = true;
            } failure:^{
                //20191120: _sub方法废弃; 第3级: 对curAlg的(subAlg&subValue)分别判定; (目前仅支持a2+v1各一个)
                //NSArray *subResult = ARRTOOK([self convert2Out_Single_Sub:curAlg_p]);
                //[result addObjectsFromArray:subResult];
                //8. 未联想到hnAlg,失败;
                WLog(@"长时_行为化失败");
            }];
            if (successed) return;
        }
    }
    failure();
}

//MARK:===============================================================
//MARK:                     < Relative >
//MARK:===============================================================

/**
 *  MARK:--------------------对单稀疏码的变化进行行为化--------------------
 *  @desc 伪代码:
 *  1. 根据type和value_p找ATLess/ATGreater
 *      2. 找不到,failure;
 *      3. 找到,判断range是否导致条件C转移;
 *          4. 未转移: success
 *          5. 转移: C条件->递归到convert2Out_Single_Alg();
 *  @param at & ds : 用作查找"大/小"的标识;
 */
-(void) convert2Out_RelativeValue:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type vSuccess:(void(^)(AIFoNodeBase *glFo,NSArray *acts))vSuccess vFailure:(void(^)())vFailure {
    //1. 数据检查
    if ((type != ATGreater && type != ATLess)) {
        WLog(@"value_行为化类参数type|value_p错误");
        vFailure();
        return;
    }
    
    //2. 根据type和value_p找ATLess/ATGreater
    NSLog(@"----> RelativeValue Start at:%@ ds:%@ type:%ld",at,ds,(long)type);
    AIAlgNodeBase *glAlg = [ThinkingUtils dataOut_GetAlgNodeWithInnerType:type algsType:at dataSource:ds];
    if (!glAlg) {
        vFailure();
        return;
    }
    
    //3. 根据havAlg联想时序,并找出新的解决方案,与新的行为化的概念,与新的条件概念;
    __block BOOL successed = false;
    NSArray *hdRefPorts = ARR_SUB(glAlg.refPorts, 0, cHavNoneAssFoCount);
    [self convert2Out_RelativeFo_ps:[SMGUtils convertPointersFromPorts:hdRefPorts] success:^(AIFoNodeBase *glFo, NSArray *actions) {
        successed = true;
        vSuccess(glFo,actions);
    } failure:^{
        WLog(@"相对概念,行为化失败");
    }];
    
    //4. 行为化失败;
    if (!successed) vFailure();
}


/**
 *  MARK:--------------------"相对时序"的行为化--------------------
 *  @param relativeFo_ps    : 相对时序地址;
 *  @param success          : 回调传回: 相对时序 & 行为化结果;
 *  @param failure          : 只要有一条行为化成功则success(),否则failure();
 *  注:
 *      1. 参数: 由方法调用者保证传入的是"相对时序"而不是普通时序
 *      2. 流程: 取出相对时序,并取rangeOrder,行为化并返回
 */
-(void) convert2Out_RelativeFo_ps:(NSArray*)relativeFo_ps success:(void(^)(AIFoNodeBase *havFo,NSArray *actions))success failure:(void(^)())failure {
    //1. 数据准备
    relativeFo_ps = ARRTOOK(relativeFo_ps);
    
    //2. 逐个尝试行为化
    NSLog(@"----> RelativeFo_ps Start 目标:%@",[NVHeUtil getLightStr4Ps:relativeFo_ps]);
    for (AIPointer *relativeFo_p in relativeFo_ps) {
        AIFoNodeBase *relativeFo = [SMGUtils searchNode:relativeFo_p];
        
        //3. 取出havFo除第一个和最后一个之外的中间rangeOrder
        NSLog(@"---> RelativeFo Item 内容:%@",[NVHeUtil getLightStr4Ps:relativeFo.content_ps]);
        __block BOOL successed = false;
        if (relativeFo != nil && relativeFo.content_ps.count >= 1) {
            NSArray *foRangeOrder = ARR_SUB(relativeFo.content_ps, 0, relativeFo.content_ps.count - 1);
            
            //4. 未转移,不需要行为化;
            if (!ARRISOK(foRangeOrder)) {
                successed = true;
                success(relativeFo,nil);
            }else{
                
                //5. 转移,则进行行为化 (递归到总方法);
                [self convert2Out_Fo:foRangeOrder curFo:relativeFo success:^(NSArray *acts) {
                    successed = true;
                    success(relativeFo,acts);
                } failure:^{
                    failure();
                    WLog(@"相对时序行为化失败");
                }];
            }
        }
        
        //6. 成功一个item即可;
        if (successed) {
            return;
        }
    }
    failure();
}

@end
