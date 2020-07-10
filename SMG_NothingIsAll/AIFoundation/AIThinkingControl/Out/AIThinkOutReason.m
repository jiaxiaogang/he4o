//
//  AIThinkOutReason.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkOutReason.h"
#import "AIAlgNodeBase.h"
#import "AICMVNodeBase.h"
#import "AINetIndex.h"
#import "AIKVPointer.h"
#import "ThinkingUtils.h"
#import "TOFoModel.h"
#import "Output.h"
#import "AIShortMatchModel.h"
#import "TOUtils.h"
#import "AINetUtils.h"
#import "AIThinkOutAction.h"
#import "TOAlgModel.h"
#import "TOValueModel.h"
#import "DemandModel.h"

@interface AIThinkOutReason() <TOActionDelegate>

@property (strong, nonatomic) AIThinkOutAction *toAction;

@end

@implementation AIThinkOutReason

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}
-(void) initData{
    self.toAction = [[AIThinkOutAction alloc] init];
    self.toAction.delegate = self;
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

//MARK:===============================================================
//MARK:                     < 决策行为化 >
//MARK: 1. 以algScheme开始,优先使用简单的方式,后向fo,mv;
//MARK: 2. 因为TOP已经做了很多工作,此处与TOP协作 (与从左至右的理性向性是相符的);
//MARK:===============================================================

/**
 *  MARK:--------------------FromTOP主入口--------------------
 *  @version
 *      20200416 - actions行为输出前,先清空; (如不清空,下轮外循环TIR->TOP.dataOut()时,导致不重新决策,直接输出上轮actions,行为再被TIR预测,又一轮,形成外层死循环 (参考n19p5-B组BUG2);
 */


/**
 *  MARK:--------------------R+行为化--------------------
 *  @desc R+行为化,两级判断,参考:19164;
 *          1. isOut则输出;
 *          2. notOut则等待;
 *  @bug
 *      2020.06.15: 训练B2步,R-失败时,转至R+后,此处outModel.actionIndex=2,而fo.content_ps一共才2个元素,所以行为化无效 (因为倒二帧是饿输出`吃`,本来吃已经是最后一个元素,所以越界);
 *  @version
 *      2020.07.01: 对当前输入帧进行PM理性评价 (稀疏码检查,参考20063);
 */
-(void) commitReasonPlus:(TOFoModel*)outModel mModel:(AIShortMatchModel*)mModel{
    //1. 取出当前帧任务,如果无效,则直接跳下帧;
    AIFoNodeBase *fo = [SMGUtils searchNode:outModel.content_p];
    AIKVPointer *curAlg_p = ARR_INDEX(fo.content_ps, outModel.actionIndex);
    
    //2. 构建理性评价模型;
    TOAlgModel *mTOAlgModel = [TOAlgModel newWithAlg_p:curAlg_p group:outModel];
    
    //3. 将"P-M取得独特稀疏码"保留到短时记忆模型;
    [mTOAlgModel.justPValues addObjectsFromArray:[SMGUtils removeSub_ps:mModel.matchAlg.content_ps parent_ps:mModel.protoAlg.content_ps]];
    
    //4. 将理性评价"价值分"保留到短时记忆模型;
    mTOAlgModel.pm_Score = [ThinkingUtils getScoreForce:mModel.matchFo.cmvNode_p ratio:mModel.matchFoValue];
    mTOAlgModel.pm_MVAT = mModel.matchFo.cmvNode_p.algsType;
    mTOAlgModel.pm_Fo = [SMGUtils searchNode:mTOAlgModel.baseOrGroup.content_p];
    
    //5. 理性评价
    BOOL jump = [self reasonScorePM:mTOAlgModel];
    
    //6. 未跳转到PM,则将algModel设为Finish,并递归;
    if (!jump) {
        mTOAlgModel.status = TOModelStatus_Finish;
        [self singleLoopBackWithFinishModel:mTOAlgModel];
    }
}

/**
 *  MARK:--------------------R-行为化--------------------
 *  @desc R-行为化,三级判断,参考19165;
 *          1. is(SP)判断 (转移sp行为化);
 *          2. isOut判断 (输出);
 *          3. notOut判断 (等待);
 *  @存储 负只是正的帧推进器,比如买菜为了做饭 (参考19171);
 *  @bug
 *      2020.06.14 : 此处sHappend为false,按道理说,投右,已经有了s,s应该是已发生的 (经查,改为sIndex <= outModel.actionIndex即可) T;
 */
-(void) commitReasonSub:(AIFoNodeBase*)matchFo plusFo:(AIFoNodeBase*)plusFo subFo:(AIFoNodeBase*)subFo outModel:(TOFoModel*)outModel {
    //1. 数据准备
    AIKVPointer *firstPlusItem = ARR_INDEX(plusFo.content_ps, 0);
    AIFoNodeBase *fo = [SMGUtils searchNode:outModel.content_p];
    AIKVPointer *checkAlg_p = ARR_INDEX(fo.content_ps, outModel.actionIndex);
    if (!matchFo || !plusFo || !subFo || !checkAlg_p) {
        outModel.status = TOModelStatus_ActNo;
        return;
    }
    
    //2. 正影响首元素,错过判断 (错过,行为化失败);
    NSInteger firstAt_Plus = [TOUtils indexOfAbsItem:firstPlusItem atConContent:fo.content_ps];
    if (outModel.actionIndex > firstAt_Plus) {
        outModel.status = TOModelStatus_ActNo;
        return;
    }
    
    //3. 当firstPlus就是checkAlg_p时 (尝试对checkAlg行为化);
    if (firstAt_Plus == outModel.actionIndex) {
        
        //4. 从SFo中,找出checkAlg的兄弟节点matchAlg;
        AIKVPointer *matchAlg_p = [SMGUtils filterSingleFromArr:matchFo.content_ps checkValid:^BOOL(AIKVPointer *item_p) {
            return [TOUtils mcSameLayer:item_p c:checkAlg_p];
        }];
        
        //5. 根据matchAlg找到对应的S;
        AIKVPointer *sAlg_p = [SMGUtils filterSingleFromArr:subFo.content_ps checkValid:^BOOL(AIKVPointer *item) {
            return [TOUtils mIsC_1:matchAlg_p c:item];
        }];
        
        //6. 行为化 (围绕P做行为);
        TOAlgModel *algOutModel = [TOAlgModel newWithAlg_p:checkAlg_p group:outModel];
        
        //7. 找出可替代checkAlg的replaceAlgs,保留到algOutModel.replaceAlgs;
        [algOutModel.replaceAlgs addObject:checkAlg_p];
        //随后此处支持,在SP的指引下,找出checkAlg同层的其它可替代节点,加入replaceAlgs;
        
        //8. 在S有效时,尝试_SP;
        AIKVPointer *pAlg_p = firstPlusItem;
        BOOL tryAct = false;
        if (sAlg_p) {
            NSInteger sIndex = [TOUtils indexOfAbsItem:sAlg_p atConContent:matchFo.content_ps];
            BOOL sHappened = sIndex <= outModel.actionIndex;
            if (sHappened) {
                //9. S存在,且S已发生,则加工SP;
                [self.toAction convert2Out_SP:sAlg_p pAlg_p:pAlg_p outModel:algOutModel];
                tryAct = true;
            }
        }
        
        //10. 如果SP未执行,则直接调用replaceAlg;
        if (!tryAct) {
            for (AIKVPointer *replace_p in algOutModel.replaceAlgs) {
                TOAlgModel *replaceAlg = [TOAlgModel newWithAlg_p:replace_p group:algOutModel];
                [self.toAction convert2Out_Hav:replaceAlg];
                return;
            }
        }
    }
}

/**
 *  MARK:--------------------P+行为化--------------------
 *  @desc P+行为化,两级判断,参考:19166;
 *          1. isOut则输出;
 *          2. notOut则进行cHav行为化;
 *  @version
 *      2020-05-27 : 将isOut=false时等待改成进行cHav行为化;
 */
-(void) commitPerceptPlus:(TOFoModel*)outModel{
    //1. 数据检查
    AIFoNodeBase *fo = [SMGUtils searchNode:outModel.content_p];
    if (!fo) {
        outModel.status = TOModelStatus_ActNo;
        [self singleLoopBackWithFailureModel:outModel];
        return;
    }
    
    //2. 行为化;
    AIKVPointer *curAlg_p = ARR_INDEX(fo.content_ps, outModel.actionIndex);//从0开始
    
    //3. cHav行为化
    TOAlgModel *algOutModel = [TOAlgModel newWithAlg_p:curAlg_p group:outModel];
    [self.toAction convert2Out_P:algOutModel];
}

/**
 *  MARK:--------------------P-行为化--------------------
 *  @desc P-行为化,三级判断,参考19167;
 *          1. is(SP)判断 (转移sp行为化);
 *          2. isOut判断 (输出);
 *          3. notOut判断 (等待);
 *  @废弃: 因为左负是不存在的(或者说目前不需要的),可以以左正,转为右正,来实现,累了歇歇的例子;
 */
-(void) commitPerceptSub:(AIFoNodeBase*)matchFo plusFo:(AIFoNodeBase*)plusFo subFo:(AIFoNodeBase*)subFo checkFo:(AIFoNodeBase*)checkFo complete:(void(^)(BOOL actSuccess,NSArray *acts))complete{
    ////1. 数据准备
    //AIKVPointer *firstSubItem = ARR_INDEX(subFo.content_ps, 0);
    //AIKVPointer *firstPlusItem = ARR_INDEX(plusFo.content_ps, 0);
    //AIKVPointer *curAlg_p = ARR_INDEX(checkFo.content_ps, 0);//当前plusFo的具象首元素;
    //if (!matchFo || !plusFo || !subFo || !checkFo || !complete || !curAlg_p) {
    //    complete(false,nil);
    //    return;
    //}
    //
    ////1. 负影响首元素,错过判断 (错过,行为化失败);
    //NSInteger firstAt_Sub = [TOUtils indexOfAbsItem:firstSubItem atConContent:matchFo.content_ps];
    //
    ////2. 正影响首元素,错过判断 (错过,行为化失败);
    //NSInteger firstAt_Plus = [TOUtils indexOfAbsItem:firstPlusItem atConContent:checkFo.content_ps];
    //
    ////3. 三级行为化判断;
    //if (firstAt_Sub == 0 && firstAt_Plus == 0) {
    //    //a. 把S加工成P;
    //}else if(firstAt_Sub == 0){
    //    //b. 把S加工修正;
    //}else if(firstAt_Plus == 0){
    //    //c. 把P加工满足;
    //}else if(curAlg_p.isOut){
    //    //d. isOut输出;
    //    complete(true,@[curAlg_p]);
    //}else{
    //    //e. notOut等待;
    //    complete(true,nil);
    //}
}

//MARK:===============================================================
//MARK:                     < FromTOP_反射反应 >
//MARK:===============================================================
-(void) commitFromTOP_ReflexOut{
    [self dataOut_ActionScheme:nil];
}

-(void) dataOut_ActionScheme:(NSArray*)outArr{
    //1. 尝试输出找到解决问题的实际操作 (取到当前cacheModel中的最佳决策,并进行输出;)
    BOOL tryOutSuccess = false;
    if (ARRISOK(outArr)) {
        for (AIKVPointer *algNode_p in outArr) {
            //>1 检查micro_p是否是"输出";
            //>2 假如order_p足够确切,尝试检查并输出;
            BOOL invoked = [Output output_FromTC:algNode_p];
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
        
        //1. 心急情绪释放,平复思维;
        [self.delegate aiThinkOutReason_UpdateEnergy:-1];
        
        //2. 反射输出
        [Output output_FromMood:AIMoodType_Anxious];
    }
}

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 决策--------------------
 *  @desc
 *      1. 最新一帧,与上轮循环做匹配 (对单帧匹配到任务Finish的,要推动决策跳转下帧);
 *      2. 未输出行为,等待中的,也要进行下轮匹配,比如等开饭,等来开饭了; (等待的status是ActNo还是Runing?)
 *  @todo
 *      1. 此处在for循环中,所以有可能推进多条,比如我有了一只狗,可以拉雪撬,或者送给爷爷陪爷爷 (涉及多任务间的价值自由竞争),暂仅支持一条,后再支持;
 *  @result 返回pushMiddle是否成功,如果推进成功,则不再执行TOP四模式;
 */
-(BOOL) commitFromOuterPushMiddleLoop:(DemandModel*)demand latestMModel:(AIShortMatchModel*)latestMModel{
    //1. 数据检查
    if (!latestMModel) {
        return false;
    }
    
    //2. 取出所有等待下轮的outModel (ActYes&Runing);
    NSArray *waitModels = [TOUtils getSubOutModels_AllDeep:demand validStatus:@[@(TOModelStatus_ActYes),@(TOModelStatus_Runing)]];
    
    //3. 判断最近一次input是否与等待中outModel相匹配 (匹配,比如吃,确定自己是否真吃了);
    for (TOAlgModel *waitModel in waitModels) {
        if (ISOK(waitModel, TOAlgModel.class) && ISOK(waitModel.baseOrGroup, TOFoModel.class) && [TOUtils mIsC_1:latestMModel.matchAlg.pointer c:waitModel.content_p]) {
            
            //4. 将"P-M取得独特稀疏码"保留到短时记忆模型;
            [waitModel.justPValues addObjectsFromArray:[SMGUtils removeSub_ps:latestMModel.matchAlg.content_ps parent_ps:latestMModel.protoAlg.content_ps]];
            
            //5. 将理性评价"价值分"保留到短时记忆模型;
            waitModel.pm_Score = [ThinkingUtils getScoreForce:demand.algsType urgentTo:demand.urgentTo delta:demand.delta ratio:1.0f];
            waitModel.pm_MVAT = demand.algsType;
            waitModel.pm_Fo = [SMGUtils searchNode:waitModel.baseOrGroup.content_p];
            
            //6. 理性评价
            BOOL jump = [self reasonScorePM:waitModel];
            
            //7. 未跳转到PM,则将algModel设为Finish,并递归;
            if (!jump) {
                waitModel.status = TOModelStatus_Finish;
                [self singleLoopBackWithFinishModel:waitModel];
            }
            return true;
        }
    }
    return false;
}

/**
 *  MARK:--------------------理性评价--------------------
 *  @desc
 *      1. 对当前输入帧进行PM理性评价 (稀疏码检查,参考20063);
 *      2. 白话: 当具象要替代抽象时,对其多态性进行检查加工;
 *  @param outModel : 因本文是验证其多态性,所以传入的outModel.cotent即M必须是P的抽象;
 *  @version
 *      2020.07.02: 将outModel的pm相关字段放到方法调用前就处理好 (为了流程控制调用时,已经有完善可用的数据了);
 *  @result moveValueSuccess : 转移到稀疏码行为化了;
 *  @bug
 *      2020.07.05: BUG,在用MatchConF.content找交集同区稀疏码肯定找不到,改为用MatchConA后,ok了;
 *      2020.07.06: 此处M.conPorts,即sameLevelAlg_ps为空,明天查下原因 (因为MC以C做M,C有可能本来就是最具象概念);
 */
-(BOOL) reasonScorePM:(TOAlgModel*)outModel{
    //1. 数据准备
    if (!outModel || !outModel.pm_Fo) return false;
    AIAlgNodeBase *M = [SMGUtils searchNode:outModel.content_p];
    AIFoNodeBase *mMaskFo = outModel.pm_Fo;
    if (!M) return false;
    NSLog(@"\n\n=============================== PM ===============================\nM:%@\nMAtFo:%@",Alg2FStr(M),Fo2FStr(mMaskFo));
    
    //3. 将理性评价数据存到短时记忆模型;
    NSArray *except_ps = [TOUtils convertPointersFromTOModels:outModel.subModels];
    NSArray *validJustPValues = [SMGUtils removeSub_ps:except_ps parent_ps:outModel.justPValues];
    if (Log4PM) NSLog(@"---> P独特码:%@",Pits2FStr(outModel.justPValues));
    if (Log4PM) NSLog(@"---> 不应期:%@",Pits2FStr(except_ps));
    if (Log4PM) NSLog(@"---> P有效独特码:%@",Pits2FStr(validJustPValues));
        
    //4. 不用PM评价 (则交由流程控制方法,推动继续决策(跳转下帧/别的);
    if (!ARRISOK(validJustPValues)) return false;
    
    //5. 取到首个P独特稀疏码 (判断是否需要行为化);
    AIKVPointer *firstJustPValue = ARR_INDEX(validJustPValues, 0);
    NSArray *sameLevelAlg_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:M]];
    BOOL firstPNeedGL = true;
    if (firstJustPValue) {
        //a. 取出首个独特稀疏码,从同层概念中,获取模糊序列 (根据pValue_p对sameLevel_ps排序);
        NSArray *sortAlgs = [ThinkingUtils getFuzzySortWithMaskValue:firstJustPValue fromProto_ps:sameLevelAlg_ps];
        
        //b. 取模糊最匹配的概念,并取出3条refPorts的时序;
        AIAlgNodeBase *fuzzyAlg = [SMGUtils searchNode:ARR_INDEX(sortAlgs, 0)];
        if (Log4PM && fuzzyAlg) NSLog(@"-> 当前操作:%@ => %@",Pit2FStr(firstJustPValue),Alg2FStr(fuzzyAlg));
        if (fuzzyAlg) {
            NSArray *fuzzyRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Alg:fuzzyAlg]];
            fuzzyRef_ps = ARR_SUB(fuzzyRef_ps, 0, cPM_RefLimit);
            
            //c. 依次判断refPorts时序的价值,是否与matchFo相符 (只需要有一条相符就行);
            for (AIKVPointer *fuzzyRef_p in fuzzyRef_ps) {
                AIFoNodeBase *fuzzyRef = [SMGUtils searchNode:fuzzyRef_p];
                
                //d. 同区且同向,则相符;
                BOOL sameIdent = [outModel.pm_MVAT isEqualToString:fuzzyRef.cmvNode_p.algsType];
                CGFloat fuzzyRefScore = [ThinkingUtils getScoreForce:fuzzyRef.cmvNode_p ratio:1.0f];
                if (fuzzyRef && sameIdent && [ThinkingUtils sameOfScore1:fuzzyRefScore score2:outModel.pm_Score]) {
                    firstPNeedGL = false;
                    break;
                }
            }
        }
    }else{
        firstPNeedGL = false;
    }
    
    if (!firstPNeedGL) {
        //6. 不需要处理时,直接Finish,转至决策流程控制方法 (注:在TOValueModel构造方法中: proto中的value,就是subValue);
        if (Log4PM) NSLog(@"-> 无需PM,转至流程控制Finish");
        TOValueModel *toValueModel = [TOValueModel newWithSValue:firstJustPValue pValue:nil group:outModel];
        toValueModel.status = TOModelStatus_Finish;
        [self singleLoopBackWithFinishModel:toValueModel];
        return true;
    }
    
    //7. 转至_GL行为化->从matchFo.conPorts中找稳定的价值指向;
    NSMutableArray *matchConF_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:mMaskFo]];
    [matchConF_ps addObject:mMaskFo.pointer];//(像MC传过来的,mMaskFo为C所在的时序,有可能本身就是最具象节点,或包含了距0的果);
    
    //8. 依次判断conPorts是否包含"同区稀疏码" (只需要找到一条相符即可);
    for (AIKVPointer *matchConF_p in matchConF_ps) {
        //9. 找到含同区稀疏码的con时序;
        AIFoNodeBase *matchConF = [SMGUtils searchNode:matchConF_p];
        
        //9. 找到含同区稀疏码的con概念;
        AIKVPointer *matchConA_p = ARR_INDEX([SMGUtils filterSame_ps:sameLevelAlg_ps parent_ps:matchConF.content_ps], 0);
        AIAlgNodeBase *matchConA = [SMGUtils searchNode:matchConA_p];
        if (!matchConA) continue;
        
        //9. 找到同区稀疏码的glValue;
        AIKVPointer *glValue4M = [SMGUtils filterSameIdentifier_p:firstJustPValue b_ps:matchConA.content_ps];
        
        //10. 价值稳定,则转_GL行为化 (找到一条即可,因为此处只管转移,后面的逻辑由流程控制方法负责);
        BOOL sameIdent = [outModel.pm_MVAT isEqualToString:matchConF.cmvNode_p.algsType];
        CGFloat matchConScore = [ThinkingUtils getScoreForce:matchConF.cmvNode_p ratio:1.0f];
        if (glValue4M && sameIdent && [ThinkingUtils sameOfScore1:matchConScore score2:outModel.pm_Score]) {
            if (Log4PM) NSLog(@"-> 操作 Success:(%@->%@)",Pit2FStr(firstJustPValue),Pit2FStr(glValue4M));
            TOValueModel *toValueModel = [TOValueModel newWithSValue:firstJustPValue pValue:glValue4M group:outModel];
            outModel.sp_P = M;
            [self singleLoopBackWithBegin:toValueModel];
            return true;
        }
    }
    
    //11. 未找到GL的目标 (如距离0),直接计为失败;
    if (Log4PM) NSLog(@"-> 未找到GL目标,转至流程控制Failure");
    TOValueModel *toValueModel = [TOValueModel newWithSValue:firstJustPValue pValue:nil group:outModel];
    toValueModel.status = TOModelStatus_ActNo;
    [self singleLoopBackWithFailureModel:toValueModel];
    return true;
}

