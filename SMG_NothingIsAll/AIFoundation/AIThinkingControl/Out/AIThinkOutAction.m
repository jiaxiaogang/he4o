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
#import "AINetUtils.h"
#import "AINetService.h"

@implementation AIThinkOutAction

/**
 *  MARK:--------------------SP行为化--------------------
 *  @desc 参考:MC_V3;
 *  @desc 工作模式:
 *      1. 将S加工成P;
 *      2. 满足P;
 *  @param complete : 必然执行,且仅执行一次;
 *  @version
 *      2020-05-22: 调用cHav,在原先solo与group的基础上,新增了最优先的checkAlg (因为solo和group可能压根不存在此概念,而TO是主应用,而非构建的);
 */
-(void) convert2Out_SP:(AIKVPointer*)sAlg_p pAlg_p:(AIKVPointer*)pAlg_p checkAlg_p:(AIKVPointer*)checkAlg_p complete:(void(^)(BOOL success,NSArray *acts))complete {
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
    
    //3. 满足P: cHav部分;
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
        [self convert2Out_GL:pAlg vAT:pValue_p.algsType vDS:pValue_p.dataSource type:type vSuccess:^(AIFoNodeBase *glFo, NSArray *itemActs) {
            [acts addObjectsFromArray:itemActs];
        } vFailure:^{
            failure = true;
        }];
        if (failure) break;
    }
    
    //5. H行为化;
    for (AIKVPointer *pValue_p in cHavArr) {
        //a. 直接对checkAlg找cHav;
        __block BOOL hSuccess = false;
        [self convert2Out_Hav:checkAlg_p complete:^(BOOL itemSuccess, NSArray *actions) {
            hSuccess = itemSuccess;
            [acts addObjectsFromArray:actions];
        } checkScore:^BOOL(AIAlgNodeBase *mAlg) {
            return true;
        }];
        if (hSuccess) continue;
        
        //b. 将pValue_p独立找到概念,并找cHav;
        AIAbsAlgNode *soloAlg = [theNet createAbsAlg_NoRepeat:@[pValue_p] conAlgs:nil isMem:false];
        [self convert2Out_Hav:soloAlg.pointer complete:^(BOOL itemSuccess, NSArray *actions) {
            hSuccess = itemSuccess;
            [acts addObjectsFromArray:actions];
        }  checkScore:^BOOL(AIAlgNodeBase *mAlg) {
            return true;
        }];
        if (hSuccess) continue;
        
        //c. 将pValue_p+same_ps重组找到概念,并找cHav;
        AIAlgNodeBase *checkAlg = [SMGUtils searchNode:checkAlg_p];
        NSMutableArray *group_ps = [SMGUtils removeSub_ps:pAlg.content_ps parent_ps:checkAlg.content_ps];
        [group_ps addObject:pValue_p];
        AIAbsAlgNode *groupAlg = [theNet createAbsAlg_NoRepeat:group_ps conAlgs:nil isMem:false];
        [self convert2Out_Hav:groupAlg.pointer complete:^(BOOL itemSuccess, NSArray *actions) {
            hSuccess = itemSuccess;
            [acts addObjectsFromArray:actions];
        } checkScore:^BOOL(AIAlgNodeBase *mAlg) {
            return true;
        }];
        
        //c. 一条稀疏码行为化失败,则直接返回失败;
        if (!hSuccess) {
            failure = true;
            break;
        }
    }
    
    complete(!failure,acts);
}

/**
 *  MARK:--------------------P行为化--------------------
 *  @param curAlg_p : 来源: TOR.R-;
 */
-(void) convert2Out_P:(AIKVPointer*)curAlg_p complete:(void(^)(BOOL itemSuccess,NSArray *actions))complete {
    [self convert2Out_Hav:curAlg_p complete:complete checkScore:^BOOL(AIAlgNodeBase *mAlg) {
        return true;
    }];
}


