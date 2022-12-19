//
//  TIUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/27.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TIUtils.h"

@implementation TIUtils

//MARK:===============================================================
//MARK:                     < 稀疏码识别 >
//MARK:===============================================================

/**
 *  MARK:--------------------稀疏码识别--------------------
 *  @version
 *      2022.05.23: 初版,排序和限制limit条数放到此处,原来getIndex_ps()方法里并没有相近度排序 (参考26096-BUG5);
 *      2022.05.23: 废弃掉不超过10%的条件,因为它会导致过窄问题 (参考26096-BUG3-方案1);
 *  @result 返回当前码识别的相近序列;
 */
+(NSArray*) TIR_Value:(AIKVPointer*)protoV_p{
    //1. 取索引序列 & 当前稀疏码值;
    NSArray *index_ps = [AINetIndex getIndex_ps:protoV_p.algsType ds:protoV_p.dataSource isOut:protoV_p.isOut];
    double maskData = [NUMTOOK([AINetIndex getData:protoV_p]) doubleValue];
    
    //2. 按照相近度排序;
    NSArray *near_ps = [SMGUtils sortSmall2Big:index_ps compareBlock:^double(AIKVPointer *obj) {
        double objData = [NUMTOOK([AINetIndex getData:obj]) doubleValue];
        return fabs(objData - maskData);
    }];
    
    //3. 窄出,仅返回前NarrowLimit条 (最多narrowLimit条,最少1条);
    return ARR_SUB(near_ps, 0, cValueNarrowLimit);
}


//MARK:===============================================================
//MARK:                     < 概念识别 >
//MARK:===============================================================

/**
 *  MARK:--------------------识别是什么(这是西瓜)--------------------
 *
 *  注: 无条件 & 目前无能量消耗 (以后有基础思维活力值后可energy-1)
 *  注: 局部匹配_后面通过调整参数,来达到99%以上的识别率;
 *
 *  Q1: 老问题,看到的algNode与识别到的,未必是正确的,但我们应该保持使用protoAlgNode而不是recognitionAlgNode;
 *  A1: 190910在理性思维完善后,识别result和protoAlg都有用;
 *
 *  Q2: 概念的嵌套,有可能会导致识别上的一些问题; (我们需要支持结构化识别,而不仅是绝对识别和模糊识别)
 *  A2: 190910概念嵌套已取消,正在做结构化识别,此次改动是为了完善ThinkReason细节;
 *
 *  @todo
 *      1. 看到西瓜会开心 : TODO: 对自身状态的判断, (比如,看到西瓜,想吃,那么当前状态是否饿)
 *          > 已解决,将useNode去掉,并且由mModel替代后,会提交给demandManager进行这些处理;
 *
 *  @version 迭代记录:
 *      20190910: 识别"概念与时序",并构建纵向关联; (190910概念识别,添加了抽象关联)
 *      20191223: 局部匹配支持全含: 对assAlg和protoAlg直接做抽象关联,而不是新构建抽象;
 *      20200307: 迭代支持模糊匹配fuzzy
 *      20200413: 无全含时,支持最相似的seemAlg返回;
 *      20200416: 废除绝对匹配 (因概念全局去重了,绝对匹配匹配没有意义);
 *      20200703: 废弃fuzzy模糊匹配功能,因为识别期要广入 (参考20062);
 *      20201022: 同时支持matchAlg和seemAlg结果 (参考21091);
 *      20201022: 将seem的抽象搬过来,且支持三种关联处理 (参考21091-蓝绿黄三种线);
 *      20220115: 识别结果可为自身,参考partMatching_Alg(),所以不需要此处再add(self)了;
 *      20220116: 全含可能也只是相似,由直接构建抽具象关联,改成概念外类比 (参考25105);
 *      20220528: 把概念外类比关掉 (参考26129-方案2-1);
 *      20221018: 对proto直接抽象指向matchAlg (参考27153-todo3);
 *      20221024: 将抽具象相似度存至algNode中 (参考27153-todo2);
 *
 *  _result
 *      xxxx.xx.xx: completeBlock : 共支持三种返回: 匹配效果从高到低分别为:fuzzyAlg废弃,matchAlg全含,seemAlg局部;
 *      2022.01.16: 改为直接传入inModel模型,识别后赋值到inModel中即可;
 */