//MARK:===============================================================
//MARK:                   < 理性决策流程控制方法 >
//MARK: 1. 一切流程控制的转移,失败递归,成功推进,都由流程控制方法完成;
//MARK: 2. 流程控制方法,由TOAction中体方法中给status赋值的同时调用;
//MARK:===============================================================

/**
 *  MARK:--------------------新发生outModel完成,推进递归--------------------
 *  @desc
 *      1. 本方法,以递归方式运行 (反馈给上一级,跳到下帧);
 *      2. 最终输出为:
 *          a. 时序下帧概念
 *          b. 概念下帧稀疏码
 *          c. Demand最终完成
 *      3. 输入参数可能为Alg,Value,Demand,参考19203;
 *      4. 参数说明:
 *          a. 由别的方法调用时,参数为:TOAlgModel或TOValueModel;
 *          b. 由递归自行调用时,参数为:TOAlgModel或TOValueModel或DemandModel;
 *  @callers :
 *      1. 由外循环调用,当外循环输入新的matchAlg时,调用此方法推进继续决策;
 *      2. 由toAction调用,当无需行为的行为化,直接成功时,调用推进继续决策;
 *  @version
 *      2020.06.21: 当本轮决策完成(FinishModel为Demand)时,清空demand.actionFoModels,以便整体任务未完成时,继续决策 (比如不断飞近);
 *      2020.07.06: 当本轮决策完成(FinishModel为TOFoModel)时,解决方案Fo的父级也完成;
 */
