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
#import "AITime.h"
#import "AIAbsAlgNode.h"
#import "AINetAbsFoNode.h"
#import "AIAnalogy.h"
#import "DemandManager.h"
#import "AIScore.h"
#import "ReasonDemandModel.h"

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
 *  @status 2021.01.21: 废弃,R+不构成需求;
 */
-(void) commitReasonPlus:(TOFoModel*)outModel mModel:(AIShortMatchModel*)mModel{
    ////1. 取出当前帧任务,如果无效,则直接跳下帧;
    //AIFoNodeBase *fo = [SMGUtils searchNode:outModel.content_p];
    //AIKVPointer *curAlg_p = ARR_INDEX(fo.content_ps, outModel.actionIndex);
    //
    ////2. 构建理性评价模型;
    //TOAlgModel *mTOAlgModel = [TOAlgModel newWithAlg_p:curAlg_p group:outModel];
    //
    ////3. 将"P-M取得独特稀疏码"保留到短时记忆模型;
    //[mTOAlgModel.justPValues addObjectsFromArray:[SMGUtils removeSub_ps:mModel.matchAlg.content_ps parent_ps:mModel.protoAlg.content_ps]];
    //
    ////4. 将理性评价"价值分"保留到短时记忆模型;
    //mTOAlgModel.pm_Score = [AIScore score4MV:mModel.matchFo.cmvNode_p ratio:mModel.matchFoValue];
    //mTOAlgModel.pm_MVAT = mModel.matchFo.cmvNode_p.algsType;
    //mTOAlgModel.pm_Fo = [SMGUtils searchNode:mTOAlgModel.baseOrGroup.content_p];
    //
    ////5. 理性评价
    //[self reasonScorePM_V3:mTOAlgModel failure:nil success:nil notNeedPM:^{
    //    //6. 未跳转到PM,则将algModel设为Finish,并递归;
    //    mTOAlgModel.status = TOModelStatus_Finish;
    //    [self singleLoopBackWithFinishModel:mTOAlgModel];
    //}];
}

/**
 *  MARK:--------------------R-行为化--------------------
 *  @desc R-行为化 (满足S) ,三级判断,参考19165;
 *          1. is(SP)判断 (转移sp行为化);
 *          2. isOut判断 (输出);
 *          3. notOut判断 (等待);
 *  @存储 负只是正的帧推进器,比如买菜为了做饭 (参考19171);
 *  @param sFoModel : 当前方案,阻止者,是一个S类型Fo,用来阻止demand.matchFo发生;
 *  @version
 *      2020.05.22: fromAction.SP调用cHav,在原先solo与group的基础上,新增了最优先的checkAlg (因为solo和group可能压根不存在此概念,而TO是主应用,而非构建的);
 *      2020.06.03: fromAction.SP支持将cGLDic缓存至TOAlgModel,以便一条GL子任务完成时,顺利转移至下一GL子任务;
 *      2021.01.21: 大迭代 (参考22061);
 *  @bug
 *      2020.06.14: 此处sHappend为false,按道理说,投右,已经有了s,s应该是已发生的 (经查,改为sIndex<=outModel.actionIndex即可) T;
 *  @todo
 *      1. fromAction.SP收集_GL向抽象和具象延伸,而尽量避免到_Hav,尤其要避免重组,无论是group还是solo (参考n19p18-todo4);
 *      2. fromAction.SP将group和solo重组的方式废弃掉,参考:n19p18-todo5
 *      3. fromAction.SP替代group和solo的方法为: 用outModel.checkAlg找同层节点进行_Hav,并判断其符合GLDic中的稀疏码同区,且与GL的innerType相同,同大或同小;
 */
-(void) commitReasonSub:(TOFoModel*)sFoModel demand:(ReasonDemandModel*)demand{
    //1. 数据检查
    if (!sFoModel || !demand) return;
    AIFoNodeBase *matchFo = demand.inModel.matchFo;
    AIFoNodeBase *sFo = [SMGUtils searchNode:sFoModel.content_p];
    
    //2. 决策时评价 (S首元素已错过,则失败);
    BOOL score = [AIScore FRS_Miss:sFo matchFo:matchFo cutIndex:demand.inModel.cutIndex];
    if (!score) {
        sFoModel.status = TOModelStatus_ActNo;
        [self singleLoopBackWithFailureModel:sFoModel];
    }
    
    //3. 提交_Fo,逐个满足S;
    [self singleLoopBackWithBegin:sFoModel];
    

    
    //TODOTOMORROW20210121:
    /*
     
    8  能不躲了mv-? 未避开,(OPushM有mv-),则status=OutBack;
        > 不是ActYes,触发S反省标记S,且设为failure,递归任务 (尝试下一方案);
    9  能不躲了mv-? 避开,(OPushM无mv-),则最终demand成功,任务完成;
        > 还是ActYes,触发P反省标记P,且设为finish,并移除任务;
    */
}