+(void) TIR_Alg:(AIKVPointer*)algNode_p except_ps:(NSArray*)except_ps inModel:(AIShortMatchModel*)inModel{
    //1. 数据准备
    AIAlgNodeBase *protoAlg = [SMGUtils searchNode:algNode_p];
    if (protoAlg == nil) return;
    IFTitleLog(@"概念识别",@"\n%@",Alg2FStr(protoAlg));
    
    ///3. 局部匹配 -> 内存网络;
    ///200116注掉,因为识别仅是建立抽象关联,此处会极易匹配到内存中大量的具象alg,导致无法建立关联,而在硬盘网络时,这种几率则低许多;
    //if (!assAlgNode) assAlgNode = [AINetIndexUtils partMatching_Alg:algNode isMem:true except_ps:except_ps];
    
    ///4. 局部匹配 (Abs匹配 和 Seem匹配);
    [self partMatching_Alg:protoAlg except_ps:except_ps inModel:inModel];
    
    //5. 关联处理 & 外类比 (这样后面TOR理性决策时,才可以直接对当前瞬时实物进行很好的理性评价) (参考21091-蓝线);
    for (AIMatchAlgModel *matchModel in inModel.matchAlgs) {
        //4. 识别到时,value.refPorts -> 更新/加强微信息的引用序列
        AIAbsAlgNode *matchAlg = [SMGUtils searchNode:matchModel.matchAlg];
        [AINetUtils insertRefPorts_AllAlgNode:matchModel.matchAlg content_ps:matchAlg.content_ps difStrong:1];
        
        //5. 存储protoAlg与matchAlg之间的相近度记录 (参考27153-todo2);
        [protoAlg updateMatchValue:matchAlg matchValue:matchModel.matchValue];
        
        //6. 对proto直接抽象指向matchAlg,并增强强度值 (为保证抽象多样性,所以相近的也抽具象关联) (参考27153-3);
        [AINetUtils relateAlgAbs:matchAlg conNodes:@[protoAlg] isNew:false];
    }
}

/**
 *  MARK:--------------------概念局部匹配--------------------
 *  注: 根据引用找出相似度最高且达到阀值的结果返回; (相似度匹配)
 *  从content_ps的所有value.refPorts找前cPartMatchingCheckRefPortsLimit个, 如:contentCount9*limit5=45个;
 *
 *  @param except_ps : 排除_ps; (如:同一批次输入的概念组,不可用来识别自己)
 *
 *  @version:
 *      2021.09.27: 仅识别ATDefault类型 (参考24022-BUG4);
 *      2019.12.23 - 迭代支持全含,参考17215 (代码中由判断相似度,改为判断全含)
 *      2020.04.13 - 将结果通过complete返回,支持全含 或 仅相似 (因为正向反馈类比的死循环切入问题,参考:n19p6);
 *      2020.07.21 - 当Seem结果时,对seem和proto进行类比抽象,并将抽象概念返回 (参考:20142);
 *      2020.07.21 - 当Seem结果时,虽然构建了absAlg,但还是将seemAlg返回 (参考20142-Q1);
 *      2020.10.22 - 支持matchAlg和seemAlg二者都返回 (参考21091);
 *      2020.11.18 - 支持多全含识别 (将所有全含matchAlgs返回) (参考21145方案1);
 *      2020.11.18 - partAlgs将matchAlgs移除掉,仅保留非全含的部分;
 *      2022.01.13 - 迭代支持相近匹配 (参考25082 & 25083);
 *      2022.01.15 - 识别结果可为自身: 比如(飞↑)如果不识别自身,又全局防重,就识别不到最全含最相近匹配结果了;
 *      2022.05.11 - 全含不要求必须是抽象节点,因为相近匹配时,可能最具象也会全含 (且现在全是absNode类型);
 *      2022.05.12 - 仅识别有mv指向的结果 (参考26022-3);
 *      2022.05.13 - 弃用partAlgs (参考26024);
 *      2022.05.20 - 1. 窄出,仅返回前NarrowLimit条 (参考26073-TODO2);
 *      2022.05.20 - 2. 改匹配度公式: matchCount改成protoCount (参考26073-TODO3);
 *      2022.05.20 - 3. 所有结果全放到matchAlgs中 (参考26073-TODO4);
 *      2022.05.20 - 4. 废弃仅识别有mv指向的 (参考26073-TODO5);
 *      2022.05.23 - 将匹配度<90%的过滤掉 (参考26096-BUG3);
 *      2022.05.24 - 排序公式改为sumNear / matchCount (参考26103-代码);
 *      2022.05.25 - 排序公式改为sumNear / proto.count (参考26114-1);
 *      2022.05.28 - 优化性能 (参考26129-方案2);
 *      2022.06.07 - 为了打开抽象结果(确定,轻易别改了),排序公式改为sumNear / matchCount (参考2619j-TODO2);
 *      2022.06.07 - 排序公式改为sumNear / nearCount (参考2619j-TODO5);
 *      2022.06.13 - 修复因matchCount<result.count导致概念识别有错误结果的BUG (参考26236);
 *      2022.10.20 - 删掉早已废弃的partAlgs代码 & 将返回List<AlgNode>类型改成List<AIMatchAlgModel> (参考27153);
 *      2022.12.19 - 迭代概念识别结果的竞争机制 (参考2722d-方案2);
 */