-(void) singleLoopBackWithFinishModel:(TOModelBase*)finishModel {
    if (ISOK(finishModel, TOAlgModel.class)) {
        //1. Alg
        TOModelBase *base = finishModel.baseOrGroup;
        
        //2. 如果base取到fo,则下帧继续;
        if (ISOK(base, TOFoModel.class)) {
            TOFoModel *toFoModel = (TOFoModel*)base;
            
            //2. 完成,则直接返回finish (如本来就是最后一帧,则再递归至上一层);
            AIFoNodeBase *fo = [SMGUtils searchNode:toFoModel.content_p];
            if (toFoModel.actionIndex < fo.content_ps.count - 1) {
                //a. Alg转移 (下帧)
                toFoModel.actionIndex ++;
                AIKVPointer *move_p = ARR_INDEX(fo.content_ps, toFoModel.actionIndex);
                TOAlgModel *moveAlg = [TOAlgModel newWithAlg_p:move_p group:toFoModel];
                [self singleLoopBackWithBegin:moveAlg];
            }else{
                //c. 成功,递归
                toFoModel.status = TOModelStatus_Finish;
                [self singleLoopBackWithFinishModel:toFoModel.baseOrGroup];
            }
        }else if(ISOK(base, TOAlgModel.class)){
            //3. 如果base取到alg,则直接finish;
            base.status = TOModelStatus_Finish;
            [self singleLoopBackWithFinishModel:base];
        }
    }else if(ISOK(finishModel, TOValueModel.class)){
        //3. Value (如果取到alg,则应将当前已完成的value标记到algOutModel.alreadyFinishs,并提给TOAction._P/_SP继续完成去);
        TOAlgModel *toAlgModel = (TOAlgModel*)finishModel.baseOrGroup;
        
        //4. Value转移 (未行为化过的sp进行转移);
        BOOL jump = false;
        for (NSData *key in toAlgModel.cGLDic.allKeys) {
            AIKVPointer *sValue_p = DATA2OBJ(key);
            AIKVPointer *pValue_p = [toAlgModel.cGLDic objectForKey:key];
            
            //a. 转移 (找出未行为化过的)
            NSArray *alreadayAct_ps = [TOUtils convertPointersFromTOModels:toAlgModel.subModels];
            if (![alreadayAct_ps containsObject:pValue_p]) {
                TOValueModel *toValueModel = [TOValueModel newWithSValue:sValue_p pValue:pValue_p group:toAlgModel];
                jump = true;
                [self singleLoopBackWithBegin:toValueModel];
                break;
            }
        }
        
        //5. Value转移 (未行为化过的理性评价进行转移);
        if (!jump) {
            jump = [self reasonScorePM:toAlgModel];
        }
        
        //c. 未跳转到GLDic或PM,则将algModel设为Finish,并递归;
        if (!jump) {
            toAlgModel.status = TOModelStatus_Finish;
            [self singleLoopBackWithFinishModel:toAlgModel];
        }
    }else if(ISOK(finishModel, TOFoModel.class)){
        //a. Fo完成时,其父级也完成;
        finishModel.baseOrGroup.status = TOModelStatus_Finish;
        [self singleLoopBackWithFinishModel:finishModel.baseOrGroup];
    }else if(ISOK(finishModel, DemandModel.class)){
        //5. 全部完成;
        NSLog(@"SUCCESS > 本轮决策完成");
        DemandModel *demand = (DemandModel*)finishModel;
        [demand.actionFoModels removeAllObjects];
    }else{
        ELog(@"如打出此错误,则查下为何groupModel不是TOFoModel类型,因为一般行为化的都是概念,而概念的父级就是TOFoModel:%@",finishModel.class);
    }
}