//MARK:===============================================================
//MARK:                     < Fo >
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
        [self convert2Out_Hav:curAlg_p complete:^(BOOL itemSuccess, NSArray *actions) {
            //3. 行为化成功,则收集;
            successed = itemSuccess;
            [result addObjectsFromArray:actions];
        } checkScore:^BOOL(AIAlgNodeBase *mAlg) {
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

//MARK:===============================================================
//MARK:                     < H/G/L >
//MARK:===============================================================

/**
 *  MARK:--------------------单个概念的行为化--------------------
 *  第1级: 直接判定curAlg_p为输出则收集;
 *  第2级: MC匹配行为化
 *  第3级: LongNet长短时网络行为化
 *  @param curAlg_p : 三个来源: 1.Fo的元素A;  2.Range的元素A; 3.Alg的嵌套A;
 */
-(void) convert2Out_Hav:(AIKVPointer*)curAlg_p complete:(void(^)(BOOL itemSuccess,NSArray *actions))complete checkScore:(BOOL(^)(AIAlgNodeBase *mAlg))checkScore{
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    __block BOOL success = false;
    __block AIFoNodeBase *moveHFo = nil;//转移fo,暂未使用;
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
        //3. 数据检查curAlg
        AIAlgNodeBase *curAlg = [SMGUtils searchNode:curAlg_p];
        if (!curAlg) {
            complete(false,nil);
            return;
        }
        
        //4. 数据检查hAlg_根据type和value_p找ATHav
        AIAlgNodeBase *hAlg = [AINetService getInnerAlg:curAlg vAT:curAlg_p.algsType vDS:curAlg_p.dataSource type:ATHav];
        if (!hAlg) {
            complete(false,nil);
            return;
        }
        
        
        
        
        //TODOTOMORROW:
        //1. 对Hav方法,应用MC方式,更发散的联想 (参考19192,因为每次递归,都要做这种发散联想,所以从TOP搬到TOAction中来);
        //2. 转移时,对subOutModel的支持;
        
        
        
        
        
        //5. 先根据havAlg取到havFo (逐个尝试行为化,成功一条即止);
        NSArray *hdRefPorts = ARR_SUB(hAlg.refPorts, 0, cHavNoneAssFoCount);
        [self convert2Out_RelativeFo_ps:[SMGUtils convertPointersFromPorts:hdRefPorts] success:^(AIFoNodeBase *havFo, NSArray *actions) {
            success = true;
            moveHFo = havFo;
            [result addObjectsFromArray:actions];
        } failure:nil];
    }
    complete(success,result);
}

/**
 *  MARK:--------------------对单稀疏码的变化进行行为化--------------------
 *  @desc 伪代码:
 *  1. 根据type和value_p找ATLess/ATGreater
 *      2. 找不到,failure;
 *      3. 找到,判断range是否导致条件C转移;
 *          4. 未转移: success
 *          5. 转移: C条件->递归到convert2Out_Single_Alg();
 *  @param vAT & vDS : 用作查找"大/小"的标识;
 *  @param alg : GL的微信息所处的概念, (所有微信息变化不应脱离概念,比如鸡蛋可以通过烧成固态,但水不能,所以变成固态这种特征变化,不应脱离概念去操作);
 */
-(void) convert2Out_GL:(AIAlgNodeBase*)alg vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type vSuccess:(void(^)(AIFoNodeBase *glFo,NSArray *acts))vSuccess vFailure:(void(^)())vFailure {
    //1. 数据检查
    if ((type != ATGreater && type != ATLess)) {
        WLog(@"value_行为化类参数type|value_p错误");
        vFailure();
        return;
    }
    
    //2. 根据type和value_p找ATLess/ATGreater
    AIAlgNodeBase *glAlg = [AINetService getInnerAlg:alg vAT:vAT vDS:vDS type:type];
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

//MARK:===============================================================
//MARK:                     < Relativen Fos >
//MARK:===============================================================

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