+(void) partMatching_Alg:(AIAlgNodeBase*)protoAlg except_ps:(NSArray*)except_ps inModel:(AIShortMatchModel*)inModel{
    //1. 数据准备;
    if (!ISOK(protoAlg, AIAlgNodeBase.class)) return;
    except_ps = ARRTOOK(except_ps);
    NSMutableArray *protoModels = [[NSMutableArray alloc] init];    //List<AIMatchAlgModel>;
    
    //2. 广入: 对每个元素,分别取索引序列 (参考25083-1);
    for (AIKVPointer *item_p in protoAlg.content_ps) {
        
        //3. 取相近度序列 (按相近程度排序);
        NSArray *near_ps = [self TIR_Value:item_p];
        
        //4. 每个near_p做两件事:
        for (AIKVPointer *near_p in near_ps) {
            
            //5. 第1_计算出nearV (参考25082-公式1);
            double nearV = [AIAnalyst compareCansetValue:near_p protoValue:item_p];
            
            //6. 第2_取near_p的refPorts (参考25083-1);
            NSArray *refPorts = [SMGUtils filterPorts_Normal:[AINetUtils refPorts_All4Value:near_p]];
            refPorts = ARR_SUB(refPorts, 0, cPartMatchingCheckRefPortsLimit_Alg(refPorts.count));
            
            //6. 第3_仅保留有mv指向的部分 (参考26022-3);
            //refPorts = [SMGUtils filterArr:refPorts checkValid:^BOOL(AIPort *item) {
            //    return item.targetHavMv;
            //}];
            if (Log4MAlg) NSLog(@"当前near_p:%@ --ref数量:%lu",[NVHeUtil getLightStr:near_p],(unsigned long)refPorts.count);
            
            //7. 每个refPort做两件事:
            for (AIPort *refPort in refPorts) {
                
                //8. 不应期 -> 不可激活;
                if ([SMGUtils containsSub_p:refPort.target_p parent_ps:except_ps]) continue;
                
                //9. 找model (无则新建);
                AIMatchAlgModel *model = [SMGUtils filterSingleFromArr:protoModels checkValid:^BOOL(AIMatchAlgModel *item) {
                    return [item.matchAlg isEqual:refPort.target_p];
                }];
                if (!model) {
                    model = [[AIMatchAlgModel alloc] init];
                    [protoModels addObject:model];
                }
                model.matchAlg = refPort.target_p;
                
                //10. 统计匹配度matchCount & 相近度<1个数nearCount & 相近度sumNear & 引用强度sumStrong
                model.matchCount++;
                model.nearCount++;
                model.sumNear += nearV;
                model.sumRefStrong += (int)refPort.strong.value;
            }
        }
        if (Log4MAlg) if (protoModels.count) NSLog(@"计数字典匹配情况: %@ ------",[SMGUtils convertArr:protoModels convertBlock:^id(AIMatchAlgModel *obj) {
            return @(obj.matchCount);
        }]);
    }
    
    //11. 识别竞争机制 (参考2722d-方案2);
    NSDictionary *rankDic = [AIRank recognitonAlgRank:protoModels];
    
    //11. 按nearA排序 (参考25083-2&公式2 & 25084-1);
    NSArray *sortModels = [SMGUtils sortSmall2Big:protoModels compareBlock:^double(AIMatchAlgModel *obj) {
        return NUMTOOK([rankDic objectForKey:@(obj.matchAlg.pointerId)]).floatValue;
    }];
    
    //12. 全含判断: 从大到小,依次取到对应的node和matchingCount (注: 支持相近后,应该全是全含了,参考25084-1);
    NSArray *validModels = [SMGUtils filterArr:sortModels checkValid:^BOOL(AIMatchAlgModel *item) {
        //14. 过滤掉匹配度<85%的;
        if (item.matchValue < 0.90f) return false;
        
        //15. 仅保留全含 (当count!=matchCount时为局部匹配: 局部匹配partAlgs已废弃);
        AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item.matchAlg];
        if (itemAlg.count == item.matchCount) return true;
        return false;
    }];
    
    //13. 仅保留最相近的20条 (参考25083-3);
    NSArray *matchModels = ARR_SUB(validModels, 0, cAlgNarrowLimit(protoAlg.count));
    
    //16. 未将全含返回,则返回最相似 (2020.10.22: 全含返回,也要返回seemAlg) (2022.01.15: 支持相近匹配后,全是全含没局部了);
    NSLog(@"\n识别结果 >> 概念识别结果数:%ld",matchModels.count);
    for (AIMatchAlgModel *item in matchModels) {
        NSLog(@"-->>>(%d) 全含item: %@   \t相近度 => %.2f (count:%d)",item.sumRefStrong,Pit2FStr(item.matchAlg),item.matchValue,item.matchCount);
    }
    inModel.matchAlgs = matchModels;
}