/**
 *  MARK:--------------------新发生模型失败,推进递归--------------------
 *  @callers : 由行为化推动 (行为化失败时,直接推动此方法,向右上,找下一解决方案);
 *  @desc
 *      1. 参数说明:
 *          a. 由别的方法调用时,参数为:TOAlgModel或TOValueModel;
 *          b. 由递归自行调用时,参数为:TOAlgModel或TOValueModel或DemandModel;
 *      2. 参数的上级,必然是actYes或runing,对其进行再决策 (不是actYes或runing也不会有子model的failure了);
 *      3. 转移:
 *          a. avd为Alg时,转移方法为:TOAction._Hav;
 *          b. avd为Value时,转移方法为:TOAction._GL;
 *          c. avd为Demand时,转移方法为:TOP.P+;
 *  @version
 *      2020.07.06: 当failureModel为TOFoModel时,直接尝试下一方案;
 */
-(void) singleLoopBackWithFailureModel:(TOModelBase*)failureModel {
    //1. 尝试向alg.replace转移Block;
    BOOL(^ Move2ReplaceAlgBlock)(TOAlgModel *)= ^BOOL(TOAlgModel *targetAlg){
        for (AIKVPointer *replace_p in targetAlg.replaceAlgs) {
            NSArray *alreadayAct_ps = [TOUtils convertPointersFromTOModels:targetAlg.subModels];
            if (![alreadayAct_ps containsObject:replace_p]) {
                TOAlgModel *moveAlg = [TOAlgModel newWithAlg_p:replace_p group:targetAlg];
                [self singleLoopBackWithBegin:moveAlg];
                if (moveAlg.status != TOModelStatus_ActNo && moveAlg.status != TOModelStatus_ScoreNo) {
                    return true;
                }
            }
        }
        return false;
    };
    
    //2. 主方法部分;
    if (ISOK(failureModel, TOAlgModel.class)) {
        if (ISOK(failureModel.baseOrGroup, TOFoModel.class)) {
            //a. Alg.base为fo时,baseFo失败
            TOFoModel *toFoModel = (TOFoModel*)failureModel.baseOrGroup;
            toFoModel.status = TOModelStatus_ActNo;
            
            //b. 用fo向上找A/V/D进行fos再决策 (先尝试转移,后不行就递归);
            [self singleLoopBackWithBegin:toFoModel.baseOrGroup];
        }else if(ISOK(failureModel.baseOrGroup, TOAlgModel.class)){
            //c. Alg.base为alg时,baseAlg转移;
            TOAlgModel *baseAlgModel = (TOAlgModel*)failureModel.baseOrGroup;
            
            //d. 转移replaceAlg (除掉已不应期的);
            BOOL moveSuccess = Move2ReplaceAlgBlock(baseAlgModel);
            
            //e. 转移失败,完全失败;
            if (!moveSuccess) {
                baseAlgModel.status = TOModelStatus_ActNo;
                [self singleLoopBackWithFailureModel:baseAlgModel];
            }
        }
    }else if(ISOK(failureModel, TOValueModel.class)){
        //a. Value失败时时,判断其右alg的replaceAlgs转移
        TOAlgModel *baseAlg = (TOAlgModel*)failureModel.baseOrGroup;
        
        //b. 转移replaceAlg (除掉已不应期的);
        BOOL moveSuccess = Move2ReplaceAlgBlock(baseAlg);
        
        //c. 转移replace失败时,baseAlg和baseAlg.baseFo都失败
        if (!moveSuccess) {
            baseAlg.status = TOModelStatus_ActNo;
            [self singleLoopBackWithFailureModel:baseAlg.baseOrGroup];
        }
    }else if(ISOK(failureModel, TOFoModel.class)){
        //a. 解决方案失败,则跳转找出下一方案;
        failureModel.status = TOModelStatus_ActNo;
        [self singleLoopBackWithBegin:failureModel.baseOrGroup];
    }else if(ISOK(failureModel, DemandModel.class)){
        //a. 再决策未成功 (全失败了) ===> 全部失败;
        NSLog(@"Demand所有方案全部失败");
    }else{
        ELog(@"如打出此错误,则查下为何groupModel不是TOFoModel类型,因为一般行为化的都是概念,而概念的父级就是TOFoModel");
    }
}

