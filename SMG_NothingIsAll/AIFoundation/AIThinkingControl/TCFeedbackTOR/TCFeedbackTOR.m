//
//  TCFeedbackTOR.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/5.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCFeedbackTOR.h"

@implementation TCFeedbackTOR

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 决策--------------------
 *  @title 外层输入对Out短时记忆的影响处理:
 *  @实例1: 原本我要上战场,预测危险不去,结果突然看到一辆坦克,为什么我会想到驾驶坦克上战场?
 *          a. 发现坦克前: 短时记忆的父子枝结构为: 物体去战场 -> 我做为物体去战场;
 *          b. 发现坦克后: 短时记忆的父子枝结构为: 坦克去战场 -> 我开着坦克去战场 (feedback后重组反思_坦克替代物体);
 *          说明: 通过feedback,已经重刷新了记忆树的一大部分;
 *          问题: 此处如何把坦克替换到人的?因为物体在更抽象父中,而上战场在更子中 (物体和战场可能不在同一时序中);
 *  @callers : 所有的ActYes都会使用此处来收集外循环反馈;
 *      1. HNGL
 *      2. Demand
 *      3. 静默成功说明 (例:穿越森林,出门前备好枪,老虎冲出来时,开枪吓跑它):
 *          a. 备好枪后,等待老虎 (进入来的及,actYes状态);
 *          b. 当静默成功返回outBack时,会在isNormal代码处判断到mIsC成立 (如老虎冲出来了);
 *          c. 并在此方法最后提交到PM流程中 (判断这只老虎的特征是否符合被吓跑的可能);
 *          d. 流程控制自行继续推进dsFo,使之阻止R预测发生 (如在老虎咬人前,我们开枪吓跑它);
 //因为dsFo的继续推进,未必需要PM,而此处PM的推进,能否流程控制自己递归到dsFo推进?需要明天查下此代码;
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
 *      2020.08.23: 对realAlg进行收集,收集到waitTOAlgModel.feedbackAlg下; T
 *      2020.08.26: 在GL时,需要判断其"期望"与"真实"概念间是否是同一物体 (参考20204-示例);
 *  @version
 *      xxxx.xx.xx: 返回pushMiddle是否成功,如果推进成功,则不再执行TOP四模式;
 *      2020.08.05: waitModel.pm_Score的赋值改为取demand.score取负 (因为demand一般为负,而解决任务为正);
 *                  而此处,从waitModel的base中找fo较麻烦,所以省事儿,就直接取-demand.score得了;
 *      2020.08.24: 从tor_OPushM中独立出来,独立调用,处理realAlg和HNGL的变化相符判断;
 *      2020.12.21: 重新将commitFromOuterInputReason与OuterPushMiddleLoop()合并 (参考21185);
 *      2020.12.22: 在以往isNormal之外,再支持对isH,isGL的节点进行PM理性评价;
 *      2020.12.22: 将所有waitModel有效的返回都赋值OuterBack,而仅将首个focusModel进行PM理性评价;
 *      2020.12.28: waitModels仅对ActYes响应,将Runing去掉,因为Running应该到任务推进中自行进行PM匹配mModel,而非此处 (参考21208);
 *      2021.01.02: 无论GL变化type是否与waitType符合,都对新的变化进行保留到feedbackAlg (参考2120B-BUG1);
 *      2021.01.02: GL中mIsC对matchAlgs的全面支持,因为有时洽逢C不是matchAlgs首个,而致mIsC失败;
 *      2021.03.17: 将latestAlg和waitAlg之间的mIsC判断由1层改为2层 (因为在22173BUG时,发现此处输入了隔层mIsC);
 *      2021.05.09: 对OPushM反馈的GL触发ORT反省 (参考23071-方案2);
 *      2021.05.12: 整理tor_OPushM的代码易读性;
 *      2021.05.12: GL返回时,直接调用focus.base(即C).begin() (参考23075-方案);
 *      2021.05.14: 将reModel.content由matchA改成protoA后,此处GL时mIsC判断仅判断pIsM即可 (参考23076);
 *      2021.05.18: 将GL返回时,更新baseGLFo和basebaseValue的status,以使ORT中可以判断其finish状态 (参考23065-474示图);
 *      2021.05.20: 在waitModels收集中,将任何层的actNo之下都切断收集,避免距21飞错又飞回来,重复相符判断 (参考23073-假想2);
 *      2021.05.20: 当GL相符判断有结果后,targetModel(replaceAlg)也设为finish或actNo,以便_GL()中做不应期判断 (参考23079);
 *      2021.12.05: 将feedbackTOR前置到概念识别后,所以推进成功,才执行TOP四模式的逻辑作废 (参考24171-9);
 *      2021.12.23: feedback时,将root设回runing状态 (参考24212-8);
 *      2021.12.26: 废弃HN后,类型判断处理 & 兼容hActYes输出 (参考25032-6);
 *      2021.12.26: waitModels由currentDemand改为支持所有rootDemands (新螺旋架构迭代了短时记忆树,全树更新);
 *      2021.12.27: 当H反馈成功时,把hDemand设为finish;
 *  @bug
 *      2020.09.22: 加上cutStopStatus,避免同一waitModel被多次触发,导致BUG (参考21042);
 *      2020.12.26: GL时,waitType的判断改为bFo,因为只有bFo才携带了waitTypeDS (参考21204);
 *      2020.12.26: GL时,在21204BUG修复后训练时,发现mIsC有时是cIsM,所以都判断下;
 *      2020.12.26: 在OPushM继续PM前,replaceAlg时,重新赋值JustPValues=P-C (参考21206);
 */