//MARK:===============================================================
//MARK:                     < 时序识别 >
//MARK:===============================================================

/**
 *  MARK:--------------------时序局部匹配算法--------------------
 *
 *  --------------------V1--------------------
 *  参考: n17p7 TIR_FO模型到代码
 *  _param assFoIndexAlg    : 用来联想fo的索引概念 (shortMem的第3层 或 rethink的第1层) (match层,参考n18p2)
 *  _param assFoBlock       : 联想fos (联想有效的5个)
 *  _param checkItemValid   : 检查item(fo.alg)的有效性 notnull (可考虑写个isBasedNode()判断,因protoAlg可里氏替换,目前仅支持后两层)
 *  @param inModel          : 装饰结果到inModel中;
 *  _param indexProtoAlg    : assFoIndexAlg所对应的protoAlg,用来在不明确时,用其独特稀疏码指引向具象时序找"明确"预测;
 *  _param fromRegroup      : 调用者
 *                              1. 正常识别时: cutIndex=lastAssIndex;
 *                              2. 源自regroup时: cutIndex需从父任务中判断 (默认为-1);
 *  _param maskFo           : 识别时:protoFo中的概念元素为parent层, 而在反思时,其元素为match层;
 *  TODO_TEST_HERE:调试Pointer能否indexOfObject
 *  TODO_TEST_HERE:调试下item_p在indexOfObject中,有多个时,怎么办;
 *  TODO_TEST_HERE:测试下cPartMatchingThreshold配置值是否合理;
 *  @desc1: 在类比中,仅针对最后一个元素,与前面元素进行类比;
 *  @desc2: 内类比大小,将要取消(由外类比取代),此处不再支持;而内类比有无,此处理性概念全是"有";
 *  @desc:
 *      1. 根据最后一个节点,取refPorts,
 *      2. 对共同引用者的,顺序,看是否是正确的从左到右顺序;
 *      3. 能够匹配到更多个概念节点,越预测准确;
 *  TODO_FUTURE:判断概念匹配,目前仅支持一层抽象判断,是否要支持多层?实现方式比如(索引 / TIRAlg和TIRFo的协作);
 *
 *  @version:
 *      20191231: 测试到,点击饥饿,再点击乱投,返回matchFo:nil matchValue:0;所以针对此识别失败问题,发现了_fromShortMem和_fromRethink的不同,且支持了两层assFo,与全含;(参考:n18p2)
 *      20200627: 支持明确价值预测 & 支持更匹配的时序预测 (参考:20052);
 *      20200703: 废弃明确价值预测功能,因为认知期要广入,决策期再细修 (参考20063);
 *
 *  --------------------V1.5--------------------
 *  @desc
 *      1. 由v1整理而来,逻辑与v1一致 (将v1中checkItemValid和assFoBlock回调,直接写在方法中,而不由外界传入);
 *      2. 时序识别v1.5 (在V1的基础上改的,与V2最大的区别,是其未按照索引计数排序);
 *
 *  @status 启用,因为v2按照countDic排序的方式,不利于找出更确切的抽象结果;
 *
 *  --------------------v2--------------------
 *  @desc 功能说明:
 *      1. 本次v2迭代,主要在识别率上进行改进,因为v1识别率太低 (参考20111),所以迭代了v2版 (参考20112);
 *      2. 目前判断有效引用,不支持"必须包含某protoAlg" (代码第5步),以前需要再支持即可;
 *  @desc 执行步骤:
 *      1. 原始时序protoFo的每个元素都是索引;
 *      2. 对每个元素protoAlg自身1条 + 抽象5条 = 共6条做索引;
 *      3. 根据6条取refPorts引用时序;
 *      4. 对所有引用的时序,做计数判断,引用了越多的原始元素protoAlg,排在越前面;
 *      5. 从前开始找,找出引用即多,又全含的结果返回;
 *  @version 候选集
 *      2020.07.18: 将整个allRef_2拍平成一维数组,并去重 (即所有帧的refFos都算做候选集);
 *      2020.07.19: 改为仅取最后一位的refFos (因为最后一位是焦点帧,并且全含判断算法也需要支持仅末位候选集);
 *      2020.11.12: 支持except_ps参数,因为在FromShortMem时,matchAFo会识别protoFo返回,所以将protoFo不应期掉 (参考21144);
 *      2021.01.18: 联想matchFo时,由原本只获取Normal类型,改为将HNGL也加入其中 (参考22052-1a,实测未影响原多向飞行训练);
 *      2021.01.23: 支持多识别 (参考22072BUG & TIR_Fo_FromRethink注释todo更多元的评价 & 22073-todo1);
 *      2021.01.24: 改回仅识别Normal类型,因为HNGL太多了,不那么必要,还特麻烦,太多matchFos导致性能差 (参考22052-改1);
 *      2021.01.24: 将无mv指向的,算无效 (因为有大量未执行的正向反馈类比) (参考22072);
 *      2021.01.26: 为多时序识别结果做去重 (参考22074-BUG3);
 *      2021.01.31: 将无mv指向的,放开 (因为R-模式需要) (等支持反向反馈外类比后,再关掉) (参考n22p10);
 *      2021.02.03: 反向反馈外类比已支持,将无mv指向的关掉 (参考version上条);
 *      2021.02.04: 将matchFos中的虚mv筛除掉,因为现在R-模式不使用matchFos做解决方案,现在留着没用,等有用时再打开;
 *      2021.04.15: 无mv指向的支持返回为matchRFos,原来有mv指向的重命名为matchPFos (参考23014-分析1&23016);
 *      2021.06.30: 支持cutIndex回调,识别和反思时,分别走不同逻辑 (参考23152);
 *      2021.08.19: 结果PFos和RFos按(强度x匹配度)排序 (参考23222-BUG2);
 *      2022.01.16: 仅保留10条rFos和pFos (因为在十四测中,发现它们太多了,都有40条rFos的时候,依窄出原则,太多没必要);
 *      2022.03.05: 将保留10条改为全保留,因为不同调用处,需要不同的筛选排序方式 (参考25134-方案2);
 *      2022.03.09: 将排序规则由"强度x匹配度",改成直接由SP综合评分来做 (参考25142 & 25114-TODO2);
 *      2022.04.30: 识别时assIndexes取proto+matchs+parts (参考25234-1);
 *      2022.05.12: 仅识别有mv指向的结果 (参考26022-3);
 *      2022.05.18: 把pFo排序因子由评分绝对值,改成取负,因为正价值不构成任务,所以把它排到最后去;
 *      2022.05.20: 1. 废弃仅识别有mv指向的 (参考26073-TODO7);
 *      2022.05.20: 2. RFos排序,不受被引用强度影响 (参考26073-TODO9);
 *      2022.05.20: 3. prFos排序,以SP稳定性为准 (参考26073-TODO8);
 *      2022.05.20: 4. 提升识别准确度: 窄入,调整结果20条为NarrowLimit=5条 (参考26073-TODO6);
 *      2022.05.23: 将稳定性低的识别结果过滤掉 (参考26096-BUG4);
 *      2022.05.24: 稳定性支持衰减 (参考26104-方案);
 *      2022.06.07: cRFoNarrowLimit调整为0,即关掉RFos结果 (参考2619j-TODO3);
 *      2022.06.08: 排序公式改为sumNear / nearCount (参考26222-TODO1);
 *      2022.11.10: 因为最近加强了抽具象多层多样性,所以从matchAlgs+partAlgs取改为从lastAlg.absPorts取 (效用一样);
 *      2022.11.10: 时序识别中alg相似度复用-准备部分 & 参数调整 (参考27175-5);
 *      2022.11.15: 对识别结果,直接构建抽具象关联 (参考27177-todo6);
 *  @status 废弃,因为countDic排序的方式,不利于找出更确切的抽象结果 (识别不怕丢失细节,就怕不确切,不全含);
 */
