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
    [self partMatching_Alg:protoAlg isMem:false except_ps:except_ps inModel:inModel];
    
    //5. 关联处理 & 外类比 (这样后面TOR理性决策时,才可以直接对当前瞬时实物进行很好的理性评价) (参考21091-蓝线);
    for (AIAlgNodeBase *matchAlg in inModel.matchAlgs) {
        //4. 识别到时,value.refPorts -> 更新/加强微信息的引用序列
        [AINetUtils insertRefPorts_AllAlgNode:matchAlg.pointer content_ps:matchAlg.content_ps difStrong:1];
        
        //5. 识别且全含时,进行外类比 (参考25105);
        //[AIAnalogy analogyAlg:protoAlg algB:matchAlg];
    }
    
    //6. 关联处理_对seem和proto进行类比抽象 (参考21091-绿线);
    if (ARRISOK(inModel.partAlgs)) {
        NSLog(@"对局部匹配首条构建TopAbs抽象");
        AIAlgNodeBase *firstPartAlg = ARR_INDEX(inModel.partAlgs, 0);
        AIAlgNodeBase *firstMatchAlg = ARR_INDEX(inModel.matchAlgs, 0);
        AIAlgNodeBase *seemProtoAbs = [AIAnalogy analogyAlg:protoAlg algB:firstPartAlg];
        
        //7. 关联处理_对seemProtoAbs与matchAlg建立抽具象关联 (参考21091-黄线);
        if (seemProtoAbs && firstMatchAlg) {
            [AIAnalogy analogyAlg:seemProtoAbs algB:firstMatchAlg];
        }
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
 */
+(void) partMatching_Alg:(AIAlgNodeBase*)protoAlg isMem:(BOOL)isMem except_ps:(NSArray*)except_ps inModel:(AIShortMatchModel*)inModel{
    //1. 数据准备;
    if (!ISOK(protoAlg, AIAlgNodeBase.class)) return;
    except_ps = ARRTOOK(except_ps);                                 //不应期
    NSMutableArray *matchAlgs = [[NSMutableArray alloc] init];      //用来收集全含匹配结果;
    NSMutableArray *partAlgs = [[NSMutableArray alloc] init];       //用来收集局部匹配结果;
    NSMutableDictionary *countDic = [NSMutableDictionary new];      //匹配度计数字典 <K:refAlg_p,V:matchCount>;
    NSMutableDictionary *recordDic = [NSMutableDictionary new];     //pit不能做key,所以存这字典里 <K:pId,V:pit>
    NSMutableDictionary *sumNearVDic = [NSMutableDictionary new];   //相近度字典 <K:refAlg_p,V:sum(nearV)> (参考25082-公式2分子部分);
    NSMutableDictionary *sumStrongDic = [NSMutableDictionary new];  //总强度字典<K:refAPId,V:sum(strong)>;
    
    //2. 广入: 对每个元素,分别取索引序列 (参考25083-1);
    for (AIKVPointer *item_p in protoAlg.content_ps) {
        
        //3. 取相近度序列 (按相近程度排序);
        NSArray *near_ps = [self TIR_Value:item_p];
        
        //4. 每个near_p做两件事:
        for (AIKVPointer *near_p in near_ps) {
            
            //5. 第1_计算出nearV (参考25082-公式1);
            double nearV = [TOUtils compareCansetValue:near_p protoValue:item_p];
            
            //6. 第2_取near_p的refPorts (参考25083-1);
            NSArray *refPorts = [SMGUtils filterPorts_Normal:[AINetUtils refPorts_All4Value:near_p isMem:isMem]];
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
                
                //9. 第1_统计匹配度;
                //NSData *key = OBJ2DATA(refPort.target_p);
                NSNumber *key = @(refPort.target_p.pointerId);
                int oldCount = [NUMTOOK([countDic objectForKey:key]) intValue];
                [countDic setObject:@(oldCount + 1) forKey:key];
                
                //10. 第2_统计相近度;
                double oldSumNearV = [NUMTOOK([sumNearVDic objectForKey:key]) doubleValue];
                [sumNearVDic setObject:@(oldSumNearV + nearV) forKey:key];
                
                //10. 记录引用强度;
                int oldSumStrong = [NUMTOOK([sumStrongDic objectForKey:key]) intValue];
                [sumStrongDic setObject:@(oldSumStrong + refPort.strong.value) forKey:key];
                
                //11. 将指针存记录着后面用;
                [recordDic setObject:refPort.target_p forKey:key];
            }
        }
        if (Log4MAlg) if (countDic.count) NSLog(@"计数字典匹配情况: %@ ------",countDic.allValues);
    }
    
    //11. 按nearA排序 (参考25083-2&公式2 & 25084-1);
    NSArray *sortKeys = [SMGUtils sortBig2Small:countDic.allKeys compareBlock:^double(NSNumber *obj) {
        double sumNear = [NUMTOOK([sumNearVDic objectForKey:obj]) doubleValue];
        int count = [NUMTOOK([countDic objectForKey:obj]) intValue];
        return sumNear / count;
    }];
    
    //13. 仅保留最相近的20条 (参考25083-3);
    sortKeys = ARR_SUB(sortKeys, 0, cAlgNarrowLimit(protoAlg.count));
    
    //14. 全含或局部匹配判断: 从大到小,依次取到对应的node和matchingCount (注: 支持相近后,应该全是全含了,参考25084-1);
    for (NSNumber *key in sortKeys) {
        //14. 过滤掉匹配度<85%的;
        double matchV = [NUMTOOK([sumNearVDic objectForKey:key]) doubleValue] / [NUMTOOK([countDic objectForKey:key]) intValue];
        if (matchV < 0.90f) {
            continue;
        }
        
        //15. 判断全含 & 收集;
        //AIKVPointer *key_p = DATA2OBJ(key);
        AIKVPointer *key_p = [recordDic objectForKey:key];
        AIAlgNodeBase *result = [SMGUtils searchNode:key_p];
        //if (result.content_ps.count == [NUMTOOK([countDic objectForKey:key]) intValue]) {
        [matchAlgs addObject:result];
        //}else{ //[partAlgs addObject:result]; }
    }
    
    //16. 未将全含返回,则返回最相似 (2020.10.22: 全含返回,也要返回seemAlg) (2022.01.15: 支持相近匹配后,全是全含没局部了);
    NSLog(@"\n识别结果 >> 总数:%ld = 全含匹配数:%ld + 局部匹配数:%ld",sortKeys.count,matchAlgs.count,partAlgs.count);
    for (AIAlgNodeBase *item in matchAlgs) {
        //id key = OBJ2DATA(item.pointer);
        id key = @(item.pointer.pointerId);
        int sumStrong = [NUMTOOK([sumStrongDic objectForKey:key]) intValue];
        double sumNear = [NUMTOOK([sumNearVDic objectForKey:key]) doubleValue];
        int matchCount = [NUMTOOK([countDic objectForKey:key]) intValue];
        NSLog(@"-->>>(%d) 全含item: %@   \t相近度 => %.2f (count:%d)",sumStrong,Alg2FStr(item),sumNear / matchCount,matchCount);
    }
    for (AIAlgNodeBase *item in partAlgs) NSLog(@"-->>> 局部item: %@",Alg2FStr(item));
    inModel.matchAlgs = matchAlgs;
    inModel.partAlgs = partAlgs;
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
 *  @param maskFo           : 识别时:protoFo中的概念元素为parent层, 而在反思时,其元素为match层;
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
 *  @status 废弃,因为countDic排序的方式,不利于找出更确切的抽象结果 (识别不怕丢失细节,就怕不确切,不全含);
 */
+(void) partMatching_FoV1Dot5:(AIFoNodeBase*)maskFo except_ps:(NSArray*)except_ps decoratorInModel:(AIShortMatchModel*)inModel fromRegroup:(BOOL)fromRegroup{
    //1. 数据准备
    if (!ISOK(maskFo, AIFoNodeBase.class)) {
        return;
    }
    AIAlgNodeBase *lastAlg = [SMGUtils searchNode:ARR_INDEX_REVERSE(maskFo.content_ps, 0)];
    if (!lastAlg) {
        return;
    }
    
    //2. 取assIndexes (反思时: 取本身+抽象一层; 识别时: 取proto+matchs+parts);
    NSMutableArray *assIndexes = [[NSMutableArray alloc] init];
    if (fromRegroup) {
        [assIndexes addObject:lastAlg.pointer];
        [assIndexes addObjectsFromArray:Ports2Pits([AINetUtils absPorts_All_Normal:lastAlg])];
    }else{
        [assIndexes addObject:inModel.protoAlg.pointer];
        [assIndexes addObjectsFromArray:Nodes2Pits(inModel.matchAlgs)];
        [assIndexes addObjectsFromArray:Nodes2Pits(inModel.partAlgs)];
    }
    
    //3. 递归进行assFos
    if (Log4MFo) NSLog(@"------------ TIR_Fo ------------索引数:%lu",(unsigned long)assIndexes.count);
    for (AIKVPointer *assIndex_p in assIndexes) {
        AIAlgNodeBase *indexAlg = [SMGUtils searchNode:assIndex_p];
        
        //4. indexAlg.refPorts; (取识别到过的抽象节点(如苹果));
        NSArray *refFoPorts = [AINetUtils refPorts_All4Alg_Normal:indexAlg];//b. 仅Normal
        
        //6. 无mv指向的仅保留两条 (参考26022-3);
        __block int rCount = 0;
        refFoPorts = [SMGUtils filterArr:refFoPorts checkValid:^BOOL(AIPort *item) {
            if (!item.targetHavMv && ++rCount > cRFoNarrowLimit) {
                return false;
            }
            return true;
        }];
        
        NSArray *assFo_ps = Ports2Pits(refFoPorts);
        assFo_ps = [SMGUtils removeSub_ps:except_ps parent_ps:assFo_ps];
        if (Log4MFo) NSLog(@"\n-----> TIR_Fo 索引:%@ 指向有效时序数:%lu",Alg2FStr(indexAlg),(unsigned long)assFo_ps.count);
        
        //5. 依次对assFos对应的时序,做匹配度评价; (参考: 160_TIRFO单线顺序模型)
        for (AIKVPointer *assFo_p in assFo_ps) {
            AIFoNodeBase *assFo = [SMGUtils searchNode:assFo_p];
            
            //5. 虚mv,无效;
            if (assFo.cmvNode_p && [AINetUtils isVirtualMv:assFo.cmvNode_p]) continue;
            
            //6. 防重;
            BOOL pContains = ARRISOK([SMGUtils filterArr:inModel.matchPFos checkValid:^BOOL(AIMatchFoModel *item) {
                return [item.matchFo isEqual:assFo.pointer];
            }]);
            if (pContains) continue;
            
            BOOL rContains = ARRISOK([SMGUtils filterArr:inModel.matchRFos checkValid:^BOOL(AIMatchFoModel *item) {
                return [item.matchFo isEqual:assFo.pointer];
            }]);
            if (rContains) continue;
            
            //7. 全含判断;
            AIFoNodeBase *regroupFo = fromRegroup ? maskFo : nil;
            [self TIR_Fo_CheckFoValidMatch:assFo outOfFos:assFo_ps success:^(NSInteger lastAssIndex, CGFloat matchValue,CGFloat colStableScore) {
                if (Log4MFo) NSLog(@"时序识别item SUCCESS 完成度:%f %@->%@",matchValue,Fo2FStr(assFo),Mvp2Str(assFo.cmvNode_p));
                NSInteger cutIndex = fromRegroup ? -1 : lastAssIndex;
                AIMatchFoModel *newMatchFo = [AIMatchFoModel newWithMatchFo:assFo.pointer matchFoValue:matchValue colStableScore:colStableScore lastMatchIndex:lastAssIndex cutIndex:cutIndex];
                
                //8. 被引用强度;
                AIPort *newMatchFoFromPort = [AINetUtils findPort:assFo_p fromPorts:refFoPorts];
                newMatchFo.matchFoStrong = newMatchFoFromPort ? newMatchFoFromPort.strong.value : 0;
                
                //9. 收集到pFos/rFos;
                if (assFo.cmvNode_p) {
                    [inModel.matchPFos addObject:newMatchFo];
                }else{
                    [inModel.matchRFos addObject:newMatchFo];
                }
            } regroupFo:regroupFo];
        }
    }
    
    //10. 按照 (强度x匹配度) 排序,强度最重要,包含了价值初始和使用频率,其次匹配度也重要 (参考23222-BUG2);
    NSArray *sortPFos = [SMGUtils sortBig2Small:inModel.matchPFos compareBlock:^double(AIMatchFoModel *obj) {
        return obj.colStableScore;
    }];
    NSArray *sortRFos = [SMGUtils sortBig2Small:inModel.matchRFos compareBlock:^double(AIMatchFoModel *obj) {
        return obj.colStableScore;
    }];
    
    //11. 仅保留前NarrowLimit条;
    inModel.matchPFos = [[NSMutableArray alloc] initWithArray:ARR_SUB(sortPFos, 0, cFoNarrowLimit)];
    inModel.matchRFos = [[NSMutableArray alloc] initWithArray:ARR_SUB(sortRFos, 0, cFoNarrowLimit)];
    
    //11. 调试日志;
    NSLog(@"\n=====> 时序识别Finish (PFos数:%lu)",(unsigned long)inModel.matchPFos.count);
    for (AIMatchFoModel *item in inModel.matchPFos) {
        AIFoNodeBase *matchFo = [SMGUtils searchNode:item.matchFo];
        NSLog(@"强度:(%ld)\t> %@->%@ (衰后稳定性:%.2f from:%@)",item.matchFoStrong,Fo2FStr(matchFo), Mvp2Str(matchFo.cmvNode_p),item.colStableScore,CLEANSTR(matchFo.spDic));
    }
        
    NSLog(@"\n=====> 时序识别Finish (RFos数:%lu)",(unsigned long)inModel.matchRFos.count);
    for (AIMatchFoModel *item in inModel.matchRFos){
        AIFoNodeBase *matchFo = [SMGUtils searchNode:item.matchFo];
        NSLog(@"强度:(%ld)\t> %@ (衰后稳定性:%.2f from:%@)",item.matchFoStrong,Pit2FStr(item.matchFo),item.colStableScore,CLEANSTR(matchFo.spDic));
    }
}

/**
 *  MARK:--------------------时序识别之: protoFo&assFo匹配判断--------------------
 *  要求: protoFo必须全含assFo对应的last匹配下标之前的所有元素;
 *  例如: 如: protFo:[abcde] 全含 assFo:[acefg]
 *  名词说明:
 *      1. 全含: 指从lastAssIndex向前,所有的assItemAlg都匹配成功;
 *      2. 非全含: 指从lastAssIndex向前,只要有一个assItemAlg匹配失败,则非全含;
 *  @param success  : lastAssIndex指已发生到的index,后面则为时序预测; matchValue指匹配度(0-1) notnull;
 *  @param outOfFos : 用于计算衰减值;
 *  @version
 *      2022.04.30: 将每帧的matchAlgs和partAlgs用于全含判断,而不是单纯用protoFo来判断 (参考25234-6);
 *      2022.05.23: 反思时,改回旧有mIsC判断方式 (参考26096-BUG6);
 *      2022.05.25: 将衰后稳定性计算集成到全含判断方法中 (这样性能好些);
 *  _result 将protoFo与assFo判断是否全含,并将匹配度返回;
 */
+(void) TIR_Fo_CheckFoValidMatch:(AIFoNodeBase*)assFo outOfFos:(NSArray*)outOfFos success:(void(^)(NSInteger lastAssIndex,CGFloat matchValue,CGFloat colStableScore))success regroupFo:(AIFoNodeBase*)regroupFo{
    //1. 数据准备;
    BOOL paramValid = assFo && assFo.content_ps.count > 0 && success;
    if (!paramValid) {
        NSLog(@"参数错误");
        return;
    }
    if (Log4MFo) NSLog(@"------------------------ 时序全含检查 ------------------------\nass:%@->%@",Fo2FStr(assFo),Mvp2Str(assFo.cmvNode_p));
    
    //1. 默认有效数为1 (因为lastAlg肯定有效);
    int validItemCount = 1;
    //1. 在assFo已发生到的index,后面为预测;
    NSInteger lastAssIndex = -1;
    
    //2. 找出lastIndex
    for (NSInteger i = 0; i < assFo.content_ps.count; i++) {
        NSInteger curIndex = assFo.content_ps.count - i - 1;
        AIKVPointer *checkAssAlg_p = ARR_INDEX(assFo.content_ps, curIndex);
        
        //2. 匹配判断: 反思时用mIsC判断 & 识别时用瞬时末帧matchAlgs+partAlgs包含来判断;
        BOOL mIsC = false;
        if (regroupFo) {
            AIKVPointer *reoupAlg_p = ARR_INDEX_REVERSE(regroupFo.content_ps, 0);
            mIsC = [TOUtils mIsC_1:reoupAlg_p c:checkAssAlg_p];
        }else{
            NSArray *lastAlgs = [self getMatchAndPartAlgPs:theTC.inModelManager.models.count - 1];
            mIsC = [lastAlgs containsObject:checkAssAlg_p];
        }
        
        //2. 匹配则记录lastAssIndex值;
        if (mIsC) {
            lastAssIndex = curIndex;
            break;
        }
    }
    if (lastAssIndex == -1) {
        NSLog(@"时序识别: lastItem匹配失败,查看是否在联想时就出bug了");
        return;
    }
    
    //3. 稳定性<0.4的过滤掉;
    NSInteger cutIndex = regroupFo ? -1 : lastAssIndex;
    CGFloat colStableScore = [TOUtils getColStableScore:assFo outOfFos:outOfFos startSPIndex:cutIndex + 1 endSPIndex:assFo.count];
    CGFloat needScore = assFo.cmvNode_p ? 0.1f : 0.4f;
    if (colStableScore < needScore) {
        return;
    }
    
    //3. 从lastAssIndex向前逐个匹配;
    if (Log4MFo)NSLog(@"--->>>>> 在%ld位,找到LastItem匹配",lastAssIndex);
    for (NSInteger i = lastAssIndex - 1; i >= 0; i--) {
        AIKVPointer *checkAssAlg_p = ARR_INDEX(assFo.content_ps, i);
        if (checkAssAlg_p) {
            
            //4. 在protoFo中同样从lastProtoIndex依次向前找匹配 (从倒数第二个开始);
            BOOL checkResult = false;
            NSInteger lastProtoIndex = (regroupFo ? regroupFo.count : theTC.inModelManager.models.count) - 2;
            for (NSInteger j = lastProtoIndex; j >= 0; j--) {
                //2. 匹配判断: 反思时用mIsC判断 & 识别时用瞬时末帧matchAlgs+partAlgs包含来判断;
                BOOL mIsC = false;
                if (regroupFo) {
                    AIKVPointer *reoupAlg_p = ARR_INDEX(regroupFo.content_ps, j);
                    mIsC = [TOUtils mIsC_1:reoupAlg_p c:checkAssAlg_p];
                }else{
                    NSArray *frameAlgs = [self getMatchAndPartAlgPs:j];
                    mIsC = [frameAlgs containsObject:checkAssAlg_p];
                }
                
                //2. 匹配时处理;
                if (mIsC) {
                    lastProtoIndex = j; //成功匹配alg时,更新protoIndex (以达到只能向前匹配的目的);
                    checkResult = true;
                    validItemCount ++;  //有效数+1;
                    if (Log4MFo)NSLog(@"时序识别: item有效+1");
                    break;
                }else{
                    if (Log4MFo)NSLog(@"---->匹配失败:\n%@",AlgP2FStr(checkAssAlg_p));
                }
            }
            
            //5. 非全含 (一个失败,全盘皆输);
            if (!checkResult) {
                if (Log4MFo) NSLog(@"时序识别: item无效,未在protoFo中找到,所有非全含,不匹配");
                return;
            }
        }
    }
    
    //6. 到此全含成功 之: 匹配度计算
    CGFloat matchValue = (float)validItemCount / assFo.content_ps.count;
    
    //7. 到此全含成功 之: 返回success
    success(lastAssIndex,matchValue,colStableScore);
}

/**
 *  MARK:--------------------获取某帧shortModel的matchAlgs+partAlgs--------------------
 */
+(NSArray*) getMatchAndPartAlgPs:(NSInteger)frameIndex {
    NSArray *inModels = theTC.inModelManager.models;
    AIShortMatchModel *inModel = ARR_INDEX(inModels, frameIndex);
    return [self getMatchAndPartAlgPsByModel:inModel];
}
+(NSArray*) getMatchAndPartAlgPsByModel:(AIShortMatchModel*)frameModel {
    NSArray *algs = [SMGUtils collectArrA:frameModel.matchAlgs arrB:frameModel.partAlgs];
    NSArray *result = Nodes2Pits(algs);
    return result;
}

@end
