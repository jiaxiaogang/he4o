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
//MARK:                     < 概念识别 >
//MARK:===============================================================

/**
 *  MARK:--------------------识别是什么(这是西瓜)--------------------
 *  @param fromGroup_ps : 当前输入批次的整组概念指针;
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
 *  @param complete : 共支持三种返回: 匹配效果从高到低分别为:fuzzyAlg废弃,matchAlg全含,seemAlg局部;
 */
+(void) TIR_Alg:(AIKVPointer*)algNode_p fromGroup_ps:(NSArray*)fromGroup_ps complete:(void(^)(NSArray *matchAlgs,NSArray *partAlg_ps))complete{
    //1. 数据准备
    AIAlgNodeBase *protoAlg = [SMGUtils searchNode:algNode_p];
    if (protoAlg == nil) return;
    IFTitleLog(@"概念识别",@"\n%@",Alg2FStr(protoAlg));
    
    //2. 对value.refPorts进行检查识别; (noMv信号已输入完毕,识别联想)
    __block NSMutableArray *matchAlgs = [[NSMutableArray alloc] init];
    __block NSArray *partAlg_ps = nil;
    ///1. 自身匹配 (Self匹配);
    if ([self inputAlgIsOld:protoAlg]) {
        [matchAlgs addObject:protoAlg];
    }
    
    ///3. 局部匹配 -> 内存网络;
    ///19xxxx注掉,不能太过于脱离持久网络做思考,所以先注掉;
    ///190625放开,因采用内存网络后,靠这识别;
    ///200116注掉,因为识别仅是建立抽象关联,此处会极易匹配到内存中大量的具象alg,导致无法建立关联,而在硬盘网络时,这种几率则低许多;
    //if (!assAlgNode) {
    //    assAlgNode = [AINetIndexUtils partMatching_Alg:algNode isMem:true except_ps:fromGroup_ps];
    //}
    
    ///4. 局部匹配 (Abs匹配 和 Seem匹配);
    [self partMatching_Alg:protoAlg isMem:false except_ps:fromGroup_ps complete:^(NSArray *_matchAlgs, NSArray *_partAlg_ps) {
        [matchAlgs addObjectsFromArray:_matchAlgs];
        partAlg_ps = _partAlg_ps;
    }];
    
    //5. 关联处理_直接将match设置为proto的抽象; (这样后面TOR理性决策时,才可以直接对当前瞬时实物进行很好的理性评价) (参考21091-蓝线);
    for (AIAlgNodeBase *matchAlg in matchAlgs) {
        //4. 识别到时,value.refPorts -> 更新/加强微信息的引用序列
        [AINetUtils insertRefPorts_AllAlgNode:matchAlg.pointer content_ps:matchAlg.content_ps difStrong:1];
        
        //5. 识别且全含时,进行抽具象关联 & 存储 (20200103:测得,algNode为内存节点时,关联也在内存)
        [AINetUtils relateAlgAbs:(AIAbsAlgNode*)matchAlg conNodes:@[protoAlg] isNew:false];
    }
    
    //6. 关联处理_对seem和proto进行类比抽象 (参考21091-绿线);
    if (ARRISOK(partAlg_ps)) {
        AIAlgNodeBase *firstPartAlg = [SMGUtils searchNode:ARR_INDEX(partAlg_ps, 0)];
        AIAlgNodeBase *firstMatchAlg = ARR_INDEX(matchAlgs, 0);
        NSArray *same_ps = [SMGUtils filterSame_ps:protoAlg.content_ps parent_ps:firstPartAlg.content_ps];
        AIAlgNodeBase *seemProtoAbs = [theNet createAbsAlg_NoRepeat:same_ps conAlgs:@[firstPartAlg,protoAlg] isMem:false at:nil type:ATDefault];
        NSLog(@"构建相似抽象:%@",Alg2FStr(seemProtoAbs));
        
        //7. 关联处理_对seemProtoAbs与matchAlg建立抽具象关联 (参考21091-黄线);
        if (seemProtoAbs && firstMatchAlg) {
            NSArray *same_ps = [SMGUtils filterSame_ps:seemProtoAbs.content_ps parent_ps:firstMatchAlg.content_ps];
            AIAlgNodeBase *topAbs = [theNet createAbsAlg_NoRepeat:same_ps conAlgs:@[seemProtoAbs,firstMatchAlg] isMem:false at:nil type:ATDefault];
            NSLog(@"构建TopAbs抽象:%@",Alg2FStr(topAbs));
        }
    }
    
    //3. 全含时,可进行模糊匹配 (Fuzzy匹配) //因TOR未支持fuzzy,故目前仅将最相似的fuzzy放到AIShortMatchModel中当matchAlg用;
    //if (matchType == MatchType_Abs) {
    //    NSArray *fuzzys = ARRTOOK([self matchAlg2FuzzyAlgV2:algNode matchAlg:assAlgNode except_ps:fromGroup_ps]);
    //    AIAlgNodeBase *fuzzyAlg = ARR_INDEX(fuzzys, 0);
    //    //a. 模糊匹配有效时,增强关联,并截胡;
    //    if (fuzzyAlg) {
    //        [AINetUtils insertRefPorts_AllAlgNode:fuzzyAlg.pointer content_ps:fuzzyAlg.content_ps difStrong:1];
    //        assAlgNode = fuzzyAlg;
    //        matchType = MatchType_Fuzzy;
    //    }
    //}
    
    //4. 调试日志
    NSLog(@"--->>> 概念识别Finish 全含:\n%@",Pits2FStr_MultiLine(Nodes2Pits(matchAlgs)));
    NSLog(@"--->>> 概念识别Finish 局部:\n%@",Pits2FStr_MultiLine(ARR_SUB(partAlg_ps, 0, 3)));
    complete(matchAlgs,partAlg_ps);
}