+(void) partMatching_FoV1Dot5:(AIFoNodeBase*)protoOrRegroupFo except_ps:(NSArray*)except_ps decoratorInModel:(AIShortMatchModel*)inModel fromRegroup:(BOOL)fromRegroup{
    //2. 取assIndexes (反思时: 取本身+抽象一层; 识别时: 取proto+matchs+parts);
    AddTCDebug(@"时序识别0");
    AIAlgNodeBase *lastAlg = [SMGUtils searchNode:ARR_INDEX_REVERSE(protoOrRegroupFo.content_ps, 0)];
    NSMutableArray *assIndexes = [[NSMutableArray alloc] init];
    [assIndexes addObject:lastAlg.pointer];
    [assIndexes addObjectsFromArray:Ports2Pits([AINetUtils absPorts_All_Normal:lastAlg])];
    AddTCDebug(@"时序识别1");
    
    //3. 递归进行assFos
    if (Log4MFo) NSLog(@"------------ TIR_Fo ------------索引数:%lu",(unsigned long)assIndexes.count);
    for (AIKVPointer *assIndex_p in assIndexes) {
        //4. indexAlg.refPorts; (取识别到过的抽象节点(如苹果));
        //TODOTOMORROW20220821: 经测此处卡了286ms (识别算法共用了626ms);
        AIAlgNodeBase *indexAlg = [SMGUtils searchNode:assIndex_p];
        NSArray *assFoPorts = [AINetUtils refPorts_All4Alg_Normal:indexAlg];//b. 仅Normal
        AddTCDebug(@"时序识别3");
        
        //6. 无mv指向的仅保留limit(0)条 (参考26022-3);
        __block int rCount = 0;
        assFoPorts = [SMGUtils filterArr:assFoPorts checkValid:^BOOL(AIPort *item) {
            if (!item.targetHavMv && ++rCount > cRFoNarrowLimit) {
                return false;
            }
            return true;
        }];
        NSArray *assFo_ps = Ports2Pits(assFoPorts);
        if (Log4MFo) NSLog(@"\n-----> TIR_Fo 索引:%@ 时序数:%lu",Alg2FStr(indexAlg),(unsigned long)assFo_ps.count);
        AddTCDebug(@"时序识别4");
        
        //5. 依次对assFos对应的时序,做匹配度评价; (参考: 160_TIRFO单线顺序模型)
        for (AIKVPointer *assFo_p in assFo_ps) {
        
            //5. 不应期;
            if ([except_ps containsObject:assFo_p]) continue;
            
            AIFoNodeBase *assFo = [SMGUtils searchNode:assFo_p];
            AddTCDebug(@"时序识别6");
            
            //5. 虚mv,无效;
            if (assFo.cmvNode_p && [AINetUtils isVirtualMv:assFo.cmvNode_p]) continue;
            AddTCDebug(@"时序识别7");
            
            //6. 防重;
            BOOL pContains = ARRISOK([SMGUtils filterArr:inModel.matchPFos checkValid:^BOOL(AIMatchFoModel *item) {
                return [item.matchFo isEqual:assFo.pointer];
            }]);
            AddTCDebug(@"时序识别8");
            if (pContains) continue;
            
            BOOL rContains = ARRISOK([SMGUtils filterArr:inModel.matchRFos checkValid:^BOOL(AIMatchFoModel *item) {
                return [item.matchFo isEqual:assFo.pointer];
            }]);
            AddTCDebug(@"时序识别9");
            if (rContains) continue;
            
            //7. 全含判断;
            NSDictionary *indexDic = [self TIR_Fo_CheckFoValidMatchV2:assFo protoOrRegroupFo:protoOrRegroupFo];
            if (!DICISOK(indexDic)) continue;
            
            //7. cutIndex在fromRegroup时为-1,全未发生 (旧代码一直如此,未知原因);
            //说明: cutIndex指已发生到的index,后面则为时序预测; matchValue指匹配度(0-1)
            NSInteger cutIndex = fromRegroup ? -1 : [AINetUtils getCutIndexByIndexDic:indexDic];
            
            //7. 根据indexDic取nearCount & sumNear;
            NSArray *nearData = [AINetUtils getNearDataByIndexDic:indexDic absFo:assFo_p conFo:protoOrRegroupFo.pointer callerIsAbs:false];
            int nearCount = NUMTOOK(ARR_INDEX(nearData, 0)).intValue;
            CGFloat sumNear = NUMTOOK(ARR_INDEX(nearData, 1)).floatValue;
            AddTCDebug(@"时序识别24");
            
            //7. 实例化识别结果AIMatchFoModel;
            AIMatchFoModel *newMatchFo = [AIMatchFoModel newWithMatchFo:assFo.pointer protoOrRegroupFo:protoOrRegroupFo.pointer sumNear:sumNear nearCount:nearCount indexDic:indexDic cutIndex:cutIndex];
            if (Log4MFo) NSLog(@"时序识别itemSUCCESS 匹配度:%f %@->%@",newMatchFo.matchFoValue,Fo2FStr(assFo),Mvp2Str(assFo.cmvNode_p));
            AddTCDebug(@"时序识别25");
            
            //8. 被引用强度;
            AIPort *newMatchFoFromPort = [AINetUtils findPort:assFo_p fromPorts:assFoPorts];
            newMatchFo.matchFoStrong = newMatchFoFromPort ? newMatchFoFromPort.strong.value : 0;
            AddTCDebug(@"时序识别26");
            
            //9. 收集到pFos/rFos;
            if (assFo.cmvNode_p) {
                [inModel.matchPFos addObject:newMatchFo];
            }else{
                [inModel.matchRFos addObject:newMatchFo];
            }
            AddTCDebug(@"时序识别27");
        }
    }
    AddTCDebug(@"时序识别28");
    
    //10. 按照 (强度x匹配度) 排序,强度最重要,包含了价值初始和使用频率,其次匹配度也重要 (参考23222-BUG2);
    NSArray *sortPFos = [SMGUtils sortBig2Small:inModel.matchPFos compareBlock:^double(AIMatchFoModel *obj) {
        return obj.matchFoValue;
    }];
    AddTCDebug(@"时序识别29");
    NSArray *sortRFos = [SMGUtils sortBig2Small:inModel.matchRFos compareBlock:^double(AIMatchFoModel *obj) {
        return obj.matchFoValue;
    }];
    AddTCDebug(@"时序识别30");
    
    //11. 仅保留前NarrowLimit条;
    inModel.matchPFos = [[NSMutableArray alloc] initWithArray:ARR_SUB(sortPFos, 0, cFoNarrowLimit)];
    inModel.matchRFos = [[NSMutableArray alloc] initWithArray:ARR_SUB(sortRFos, 0, cFoNarrowLimit)];
    AddTCDebug(@"时序识别31");
    
    //11. 调试日志;
    NSLog(@"\n=====> 时序识别Finish (PFos数:%lu)",(unsigned long)inModel.matchPFos.count);
    for (AIMatchFoModel *item in inModel.matchPFos) {
        AIFoNodeBase *matchFo = [SMGUtils searchNode:item.matchFo];
        NSLog(@"强度:(%ld)\t> %@->%@ (from:%@)",item.matchFoStrong,Fo2FStr(matchFo), Mvp2Str(matchFo.cmvNode_p),CLEANSTR(matchFo.spDic));
    }
        
    NSLog(@"\n=====> 时序识别Finish (RFos数:%lu)",(unsigned long)inModel.matchRFos.count);
    for (AIMatchFoModel *item in inModel.matchRFos){
        AIFoNodeBase *matchFo = [SMGUtils searchNode:item.matchFo];
        NSLog(@"强度:(%ld)\t> %@ (from:%@)",item.matchFoStrong,Pit2FStr(item.matchFo),CLEANSTR(matchFo.spDic));
    }
    AddTCDebug(@"时序识别32");
    
    //12. 关联处理,直接protoFo抽象指向matchFo,并持久化indexDic (参考27177-todo6);
    for (AIMatchFoModel *item in inModel.matchPFos) {
        //4. 识别到时,refPorts -> 更新/加强微信息的引用序列
        AIFoNodeBase *matchFo = [SMGUtils searchNode:item.matchFo];
        [AINetUtils insertRefPorts_AllFoNode:item.matchFo order_ps:matchFo.content_ps ps:matchFo.content_ps];
        
        //5. 存储matchFo与protoFo之间的indexDic映射 (参考27177-todo5);
        [protoOrRegroupFo updateIndexDic:matchFo indexDic:item.indexDic2];
        
        //6. 对proto直接抽象指向matchAlg,并增强强度值 (为保证抽象多样性,所以相近的也抽具象关联) (参考27153-3);
        [AINetUtils relateFoAbs:matchFo conNodes:@[protoOrRegroupFo] isNew:false];
    }
}