/**
 *  MARK:--------------------决策流程控制_Begin--------------------
 *  @version
 *      2020.07.06: 当begin为Fo时,直接向上递归;
 */
-(void) singleLoopBackWithBegin:(TOModelBase*)beginModel {
    //a. 转移
    if (ISOK(beginModel, TOAlgModel.class)) {
        //a1. avdIsAlg: 再决策,转移至TOAction;
        [self.toAction convert2Out_Hav:(TOAlgModel*)beginModel];
    }else if(ISOK(beginModel, TOValueModel.class)){
        //a2. avdIsValue: 再决策,转移至TOAction;
        TOAlgModel *baseAlg = (TOAlgModel*)beginModel.baseOrGroup;
        [self.toAction convert2Out_GL:baseAlg.sp_P outModel:(TOValueModel*)beginModel];
    }else if(ISOK(beginModel, DemandModel.class)){
        //a3. avdIsDemand: 再决策,转移至TOP.P+;
        [self.delegate aiTOR_MoveForDemand:(DemandModel*)beginModel];
    }else if(ISOK(beginModel, TOFoModel.class)){
        ELog(@"如打出此错误,则查下为何beginModel是TOFoModel类型,因为一般Fo都直接取index去行为化了,而Fo是不应该传递到Begin方法中来的;");
        [self singleLoopBackWithBegin:beginModel.baseOrGroup];
    }
}

//MARK:===============================================================
//MARK:                     < TOActionDelegate >
//MARK:===============================================================
-(void)toAction_updateEnergy:(CGFloat)delta{
    [self.delegate aiThinkOutReason_UpdateEnergy:delta];
}
-(BOOL)toAction_EnergyValid{
    return [self.delegate aiThinkOutReason_EnergyValid];
}
-(void)toAction_Output:(NSArray *)actions{
    actions = ARRTOOK(actions);
    for (AIKVPointer *algNode_p in actions) {
        BOOL invoked = [Output output_FromTC:algNode_p];
    }
}
-(AIShortMatchModel*) toAction_RethinkInnerFo:(AIFoNodeBase*)fo{
    return [self.delegate aiTOR_RethinkInnerFo:fo];
}
-(void) toAction_SubModelFinish:(TOModelBase*)outModel{
    [self singleLoopBackWithFinishModel:outModel];
}
-(void) toAction_SubModelFailure:(TOModelBase*)outModel{
    [self singleLoopBackWithFailureModel:outModel];
}
-(BOOL) toAction_ReasonScorePM:(TOAlgModel*)outModel{
    return [self reasonScorePM:outModel];
}

@end