/**
 *  MARK:--------------------概念局部匹配--------------------
 *  注: 根据引用找出相似度最高且达到阀值的结果返回; (相似度匹配)
 *  从content_ps的所有value.refPorts找前cPartMatchingCheckRefPortsLimit个, 如:contentCount9*limit5=45个;
 *
 *  @param complete : 根据匹配度排序,并返回 (全含+局部);
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
 *      2020.11.18 - partAlg_ps将matchAlgs移除掉,仅保留非全含的部分;
 */
+(void) partMatching_Alg:(AIAlgNodeBase*)protoAlg isMem:(BOOL)isMem except_ps:(NSArray*)except_ps complete:(void(^)(NSArray *matchAlgs,NSArray *partAlg_ps))complete{
    //1. 数据准备;
    if (!ISOK(protoAlg, AIAlgNodeBase.class)) return;
    except_ps = ARRTOOK(except_ps);
    NSMutableArray *matchAlgs = [[NSMutableArray alloc] init];
    NSArray *partAlg_ps = nil;
    NSMutableDictionary *countDic = [[NSMutableDictionary alloc] init];
    
    //2. 对每个微信息,取被引用的强度前cPartMatchingCheckRefPortsLimit个;
    for (AIKVPointer *item_p in protoAlg.content_ps) {
        
        //1> 数据准备 (value_p的refPorts是单独存储的);
        NSArray *refPorts = [SMGUtils filterPorts_Normal:[AINetUtils refPorts_All4Value:item_p isMem:isMem]];
        refPorts = ARR_SUB(refPorts, 0, cPartMatchingCheckRefPortsLimit_Alg);
        if (Log4MAlg) NSLog(@"当前item_p:%@ -------------------数量:%lu",[NVHeUtil getLightStr:item_p],(unsigned long)refPorts.count);
        //3. 进行计数
        for (AIPort *refPort in refPorts) {
            
            //2> 自身 | 不应期 -> 不可激活;
            if ([refPort.target_p isEqual:protoAlg.pointer]) continue;
            if ([SMGUtils containsSub_p:refPort.target_p parent_ps:except_ps]) continue;
            
            //3> 计数;
            NSData *key = OBJ2DATA(refPort.target_p);
            int oldCount = [NUMTOOK([countDic objectForKey:key]) intValue];
            [countDic setObject:@(oldCount + 1) forKey:key];
        }
        if (Log4MAlg) if (countDic.count) NSLog(@"匹配情况: %@ -----------------",countDic.allValues);
    }
    
    //4. 排序相似数从大到小;
    NSArray *sortKeys = ARRTOOK([countDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        int matchingCount1 = [NUMTOOK([countDic objectForKey:obj1]) intValue];
        int matchingCount2 = [NUMTOOK([countDic objectForKey:obj2]) intValue];
        return matchingCount1 < matchingCount2;
    }]);
    
    //5. 从大到小,依次取到对应的node和matchingCount
    for (NSData *key in sortKeys) {
        AIKVPointer *key_p = DATA2OBJ(key);
        AIAlgNodeBase *result = [SMGUtils searchNode:key_p];
        int matchingCount = [NUMTOOK([countDic objectForKey:key]) intValue];
        
        //6. 判断全含; (matchingCount == assAlg.content.count) (且只能识别为抽象节点)
        if (ISOK(result, AIAbsAlgNode.class) && result.content_ps.count == matchingCount) {
            [matchAlgs addObject:result];
        }
    }
    
    //7. 未将全含返回,则返回最相似;
    //2020.10.22: 全含返回,也要返回seemAlg;
    partAlg_ps = DATAS2OBJS(sortKeys);
    partAlg_ps = [SMGUtils removeSub_ps:[SMGUtils convertPointersFromNodes:matchAlgs] parent_ps:partAlg_ps];
    if (Log4MAlg) NSLog(@"识别结果 >> 总数:%ld = 全含:%ld + 非全含数:%ld",sortKeys.count,matchAlgs.count,partAlg_ps.count);
    complete(matchAlgs,partAlg_ps);
}