/**
 *  MARK:--------------------时序识别之: protoFo&assFo匹配判断--------------------
 *  要求: protoFo必须全含assFo对应的last匹配下标之前的所有元素,即:
 *       1. proto的末帧,必须在assFo中找到 (并记录找到的assIndex为cutIndex截点);
 *       2. assFo在cutIndex截点前的部分,必须在protoFo中找到 (找到即全含,否则为整体失败);
 *  例如: 如: protFo:[abcde] 全含 assFo:[acefg]
 *  名词说明:
 *      1. 全含: 指从lastAssIndex向前,所有的assItemAlg都匹配成功;
 *      2. 非全含: 指从lastAssIndex向前,只要有一个assItemAlg匹配失败,则非全含;
 *  _param outOfFos : 用于计算衰减值; (未知何时已废弃)
 *  @version
 *      2022.04.30: 将每帧的matchAlgs和partAlgs用于全含判断,而不是单纯用protoFo来判断 (参考25234-6);
 *      2022.05.23: 反思时,改回旧有mIsC判断方式 (参考26096-BUG6);
 *      2022.05.25: 将衰后稳定性计算集成到全含判断方法中 (这样性能好些);
 *      2022.06.08: 稳定性低的不过滤了,因为学时统计,不关稳定性(概率)的事儿 (参考26222-TODO1);
 *      2022.06.08: 排序公式改为sumNear / nearCount (参考26222-TODO1);
 *      2022.09.15: 修复indexDic收集的KV反了的BUG (与pFo.indexDic的定义不符);
 *      2022.11.10: 复用alg相似度,且原本比对相似度的性能问题自然也ok了 (参考27175-5);
 *      2022.11.11: 全改回用mIsC判断,因为等效 (matchAlgs全是protoAlg的抽象,且mIsC是有缓存的,无性能问题),且全用mIsC后代码更精简;
 *      2022.11.11: 将找末位,和找全含两个部分,合而为一,使算法代码更精简易读 (参考27175-7);
 *      2022.11.11: BUG_indexDic中有重复的Value (一个protoA对应多个assA): 将nextMaxForProtoIndex改为protoIndex-1后ok (参考27175-8);
 *      2022.11.13: 迭代V2: 仅返回indexDic (参考27177);
 *  @result 判断protoFo是否全含assFo: 成功时返回indexDic / 失败时返回空dic;
 */