+(void) feedbackTOR:(AIShortMatchModel*)model{
    //4. 将新一帧数据报告给TOR,以进行短时记忆的更新,比如我输出行为"打",短时记忆由此知道输出"打"成功 (外循环入->推进->中循环出);
    //2. 取出所有等待下轮的outModel (ActYes&Runing);
    NSMutableArray *waitModels = [[NSMutableArray alloc] init];
    for (ReasonDemandModel *root in theTC.outModelManager.getAllDemand) {
        [waitModels addObjectsFromArray:[TOUtils getSubOutModels_AllDeep:root validStatus:@[@(TOModelStatus_ActYes)]]];
    }
    OFTitleLog(@"tor_OPushM", @"\n输入M:%@\n输入P:%@\n等待中任务数:%lu",Alg2FStr(model.matchAlg),Alg2FStr(model.protoAlg),(long)waitModels.count);
    
    //3. 判断最近一次input是否与等待中outModel相匹配 (匹配,比如吃,确定自己是否真吃了);
    //3. 保留/更新实际发生到outModel (通过了有效判断的,将实际概念直接存留到waitModel);
    for (TOAlgModel *waitModel in waitModels) {
        
        //3. waitModel有效检查;
        if (Log4OPushM) NSLog(@"==> checkTOModel: %@",Pit2FStr(waitModel.content_p));
        BOOL waitIsAlgAndBaseIsFo = ISOK(waitModel, TOAlgModel.class) && ISOK(waitModel.baseOrGroup, TOFoModel.class);
        if (!waitIsAlgAndBaseIsFo) continue;
        
        //3. 不同类型不同处理;
        //4. ============= H返回的有效判断 =============
        if (ISOK(waitModel.baseOrGroup.baseOrGroup, HDemandModel.class)) {
            NSLog(@"========4");
            TOFoModel *hFoModel = (TOFoModel*)waitModel.baseOrGroup;    //h解决方案;
            HDemandModel *hDemand = (HDemandModel*)hFoModel.baseOrGroup;//h需求模型
            TOAlgModel *targetAlg = (TOAlgModel*)hDemand.baseOrGroup;   //hDemand的目标alg;
            TOFoModel *targetFo = (TOFoModel*)targetAlg.baseOrGroup;    //hDemand的目标alg所在的fo;
            BOOL mIsC = [TOUtils mIsC_1:model.matchAlg.pointer c:targetAlg.content_p];
            if (Log4OPushM) NSLog(@"H有效判断_mIsC:(M=headerM C=%@) 结果:%d",Pit2FStr(targetAlg.content_p),mIsC);
            if (mIsC) {
                //1. 在ATHav时,执行到此处,说明waitModel和baseFo已完成;
                waitModel.status = TOModelStatus_OuterBack;
                hFoModel.status = TOModelStatus_Finish;
                targetAlg.status = TOModelStatus_OuterBack;
                targetAlg.feedbackAlg = model.protoAlg;
                hDemand.status = TOModelStatus_Finish;
                
                //2. root设回runing
                DemandModel *root = [TOUtils getRootDemandModelWithSubOutModel:waitModel];
                root.status = TOModelStatus_Runing;
                
                //2. 重组;
                [TCRegroup feedbackRegroup:targetFo];
            }
        }
        
        //7. ============= "行为输出" 和 "demand.ActYes" 和 "静默成功 的有效判断 =============
        if (ISOK(waitModel.baseOrGroup.baseOrGroup, ReasonDemandModel.class)) {
            TOAlgModel *targetAlg = waitModel;                          //等待中的目标alg;
            TOFoModel *targetFo = (TOFoModel*)targetAlg.baseOrGroup;    //目标alg所在的fo;
            BOOL mIsC = [TOUtils mIsC_2:model.matchAlg.pointer c:targetAlg.content_p];
            if (Log4OPushM) NSLog(@"Normal有效判断_mIsC:(M=headerM C=%@) 结果:%d",Pit2FStr(targetAlg.content_p),mIsC);
            if (mIsC) {
                //1. 赋值
                targetAlg.status = TOModelStatus_OuterBack;
                targetAlg.feedbackAlg = model.protoAlg;
                
                //2. root设回runing
                DemandModel *root = [TOUtils getRootDemandModelWithSubOutModel:targetAlg];
                root.status = TOModelStatus_Runing;
                
                //2. 重组
                [TCRegroup feedbackRegroup:targetFo];
            }
        }
    }
}

@end
