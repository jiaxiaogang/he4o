//
//  TOAlgScheme.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/19.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkOutAction.h"
#import "AIAbsAlgNode.h"
#import "ThinkingUtils.h"
#import "AINetUtils.h"
#import "AINetService.h"
#import "ShortMatchManager.h"
#import "AIShortMatchModel.h"
#import "TOFoModel.h"
#import "TOAlgModel.h"
#import "TOValueModel.h"
#import "TOUtils.h"
#import "AIPort.h"

@implementation AIThinkOutAction

/**
 *  MARK:--------------------SP行为化--------------------
 *  @desc 参考:MC_V3;
 *  @desc 工作模式:
 *      1. 将S加工成P;
 *      2. 满足P;
 *  _param complete : 必然执行,且仅执行一次;
 *  @version
 *      2020-05-22: 调用cHav,在原先solo与group的基础上,新增了最优先的checkAlg (因为solo和group可能压根不存在此概念,而TO是主应用,而非构建的);
 *      2020-06-03: 支持将cGLDic缓存至TOAlgModel,以便一条GL子任务完成时,顺利转移至下一GL子任务;
 *  @TODO_TEST_HERE:
 *      1. 测试时,在_GL时,可将pAlg换成checkAlg试试,因为pAlg本来就是反向类比后的fo,可能没有再进行内类比的机会,所以无_GL经验;
 *  @todo
 *      1. 收集_GL向抽象和具象延伸,而尽量避免到_Hav,尤其要避免重组,无论是group还是solo (参考n19p18-todo4);
 *      2. 将group和solo重组的方式废弃掉,参考:n19p18-todo5
 *      3. 替代group和solo的方法为: 用outModel.checkAlg找同层节点进行_Hav,并判断其符合GLDic中的稀疏码同区,且与GL的innerType相同,同大或同小;
 *  @bug
 *      1. 发现,很多glValue稀疏码节点的ds和值,完全对不上;对不上应该是正常的,不过应该是大对应小,有对应无,这样正常;随后再查查;后未复现; T
 */