+(NSDictionary*) TIR_Fo_CheckFoValidMatchV2:(AIFoNodeBase*)assFo protoOrRegroupFo:(AIFoNodeBase*)protoOrRegroupFo{
    AddTCDebug(@"时序识别10");
    if (Log4MFo) NSLog(@"------------------------ 时序全含检查 ------------------------\nass:%@->%@",Fo2FStr(assFo),Mvp2Str(assFo.cmvNode_p));
    //1. 数据准备;
    NSMutableDictionary *indexDic = [[NSMutableDictionary alloc] init]; //记录protoIndex和assIndex的映射字典 <K:assIndex, V:protoIndex>;
    AddTCDebug(@"时序识别11");
    
    //3. 用于找着时:记录下进度,下次循环时,这个进度已处理过的不再处理;
    NSInteger nextMaxForProtoIndex = protoOrRegroupFo.count - 1;
    
    //4. 从后向前倒着一帧帧,找assFo的元素,要求如下:
    for (NSInteger assIndex = assFo.count - 1; assIndex >= 0; assIndex--) {
        AIKVPointer *assAlg_p = ARR_INDEX(assFo.content_ps, assIndex);
        BOOL itemSuccess = false;
        for (NSInteger protoIndex = nextMaxForProtoIndex; protoIndex >= 0; protoIndex--) {
            
            //5. mIsC判断匹配;
            AIKVPointer *protoAlg_p = ARR_INDEX(protoOrRegroupFo.content_ps, protoIndex);
            BOOL mIsC = [TOUtils mIsC_1:protoAlg_p c:assAlg_p];
            AddTCDebug(@"时序识别13");
            if (mIsC) {
                
                //7. 匹配时_记录下次循环proto时,从哪帧开始倒序循环: nextMaxForProtoIndex进度
                nextMaxForProtoIndex = protoIndex - 1;
                
                //8. 匹配时_记录本条成功标记;
                itemSuccess = true;
                
                //9. 匹配时_记录indexDic映射
                [indexDic setObject:@(protoIndex) forKey:@(assIndex)];
                if (Log4MFo)NSLog(@"时序识别: item有效+1");
                break;
            } else {
                //11. proto的末帧必须找到,所以不匹配时,直接break,继续ass循环找它... (参考: 注释要求1);
                if (protoIndex == protoOrRegroupFo.count - 1) break;
            }
            AddTCDebug(@"时序识别16");
        }
        
        //12. 非全含 (一个失败,全盘皆输);
        if (!itemSuccess) {
            if (Log4MFo) NSLog(@"末帧时,找不着则联想时就:有BUG === 非末帧时,则ass未在proto中找到:非全含");
            return [NSMutableDictionary new];
        }
    }
    AddTCDebug(@"时序识别17");
    
    //13. 到此全含成功: 返回success
    return indexDic;
}

/**
 *  MARK:--------------------获取某帧shortModel的matchAlgs+partAlgs--------------------
 */
+(NSArray*) getMatchAndPartAlgPsByModel:(AIShortMatchModel*)frameModel {
    NSArray *matchAlg_ps = [SMGUtils convertArr:frameModel.matchAlgs convertBlock:^id(AIMatchAlgModel *o) {
        return o.matchAlg;
    }];
    return [SMGUtils collectArrA:matchAlg_ps arrB:Nodes2Pits(frameModel.partAlgs)];
}

/**
 *  MARK:--------------------获取某帧Index的matchAlgs+partAlgs--------------------
 *  @status 废弃状态 (如果2023.10之前未用,则删除);
 */
+(NSArray*) getMatchAndPartAlgPs:(NSInteger)frameIndex {
    AIShortMatchModel *inModel = [theTC.inModelManager getFrameModel:frameIndex];
    return [self getMatchAndPartAlgPsByModel:inModel];
}

@end