/**
 *  MARK:--------------------P+行为化--------------------
 *  @desc P+行为化,两级判断,参考:19166;
 *          1. isOut则输出;
 *          2. notOut则进行cHav行为化;
 *  @version
 *      2020.05.27: 将isOut=false时等待改成进行cHav行为化;
 *      2020.12.17: 将此方法,归由流程控制控制 (跑下来逻辑与原来没啥不同);
 */
-(void) commitPerceptSub:(TOFoModel*)outModel{
    [self singleLoopBackWithBegin:outModel];
}

/**
 *  MARK:--------------------P-行为化--------------------
 *  @desc P-行为化,三级判断,参考19167;
 *          1. is(SP)判断 (转移sp行为化);
 *          2. isOut判断 (输出);
 *          3. notOut判断 (等待);
 *  @废弃: 因为正价值是不产生需求的(或者说目前不需要的),可以以P-/R-来实现,累了歇歇的例子;
 */
-(void) commitPerceptPlus:(AIFoNodeBase*)matchFo plusFo:(AIFoNodeBase*)plusFo subFo:(AIFoNodeBase*)subFo checkFo:(AIFoNodeBase*)checkFo complete:(void(^)(BOOL actSuccess,NSArray *acts))complete{
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
 *  @title 外层输入对Out短时记忆的影响处理:
 *  @desc
 *      1. 最新一帧,与上轮循环做匹配 (对单帧匹配到任务Finish的,要推动决策跳转下帧);
 *      2. 未输出行为,等待中的,也要进行下轮匹配,比如等开饭,等来开饭了; (等待的status是ActNo还是Runing?)
 *      3. 流程说明: OPushM成功时,调用PM继续推进流程;
 *      4. 流程说明: OPushM失败时,待生物钟触发器触发反省类比,再推进流程;
 *  @desc 外循环回来,把各自实际输入的概念,存入到TOAlgModel.realAlg中;
 *      1. 三种ActYes方式: (HNGL,isOut输出,demand完成);
 *      2. 其中,"isOut输出"和"demand完成"和"HNGL.H"时的ActYes直接根据mIsC判断外循环输入是否符合即可;
 *      3. 而HNGL.GL需要根据输入的稀疏码变化是否符合GL来判断 (base.base可找到期望稀疏码,参考:20204);
 *  @todo
 *      1. 此处在for循环中,所以有可能推进多条,比如我有了一只狗,可以拉雪撬,或者送给爷爷陪爷爷 (涉及多任务间的价值自由竞争),暂仅支持一条,后再支持;
 *      2020.08.23: 在inputMv时,支持当前actYes的fo进行抵消 (或设置为Finish) (T 由demandManager完成);
 *      2020.08.23: 在waitModel为ActYes且为HNGL时,仅判定其是否符合HNGL变化; T
 *      2020.08.23: 对realAlg进行收集,收集到waitTOAlgModel.realContent_p下; T
 *      2020.08.26: 在GL时,需要判断其"期望"与"真实"概念间是否是同一物体 (参考20204-示例);
 *  @result 返回pushMiddle是否成功,如果推进成功,则不再执行TOP四模式;
 *  @version
 *      2020.08.05: waitModel.pm_Score的赋值改为取demand.score取负 (因为demand一般为负,而解决任务为正);
 *                  而此处,从waitModel的base中找fo较麻烦,所以省事儿,就直接取-demand.score得了;
 *      2020.08.24: 从commitFromOuterPushMiddleLoop中独立出来,独立调用,处理realAlg和HNGL的变化相符判断;
 *      2020.12.21: 重新将commitFromOuterInputReason与OuterPushMiddleLoop()合并 (参考21185);
 *      2020.12.22: 在以往isNormal之外,再支持对isH,isGL的节点进行PM理性评价;
 *      2020.12.22: 将所有waitModel有效的返回都赋值OuterBack,而仅将首个focusModel进行PM理性评价;
 *      2020.12.28: waitModels仅对ActYes响应,将Runing去掉,因为Running应该到任务推进中自行进行PM匹配mModel,而非此处 (参考21208);
 *      2021.01.02: 无论GL变化type是否与waitType符合,都对新的变化进行保留到realContent (参考2120B-BUG1);
 *      2021.01.02: GL中mIsC对matchAlgs的全面支持,因为有时洽逢C不是matchAlgs首个,而致mIsC失败;
 *  @bug
 *      2020.09.22: 加上cutStopStatus,避免同一waitModel被多次触发,导致BUG (参考21042);
 *      2020.12.26: GL时,waitType的判断改为bFo,因为只有bFo才携带了waitTypeDS (参考21204);
 *      2020.12.26: GL时,在21204BUG修复后训练时,发现mIsC有时是cIsM,所以都判断下;
 *      2020.12.26: 在OPushM继续PM前,replaceAlg时,重新赋值JustPValues=P-C (参考21206);
 */
-(BOOL) commitFromOuterPushMiddleLoop:(DemandModel*)demand latestMModel:(AIShortMatchModel*)latestMModel{
    //1. 数据检查
    if (!demand || !latestMModel) return false;
    
    //2. 取出所有等待下轮的outModel (ActYes&Runing);
    NSArray *waitModels = [TOUtils getSubOutModels_AllDeep:demand validStatus:@[@(TOModelStatus_ActYes)] cutStopStatus:@[@(TOModelStatus_Finish),@(TOModelStatus_ActNo),@(TOModelStatus_ScoreNo)]];
    NSLog(@"\n\n=============================== OPushM ===============================\n输入M:%@\n输入P:%@\n等待中任务数:%lu",Alg2FStr(latestMModel.matchAlg),Alg2FStr(latestMModel.protoAlg),(long)waitModels.count);
    
    //3. 判断最近一次input是否与等待中outModel相匹配 (匹配,比如吃,确定自己是否真吃了);
    //3. 保留/更新实际发生到outModel (通过了有效判断的,将实际概念直接存留到waitModel);
    TOAlgModel *focusModel = nil;
    for (TOAlgModel *waitModel in waitModels) {
        if (Log4OPushM) NSLog(@"==> checkTOModel: %@",Pit2FStr(waitModel.content_p));
        if (ISOK(waitModel, TOAlgModel.class) && ISOK(waitModel.baseOrGroup, TOFoModel.class)) {
            if ([TOUtils isHNGL_toModel:waitModel]) {
                //4. "H"的有效判断;
                if ([TOUtils isH_toModel:waitModel]) {
                    TOAlgModel *targetModel = (TOAlgModel*)waitModel.baseOrGroup.baseOrGroup;
                    BOOL mIsC = [TOUtils mIsC_1:latestMModel.matchAlg.pointer c:targetModel.content_p];
                    if (Log4OPushM) NSLog(@"H有效判断_mIsC:(M=headerM C=%@) 结果:%d",Pit2FStr(targetModel.content_p),mIsC);
                    if (mIsC) {
                        waitModel.status = TOModelStatus_OuterBack;
                        waitModel.realContent_p = latestMModel.protoAlg.pointer;
                        
                        //1. 在ATHav时,执行到此处,说明waitModel和baseFo已完成;
                        waitModel.baseOrGroup.status = TOModelStatus_Finish;
                        
                        //2. 应跳到: baseFo.baseAlg与此处inputMModel.protoAlg之间,进行PM评价;
                        if (!focusModel) NSLog(@"=== OPushM成功 Hav继续PM: %@",Pit2FStr(targetModel.content_p));
                        if (!focusModel) focusModel = targetModel;
                    }
                }else if([TOUtils isG_toModel:waitModel] || [TOUtils isL_toModel:waitModel]){
                    //a. 从父级fo的父级取得原稀疏码值 (valueModel中有期望稀疏码sValue);
                    TOFoModel *bFo = (TOFoModel*)waitModel.baseOrGroup;         //waitModel所属glFo
                    TOValueModel *bbValue = (TOValueModel*)bFo.baseOrGroup;     //glFo是为了bbValue
                    TOAlgModel *targetModel = (TOAlgModel*)bbValue.baseOrGroup; //bbValue所属目标alg
                    
                    //5. "GL"的有效判断;
                    AIKVPointer *hopeValue_p = bbValue.sValue_p;
                    
                    //b. 在inputProtoAlg中找到实际稀疏码realValue;
                    AIKVPointer *realValue_p = [SMGUtils filterSameIdentifier_p:hopeValue_p b_ps:latestMModel.protoAlg.content_ps];
                    
                    //c. 对期望与实际稀疏码比较得到实际ATType;
                    if (hopeValue_p && realValue_p) {
                        BOOL mIsC = false;
                        for (AIAlgNodeBase *item in latestMModel.matchAlgs) {
                            mIsC = [TOUtils mIsC_1:item.pointer c:targetModel.content_p] || [TOUtils mIsC_1:targetModel.content_p c:item.pointer];
                            if (mIsC) {
                                if (Log4OPushM) NSLog(@"GL有效判断_mIsC:(M=%@ C=%@) 结果:%d",Alg2FStr(item), Pit2FStr(targetModel.content_p),mIsC);
                                break;
                            }
                        }
                        
                        //e. mIsC判断 (20201226:在21204BUG修复后训练时,发现mIsC有时是cIsM,所以都判断下);
                        if (mIsC) {
                            //d. 当实际ATType与等待中的ATType一致时,符合预期 (20201226改为判断bFo,因为只有bFo才携带了waitTypeDS,参考21204);
                            AnalogyType realType = [ThinkingUtils compare:hopeValue_p valueB_p:realValue_p];
                            AnalogyType waitType = [ThinkingUtils convertDS2AnalogyType:bFo.content_p.dataSource];
                            
                            //e. 只有符合变化时,才改为OuterBack,否则不改,使之反省类比时,可以发现不符合问题;
                            if (realType == waitType){
                                waitModel.status = TOModelStatus_OuterBack;
                            }
                            waitModel.realContent_p = latestMModel.protoAlg.pointer;
                            
                            //1. 在ATHav时,执行到此处,说明waitModel和baseFo已完成;
                            waitModel.baseOrGroup.status = TOModelStatus_Finish;
                            
                            //2. 应跳到: baseFo.baseAlg与此处inputMModel.protoAlg之间,进行PM评价;
                            if (!focusModel) NSLog(@"=== OPushM成功 GL:%@ 继续PM:%@ bFo:%@",realType == waitType ? @"符合" : @"不符合",Pit2FStr(targetModel.content_p),Pit2FStr(bFo.content_p));
                            if (!focusModel) focusModel = targetModel;
                        }
                    }
                }
            }else{
                //7. "行为输出" 和 "demand.ActYes"的有效判断;
                BOOL mIsC = [TOUtils mIsC_1:latestMModel.matchAlg.pointer c:waitModel.content_p];
                if (Log4OPushM) NSLog(@"Normal有效判断_mIsC:(M=headerM C=%@) 结果:%d",Pit2FStr(waitModel.content_p),mIsC);
                if (mIsC) {
                    waitModel.status = TOModelStatus_OuterBack;
                    waitModel.realContent_p = latestMModel.protoAlg.pointer;
                    if (!focusModel) NSLog(@"=== OPushM成功 Normal继续PM: %@",Pit2FStr(waitModel.content_p));
                    if (!focusModel) focusModel = waitModel;
                }
            }
        }
    }
    
    //8. 将首个focusModel进行PM修正 (理性评价);
    if (focusModel) {
        
        //4. 先清空justPValues,再重新根据两种情况赋值;
        [focusModel.justPValues removeAllObjects];
        
        //4. 为replaceAlg时,取"P-C取得独特稀疏码"保留到短时记忆模型;
        TOModelBase *baseAlg = focusModel.baseOrGroup;
        if (ISOK(baseAlg, TOAlgModel.class) && [((TOAlgModel*)baseAlg).replaceAlgs containsObject:focusModel.content_p]) {
            AIAlgNodeBase *inHeartNeedAlg = [SMGUtils searchNode:baseAlg.content_p];
            [focusModel.justPValues addObjectsFromArray:[SMGUtils removeSub_ps:inHeartNeedAlg.content_ps parent_ps:latestMModel.protoAlg.content_ps]];
            NSLog(@"JustPValues重赋值-> P:%@ - C:%@ = %@",Alg2FStr(latestMModel.protoAlg),Alg2FStr(inHeartNeedAlg),Pits2FStr(focusModel.justPValues));
        }else{
            //非replaceAlg时,取"P-M取得独特码"保留到短时记忆模型;
            [focusModel.justPValues addObjectsFromArray:[SMGUtils removeSub_ps:latestMModel.matchAlg.content_ps parent_ps:latestMModel.protoAlg.content_ps]];
            NSLog(@"JustPValues重赋值-> P:%@ - M:%@ = %@",Alg2FStr(latestMModel.protoAlg),Alg2FStr(latestMModel.matchAlg),Pits2FStr(focusModel.justPValues));
        }
        
        //5. 将理性评价"价值分"保留到短时记忆模型;
        focusModel.pm_Score = -[AIScore score4MV:demand.algsType urgentTo:demand.urgentTo delta:demand.delta ratio:1.0f];
        focusModel.pm_MVAT = demand.algsType;
        focusModel.pm_Fo = [SMGUtils searchNode:focusModel.baseOrGroup.content_p];
        
        //6. 理性评价
        [self reasonScorePM_V3:focusModel failure:nil success:^{
            NSLog(@"OPushM: 跳转成功");
        } notNeedPM:^{
            //7. 未跳转到PM,则将algModel设为Finish,并递归;
            NSLog(@"OPushM: 不用跳转");
            focusModel.status = TOModelStatus_Finish;
            [self singleLoopBackWithFinishModel:focusModel];
        }];
        return true;
    }
    
    NSLog(@"OPushM: 无一被需要");
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
 *      2020.07.14: 支持综合评价totalRefScore,因为不综合评价的话,会出现不稳定的BUG,参考20093;
 *      2020.07.16: 废除综合评价,改为只找出一条 (参考n20p10-todo1);
 *      2020.09.03: v2_将反省类比的SP用于PM理性评价 (参考20206);
 *      2020.09.09: 转移_GL时,取GL目标值,改为从P中取 (参考20207);
 *      2020.11.23: 将return BOOL改为三个block: (failure,success,notNeedPM) (参考21147);
 *      2021.01.01: v3_评价依据改为值域求和 (参考2120A & n21p21);
 *  _result moveValueSuccess : 转移到稀疏码行为化了,转移成功则返回true,未转移则返回false;
 *  @bug
 *      2020.07.05: BUG,在用MatchConF.content找交集同区稀疏码肯定找不到,改为用MatchConA后,ok了;
 *      2020.07.06: 此处M.conPorts,即sameLevelAlg_ps为空,明天查下原因 (因为MC以C做M,C有可能本来就是最具象概念);
 *      2020.07.12: PM会加工"经"和"纬"的问题,改为在判断时,仅对指向了mv的fo做判断后修复,参考:20092;
 *      2020.07.13: fuzzyFo有时含多条同区码,导致其价值指向不确定,是否需加工判错,改成只判断单码后fix(如[距34,距0,吃]->{mv+},但显然距34并不能吃);
 *      2020.09.30: 类型错误,导致闪退的BUG (参考21056);
 *      2020.10.14: 有时gl修正目标码在MC的C中,而不在Plus中,要优先从C中取 (参考21059);
 *      2020.11.23: 在GL失败时,failure()返回_Hav继续进行行为化 (参考21147);
 *  @callers
 *      1. MC调用: 参考21059-344结构图;
 */
-(void) reasonScorePM_V3:(TOAlgModel*)outModel failure:(void(^)())failure success:(void(^)())success notNeedPM:(void(^)())notNeedPM{
    //1. 数据准备
    AIAlgNodeBase *M = [SMGUtils searchNode:outModel.content_p];
    AIFoNodeBase *mMaskFo = outModel.pm_Fo;
    if (!outModel || !outModel.pm_Fo || !M) {
        if (notNeedPM) notNeedPM();
        return;
    }
    
    //3. 将理性评价数据存到短时记忆模型 (excepts收集所有已PM过的);
    NSArray *except_ps = [TOUtils convertPointersFromTOValueModelSValue:outModel.subModels validStatus:nil];
    NSArray *validJustPValues = [SMGUtils removeSub_ps:except_ps parent_ps:outModel.justPValues];
    
    //4. 不用PM评价 (则交由流程控制方法,推动继续决策(跳转下帧/别的);
    if (!ARRISOK(validJustPValues)) {
        if (notNeedPM) notNeedPM();
        return;
    }
    NSLog(@"\n\n=============================== PM ===============================\nM:%@\nMAtFo:%@",Alg2FStr(M),Fo2FStr(mMaskFo));
    if (Log4PM) NSLog(@"---> P独特码:%@",Pits2FStr(outModel.justPValues));
    if (Log4PM) NSLog(@"---> 不应期:%@",Pits2FStr(except_ps));
    if (Log4PM) NSLog(@"---> P有效独特码:%@",Pits2FStr(validJustPValues));
    
    //5. 理性评价: 取到首个P独特稀疏码 (判断是否需要行为化);
    AIKVPointer *firstJustPValue = ARR_INDEX(validJustPValues, 0);
    if (firstJustPValue) {
        //5. 取得当前帧alg模型 (参考20206-结构图) 如: A22(速0,高5,距0,向→,皮0);
        TOAlgModel *curAlgModel = (TOAlgModel*)outModel.baseOrGroup;
        AIAlgNodeBase *curAlg = [SMGUtils searchNode:curAlgModel.content_p];
        
        //6. 取当前方案fo模型 (参考20206-结构图) 如: P+新增一例解决方案: F23[A22(速0,高5,距0,向→,皮0),A1(吃1)]->M7{64};
        TOFoModel *curFoModel = (TOFoModel*)curAlgModel.baseOrGroup;
        AIFoNodeBase *curFo = [SMGUtils searchNode:curFoModel.content_p];
        
        //7. 根据curAlg和curFo取有效的部分validAlgSPs (参考20206-步骤图-第1步);
        NSArray *sPorts = [ThinkingUtils pm_GetValidSPAlg_ps:curAlg curFo:curFo type:ATSub];
        
        //8. 根据curAlg和curFo取有效部分的pPorts,并筛选有效分区部分;
        NSArray *pPorts = [ThinkingUtils pm_GetValidSPAlg_ps:curAlg curFo:curFo type:ATPlus];
        
        //8. 2021.01.01: 个性评价依据,以值域求和方式来实现 (参考2120A & n21p21);
        BOOL score = [AIScore VRS:firstJustPValue cAlg:curAlg sPorts:sPorts pPorts:pPorts];
        
        //8. 从validAlgSs和validAlgPs中,以firstJustPValue同区稀疏码相近排序 (参考20206-步骤图-第2步);
        NSArray *sortPAlgs = [ThinkingUtils getFuzzySortWithMaskValue:firstJustPValue fromProto_ps:Ports2Pits(pPorts)];
        
        //9. 将最接近的取出,并根据源于S或P作为理性评价结果,判断是否修正;
        AIAlgNodeBase *mostSimilarAlg = ARR_INDEX(sortPAlgs, 0);
        if (Log4PM) NSLog(@"> 当前修正:%@ 最近P:%@ 评价:%@",Pit2FStr(firstJustPValue),Alg2FStr(mostSimilarAlg),score?@"通过":@"未通过");
        if (Log4PM) NSLog(@"--> S数:%lu [%@]",(unsigned long)sPorts.count,Pits2FStr(Ports2Pits(sPorts)));
        if (Log4PM) NSLog(@"--> P数:%lu [%@]",(unsigned long)pPorts.count,Pits2FStr(Ports2Pits(pPorts)));
        if (Log4PM) NSLog(@"--> SP From: %@ %@",Alg2FStr(curAlg),Fo2FStr(curFo));
        if (!score) {
            //10. 优先从MC的C中找同区码,作为修正GL的目标;
            AIKVPointer *glValue4M = [SMGUtils filterSameIdentifier_p:firstJustPValue b_ps:curAlg.content_ps];
            if (Log4PM) NSLog(@"find glValue4M %@ from C:(%@->%@) conF:%@ conA:%@",glValue4M ? @"success" : @"failure", Pit2FStr(firstJustPValue),Pit2FStr(glValue4M),Fo2FStr(curFo),Alg2FStr(curAlg));
            
            //10. 其次,找不到时,再从Plus中找: 评价结果为S -> 需要修正,找最近的P:mostSimilarPAlg, 作为GL修正目标值 (参考20207-示图);
            if (!glValue4M) {
                for (AIAlgNodeBase *item in sortPAlgs) {
                    //10. 仅找P第一条即可;
                    glValue4M = [SMGUtils filterSameIdentifier_p:firstJustPValue b_ps:item.content_ps];
                    if (Log4PM) NSLog(@"find glValue4M %@ from P:(%@->%@) conF:%@ conA:%@",glValue4M ? @"success" : @"failure", Pit2FStr(firstJustPValue),Pit2FStr(glValue4M),Fo2FStr(curFo),Alg2FStr(curAlg));
                    break;
                }
            }
            
            //11. 修正找到时,转至Begin-TOValueModel,并转移_GL;
            if (glValue4M) {
                if (Log4PM) NSLog(@"-> 转移 Success:(%@->%@)",Pit2FStr(firstJustPValue),Pit2FStr(glValue4M));
                TOValueModel *toValueModel = [TOValueModel newWithSValue:firstJustPValue pValue:glValue4M group:outModel];
                outModel.sp_P = M;
                [self singleLoopBackWithBegin:toValueModel];
                if (success) success();
                return;
            }
            
            //12. ------> 未找到GL的目标 (如距离0),直接计为失败;
            if (Log4PM) NSLog(@"-> 未找到GL目标,转至流程控制Failure");
            if (failure) failure();
            return;
        }else {
            //13. ------> 评价结果为P -> 无需修正,直接Finish (注:在TOValueModel构造方法中: proto中的value,就是subValue);
            if (Log4PM) NSLog(@"-> 无需PM,转至流程控制Finish");
            TOValueModel *toValueModel = [TOValueModel newWithSValue:firstJustPValue pValue:nil group:outModel];
            toValueModel.status = TOModelStatus_NoNeedAct;
            [self singleLoopBackWithFinishModel:toValueModel];
            if (success) success();
            return;
        }
    }
    
    //14. 无justP目标需转移,直接返回false,调用PM者会使outModel直接Finish;
    if (notNeedPM) notNeedPM();
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
 *      2020.08.22: BaseFo完成时,仅设定demand.status=ActYes,等待外循环返回"抵消价值";
 *      2020.09.16: TOFoModel不由此处Finish,而是由ActYes来处理,共有两种Fo (1. HNGL由末位转至ActYes  2. 普通Fo,直接转至ActYes);
 *      2020.12.18: TOFoModel不由此处跳帧,而是由toAction._Fo()来处理;
 */
-(void) singleLoopBackWithFinishModel:(TOModelBase*)finishModel {
    if (ISOK(finishModel, TOAlgModel.class)) {
        //1. Alg
        TOModelBase *base = finishModel.baseOrGroup;
        
        //2. 如果base取到fo,则下帧继续;
        if (ISOK(base, TOFoModel.class)) {
            //2. 完成,则直接返回finish (如本来就是最后一帧,则再递归至上一层);
            [self.toAction convert2Out_Fo:(TOFoModel*)base];
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
            [self reasonScorePM_V3:toAlgModel failure:^{
                //6. 当PM转移失败时,递归到Action._Hav;
                //2020.11.27: algModel本级递归 (只有在_Hav中全部失败后,才算真正的失败) (参考2114B);
                [self singleLoopBackWithBegin:toAlgModel];
            } success:nil notNeedPM:^{
                //c. 未跳转到GLDic或PM,则将algModel设为Finish,并递归;
                toAlgModel.status = TOModelStatus_Finish;
                [self singleLoopBackWithFinishModel:toAlgModel];
            }];
        }
    }else if(ISOK(finishModel, TOFoModel.class)){
        //TOFoModel不由此处Finish,而是由ActYes来处理,共有两种Fo (参考注释version-20200916);
        //if (ISOK(finishModel.baseOrGroup, DemandModel.class)) {
        //    finishModel.baseOrGroup.status = TOModelStatus_ActYes;
        //    NSLog(@"SUCCESS > 本轮决策完成");
        //    [self singleLoopBackWithActYes:finishModel.baseOrGroup];
        //}else{
        //    //b. 子Fo完成时,其父级也完成 (不过一般子fo是HNGL类型,如果到这儿,说明出了BUG);
        //    WLog(@"一般子fo是HNGL类型,如果到这儿,说明出了BUG");
        //    finishModel.baseOrGroup.status = TOModelStatus_Finish;
        //    [self singleLoopBackWithFinishModel:finishModel.baseOrGroup];
        //}
    }else if(ISOK(finishModel, DemandModel.class)){
        //全部完成,不由此处执行,而是由外循环传入mv抵消后,再移除此demand;
        //DemandModel *demand = (DemandModel*)finishModel;
        //[demand.actionFoModels removeAllObjects];
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
 *      4. 递归说明: (上级递归方式,即每次failure向宏观级递归);
 *          a. value失败时,递归到alg.begin (_Hav中不应期递归循环);
 *          b. alg失败时,递归到fo.begin;
 *          c. fo失败时,递归到demand.begin (TOP+换新解决方案);
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
            
            //b. 一条alg失败时,整个fo失败;
            [self singleLoopBackWithFailureModel:toFoModel];
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
        
        //b. 2020.11.27: algModel永不言败 (永远传给_Hav,只有_Hav全部失败时,才会自行调用failure声明失败) (参考2114B);
        [self singleLoopBackWithBegin:baseAlg];
    }else if(ISOK(failureModel, TOFoModel.class)){
        //a. 解决方案失败,则跳转找出下一方案 (用fo向上找A/V/D进行fos再决策 (先尝试转移,后不行就递归));
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
 *      2020.12.15: 当begin为Fo时,向toAction._Fo执行 (因为原来不支持fo.begin,流程控制不完整);
 */
-(void) singleLoopBackWithBegin:(TOModelBase*)beginModel {
    //1. 活跃度判断
    if (!beginModel || ![theTC energyValid]) {
        return;
    }
    [theTC updateEnergy:-0.2f];
    
    //a. 转移
    if (ISOK(beginModel, TOAlgModel.class)) {
        //a1. avdIsAlg: 再决策,转移至TOAction;
        [self.toAction convert2Out_Hav:(TOAlgModel*)beginModel];
    }else if(ISOK(beginModel, TOValueModel.class)){
        //a2. avdIsValue: 再决策,转移至TOAction;
        TOAlgModel *baseAlg = (TOAlgModel*)beginModel.baseOrGroup;
        //a2. 2020.10.18: 传递参数由baseAlg.sp_P改成pm_ProtoAlg (因为飞近上面的坚果,却飞向左) (参考2105c)
        [self.toAction convert2Out_GL:baseAlg.pm_ProtoAlg outModel:(TOValueModel*)beginModel];
    }else if(ISOK(beginModel, DemandModel.class)){
        //a3. avdIsDemand: 再决策,转移至TOP.P-;
        [self.delegate aiTOR_MoveForDemand:(DemandModel*)beginModel];
    }else if(ISOK(beginModel, TOFoModel.class)){
        //a4. 将一次性relative_fos改为由递归逐条执行;
        [self.toAction convert2Out_Fo:(TOFoModel*)beginModel];
    }
}

/**
 *  MARK:--------------------ActYes的流程控制--------------------
 *  @desc : 当ActYes时,一般等待外循环反馈,而此处构建生物钟触发器,用于超时时触发反省类比;
 *      1. 调用AITime触发器;
 *      2. 当生物钟触发器触发时,如果未输入有效"理性推进" 或 "感性抵消",则对这些期望与实际的差距进行反省类比;
 *  @callers
 *      1. demand.ActYes处
 *      2. 行为化Hav().HNGL.ActYes处
 *      3. 行为输出ActYes处
 *  @todo
 *      2020.08.31: 对isOut触发的,先不做处理,因为一般都能直接行为输出并匹配上,所以暂不处理;
 *  @version
 *      2020.10.17: 在生物钟触发器触发器,做有根判定,任务失效时,不进行反省 (参考note21-todolist-1);
 *      2020.12.18: HNGL失败时再调用Begin会死循环的问题,改为HNGL.ActYes失败时,则直接调用FC.Failure(hnglAlg);
 */
-(void) singleLoopBackWithActYes:(TOModelBase*)actYesModel {
    NSLog(@"\n\n=============================== 流程控制:ActYes ===============================\nModel:%@ %@",actYesModel.class,Pit2FStr(actYesModel.content_p));
    if (ISOK(actYesModel, TOAlgModel.class)) {
        //1. TOAlgModel时;
        TOAlgModel *algModel = (TOAlgModel*)actYesModel;
        TOFoModel *foModel = (TOFoModel*)algModel.baseOrGroup;
        AIFoNodeBase *foNode = [SMGUtils searchNode:foModel.content_p];
        if ([TOUtils isHNGL_toModel:algModel]) {
            //2. 如果TOAlgModel为HNGL时,
            NSInteger cutIndex = foNode.content_ps.count - 1;
            double deltaTime = [NUMTOOK(ARR_INDEX(foNode.deltaTimes, cutIndex)) doubleValue];
            
            //3. 触发器 (触发条件:未等到实际输入);
            NSLog(@"---//触发器A_生成: %@ from:%@ time:%f",AlgP2FStr(algModel.content_p),Fo2FStr(foNode),deltaTime);
            [AITime setTimeTrigger:deltaTime trigger:^{
                
                //4. 反省类比(成功/未成功)的主要原因;
                AnalogyType type = (algModel.status == TOModelStatus_ActYes) ? ATSub : ATPlus;
                NSLog(@"---//触发器A_触发: %@ from %@ (%@)",AlgP2FStr(algModel.content_p),Fo2FStr(foNode),ATType2Str(type));
                [AIAnalogy analogy_ReasonRethink:foModel cutIndex:cutIndex type:type];
                
                //5. 失败时,转流程控制-失败 (会开始下一解决方案);
                DemandModel *root = [TOUtils getDemandModelWithSubOutModel:algModel];
                BOOL havRoot = [theTC.outModelManager.getAllDemand containsObject:root];
                if (algModel.status == TOModelStatus_ActYes && havRoot) {
                    NSLog(@"====ActYes is ATSub -> 递归alg");
                    //5. 2020.11.28: alg本级递归 (只有_Hav全部失败时,才会自行调用failure声明失败) (参考2114C);
                    algModel.status = TOModelStatus_ActNo;
                    [self singleLoopBackWithFailureModel:algModel];
                }
            }];
        }else if(actYesModel.content_p.isOut){
            ////2. 为行为输出时;
            //int algIndex = [foNode.content_ps indexOfObject:algModel.content_p];
            //int deltaTime = [NUMTOOK(ARR_INDEX(foNode.deltaTimes, algIndex)) intValue];
            //
            ////b. 触发器
            //[AITime setTimeTrigger:deltaTime canTrigger:^BOOL{
            //    //c. 触发条件: (未等到实际输入);
            //    return algModel.status == TOModelStatus_ActYes;
            //} trigger:^{
            //    //1. 对已发生的 (< algIndex) 的部分收集sub稀疏码,构建ATSubAlg;
            //    //2. 对上述ATSubAlgs构建成ATSub时序;
            //}];
        }
    }else if(ISOK(actYesModel, TOFoModel.class)){
        if (ISOK(actYesModel.baseOrGroup, ReasonDemandModel.class)) {
            //R-模式ActYes处理;
            
            //TODOTOMORROW20210122:
            //1. 取matchFo已发生,到末位mvDeltaTime,所有时间之和做触发;
            //2 触发条件为: 当mv-未发生,则成功P,否则失败S;
            
            
            return;
        }
        
        //1. P-模式ActYes处理 (TOFoModel时,数据准备);
        TOFoModel *foModel = (TOFoModel*)actYesModel;
        AIFoNodeBase *actYesFo = [SMGUtils searchNode:foModel.content_p];
        DemandModel *demand = (DemandModel*)actYesModel.baseOrGroup;
        if (!ISOK(demand, DemandModel.class)) WLog(@"HNGL应该直接转至HNGL.actYes,如果转到这儿,说明出了BUG");
        
        //2. 触发器 (触发条件:任务未在demandManager中抵消);
        NSLog(@"---//触发器F_生成: %p -> %@ time:%f",demand,Fo2FStr(actYesFo),actYesFo.mvDeltaTime);
        [AITime setTimeTrigger:actYesFo.mvDeltaTime trigger:^{
            
            //3. 反省类比(成功/未成功)的主要原因;
            AnalogyType type = (demand.status != TOModelStatus_Finish) ? ATSub : ATPlus;
            NSLog(@"---//触发器F_触发: %p -> %@ (%@)",demand,Fo2FStr(actYesFo),ATType2Str(type));
            [AIAnalogy analogy_ReasonRethink:foModel cutIndex:NSIntegerMax type:type];
            
            //4. 失败时,转流程控制-失败 (会开始下一解决方案);
            BOOL havRoot = [theTC.outModelManager.getAllDemand containsObject:demand];
            if (demand.status != TOModelStatus_Finish && havRoot) {
                NSLog(@"====ActYes is Fo update status");
                actYesModel.status = TOModelStatus_ScoreNo;
                [self singleLoopBackWithFailureModel:actYesModel];
            }
        }];
    }
}

//MARK:===============================================================
//MARK:                     < TOActionDelegate >
//MARK:===============================================================
-(void)toAction_Output:(NSArray *)actions{
    actions = ARRTOOK(actions);
    for (AIKVPointer *algNode_p in actions) {
        BOOL invoked = [Output output_FromTC:algNode_p];
        NSLog(@"===执行%@",invoked ? @"success" : @"failure");
    }
}
-(AIShortMatchModel*) toAction_RethinkInnerFo:(AIFoNodeBase*)fo{
    return [self.delegate aiTOR_RethinkInnerFo:fo];
}
-(void) toAction_SubModelFinish:(TOModelBase*)outModel{
    [self singleLoopBackWithFinishModel:outModel];
}
-(void) toAction_SubModelActYes:(TOModelBase*)outModel{
    [self singleLoopBackWithActYes:outModel];
}
-(void) toAction_SubModelFailure:(TOModelBase*)outModel{
    [self singleLoopBackWithFailureModel:outModel];
}
-(void) toAction_SubModelBegin:(TOModelBase*)outModel{
    [self singleLoopBackWithBegin:outModel];
}
-(void) toAction_ReasonScorePM:(TOAlgModel*)outModel failure:(void(^)())failure notNeedPM:(void(^)())notNeedPM{
    [self reasonScorePM_V3:outModel failure:failure success:nil notNeedPM:notNeedPM];
}

@end