-(void) convert2Out_SP:(AIKVPointer*)sAlg_p pAlg_p:(AIKVPointer*)pAlg_p outModel:(TOAlgModel*)outModel {
    //1. 结果数据准备
    AIAlgNodeBase *sAlg = [SMGUtils searchNode:sAlg_p];
    AIAlgNodeBase *pAlg = [SMGUtils searchNode:pAlg_p];
    if (!pAlg) {
        outModel.status = TOModelStatus_ActNo;
        [self.delegate toAction_SubModelFailure:outModel];
        return;
    }
    NSLog(@"\n\n=============================== SP START ===============================\nS:%@\nP:%@",Alg2FStr(sAlg),Alg2FStr(pAlg));
    
    //2. 满足P: GL部分;
    NSDictionary *cGLDic = [SMGUtils filterPointers:sAlg.content_ps b_ps:pAlg.content_ps checkItemValid:^BOOL(AIKVPointer *a_p, AIKVPointer *b_p) {
        return [a_p.identifier isEqualToString:b_p.identifier];
    }];
    
    //3. 将cGLDic & pAlg保留到短时记忆;
    [outModel.cGLDic setDictionary:cGLDic];
    outModel.sp_P = pAlg;
    
    //3. 满足P: cHav部分;
    NSArray *cHavArr = [SMGUtils removeSub_ps:cGLDic.allValues parent_ps:pAlg.content_ps];
    
    //4. GL行为化 (仅对第一条行为化,其后都由流程控制方法来控制推动);
    for (NSData *key in cGLDic.allKeys) {
        //a. 数据准备;
        AIKVPointer *sValue_p = DATA2OBJ(key);
        AIKVPointer *pValue_p = [cGLDic objectForKey:key];
        TOValueModel *valueOutModel = [TOValueModel newWithSValue:sValue_p pValue:pValue_p group:outModel];
        //b. 行为化
        NSLog(@"------SP_GL行为化:%@ -> %@",[NVHeUtil getLightStr:sValue_p],[NVHeUtil getLightStr:pValue_p]);
        AIAlgNodeBase *pConAlg = [SMGUtils searchNode:outModel.content_p];
        [self convert2Out_GL:pConAlg outModel:valueOutModel];
        break;//仅处理首条,其它条交由流程控制来做;
    }
    
    //5. H行为化;
    for (AIKVPointer *pValue_p in cHavArr) {
        //b. 将pValue_p独立找到概念,并找cHav;
        AIAbsAlgNode *soloAlg = [theNet createAbsAlg_NoRepeat:@[pValue_p] conAlgs:nil isMem:false];
        TOAlgModel *soloOutModel = [TOAlgModel newWithAlg_p:soloAlg.pointer group:outModel];
        [self convert2Out_Hav:soloOutModel];
        if (soloOutModel.status == TOModelStatus_ActNo || soloOutModel.status == TOModelStatus_ScoreNo) {
            continue;
        }
        
        //c. 将pValue_p+same_ps重组找到概念,并找cHav;
        AIAlgNodeBase *checkAlg = [SMGUtils searchNode:outModel.content_p];
        NSMutableArray *group_ps = [SMGUtils removeSub_ps:pAlg.content_ps parent_ps:checkAlg.content_ps];
        [group_ps addObject:pValue_p];
        AIAbsAlgNode *groupAlg = [theNet createAbsAlg_NoRepeat:group_ps conAlgs:nil isMem:false];
        TOAlgModel *groupOutModel = [TOAlgModel newWithAlg_p:groupAlg.pointer group:outModel];
        [self convert2Out_Hav:groupOutModel];
        if (groupOutModel.status == TOModelStatus_ActNo || groupOutModel.status == TOModelStatus_ScoreNo) {
            continue;
        }
        
        //c. solo和group方式都未成功,则: 一条稀疏码行为化失败,则直接返回失败;
        outModel.status = TOModelStatus_ActNo;
        [self.delegate toAction_SubModelFailure:outModel];
        return;
    }
}

/**
 *  MARK:--------------------P行为化--------------------
 *  _param curAlg_p : 来源: TOR.R-;
 */