//输入概念判断
+(BOOL) inputAlgIsOld:(AIAlgNodeBase*)inputAlg{
    if (inputAlg) {
        NSArray *refPorts = [AINetUtils refPorts_All4Alg:inputAlg];
        if (refPorts.count > 0) return true;
    }
    return false;
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
 *  @param findCutIndex     : 找出已发生部分的截点
 *                              1. fromTIM时,cutIndex=lastAssIndex;
 *                              2. fromRT时,cutIndex需从父任务中判断 (默认为-1);
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
 *  @status 废弃,因为countDic排序的方式,不利于找出更确切的抽象结果 (识别不怕丢失细节,就怕不确切,不全含);
 */
+(void) partMatching_FoV1Dot5:(AIFoNodeBase*)maskFo except_ps:(NSArray*)except_ps decoratorInModel:(AIShortMatchModel*)inModel findCutIndex:(NSInteger(^)(AIFoNodeBase *matchFo,NSInteger lastMatchIndex))findCutIndex{
    //1. 数据准备
    if (!ISOK(maskFo, AIFoNodeBase.class)) {
        return;
    }
    AIAlgNodeBase *lastAlg = [SMGUtils searchNode:ARR_INDEX_REVERSE(maskFo.content_ps, 0)];
    if (!lastAlg) {
        return;
    }
    
    //2. 取assIndexes (取递归两层)
    NSMutableArray *assIndexes = [[NSMutableArray alloc] init];
    [assIndexes addObject:lastAlg.pointer];
    [assIndexes addObjectsFromArray:[SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All_Normal:lastAlg]]];
    
    //3. 递归进行assFos
    if (Log4MFo) NSLog(@"------------ TIR_Fo ------------索引数:%lu",(unsigned long)assIndexes.count);
    for (AIKVPointer *assIndex_p in assIndexes) {
        AIAlgNodeBase *indexAlg = [SMGUtils searchNode:assIndex_p];
        
        //4. indexAlg.refPorts; (取识别到过的抽象节点(如苹果));
        //NSArray *refFoPorts = [AINetUtils refPorts_All4Alg:indexAlg];//a. Normal+HNGL_1
        //refFoPorts = [SMGUtils filterPorts:refFoPorts havTypes:nil noTypes:@[@(ATPlus),@(ATSub)]];//a. Normal+HNGL_2
        NSArray *refFoPorts = [AINetUtils refPorts_All4Alg_Normal:indexAlg];//b. 仅Normal
        
        NSArray *assFo_ps = Ports2Pits(refFoPorts);
        assFo_ps = [SMGUtils removeSub_ps:except_ps parent_ps:assFo_ps];
        assFo_ps = ARR_SUB(assFo_ps, 0, cPartMatchingCheckRefPortsLimit_Fo);
        if (Log4MFo) NSLog(@"\n-----> TIR_Fo 索引:%@ 指向有效时序数:%lu",Alg2FStr(indexAlg),(unsigned long)assFo_ps.count);
        
        //5. 依次对assFos对应的时序,做匹配度评价; (参考: 160_TIRFO单线顺序模型)
        for (AIKVPointer *assFo_p in assFo_ps) {
            AIFoNodeBase *assFo = [SMGUtils searchNode:assFo_p];
            
            //5. 虚mv,无效;
            if (assFo.cmvNode_p && [AINetUtils isVirtualMv:assFo.cmvNode_p]) continue;
            
            //6. 防重;
            BOOL pContains = ARRISOK([SMGUtils filterArr:inModel.matchPFos checkValid:^BOOL(AIMatchFoModel *item) {
                return [item.matchFo isEqual:assFo];
            }]);
            if (pContains) continue;
            
            BOOL rContains = ARRISOK([SMGUtils filterArr:inModel.matchRFos checkValid:^BOOL(AIMatchFoModel *item) {
                return [item.matchFo isEqual:assFo];
            }]);
            if (rContains) continue;
            
            //7. 全含判断;
            [self TIR_Fo_CheckFoValidMatch:maskFo assFo:assFo success:^(NSInteger lastAssIndex, CGFloat matchValue) {
                if (Log4MFo) NSLog(@"时序识别item SUCCESS 完成度:%f %@->%@",matchValue,Fo2FStr(assFo),Mvp2Str(assFo.cmvNode_p));
                NSInteger cutIndex = findCutIndex(assFo,lastAssIndex);
                AIMatchFoModel *newMatchFo = [AIMatchFoModel newWithMatchFo:assFo matchFoValue:matchValue lastMatchIndex:lastAssIndex cutIndex:cutIndex];
                
                //8. 被引用强度;
                AIPort *newMatchFoFromPort = [AINetUtils findPort:assFo_p fromPorts:refFoPorts];
                newMatchFo.matchFoStrong = newMatchFoFromPort ? newMatchFoFromPort.strong.value : 0;
                
                //9. 收集到pFos/rFos;
                if (assFo.cmvNode_p) {
                    [inModel.matchPFos addObject:newMatchFo];
                }else{
                    [inModel.matchRFos addObject:newMatchFo];
                }
            }];
        }
    }
    
    //10. 按照 (强度x匹配度) 排序,强度最重要,包含了价值初始和使用频率,其次匹配度也重要 (参考23222-BUG2);
    inModel.matchPFos = [[NSMutableArray alloc] initWithArray:[SMGUtils sortBig2Small:inModel.matchPFos compareBlock:^double(AIMatchFoModel *obj) {
        return obj.matchFoStrong * obj.matchFoValue;
    }]];
    inModel.matchRFos = [[NSMutableArray alloc] initWithArray:[SMGUtils sortBig2Small:inModel.matchRFos compareBlock:^double(AIMatchFoModel *obj) {
        return obj.matchFoStrong * obj.matchFoValue;
    }]];
    
    //11. 调试日志;
    NSLog(@"\n=====> 时序识别Finish (PFos数:%lu)",(unsigned long)inModel.matchPFos.count);
    for (AIMatchFoModel *item in inModel.matchPFos)
        NSLog(@"强度:(%ld)\t> %@->%@ (匹配度:%@)",item.matchFoStrong,Fo2FStr(item.matchFo), Mvp2Str(item.matchFo.cmvNode_p),Double2Str_NDZ(item.matchFoValue));
    NSLog(@"\n=====> 时序识别Finish (RFos数:%lu)",(unsigned long)inModel.matchRFos.count);
    for (AIMatchFoModel *item in inModel.matchRFos)
        NSLog(@"强度:(%ld)\t> %@ (匹配度:%@)",item.matchFoStrong,Fo2FStr(item.matchFo),Double2Str_NDZ(item.matchFoValue));
}


