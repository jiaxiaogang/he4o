//
//  TOAlgScheme.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/19.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOAlgScheme.h"
#import "ThinkingUtils.h"
#import "AIKVPointer.h"
#import "AIAbsAlgNode.h"
#import "AINetAbsFoNode.h"
#import "AIPort.h"
#import "AINetIndex.h"
#import "AIShortMatchModel.h"
#import "AINetIndexUtils.h"
#import "AIThinkOutAnalogy.h"

@interface TOAlgScheme()

@property (strong, nonatomic) AIShortMatchModel *shortMatchModel;

@end

@implementation TOAlgScheme

-(void)setData:(AIShortMatchModel *)shortMatchModel{
    self.shortMatchModel = shortMatchModel;
}

//MARK:===============================================================
//MARK:                     < FO & ALG >
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
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!ARRISOK(curAlg_ps) || curFo == nil) {
        failure();
        WLog(@"fo行为化失败,参数无效");
    }
    if (![self.delegate toAlgScheme_EnergyValid]) {
        failure();
        WLog(@"思维活跃度耗尽,无法决策行为化");
    }
        
    //2. 依次单个概念行为化
    [theNV setNodeData:curFo.pointer lightStr:@"行为化时序"];
    for (AIKVPointer *curAlg_p in curAlg_ps) {
        __block BOOL successed = false;
        [self convert2Out_Alg:curAlg_p type:AnalogyInnerType_Hav success:^(NSArray *actions) {
            //3. 行为化成功,则收集;
            successed = true;
            NSLog(@"行为化成功");
            [result addObjectsFromArray:actions];
        } failure:^{
            WLog(@"行为化失败");
        } checkScore:^BOOL(AIAlgNodeBase *mAlg) {
            if (mAlg) {
                //5. MC反思: 用curAlg_ps + matchAlg组成rethinkAlg_ps
                NSMutableArray *rethinkAlg_ps = [[NSMutableArray alloc] initWithArray:curFo.content_ps];
                NSInteger replaceIndex = [rethinkAlg_ps indexOfObject:curAlg_p];
                [rethinkAlg_ps replaceObjectAtIndex:replaceIndex withObject:mAlg.pointer];
                
                //6. MC反思: 回归tir反思,重新识别理性预测时序,预测价值; (预测到鸡蛋变脏,或者cpu损坏) (理性预测影响评价即理性评价)
                AIShortMatchModel *mModel = [self.delegate toAlgScheme_LSPRethink:mAlg rtFoContent_ps:rethinkAlg_ps];
                
                //7. MC反思: 对mModel进行评价;
                CGFloat mcScore = [ThinkingUtils getScoreForce:mModel.matchFo.cmvNode_p ratio:mModel.matchFoValue];
                
                //8. 对原fo进行评价
                CGFloat curScore = [ThinkingUtils getScoreForce:curFo.cmvNode_p ratio:1.0f];
                
                //9. 写评价时所需要,"设定的"的计算算法;
                
                //10. 对mcScore和curScore返回评价值进行类比 (如宁饿死不吃屎);
                CGFloat validDelta = -3;//阈值为-3;
                return curScore + mcScore > validDelta;
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
    [self.delegate toAlgScheme_updateEnergy:-1];
    success(result);
}


/**
 *  MARK:--------------------单个概念的行为化--------------------
 *  第1级: 直接判定curAlg_p为输出则收集;
 *  第2级: MC匹配行为化
 *  第3级: LongNet长短时网络行为化
 *  @param type : cHav或cNone
 *  @param curAlg_p : 三个来源: 1.Fo的元素A;  2.Range的元素A; 3.Alg的嵌套A;
 */
-(void) convert2Out_Alg:(AIKVPointer*)curAlg_p type:(AnalogyInnerType)type success:(void(^)(NSArray *actions))success failure:(void(^)())failure checkScore:(BOOL(^)(AIAlgNodeBase *mAlg))checkScore{
    //1. 数据准备;
    if (!curAlg_p) {
        failure();
    }
    if (type != AnalogyInnerType_Hav && type != AnalogyInnerType_None) {
        WLog(@"SingleAlg_行为化类参数type错误");
        failure();
    }
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //2. 本身即是isOut时,直接行为化返回;
    if (curAlg_p.isOut) {
        [result addObject:curAlg_p];
        success(result);
        return;
    }else{
        AIAlgNodeBase *curAlg = [SMGUtils searchNode:curAlg_p];
        if (self.shortMatchModel && curAlg) {
            AIAlgNodeBase *matchAlg = self.shortMatchModel.matchAlg;
            
            //3. 单cHav时,直接从瞬时做MC匹配行为化;
            __block BOOL successed = false;
            if (type == AnalogyInnerType_Hav) {
                [self convert2Out_Short_MC_V2:matchAlg curAlg:curAlg mcSuccess:^(NSArray *acts) {
                    [result addObjectsFromArray:acts];
                    successed = true;
                    NSLog(@"MC_行为化成功, 输出行为: %@",acts);
                } mcFailure:^{
                    WLog(@"MC_行为化失败");
                } checkScore:checkScore];
            }
            
            //4. mc行为化失败,则联想长时行为化;
            if (successed) {
                success(result);
                return;
            }else{
                [self convert2Out_Long_NET:type at:curAlg_p.algsType ds:curAlg_p.dataSource success:^(AIFoNodeBase *havFo, NSArray *actions) {
                    //4. hnAlg行为化成功;
                    [result addObjectsFromArray:actions];
                    success(result);
                    successed = true;
                } failure:^{
                    //20191120: _sub方法废弃; 第3级: 对curAlg的(subAlg&subValue)分别判定; (目前仅支持a2+v1各一个)
                    //NSArray *subResult = ARRTOOK([self convert2Out_Single_Sub:curAlg_p]);
                    //[result addObjectsFromArray:subResult];
                    //8. 未联想到hnAlg,失败;
                    WLog(@"长时_行为化失败");
                }];
            }
            if (!successed) {
                failure();
                return;
            }
        }
    }
    failure();
}


//MARK:===============================================================
//MARK:                     < ShortMC & LongNET >
//MARK:===============================================================

/**
 *  MARK:--------------------MC匹配行为化--------------------
 *  ********** v1 **********
 *  @desc 伪代码:
 *  1. MC匹配时,判断是否可LSP里氏替换;
 *      2. 可替换,success
 *      3. 不可替换,changeM2C,判断条件为value_p.cLess / value_p.cGreater / alg_p.cHav / alg_p.cNone;
 *          4. alg_p则递归到convert2Out_Single_Alg();
 *          5. value_p则递归到convert2Out_Single_Value();
 *  @desc
 *      1. MC匹配,仅针对cHav做行为化;
 *      2. MC匹配,是对瞬时记忆中的matchAlg做匹配行为化;
 *      3. 当MC匹配转移change条件时,递归到single_Alg或single_Value进行行为化;
 *
 *  @desc
 *      1. xx年xx月xx日: matchAlg优先,都是通过抽具象关联来判断的,而不是直接对比其内容;
 *      2. 20200204: ms&cs抵消的条件,由ms.content_ps.count=cs.content_ps.count == 1改为,两者不同稀疏码长度为1;(参考18075)
 *
 *  @todo
 *      TODO_TEST_HERE: 在alg抽象匹配时,核实下将absAlg去重,为了避免绝对匹配重复导致的联想不以cHav
 *
 *  ********** v2 **********
 *  @desc
 *      1. 运行方式: 分为GLHN四种处理方式; (Greater,Less,Hav,None)
 *      2. 主要改进: 对MC类比得到ms&cs&mcs并各进行精确的评价和行为化;
 *
 *  @desc 理性决策:
 *      1. 进行理性MC,并返回到checkScore进行理性预测评价;
 *      2. GLH为理性,因为必须满足,(其中H随后看是否需要进行评价下,比如苹果不甜,也照样能吃);
 *
 *  @实例: 用几个例子,来跑此处代码,看mAlg应该如何得来?如烤蘑菇的例子,坚果去皮的例子,cpu煎蛋的例子;
 */
-(void) convert2Out_Short_MC_V2:(AIAlgNodeBase*)matchAlg curAlg:(AIAlgNodeBase*)curAlg mcSuccess:(void(^)(NSArray *acts))mcSuccess mcFailure:(void(^)())mcFailure checkScore:(BOOL(^)(AIAlgNodeBase *mAlg))checkScore{
    //0. 数据准备
    __block BOOL failured = false;
    NSMutableArray *allActs = [[NSMutableArray alloc] init];
    NSMutableArray *alreadyGLs = [[NSMutableArray alloc] init];
    if (matchAlg && curAlg) {
        
        //1. MC匹配之: LSP里氏判断,M是否是C
        BOOL cIsAbs = ISOK(curAlg, AIAbsAlgNode.class);
        NSArray *cConPorts = cIsAbs ? ((AIAbsAlgNode*)curAlg).conPorts : nil;
        BOOL mIsC = [SMGUtils containsSub_p:matchAlg.pointer parentPorts:cConPorts];
        [AIThinkOutAnalogy mcAnalogy:matchAlg cAlg:curAlg complete:^(NSArray *mcs, NSArray *ms, NSArray *cs) {
            //2. 数据准备: (mcs无效且m不抽象自C时 = 则不匹配)
            if (!ARRISOK(mcs) && !mIsC) {
                return;
            }
            NSArray *msAlgs = [SMGUtils searchNodes:ms];
            
            //2. 当mNotS时,进行cs处理
            if (!mIsC) {
                NSArray *csAlgs = [SMGUtils searchNodes:cs];
                
                //3. MC抵消GL处理之: 判断长度为1;
                for (AIAlgNodeBase *csAlg in csAlgs) {
                    for (AIAlgNodeBase *msAlg in msAlgs) {
                        
                        //3. ms&cs仅有1条不同稀疏码;
                        NSArray *csSubMs = [SMGUtils removeSub_ps:msAlg.content_ps parent_ps:csAlg.content_ps];
                        NSArray *msSubCs = [SMGUtils removeSub_ps:csAlg.content_ps parent_ps:msAlg.content_ps];
                        if (csSubMs.count == 1 && msSubCs.count == 1) {
                            //4. MC抵消GL处理之: 判断标识相同
                            AIKVPointer *csValue_p = ARR_INDEX(csSubMs, 0);
                            AIKVPointer *msValue_p = ARR_INDEX(msSubCs, 0);
                            if ([csValue_p.identifier isEqualToString:msValue_p.identifier]) {
                                //5. MC抵消GL处理之: 转移到_Value()
                                NSNumber *csValue = NUMTOOK([AINetIndex getData:csValue_p]);
                                NSNumber *msValue = NUMTOOK([AINetIndex getData:msValue_p]);
                                AnalogyInnerType type = AnalogyInnerType_None;
                                if (csValue > msValue) {//需增大
                                    type = AnalogyInnerType_Greater;
                                }else if(csValue < msValue){//需减小
                                    type = AnalogyInnerType_Less;
                                }else{}//再者一样,不处理;
                                if (!failured && type != AnalogyInnerType_None) {
                                    [self convert2Out_RelativeValue:msValue_p type:type vSuccess:^(AIFoNodeBase *glFo, NSArray *acts) {
                                        [allActs addObjectsFromArray:acts];
                                    } vFailure:^{
                                        failured = true;
                                    }];
                                }
                                
                                //6. MC抵消GL处理之: 标记已处理;
                                [alreadyGLs addObject:csAlg];
                                [alreadyGLs addObject:msAlg];
                                break;
                            }
                        }
                    }
                    
                    //7. MC未抵消H处理之: 满足csAlg;
                    for (AIAlgNodeBase *csAlg in csAlgs) {
                        if (![alreadyGLs containsObject:csAlg] && !failured) {
                            [self convert2Out_Alg:csAlg.pointer type:AnalogyInnerType_Hav success:^(NSArray *acts) {
                                [allActs addObjectsFromArray:acts];
                            } failure:^{
                                failured = true;
                            } checkScore:checkScore];
                        }
                    }
                }
            }
            
            //8. MC未抵消N处理之: 修正msAlg;
            for (AIAlgNodeBase *msAlg in msAlgs) {
                if (![alreadyGLs containsObject:msAlg] && !failured) {
                    
                    //9. 对msAlg进行评价,看是否需要修正;
                    BOOL scoreSuccess = checkScore(msAlg);
                    if (!scoreSuccess) {
                        [self convert2Out_Alg:msAlg.pointer type:AnalogyInnerType_None success:^(NSArray *acts) {
                            [allActs addObjectsFromArray:acts];
                        } failure:^{
                            failured = true;
                        } checkScore:checkScore];
                    }
                }
            }
        }];
    }
    
    //10. 结果
    if (failured) {
        mcFailure();
    }else{
        mcSuccess(allActs);
    }
}

/**
 *  MARK:--------------------对MC中的Value部分代码--------------------
 *  @caller : 由MC方法调用;
 */
-(void) convert2Out_Short_MC_Value:(AIAlgNodeBase*)mAlg cAlg:(AIAlgNodeBase*)cAlg pAlg:(AIAlgNodeBase*)pAlg checkScore:(BOOL(^)(AIAlgNodeBase *mAlg))checkScore{
    //1. 数据检查;
    if (!mAlg || !cAlg) {
        return;
    }
    
    //2. ms&cs仅有1条不同稀疏码;
    NSArray *csSubMs = [SMGUtils removeSub_ps:mAlg.content_ps parent_ps:cAlg.content_ps];
    NSArray *msSubCs = [SMGUtils removeSub_ps:cAlg.content_ps parent_ps:mAlg.content_ps];
    if (csSubMs.count == 1 && msSubCs.count == 1) {
        //4. MC抵消GL处理之: 判断标识相同
        AIKVPointer *csValue_p = ARR_INDEX(csSubMs, 0);
        AIKVPointer *msValue_p = ARR_INDEX(msSubCs, 0);
        if ([csValue_p.identifier isEqualToString:msValue_p.identifier]) {
            //5. MC抵消GL处理之: 转移到_Value()
            
            //TODO: 取到protoAlg.value的值;
            //查下,在类比抽象时,是否会形成不同value值,被抽象成同一抽象节点的可能性;
            
            
            
            
            NSNumber *csValue = NUMTOOK([AINetIndex getData:csValue_p]);
            NSNumber *msValue = NUMTOOK([AINetIndex getData:msValue_p]);
            AnalogyInnerType type = AnalogyInnerType_None;
            if (csValue > msValue) {//需增大
                type = AnalogyInnerType_Greater;
            }else if(csValue < msValue){//需减小
                type = AnalogyInnerType_Less;
            }else{}//再者一样,不处理;
        }
    }
    
}

/**
 *  MARK:--------------------"相对概念"的行为化--------------------
 *  1. 先根据havAlg取到havFo;
 *  2. 再判断havFo中的rangeOrder的行为化;
 *  3. 思考: 是否做alg局部匹配,递归取3个左右,逐个取并取其cHav (并类比缺失部分,循环); (191120废弃,不做)
 *  @param success : 行为化成功则返回(havFo + 行为序列); (havFo notnull, actions notnull)
 */
-(void) convert2Out_Long_NET:(AnalogyInnerType)type at:(NSString*)at ds:(NSString*)ds success:(void(^)(AIFoNodeBase *havFo,NSArray *actions))success failure:(void(^)())failure {
    //1. 数据准备
    AIAlgNodeBase *hnAlg = [ThinkingUtils dataOut_GetAlgNodeWithInnerType:type algsType:at dataSource:ds];
    if (!hnAlg) {
        //2. 未联想到hnAlg,失败;
        failure();
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
//MARK:             < RelativeValue & RelativeFo >
//MARK:===============================================================
/**
 *  MARK:--------------------对单稀疏码的变化进行行为化--------------------
 *  @desc 伪代码:
 *  1. 根据type和value_p找cLess/cGreater
 *      2. 找不到,failure;
 *      3. 找到,判断range是否导致条件C转移;
 *          4. 未转移: success
 *          5. 转移: C条件->递归到convert2Out_Single_Alg();
 */
-(void) convert2Out_RelativeValue:(AIKVPointer*)value_p type:(AnalogyInnerType)type vSuccess:(void(^)(AIFoNodeBase *glFo,NSArray *acts))vSuccess vFailure:(void(^)())vFailure {
    //1. 数据检查
    if ((type != AnalogyInnerType_Greater && type != AnalogyInnerType_Less) || !value_p) {
        WLog(@"value_行为化类参数type|value_p错误");
        vFailure();
    }
    
    //1. 根据type和value_p找cLess/cGreater
    AIAlgNodeBase *glAlg = [ThinkingUtils dataOut_GetAlgNodeWithInnerType:type algsType:value_p.algsType dataSource:value_p.dataSource];
    
    //2. 找不到glAlg,failure;
    if (!glAlg) {
        vFailure();
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
    if (!successed) {
        vFailure();
    }
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
    for (AIPointer *relativeFo_p in relativeFo_ps) {
        AIFoNodeBase *relativeFo = [SMGUtils searchNode:relativeFo_p];
        
        //3. 取出havFo除第一个和最后一个之外的中间rangeOrder
        __block BOOL successed = false;
        if (relativeFo != nil && relativeFo.content_ps.count >= 2) {
            NSArray *foRangeOrder = ARR_SUB(relativeFo.content_ps, 1, relativeFo.content_ps.count - 2);
            
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

//20191107备, 说明: 此_sub方法为嵌套时,一个value_p一个subAlg_p时,做行为化的;
/**
 *  MARK:--------------------对单个概念的sub拆分行为化--------------------
 *      1. 对curAlg的(subAlg&subValue)分别判定;
 *      2. 目前仅支持 1 x subAlg + 1 x subValue (目前仅支持a2+v1各一个);
 *      3. TODO:支持"多个概念+多个value",建议"两个概念+两个value",然后,更复杂的情况用"抽象精简"和"具象展开"来解决;
 *
 *
 *  写类比,alg.content_ps中哪些已行为化,哪里还没有;
 *  TODO:
 *      TODO191106:因为此方法中,概念嵌套并未支持,所以需要重写此方法;
 *      TODO191107:考虑,将此_sub方法与_single方法进行合并;
 *      TODO191106:content_ps.count != 2的情况 (因为没有概念嵌套) 是否涉及到要改cHav索引,因为需要at&ds不明确的索引;
 *      TODO191106:以下subHavAlg要优先取shortMatchModel (在2Out_Alg()中已实现,优先MC后NET);
 *      TODO191106:第5步: 确定下:现在cHavFo与其抽象前的时序,是抽象关联吗?
 */
//-(NSArray*) convert2Out_Single_Sub:(AIKVPointer*)curAlg_p{
//    //1. 数据检查准备;
//    AIAlgNodeBase *curAlg = [SMGUtils searchNode:curAlg_p];
//    if (!curAlg) return nil;
//    NSMutableArray *result = [[NSMutableArray alloc] init];
//
//
//    // TODO191106:content_ps.count != 2的情况 (因为没有概念嵌套) 是否涉及到要改cHav索引,因为需要at&ds不明确的索引;
//
//
//    //2. 将curAlg.content_ps提取为subAlg_p和subValue_p;
//    if (curAlg.content_ps.count == 2) {
//        AIKVPointer *first_p = ARR_INDEX(curAlg.content_ps, 0);
//        AIKVPointer *second_p = ARR_INDEX(curAlg.content_ps, 1);
//        AIKVPointer *subAlg_p = nil;
//        AIKVPointer *subValue_p = nil;
//        if ([kPN_ALG_ABS_NODE isEqualToString:first_p.folderName]) {
//            subAlg_p = first_p;
//        }else if([kPN_ALG_ABS_NODE isEqualToString:second_p.folderName]){
//            subAlg_p = second_p;
//        }
//        if([kPN_VALUE isEqualToString:first_p.folderName]){
//            subValue_p = first_p;
//        }else if([kPN_VALUE isEqualToString:second_p.folderName]){
//            subValue_p = second_p;
//        }
//        if (!subAlg_p || !subValue_p) return nil;
//
//
//        // TODO191106:以下subHavAlg要优先取shortMatchModel
//
//        //3. 先对subHavAlg行为化; (坚果树会掉坚果);
//        AIAlgNodeBase *subHavAlg = [ThinkingUtils dataOut_GetAlgNodeWithInnerType:AnalogyInnerType_Hav algsType:subAlg_p.algsType dataSource:subAlg_p.dataSource];
//        [self convert2Out_Long_NET:subHavAlg success:^(AIFoNodeBase *havFo, NSArray *subHavActions) {
//
//            //4. 再对subValue行为化; (坚果会掉到树下,我们可以飞过去吃) 参考图109_subValue行为化;
//            if (!ISOK(havFo, AINetAbsFoNode.class)) return;
//            AINetAbsFoNode *subHavFo = (AINetAbsFoNode*)havFo;
//
//            //5. 从subHavFo联想其"具象序列":conSubHavFo;
//            //TODO: 目前仅支持一个,随后要支持三个左右;
//
//            // TODO191106:确定下:现在cHavFo与其抽象前的时序,是抽象关联吗?
//
//            AIFoNodeBase *conSubHavFo = [ThinkingUtils getNodeFromPort:ARR_INDEX(subHavFo.conPorts, 0)];
//            if (!ISOK(conSubHavFo, AIFoNodeBase.class)) return;
//
//            //6. 从conSubHavFo中,找到与forecastAlg_p预测概念指针;
//            AIKVPointer *forecastAlg_p = nil;
//            for (AIKVPointer *item_p in conSubHavFo.content_ps) {
//
//                //7. 判断item_p是subAlg的具象节点;
//                if ([ThinkingUtils containsConAlg:item_p absAlg:subAlg_p]) {
//                    forecastAlg_p = item_p;
//                    break;
//                }
//            }
//            if (!forecastAlg_p) return;
//
//            //8. 取出"预测"概念信息;
//            AIAlgNodeBase *forecastAlg = [SMGUtils searchNode:forecastAlg_p];
//            if (!forecastAlg) return;
//
//            //8. 进一步取出预测微信息;
//            AIKVPointer *forecastValue_p = [ThinkingUtils filterPointer:forecastAlg.content_ps identifier:subValue_p.identifier];
//            if (!forecastValue_p) return;
//
//            //9. 将诉求信息:subValue与预测信息:forecastValue进行类比;
//            NSNumber *subValue = NUMTOOK([AINetIndex getData:subValue_p]);
//            NSNumber *forecastValue = NUMTOOK([AINetIndex getData:forecastValue_p]);
//            NSComparisonResult compareResult = [subValue compare:forecastValue];
//
//            //10. 得出是要找cLess或cGreater;
//            if (compareResult == NSOrderedSame) {
//                [result addObjectsFromArray:subHavActions];//成功A;
//                return;
//            }else{
//                AnalogyInnerType type = (compareResult == NSOrderedAscending) ? AnalogyInnerType_Greater : AnalogyInnerType_Less;
//                AIAlgNodeBase *glAlg = [ThinkingUtils dataOut_GetAlgNodeWithInnerType:type algsType:subValue_p.algsType dataSource:subValue_p.dataSource];
//                [self convert2Out_Long_NET:glAlg success:^(AIFoNodeBase *havFo, NSArray *actions) {
//                    //TODO:有些预测确定,有些不那么确定;(未必就可以直接添加到行为中)
//                    [result addObjectsFromArray:subHavActions];
//                    [result addObjectsFromArray:actions];//成功B;
//                } failure:nil];
//            }
//        } failure:nil];
//    }
//    return result;
//}

//20191226正式改用v2方法; (v1说明:以LSP和同级两种匹配,同级时单value则GL,多value则HN) (v2说明:以MC类比,并得出ms&cs&mcs各进行评价与行为化)
/**
 *  MARK:--------------------MC匹配行为化--------------------
 *  @desc 伪代码:
 *  1. MC匹配时,判断是否可LSP里氏替换;
 *      2. 可替换,success
 *      3. 不可替换,changeM2C,判断条件为value_p.cLess / value_p.cGreater / alg_p.cHav / alg_p.cNone;
 *          4. alg_p则递归到convert2Out_Single_Alg();
 *          5. value_p则递归到convert2Out_Single_Value();
 *  @desc
 *      1. MC匹配,仅针对cHav做行为化;
 *      2. MC匹配,是对瞬时记忆中的matchAlg做匹配行为化;
 *      3. 当MC匹配转移change条件时,递归到single_Alg或single_Value进行行为化;
 *
 *  @desc
 *      1. xx年xx月xx日: matchAlg优先,都是通过抽具象关联来判断的,而不是直接对比其内容;
 *
 *  @todo
 *      TODO_TEST_HERE: 在alg抽象匹配时,核实下将absAlg去重,为了避免绝对匹配重复导致的联想不以cHav
 *
 *  @实例: 用几个例子,来跑此处代码,看mAlg应该如何得来?如烤蘑菇的例子,坚果去皮的例子,cpu煎蛋的例子;
 *
 */
//-(void) convert2Out_Short_MC_V1:(AIAlgNodeBase*)matchAlg curAlg:(AIAlgNodeBase*)curAlg mcSuccess:(void(^)(NSArray *acts))mcSuccess mcFailure:(void(^)())mcFailure checkScore:(BOOL(^)(AIAlgNodeBase *mAlg))checkScore{
//    if (matchAlg && curAlg) {
//        //3. MC匹配之: LSP里氏判断,M是否是C
//        BOOL cIsAbs = ISOK(curAlg, AIAbsAlgNode.class);
//        NSArray *cConPorts = cIsAbs ? ((AIAbsAlgNode*)curAlg).conPorts : nil;
//        BOOL mIsC = [SMGUtils containsSub_p:matchAlg.pointer parentPorts:cConPorts];
//        if (mIsC) {
//
//            //4. 进行反思
//            BOOL rtSuccess = checkScore(matchAlg);
//            if (rtSuccess) {
//                mcSuccess(nil);
//            }else{
//                WLog(@"行为化失败,里氏替换评价未通过");
//                mcFailure();
//            }
//        }else{
//            //5. MC匹配之: 同级判断,M和C都是absMC
//            NSArray *mAbs_ps = [SMGUtils convertPointersFromPorts:matchAlg.absPorts];
//            NSArray *cAbs_ps = [SMGUtils convertPointersFromPorts:curAlg.absPorts];
//            //6. c更重要,c的abs强度优先;
//            NSArray *absMC_ps = ARRTOOK([SMGUtils filterSame_ps:cAbs_ps parent_ps:mAbs_ps]);
//            __block BOOL successed = false;
//
//            for (AIPointer *absMC_p in absMC_ps) {
//                //7. 同级加工,changeM2C之: 取subM和subC分别多余信息;
//                AIAlgNodeBase *absMC = [SMGUtils searchNode:absMC_p];
//                if (absMC) {
//                    NSArray *subM = [SMGUtils removeSub_ps:matchAlg.content_ps parent_ps:absMC.content_ps];
//                    NSArray *subC = [SMGUtils removeSub_ps:curAlg.content_ps parent_ps:absMC.content_ps];
//
//                    //8. 加工changeM2C (目前仅支持一个特征不同);
//                    AIKVPointer *change_p = nil;
//                    AnalogyInnerType changeType = AnalogyInnerType_Default;
//                    if (subM.count > 0 && subC.count == 0) {
//                        if (subM.count == 1) {
//                            //9. 多余单value_p
//                            change_p = ARR_INDEX(subM, 0);
//                            changeType = AnalogyInnerType_Less;
//                        }else{
//                            //10 多余单alg_p
//                            AIAlgNodeBase *alg = [AINetIndexUtils getAbsoluteMatchingAlgNodeWithValuePs:subM];
//                            if (alg) change_p = alg.pointer;
//                            changeType = AnalogyInnerType_None;
//                        }
//                    }else if (subC.count > 0 && subM.count == 0) {
//                        if (subC.count == 1) {
//                            //11. 缺少单value_p
//                            change_p = ARR_INDEX(subC, 0);
//                            changeType = AnalogyInnerType_Greater;
//                        }else{
//                            //12. 缺少单alg_p
//                            AIAlgNodeBase *alg = [AINetIndexUtils getAbsoluteMatchingAlgNodeWithValuePs:subC];
//                            if (alg) change_p = alg.pointer;
//                            changeType = AnalogyInnerType_Hav;
//                        }
//                    }
//
//                    //13. 针对change_p进行行为化;
//                    if (change_p) {
//                        if (changeType == AnalogyInnerType_Greater || changeType == AnalogyInnerType_Less) {
//
//                            //TODO191213: 去转化,将parentCheckScore传递过去,供_fos使用;
//                            [self convert2Out_RelativeValue:change_p type:changeType vSuccess:^(AIFoNodeBase *glFo, NSArray *acts) {
//                                mcSuccess(acts);
//                                successed = true;
//                            } vFailure:^{
//                                WLog(@"value_行为化失败");
//                            }];
//                        }else if (changeType == AnalogyInnerType_Hav || changeType == AnalogyInnerType_None){
//                            //Q: 为何此处curAlg_ps传nil?
//                            //A: 因为change_p不是curAlg,比如curAlg_ps是[吃,烤蘑菇],那么change_p可能是火,如果重组LSPFo可能会组成[吃,火] (解决方案参考:17208表);
//                            [self convert2Out_Alg:change_p type:changeType success:^(NSArray *acts) {
//                                mcSuccess(acts);
//                                successed = true;
//                            } failure:nil checkScore:checkScore];
//                        }
//                    }
//                }
//
//                //14. 成功时,跳出循环;
//                if (successed) {
//                    return;
//                }
//            }
//        }
//    }
//    mcFailure();
//}