-(void) convert2Out_P:(TOAlgModel*)outModel{
    [self convert2Out_Hav:outModel];
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
 *  @version
 *      2020.12.15: _Fo统一由fo.begin调用 (参考21183:将RelativeFos改为逐个返回,21184:Fo流程控制);
 */
-(void) convert2Out_Fo:(TOFoModel*)outModel{
    //1. 取出需行为化的content_ps部分;
    AIFoNodeBase *curFo = [SMGUtils searchNode:outModel.content_p];
    NSArray *curAlg_ps = nil;
    if ([TOUtils isHNGL:outModel.content_p]) {
        curAlg_ps = ARR_SUB(curFo.content_ps, 0, curFo.content_ps.count - 1);
    }else{
        curAlg_ps = curFo.content_ps;
    }
    
    //2. 数据检查
    NSLog(@"\n\n=============================== 行为化 ===============================\n时序:%@->%@\n需要:[%@]",Fo2FStr(curFo),Mvp2Str(curFo.cmvNode_p),Pits2FStr(curAlg_ps));
    if (!ARRISOK(curAlg_ps) || curFo == nil) {
        outModel.status = TOModelStatus_ActNo;
        [self.delegate toAction_SubModelFailure:outModel];
        return;
    }
    
    //3. fo反思评价
    BOOL scoreSuccess = [TOUtils toAction_RethinkScore:outModel rtBlock:^AIShortMatchModel *{
        return [self.delegate toAction_RethinkInnerFo:curFo];
    }];
    if (!scoreSuccess) {
        outModel.status = TOModelStatus_ScoreNo;
        [self.delegate toAction_SubModelFailure:outModel];
        return;
    }

    //4. 触发,首个概念行为化;
    for (AIKVPointer *curAlg_p in curAlg_ps) {
        TOAlgModel *algOutModel = [TOAlgModel newWithAlg_p:curAlg_p group:outModel];
        [self.delegate toAction_SubModelBegin:algOutModel];
        return;
    }
}

//MARK:===============================================================
//MARK:                     < H/G/L >
//MARK:===============================================================

/**
 *  MARK:--------------------单个概念的行为化--------------------
 *  第1级: 直接判定curAlg_p为输出则收集;
 *  第2级: MC匹配行为化
 *  第3级: LongNet长短时网络行为化
 *  _param curAlg_p : 三个来源: 1.Fo的元素A;  2.Range的元素A; 3.Alg的嵌套A;
 *  @version
 *      2020-05-22 : 支持更发散的联想(要求matchAlg和hAlg同被引用),因每次递归都要这么联想,所以从TOP搬到这来 (由19152改成19192);
 *      2020-05-27 : 支持outModel (目前cHav方法,收集所有acts,一次性返回行为,而并未进行多轮外循环,所以此处不必做subOutModel);
 *      2020-07-05 : 支持MC匹配,优先级小于isOut=true,大于RelativeFos;
 *      2020-07-06 : PM本质上是多态修正方法,所以不能将C作为M传过去,改为将M传过去;
 *      2020-07-07 : RelativeFo最后一位,不用行为化;
 *      2020-07-08 : 删掉HNGL调用递归,因为HNGL不是完成,外循环input回来,才算完成,(如飞了一步,还要继续飞)(如下了蛋,得看到蛋),参考20081;
 *      2020-07-27 : hAlg的获取方案relativeFos,由纯理性交集(参考19192),改为优化取理性交集,其次取纯空想 (因为常无法一蹴而就,需递归判定,但又不得不承认,有时候确实可以一蹴而就,比如在家时有冰箱,就不用想回京吃外卖);
 *      2020.08.22 : HNGL时,仅设定status=ActYes,等待外循环返回"理性符合的HNGL"结果;
 *      2020.11.23 : PM理性评价结果,之后的逻辑改动 (参考21147);
 *      2020.12.16 : 将第0级,isHNGL判断,改为先判断baseFo是HNGL,然后alg是末位,则说明是hnglAlg (参考21115-glConAlg并不是ATGL);
 *  @todo
 *      2020-07-05 : 在下面MC中,转至PM时,是将C作为M的,随后需测下,看是否需要独立对MC做类似PM的理性评价,即将一步到位,细化成两步各自评价;
 *  @bug
 *      2020.09.15: 将isOut=true时,改为调Finish,因为目前ActYes暂不对行为输出做处理,但流程控制要继续推进,否则会BUG (参考21025);
 *      2020.09.22: 取消行为输出时直接调用Finish,因为在OPushM中也会推进流程控制,如果这里再调用,会重复触发反省类比 (参考21042);
 *      2020.09.28: 独特码取到的不是最新帧,导致反省类比P时,不是距0而是距6,将mIsC的for循环改为新帧优先即可 (参考21054);
 *      2020.11.11: 修复cIsM导致mIsC判断失败的BUG (参考21143);
 *      2020.11.18: mIsC不稳定BUG,将mIsC改为对matchAlgs依次判断 (参考21145);
 */
-(void) convert2Out_Hav:(TOAlgModel*)outModel {
    //1. 数据准备 (空白无需行为化);
    if (!outModel.content_p) {
        outModel.status = TOModelStatus_Finish;
        [self.delegate toAction_SubModelFinish:outModel];
        return;
    }
    
    //1. 第0级: 本身即是cHav节点,不用行为化,即成功 (但不用递归,等外循环返回行为结果);
    if ([TOUtils isHNGL_toAlgModel:outModel]) {
        outModel.status = TOModelStatus_ActYes;//只需要等
        [self.delegate toAction_SubModelActYes:outModel];
        return;
    }else if (outModel.content_p.isOut) {
        //2. 第1级: 本身即是isOut时,直接行为化返回;
        NSLog(@"\n\n=============================== 行为输出 ===============================\n%@",AlgP2FStr(outModel.content_p));
        //2. 输出前改为ActYes (避免重复决策当前demand) (isOut=true暂无需反省类比);
        outModel.status = TOModelStatus_ActYes;
        //[self.delegate toAction_SubModelActYes:outModel];
        
        //2. 消耗活跃度并输出
        [theTC updateEnergy:-1.0f];
        [self.delegate toAction_Output:@[outModel.content_p]];
        
        //2. 输出后,直接改为Finish,因为行为输出本身暂无需反省类比(但需要推动baseFo的反省类比) (所以直接代替OPushM改状态为Finish);
        //2. 2020.09.22: 注掉,因为OPushM中未排除isOut=true的情况,所以会触发反省类比,再加上这儿成了两次触发 (参考21042);
        //outModel.status = TOModelStatus_Finish;
        //[self.delegate toAction_SubModelFinish:outModel];
        return;
    }else{
        //3. 数据检查curAlg
        AIAlgNodeBase *curAlg = [SMGUtils searchNode:outModel.content_p];
        NSLog(@"\n\n=============================== 行为化_Hav ===============================\nC:%@",Alg2FStr(curAlg));
        if (!curAlg) {
            outModel.status = TOModelStatus_ActNo;
            [self.delegate toAction_SubModelFailure:outModel];
            return;
        }
        
        //3. 第2级: 优先MC匹配 (当父级为时序,且mv有效时,执行) (参考21059-344图);
        AIFoNodeBase *baseFo = [SMGUtils searchNode:outModel.baseOrGroup.content_p];
        if (ISOK(outModel.baseOrGroup, TOFoModel.class) && baseFo && baseFo.cmvNode_p) {
            
            //a. 依次判断mModel,只要符合mIsC即可;
            for (NSInteger i = 0; i < theTC.inModelManager.models.count; i++) {
                AIShortMatchModel *model = ARR_INDEX_REVERSE(theTC.inModelManager.models, i);
                
                //b. 2020.11.27: 不应期检查 (参考2114B);
                if ([outModel.replaceAlgs containsObject:model.matchAlg.pointer]) {
                    continue;
                }
                
                NSLog(@"====== checkMC ====== Proto:%@",Alg2FStr(model.protoAlg));
                BOOL mIsC = false;
                for (AIAlgNodeBase *item in model.matchAlgs) {
                    BOOL itemMIsC = [TOUtils mIsC_2:curAlg.pointer c:item.pointer] || [TOUtils mIsC_2:item.pointer c:curAlg.pointer];
                    if (!mIsC && itemMIsC) mIsC = true;
                    NSLog(@"M:%@ isC %@",Alg2FStr(item),itemMIsC ? @"true" : @"false");
                    //if (mIsC) break;
                }
                if (mIsC) {
                    NSLog(@"===> 转至PM ↓↓↓↓↓↓↓↓↓ (C作为M,P作为P)");
                    
                    //b. 生成replaceAlg转移 & 保留到outModel.replaceAlgs;
                    TOAlgModel *reModel = [TOAlgModel newWithAlg_p:model.matchAlg.pointer group:outModel];
                    [outModel.replaceAlgs addObject:reModel.content_p];
                    
                    //c. 将"P-M取得独特稀疏码"保留到短时记忆模型;
                    [reModel.justPValues addObjectsFromArray:[SMGUtils removeSub_ps:curAlg.content_ps parent_ps:model.protoAlg.content_ps]];
                        
                    //d. 将理性评价"价值分"保留到短时记忆模型;
                    reModel.pm_Score = [ThinkingUtils getScoreForce:baseFo.cmvNode_p ratio:1.0f];
                    reModel.pm_MVAT = baseFo.cmvNode_p.algsType;
                    reModel.pm_Fo = baseFo;
                    reModel.pm_ProtoAlg = model.protoAlg;
                    
                    //e. 理性评价
                    __block BOOL reasonScore = true;
                    [self.delegate toAction_ReasonScorePM:reModel failure:^{
                        reasonScore = false;
                    } notNeedPM:^{
                        //f. 未跳转到PM,则将algModel设为Finish,并递归;
                        reModel.status = TOModelStatus_Finish;
                        [self.delegate toAction_SubModelFinish:reModel];
                    }];
                    
                    //g. 评价成功一条,即返回 & 评价失败时,继续循环尝试下帧短时记忆 & 所有帧都失败时,转至relativeFos;
                    if (reasonScore) return;
                }else{
                    for (AIAlgNodeBase *item in model.matchAlgs) NSLog(@"==> mIsC转至PM失败: %@",Alg2FStr(item));
                }
            }
        }
        
        //4. 第3级: 数据检查hAlg_根据type和value_p找ATHav
        NSArray *relativeFos = [AINetService getInner1Alg:curAlg vAT:outModel.content_p.algsType vDS:outModel.content_p.dataSource type:ATHav except_ps:nil];
        if (Log4ActHav) NSLog(@"getInnerAlg: 根据:%@ 找:%@_%@ relativeFos数:%lu",Alg2FStr(curAlg),outModel.content_p.algsType,outModel.content_p.dataSource,(unsigned long)relativeFos.count);
        
        //5. 去掉不应期
        NSArray *except_ps = [TOUtils convertPointersFromTOModels:outModel.actionFoModels];
        relativeFos = [SMGUtils removeSub_ps:except_ps parent_ps:relativeFos];
        
        //6. 只要有善可尝试的方式,即从首条开始尝试;
        if (Log4ActHav) NSLog(@"去掉不应期后_RelativeFos条数:%lu %@",(unsigned long)relativeFos.count,relativeFos.count > 0 ? @"↓↓↓↓↓↓↓↓" : @"无计可施");
        if (ARRISOK(relativeFos)) {
            [self convert2Out_RelativeFo_ps:relativeFos outModel:outModel];
        }
    }
    
    //10. 所有mModel都没成功行为化一条,则失败 (无计可施);
    outModel.status = TOModelStatus_ActNo;
    [self.delegate toAction_SubModelFailure:outModel];
}

/**
 *  MARK:--------------------对单稀疏码的变化进行行为化--------------------
 *  @desc 伪代码:
 *  1. 根据type和value_p找ATLess/ATGreater
 *      2. 找不到,failure;
 *      3. 找到,判断range是否导致条件C转移;
 *          4. 未转移: success
 *          5. 转移: C条件->递归到convert2Out_Single_Alg();
 *  _param vAT & vDS : 用作查找"大/小"的标识;
 *  @param alg : GL(pAlg)的具象概念, (所有微信息变化不应脱离概念,比如鸡蛋可以通过烧成固态,但水不能,所以变成固态这种特征变化,不应脱离概念去操作);
 *          1. _SP时,将pAlg传入;
 *          2. _PM时,将M传入;
 */
-(void) convert2Out_GL:(AIAlgNodeBase*)alg outModel:(TOValueModel*)outModel {
    NSLog(@"\n\n=============================== 行为化_GL ===============================\n%@",Alg2FStr(alg));
    //1. 数据准备
    AnalogyType type = [ThinkingUtils compare:outModel.sValue_p valueB_p:outModel.content_p];
    NSString *vAT = outModel.content_p.algsType;
    NSString *vDS = outModel.content_p.dataSource;
    if ((type != ATGreater && type != ATLess)) {
        WLog(@"value_行为化类参数type|value_p错误,相等不必行为化");
        //相等不必行为化,直接返回true;
        outModel.status = TOModelStatus_Finish;
        [self.delegate toAction_SubModelFinish:outModel];
        return;
    }
    
    //2. 根据type和value_p找ATLess/ATGreater
    
    //TODOTOMORROW: 查此处,C1训练右飞两次后,为何还是找不到距离变小索引;
    //经查,此处alg是pAlg,就是dis0的组节点,而并未经历过飞到0的经验,所以无法获取到glAlg结果;
    //可以尝试将此处,改为找将sAlg变小,而不是将其变成pAlg,即以s出发,接近p;
    NSArray *relativeFos = [AINetService getInner1Alg:alg vAT:vAT vDS:vDS type:type except_ps:nil];
    if (Log4ActGL) NSLog(@"getInnerAlg: 根据:%@->%@ 找:%@%@ GL有效经历数:%lu",Pit2FStr(outModel.sValue_p),Pit2FStr(outModel.content_p),vDS,Data2FStr(type, vAT, vDS),(unsigned long)relativeFos.count);
    
    //3. 根据havAlg联想时序,并找出新的解决方案,与新的行为化的概念,与新的条件概念; (2020.11.06: 由getInner1Alg直接取relativeFos);
    //NSArray *hdRef_ps = [SMGUtils convertPointersFromPorts:ARR_SUB(glAlg.refPorts, 0, cHavNoneAssFoCount)];
    
    //4. 去掉不应期
    NSArray *except_ps = [TOUtils convertPointersFromTOModels:outModel.actionFoModels];
    relativeFos = [SMGUtils removeSub_ps:except_ps parent_ps:relativeFos];
    
    //5. 转移至_fos
    if (ARRISOK(relativeFos)) {
        [self convert2Out_RelativeFo_ps:relativeFos outModel:outModel];
    }else{
        //6. 无计可施
        outModel.status = TOModelStatus_ActNo;
        [self.delegate toAction_SubModelFailure:outModel];
    }
}

//MARK:===============================================================
//MARK:                     < Relativen Fos >
//MARK:===============================================================

/**
 *  MARK:--------------------"相对时序"的行为化--------------------
 *  @param relativeFo_ps    : 相对时序地址;
 *  _param success          : 回调传回: 相对时序 & 行为化结果;
 *  _param failure          : 只要有一条行为化成功则success(),否则failure();
 *  注:
 *      1. 参数: 由方法调用者保证传入的是"相对时序"而不是普通时序
 *      2. 流程: 取出相对时序,并取rangeOrder,行为化并返回
 */
-(void) convert2Out_RelativeFo_ps:(NSArray*)relativeFo_ps outModel:(TOModelBase<ITryActionFoDelegate>*)outModel {
    //1. 数据准备
    relativeFo_ps = ARRTOOK(relativeFo_ps);
    
    //2. 逐个尝试行为化
    for (AIPointer *relativeFo_p in relativeFo_ps) {
        AIFoNodeBase *relativeFo = [SMGUtils searchNode:relativeFo_p];
        if (Log4ActRelativeFos) NSLog(@"------> RelativeFo_ps Start 共有方案%lu条,%@",(unsigned long)relativeFo_ps.count,Fo2FStr(relativeFo));
    }
    for (AIPointer *relativeFo_p in relativeFo_ps) {
        AIFoNodeBase *relativeFo = [SMGUtils searchNode:relativeFo_p];
        
        //3. 取出havFo除第一个和最后一个之外的中间rangeOrder
        NSLog(@"---> RelativeFo 行为化时序:%@",Fo2FStr(relativeFo));
        if (relativeFo != nil && relativeFo.content_ps.count >= 1) {
            //5. 转移,则进行行为化 (递归到总方法);
            TOFoModel *foOutModel = [TOFoModel newWithFo_p:relativeFo.pointer base:outModel];
            [self.delegate toAction_SubModelBegin:foOutModel];
            return;
        }
    }
    //7. 没一个成功 或 行为化成功 或 等待行为化,则失败;
    outModel.status = TOModelStatus_ActNo;
    NSLog(@"---> RelativeFo 行为化失败:%@",Pit2FStr(outModel.content_p));
    [self.delegate toAction_SubModelFailure:outModel];
}

@end