/**
 *  MARK:--------------------时序识别之: protoFo&assFo匹配判断--------------------
 *  要求: protoFo必须全含assFo对应的last匹配下标之前的所有元素;
 *  例如: 如: protFo:[abcde] 全含 assFo:[acefg]
 *  名词说明:
 *      1. 全含: 指从lastAssIndex向前,所有的assItemAlg都匹配成功;
 *      2. 非全含: 指从lastAssIndex向前,只要有一个assItemAlg匹配失败,则非全含;
 *  @param success : lastAssIndex指已发生到的index,后面则为时序预测; matchValue指匹配度(0-1);
 *  @param protoFo : 四层说明: 在fromShortMem时,protoFo中的概念元素为parent层, 而在fromRethink时,其元素为match层;
 *  _result 将protoFo与assFo判断是否全含,并将匹配度返回;
 */
+(void) TIR_Fo_CheckFoValidMatch:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo success:(void(^)(NSInteger lastAssIndex,CGFloat matchValue))success{
    //1. 数据准备;
    BOOL paramValid = protoFo && protoFo.content_ps.count > 0 && assFo && assFo.content_ps.count > 0 && success;
    if (!paramValid) {
        NSLog(@"参数错误");
        return;
    }
    if (Log4MFo) NSLog(@"------------------------ 时序全含检查 ------------------------\nproto:%@->%@\nass:%@->%@",Fo2FStr(protoFo),Mvp2Str(protoFo.cmvNode_p),Fo2FStr(assFo),Mvp2Str(assFo.cmvNode_p));
    AIKVPointer *lastProtoAlg_p = ARR_INDEX_REVERSE(protoFo.content_ps, 0); //最后一个protoAlg指针
    int validItemCount = 1;                                                 //默认有效数为1 (因为lastAlg肯定有效);
    NSInteger lastAssIndex = -1;                                            //在assFo已发生到的index,后面为预测;
    NSInteger lastProtoIndex = protoFo.content_ps.count - 2;                //protoAlg匹配判断从倒数第二个开始,向前逐个匹配;
    
    //2. 找出lastIndex
    for (NSInteger i = 0; i < assFo.content_ps.count; i++) {
        NSInteger curIndex = assFo.content_ps.count - i - 1;
        AIKVPointer *checkAssAlg_p = ARR_INDEX(assFo.content_ps, curIndex);
        BOOL mIsC = [TOUtils mIsC_1:lastProtoAlg_p c:checkAssAlg_p];
        if (mIsC) {
            lastAssIndex = curIndex;
            break;
        }
    }
    if (lastAssIndex == -1) {
        NSLog(@"时序识别: lastItem匹配失败,查看是否在联想时就出bug了");
        return;
    }
    
    //3. 从lastAssIndex向前逐个匹配;
    if (Log4MFo)NSLog(@"--->>>>> 在%ld位,找到LastItem匹配",lastAssIndex);
    for (NSInteger i = lastAssIndex - 1; i >= 0; i--) {
        AIKVPointer *checkAssAlg_p = ARR_INDEX(assFo.content_ps, i);
        if (checkAssAlg_p) {
            
            //4. 在protoFo中同样从lastProtoIndex依次向前找匹配;
            BOOL checkResult = false;
            for (NSInteger j = lastProtoIndex; j >= 0; j--) {
                AIKVPointer *protoAlg_p = ARR_INDEX(protoFo.content_ps, j);
                BOOL mIsC = [TOUtils mIsC_1:protoAlg_p c:checkAssAlg_p];
                if (mIsC) {
                    lastProtoIndex = j; //成功匹配alg时,更新protoIndex (以达到只能向前匹配的目的);
                    checkResult = true;
                    validItemCount ++;  //有效数+1;
                    if (Log4MFo)NSLog(@"时序识别: item有效+1");
                    break;
                }else{
                    if (Log4MFo)NSLog(@"---->匹配失败:\n%@\n%@",AlgP2FStr(lastProtoAlg_p),AlgP2FStr(checkAssAlg_p));
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
    success(lastAssIndex,matchValue);
}

@end
