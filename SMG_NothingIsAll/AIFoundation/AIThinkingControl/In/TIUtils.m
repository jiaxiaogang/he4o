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
 *      xxxx.xx.xx: 返回limit不能太小,不然概念识别时,没交集了 (参考26075);
 *      2022.05.23: 初版,排序和限制limit条数放到此处,原来getIndex_ps()方法里并没有相近度排序 (参考26096-BUG5);
 *      2022.05.23: 废弃掉不超过10%的条件,因为它会导致过窄问题 (参考26096-BUG3-方案1);
 *      2023.01.31: 返回limit改成20%条目 (参考28042-思路2-1);
 *      2023.02.25: 返回limit改成80%条目 (参考28108-todo1);
 *      2023.03.16: 支持首尾循环的情况 (参考28174-todo4);
 *      2023.03.16: 修复首尾差值算错的BUG (因为测得360左右度和180左右度相近度是0.9以上);
 *      2023.06.03: 性能优化_复用cacheDataDic到循环外 (参考29109-测得3);
 *  @result 返回当前码识别的相近序列;
 */
+(NSArray*) TIR_Value:(AIKVPointer*)protoV_p{
    //1. 取索引序列 & 当前稀疏码值;
    NSDictionary *cacheDataDic = [AINetIndexUtils searchDataDic:protoV_p.algsType ds:protoV_p.dataSource isOut:protoV_p.isOut];
    NSArray *index_ps = [AINetIndex getIndex_ps:protoV_p.algsType ds:protoV_p.dataSource isOut:protoV_p.isOut];
    double maskData = [NUMTOOK([AINetIndex getData:protoV_p]) doubleValue];
    double max = [CortexAlgorithmsUtil maxOfLoopValue:protoV_p.algsType ds:protoV_p.dataSource];
    
    //2. 按照相近度排序;
    NSArray *near_ps = [SMGUtils sortSmall2Big:index_ps compareBlock:^double(AIKVPointer *obj) {
        double objData = [NUMTOOK([AINetIndex getData:obj fromDataDic:cacheDataDic]) doubleValue];
        double nearDelta = fabs(objData - maskData);
        
        //2. 循环时: 计算nearV相近度算法 (参考28174-todo4);
        if (max > 0 && nearDelta > (max / 2)) nearDelta = max - nearDelta;
        return nearDelta;
    }];
    
    //3. 窄出,仅返回前NarrowLimit条 (最多narrowLimit条,最少1条);
    NSInteger limit = MAX(near_ps.count * 0.8f, 20);
    return ARR_SUB(near_ps, 0, limit);
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
 *      1. 看到西瓜会开心 : 对自身状态的判断, (比如,看到西瓜,想吃,那么当前状态是否饿)
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
 *      20220115: 识别结果可为自身,参考recognitionAlg_Run(),所以不需要此处再add(self)了;
 *      20220116: 全含可能也只是相似,由直接构建抽具象关联,改成概念外类比 (参考25105);
 *      20220528: 把概念外类比关掉 (参考26129-方案2-1);
 *      20221018: 对proto直接抽象指向matchAlg (参考27153-todo3);
 *      20221024: 将抽具象相似度存至algNode中 (参考27153-todo2);
 *
 *  _result
 *      xxxx.xx.xx: completeBlock : 共支持三种返回: 匹配效果从高到低分别为:fuzzyAlg废弃,matchAlg全含,seemAlg局部;
 *      2022.01.16: 改为直接传入inModel模型,识别后赋值到inModel中即可;
 *      
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
 *      2023.01.18 - 相似度用相乘 (参考28035-todo1);
 *      2023.01.24 - BUG修复: 修复相似度相乘后,相似度阈值相应调低 (参考28041-BUG1);
 *      2023.02.01 - 不限制相似度,让其自然竞争越来越准确 (参考28042-思路2-4);
 *      2023.02.21 - 识别结果保留20% (参考28102-方案1);
 *      2023.02.25 - 集成概念识别过滤器 (参考28111-todo1) & 取消识别后过滤20% (参考28111-todo2);
 *      2023.04.09 - 仅识别似层 (参考29064-todo1);
 *      2023.06.01 - 将识别结果拆分成pAlgs和rAlgs两个部分 (参考29108-2.1);
 *      2023.06.02 - 性能优化_复用vInfo (在识别二次过滤器中测得,这个vInfo在循环中时性能影响挺大的);
 *      2023.06.03 - 性能优化_复用cacheDataDic到循环外 & cacheProtoData到循环外 & proto收集防重用dic (参考29109-测得3);
 */
+(void) recognitionAlgStep1:(NSArray*)except_ps inModel:(AIShortMatchModel*)inModel {
    //0. 数据准备;
    AIAlgNodeBase *protoAlg = inModel.protoAlg;
    if (!ISOK(protoAlg, AIAlgNodeBase.class)) return;
    except_ps = ARRTOOK(except_ps);
    IFTitleLog(@"概念识别",@"\n%@",Alg2FStr(protoAlg));
    
    //1. 收集prAlgs <K:pid,V:AIMatchAlgModel> (注: 现在alg的atds全是空,用pid就能判断唯一);
    NSMutableDictionary *protoPDic = [NSMutableDictionary new], *protoRDic = [NSMutableDictionary new];
    
    //2. 广入: 对每个元素,分别取索引序列 (参考25083-1);
    for (AIKVPointer *item_p in protoAlg.content_ps) {
        
        //3. 性能优化: 加载循环外缓存数据;
        NSDictionary *cacheDataDic = [AINetIndexUtils searchDataDic:item_p.algsType ds:item_p.dataSource isOut:item_p.isOut];
        AIValueInfo *vInfo = [AINetIndex getValueInfo:item_p.algsType ds:item_p.dataSource isOut:item_p.isOut];
        double cacheProtoData = [NUMTOOK([AINetIndex getData:item_p fromDataDic:cacheDataDic]) doubleValue];
        
        //3. 取相近度序列 (按相近程度排序);
        NSArray *near_ps = [self TIR_Value:item_p];
        
        //4. 每个near_p做两件事:
        for (AIKVPointer *near_p in near_ps) {
            
            //5. 第1_计算出nearV (参考25082-公式1) (性能:400次计算,耗100ms很正常);
            double nearData = [NUMTOOK([AINetIndex getData:near_p fromDataDic:cacheDataDic]) doubleValue];
            double nearV = [AIAnalyst compareCansetValue:nearData protoV:cacheProtoData at:item_p.algsType ds:item_p.dataSource isOut:item_p.isOut vInfo:vInfo];
            
            //2024.04.27: BUG_这里有nearV为0的,导致后面可能激活一些完全不准确的结果 (修复: 加上末尾淘汰: 相似度为0的就不收集了先,看下应该也不影响别的什么);
            if (nearV == 0) continue;
            
            //6. 第2_取near_p的refPorts (参考25083-1) (性能: 无缓存时读266耗240,有缓存时很快);
            NSArray *refPorts = [AINetUtils refPorts_All4Value:near_p];
            
            //2024.04.27: BUG_把此处强度淘汰取消掉,不然淘汰70%也太多了,新的概念即使再准也没机会 (比如: 向90跑10左右的有皮果,因为是后期特定训练步骤里才经历的,在这里老是识别不到);
            //refPorts = ARR_SUB(refPorts, 0, cPartMatchingCheckRefPortsLimit_Alg(refPorts.count));
            
            //6. 第3_仅保留有mv指向的部分 (参考26022-3);
            //refPorts = [SMGUtils filterArr:refPorts checkValid:^BOOL(AIPort *item) {
            //    return item.targetHavMv;
            //}];
            //if (Log4MAlg) NSLog(@"当前near_p:%@ --ref数量:%lu",[NVHeUtil getLightStr:near_p],(unsigned long)refPorts.count);
            
            //7. 每个refPort做两件事: (性能: 以下for循环耗150ms很正常);
            for (AIPort *refPort in refPorts) {
                //8. 不应期 -> 不可激活;
                if ([SMGUtils containsSub_p:refPort.target_p parent_ps:except_ps]) continue;
                
                //9. 找model (无则新建) (性能: 此处在循环中,所以防重耗60ms正常,收集耗100ms正常);
                NSMutableDictionary *protoDic = refPort.targetHavMv ? protoPDic : protoRDic;
                AIMatchAlgModel *model = [protoDic objectForKey:@(refPort.target_p.pointerId)];
                if (!model) {
                    model = [[AIMatchAlgModel alloc] init];
                    //9. 收集;
                    [protoDic setObject:model forKey:@(refPort.target_p.pointerId)];
                }
                model.matchAlg = refPort.target_p;
                
                //10. 统计匹配度matchCount & 相近度<1个数nearCount & 相近度sumNear & 引用强度sumStrong
                model.matchCount++;
                model.nearCount++;
                model.sumNear *= nearV;
                model.sumRefStrong += (int)refPort.strong.value;
            }
        }
    }
    
    //12. 全含判断: 从大到小,依次取到对应的node和matchingCount (注: 支持相近后,应该全是全含了,参考25084-1) (性能:无缓存时读400耗400ms,有缓存时30ms);
    NSArray *validPAlgs = [self recognitionAlg_CheckValid:protoPDic.allValues protoAlgCount:protoAlg.count];
    NSArray *validRAlgs = [self recognitionAlg_CheckValid:protoRDic.allValues protoAlgCount:protoAlg.count];
    
    //13. 似层交层分开进行竞争 (分开竞争是以前就一向如此的,因为同质竞争才公平) (为什么要保留交层: 参考31134-TODO1);
    NSArray *validPSAlgs = [SMGUtils filterArr:validPAlgs checkValid:^BOOL(AIMatchAlgModel *item) {
        AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item.matchAlg];
        return itemAlg.count == protoAlg.count;
    }];
    NSArray *validPJAlgs = [SMGUtils filterArr:validPAlgs checkValid:^BOOL(AIMatchAlgModel *item) {
        AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item.matchAlg];
        return itemAlg.count != protoAlg.count;
    }];
    NSArray *validRSAlgs = [SMGUtils filterArr:validRAlgs checkValid:^BOOL(AIMatchAlgModel *item) {
        AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item.matchAlg];
        return itemAlg.count == protoAlg.count;
    }];
    NSArray *validRJAlgs = [SMGUtils filterArr:validRAlgs checkValid:^BOOL(AIMatchAlgModel *item) {
        AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item.matchAlg];
        return itemAlg.count != protoAlg.count;
    }];
    
    //13. 识别过滤器 (参考28109-todo2);
    NSArray *filterPSAlgs = [AIFilter recognitionAlgFilter:validPSAlgs radio:0.5f];
    NSArray *filterPJAlgs = [AIFilter recognitionAlgFilter:validPJAlgs radio:0.5f];
    NSArray *filterRSAlgs = [AIFilter recognitionAlgFilter:validRSAlgs radio:0.16f];
    NSArray *filterRJAlgs = [AIFilter recognitionAlgFilter:validRJAlgs radio:0.16f];
    
    //14. 识别竞争机制 (参考2722d-方案2);
    //14. 按nearA排序 (参考25083-2&公式2 & 25084-1);
    //15. 未将全含返回,则返回最相似 (2020.10.22: 全含返回,也要返回seemAlg) (2022.01.15: 支持相近匹配后,全是全含没局部了);
    inModel.matchAlgs_PS = [AIRank recognitionAlgRank:filterPSAlgs];
    inModel.matchAlgs_PJ = [AIRank recognitionAlgRank:filterPJAlgs];
    inModel.matchAlgs_RS = [AIRank recognitionAlgRank:filterRSAlgs];
    inModel.matchAlgs_RJ = [AIRank recognitionAlgRank:filterRJAlgs];
    
    //16. debugLog
    NSLog(@"\n概念识别结果 (感似:%ld条 理似:%ld条 感交:%ld 理交:%ld) protoAlg:%@",inModel.matchAlgs_PS.count,inModel.matchAlgs_RS.count,inModel.matchAlgs_PJ.count,inModel.matchAlgs_RJ.count,Alg2FStr(protoAlg));
    [inModel log4HavXianWuJv_AlgPJ:@"fltx1"];
}

/**
 *  MARK:--------------------概念识别全含判断--------------------
 */
+(NSArray*) recognitionAlg_CheckValid:(NSArray*)protoPRModels protoAlgCount:(NSInteger)protoAlgCount{
    //1. 全含判断: 从大到小,依次取到对应的node和matchingCount (注: 支持相近后,应该全是全含了,参考25084-1);
    return [SMGUtils filterArr:protoPRModels checkValid:^BOOL(AIMatchAlgModel *item) {
        //2. 过滤掉匹配度<85%的;
        //if (item.matchValue < 0.60f) return false;
        
        //3. 过滤掉非全含的 (当count!=matchCount时为局部匹配: 局部匹配partAlgs已废弃);
        AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item.matchAlg];
        if (itemAlg.count != item.matchCount) return false;
        
        //4. 过滤掉非似层的 (参考29064-todo1);
        //2024.03.28: 交似层都返回 (参考31134-TODO1);
        //if (itemAlg.count != protoAlgCount) return false;
        return true;
    }];
}

/**
 *  MARK:--------------------概念识别-第二步: 抽具象关联--------------------
 */
+(void) recognitionAlgStep2:(AIShortMatchModel*)inModel {
    //5. 关联处理 & 外类比 (这样后面TOR理性决策时,才可以直接对当前瞬时实物进行很好的理性评价) (参考21091-蓝线);
    NSLog(@"概念识别关联 (感似:%ld条 理似:%ld条 感交:%ld 理交:%ld) protoAlg:%@",inModel.matchAlgs_PS.count,inModel.matchAlgs_RS.count,inModel.matchAlgs_PJ.count,inModel.matchAlgs_RJ.count,Alg2FStr(inModel.protoAlg));
    for (AIMatchAlgModel *matchModel in inModel.matchAlgs_All) {
        //4. 识别到时,value.refPorts -> 更新/加强微信息的引用序列
        AIAbsAlgNode *matchAlg = [SMGUtils searchNode:matchModel.matchAlg];
        [AINetUtils insertRefPorts_AllAlgNode:matchModel.matchAlg content_ps:matchAlg.content_ps difStrong:1];
        
        //5. 存储protoAlg与matchAlg之间的相近度记录 (参考27153-todo2);
        [inModel.protoAlg updateMatchValue:matchAlg matchValue:matchModel.matchValue];
        
        //6. 对proto直接抽象指向matchAlg,并增强强度值 (为保证抽象多样性,所以相近的也抽具象关联) (参考27153-3);
        [AINetUtils relateAlgAbs:matchAlg conNodes:@[inModel.protoAlg] isNew:false];
        [AITest test25:matchAlg conAlgs:@[inModel.protoAlg]];
    }
    
    for (AIMatchAlgModel *matchModel in ARR_SUB(inModel.matchAlgs_PS, 0, 5)) {
        //7. log
        NSString *prDesc = [inModel.matchAlgs_R containsObject:matchModel] ? @"r" : @"p";
        NSString *sjDesc = [inModel.matchAlgs_Si containsObject:matchModel] ? @"s" : @"j";
        if (Log4MAlg) NSLog(@"%@%@-->>>(%d) 全含item: %@   \t相近度 => %.2f (count:%d)",prDesc,sjDesc,matchModel.sumRefStrong,Pit2FStr(matchModel.matchAlg),matchModel.matchValue,matchModel.matchCount);
    }
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
 *  @param matchAlgs        : 触发此识别时的那一帧的概念识别结果 (参考28103-2);
 *  @param protoOrRegroupCutIndex : proto或regroup当前已经进展到哪里,发进来cutIndex (proto时一般是全已发生);
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
 *      2022.12.28: 求出匹配部分的综合引用强度值,并参与到综合竞争中 (参考2722f-todo13&todo14);
 *      2022.12.29: 时序识别后,增强indexDic已发生部分的refStrong和contentStrong (参考2722f-todo32&todo33);
 *      2023.02.21: 废弃收集proto的lastAlg当索引,因为它只被protoFo一条时序引用,所以在时序识别中没什么用 (参考28103-4另);
 *      2023.02.21: 传入触发帧概念识别结果matchAlgs的前10条做为时序识别的索引 (参考28103-2);
 *      2023.02.24: 提升时序识别成功率: 把索引改成所有proto帧的抽象alg (参考28107-todo1);
 *      2023.02.24: 提升时序识别成功率: 废弃matchRFos (其实早废弃了,借着这次改,彻底此处相关代码删掉);
 *      2023.02.24: 提升时序识别成功率: 时序结果保留20% (参考28107-todo4);
 *      2023.03.15: 打开matchRFos (参考28181-方案3);
 *      2023.03.17: 关闭matchRFos (参考28184-原因1&2);
 *      2023.07.11: 行为化反思时,将regroupCutIndex传进来,并根据它计算出absMatchFo的cutIndex,避免因此而计算sp率等不准确;
 *      2023.07.19: TC线程_因为数组多线程导致,导致foreach中闪退问题 (改加上copy);
 *      2024.10.29: 时序识别似层化 (参考33111-TODO1);
 *  @status 废弃,因为countDic排序的方式,不利于找出更确切的抽象结果 (识别不怕丢失细节,就怕不确切,不全含);
 */
+(void) recognitionFoStep1:(AIFoNodeBase*)protoOrRegroupFo except_ps:(NSArray*)except_ps decoratorInModel:(AIShortMatchModel*)inModel fromRegroup:(BOOL)fromRegroup matchAlgs:(NSArray*)matchAlgs protoOrRegroupCutIndex:(NSInteger)protoOrRegroupCutIndex debugMode:(BOOL)debugMode{
    //1. 数据准备;
    except_ps = ARRTOOK(except_ps);
    NSMutableArray *protoPModels = [[NSMutableArray alloc] init];
    NSMutableArray *protoRModels = [[NSMutableArray alloc] init];
    
    //2. 广入: 对每个元素,分别取索引序列 (参考25083-1);
    NSArray *protoOrRegroupContent_ps = [protoOrRegroupFo.content_ps copy];
    //AddDebugCodeBlock_Key(@"时序识别", @"1调用"); //用于调试当时序识别结果条数不正常时,用这个调试下,下面各步骤都执行了多少次,直至查明为何最终条数不正常;
    for (NSInteger i = 0; i < protoOrRegroupContent_ps.count; i++) {
        AIKVPointer *proto_p = ARR_INDEX(protoOrRegroupContent_ps, i);
        AIAlgNodeBase *protoAlg = [SMGUtils searchNode:proto_p];
        
        //3. 每个abs_p分别索引;
        NSArray *protoAlgAbs_ps = [self getProtoAlgAbsPs:protoOrRegroupFo protoIndex:i inModel:inModel fromRegroup:fromRegroup];
        
        //4. 仅保留似层: 索引absAlg是交层,则直接continue (参考33111-TODO1);
        protoAlgAbs_ps = [SMGUtils filterArr:protoAlgAbs_ps checkValid:^BOOL(AIKVPointer *item) {
            return !item.isJiao;
        }];
        NSLog(@"索引数: %ld -> %ld",protoAlg.absPorts.count,protoAlgAbs_ps.count);
        //AddDebugCodeBlock_Key(@"时序识别", @"2索引");
        
        for (AIKVPointer *absAlg_p in protoAlgAbs_ps) {
            AIAlgNodeBase *absAlg = [SMGUtils searchNode:absAlg_p];
            
            //5. 第2_取abs_p的refPorts (参考28107-todo2);
            NSArray *refPorts = [[AINetUtils refPorts_All4Alg_Normal:absAlg] copy];
            
            //6. RFo的长度>1才有意义 (参考28183-BUG1);
            refPorts = [SMGUtils filterArr:refPorts checkValid:^BOOL(AIPort *item) {
                if (Switch4RecognitionMatchRFos) {
                    //a. 打开pFos和rFos;
                    AIFoNodeBase *refFo = [SMGUtils searchNode:item.target_p];
                    return item.targetHavMv || refFo.count > 1;
                } else {
                    //b. 只打开matchPFos;
                    return item.targetHavMv;
                }
            }];
            
            //7. 每个refPort做两件事:
            for (AIPort *refPort in refPorts) {
                AddDebugCodeBlock_Key(@"时序识别", @"3联想");
                //8. 不应期 -> 不可激活 & 收集到不应期同一fo仅处理一次;
                if ([SMGUtils containsSub_p:refPort.target_p parent_ps:except_ps]) continue;
                //AddDebugCodeBlock_Key(@"时序识别", @"4防重通过");
                except_ps = [SMGUtils collectArrA:except_ps arrB:@[refPort.target_p]];
                
                //7. 仅保留似层: 联想到的fo是交层,则直接continue (参考33111-TODO1);
                if (refPort.target_p.isJiao) continue;
                //AddDebugCodeBlock_Key(@"时序识别", @"5交层通过");
                
                //7. 全含判断;
                AIFoNodeBase *refFo = [SMGUtils searchNode:refPort.target_p];
                NSDictionary *indexDic = [self recognitionFo_CheckValidV3:refFo protoOrRegroupFo:protoOrRegroupFo fromRegroup:fromRegroup inModel:inModel];
                if (!DICISOK(indexDic)) continue;
                //AddDebugCodeBlock_Key(@"时序识别", @"6全含通过");
                
                //7. 取absCutIndex, 说明: cutIndex指已发生到的index,后面则为时序预测; matchValue指匹配度(0-1)
                NSInteger cutIndex = [AINetUtils getCutIndexByIndexDicV2:indexDic protoOrRegroupCutIndex:protoOrRegroupCutIndex];
                
                //7. 根据indexDic取nearCount & sumNear;
                NSArray *nearData = [AINetUtils getNearDataByIndexDic:indexDic absFo:refFo.pointer conFo:protoOrRegroupFo.pointer callerIsAbs:false];
                int nearCount = NUMTOOK(ARR_INDEX(nearData, 0)).intValue;
                CGFloat sumNear = NUMTOOK(ARR_INDEX(nearData, 1)).floatValue;
                
                //8. 被引用强度;
                NSInteger sumRefStrong = [AINetUtils getSumRefStrongByIndexDic:indexDic matchFo:refFo.pointer];
                
                //7. 实例化识别结果AIMatchFoModel;
                AIMatchFoModel *newMatchFo = [AIMatchFoModel newWithMatchFo:refFo.pointer protoOrRegroupFo:protoOrRegroupFo.pointer sumNear:sumNear nearCount:nearCount indexDic:indexDic cutIndex:cutIndex sumRefStrong:sumRefStrong baseFrameModel:inModel];
                if (Log4MFo) NSLog(@"时序识别itemSUCCESS 匹配度:%f %@->%@",newMatchFo.matchFoValue,Fo2FStr(refFo),Mvp2Str(refFo.cmvNode_p));
                
                //9. 收集到pFos/rFos;
                if (refFo.cmvNode_p) {
                    //AddDebugCodeBlock_Key(@"时序识别", @"7收集P结果");
                    [protoPModels addObject:newMatchFo];
                } else {
                    //AddDebugCodeBlock_Key(@"时序识别", @"8收集R结果");
                    [protoRModels addObject:newMatchFo];
                }
            }
        }
    }
    //PrintDebugCodeBlock_Key(@"时序识别");
    
    //10. 过滤强度前20% (参考28111-todo1);
    NSArray *filterPModels = [AIFilter recognitionFoFilter:protoPModels];
    NSArray *filterRModels = [AIFilter recognitionFoFilter:protoRModels];
    
    //10. 按照 (强度x匹配度) 排序,强度最重要,包含了价值初始和使用频率,其次匹配度也重要 (参考23222-BUG2);
    NSArray *sortPs = [AIRank recognitionFoRank:filterPModels];
    NSArray *sortRs = [AIRank recognitionFoRank:filterRModels];
    inModel.matchPFos = [[NSMutableArray alloc] initWithArray:sortPs];
    inModel.matchRFos = [[NSMutableArray alloc] initWithArray:sortRs];
    if (debugMode) NSLog(@"\n时序识别结果 P(%ld条) R(%ld条)",inModel.matchPFos.count,inModel.matchRFos.count);
    [inModel log4HavXianWuJv_PFos:@"fltx2"];
    
    //2024.12.05: 每次反馈同F只计一次: 避免F值快速重复累计到很大,sp更新(同场景下的)防重推 (参考33137-方案v5);
    //NSMutableArray *except4SP2F = [[NSMutableArray alloc] init];
    //13. inSP值子即父: 时序识别成功后,protoFo从0到cutIndex全计P+1 (参考33112-TODO4.3 & 33134-FIX2a);
    //2024.12.10: 先关掉这里,因为在forecast_Multi()中,已经给pFo已发生部分计了sp值,这里再推到F层,就重复了 (并且这种做法,只是做了proto层和pFo层,pFo的F层并未照顾到,另外其实也不太建议在识别成功后,把已发生层全计上数,感觉和SP的初衷不太相符);
    //for (NSInteger i = 0; i <= protoOrRegroupCutIndex; i++) {
    //    [AINetUtils updateInSPStrong_4IF:protoOrRegroupFo conSPIndex:i difStrong:1 type:ATPlus except4SP2F:except4SP2F];
    //}
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
 *      2023.07.11: 仅普通正向protoFo时序识别时,才要求末帧必含,regroup则不必如此 (参考30057-修复);
 *      2024.10.10: 迭代V3: 把从后往前,改成从前往后 (参考33093);
 *      2024.10.10: 把判断映射(mIsC) 与 判断是否全含(条件满足) => 整理成两步 (参考33093-TIPS);
 *  @result 判断protoFo是否全含assFo: 成功时返回indexDic / 失败时返回空dic;
 */
+(NSDictionary*) recognitionFo_CheckValidV3:(AIFoNodeBase*)assFo protoOrRegroupFo:(AIFoNodeBase*)protoOrRegroupFo fromRegroup:(BOOL)fromRegroup inModel:(AIShortMatchModel*)inModel {
    if (Log4MFo) NSLog(@"------------------------ 时序全含检查 ------------------------\nass:%@->%@",Fo2FStr(assFo),Mvp2Str(assFo.cmvNode_p));
    
    //==================== STEP1: 从前往后取匹配映射indexDic ====================
    
    //11. 数据准备;
    NSMutableDictionary *indexDic = [[NSMutableDictionary alloc] init]; //记录protoIndex和assIndex的映射字典 <K:assIndex, V:protoIndex>;
    
    //12. 依次mIsC判断匹配: 匹配时_记录indexDic映射 (此处proto抽象仅指向刚识别的matchAlgs,所以与contains等效);
    NSInteger nextStartForAssIndex = 0;
    for (NSInteger protoIndex = 0; protoIndex < protoOrRegroupFo.count; protoIndex++) {
        AIKVPointer *protoAlg_p = ARR_INDEX(protoOrRegroupFo.content_ps, protoIndex);
        for (NSInteger assIndex = nextStartForAssIndex; assIndex < assFo.count; assIndex++) {
            AIKVPointer *assAlg_p = ARR_INDEX(assFo.content_ps, assIndex);
            
            //13. 概念识别没有进行关联,所以此处也调用getProtoAlgAbsPs,替代mIsC,末帧时直接可以用inModel.matchAlg_PS.contains()来 (参考3313b-TODO5);
            NSArray *protoAlgAbs_ps = [self getProtoAlgAbsPs:protoOrRegroupFo protoIndex:protoIndex inModel:inModel fromRegroup:fromRegroup];
            BOOL mIsC = [protoAlg_p isEqual:assAlg_p] || [protoAlgAbs_ps containsObject:assAlg_p];
            if (mIsC) {
                
                //13. 匹配时_记录下次循环ass时,从哪帧开始倒序循环: nextMaxForAssIndex进度;
                //2024.12.01: 修复此处有可能输出0->1,1->0的BUG (参考33137-问题1);
                nextStartForAssIndex = assIndex + 1;
                [indexDic setObject:@(protoIndex) forKey:@(assIndex)];
                if (Log4MFo) NSLog(@"时序识别全含判断有效+1帧 (assIndex:%ld protoIndex:%ld)",assIndex,protoIndex);
                break;
            }
        }
    }
    
    //==================== STEP2: 判断含不含proto末帧,以及前段匹配是否都充足 (参考33093-TIPS) ====================
    
    //21. 前段必须全含,缺一帧也不行: 全含时,它发现的最大index就等于发现映射数 (如: 最大下标3时,发现4个);
    //说明: 中途assFo有任意一帧在proto中未匹配到,则全含失败;
    NSInteger maxAssIndex = -1;
    for (NSNumber *assIndex in indexDic.allKeys) {
        if (assIndex.integerValue > maxAssIndex) maxAssIndex = assIndex.integerValue;
    }
    if (maxAssIndex != indexDic.count - 1) {
        if (Log4MFo) NSLog(@"ass前段有一帧在proto未找到,则非全含:%@",CLEANSTR(indexDic));
        return [NSMutableDictionary new];
    }
    
    //22. TI时序识别时,要求必须包含proto末帧,否则返回failure;
    //说明: 一帧帧全匹配到了,但最终没匹配到proto的末帧,也全含失败;
    if (!fromRegroup && ![indexDic objectForKey:@(protoOrRegroupFo.count - 1)]) {
        if (Log4MFo) NSLog(@"ass最后未与proto末帧匹配上,则非全含:%@",CLEANSTR(indexDic));
        return [NSMutableDictionary new];
    }
    
    //23. 至此前段全含条件满足,返回映射结果;
    if (Log4MFo) NSLog(@"全含success:%@",CLEANSTR(indexDic));
    return indexDic;
}

/**
 *  MARK:--------------------时序识别第二步: 抽具象关联--------------------
 */
+(void) recognitionFoStep2:(AIFoNodeBase*)protoOrRegroupFo inModel:(AIShortMatchModel*)inModel debugMode:(BOOL)debugMode {
    //1. 数据准备;
    NSArray *allMatchFos = [[SMGUtils collectArrA:inModel.matchPFos arrB:inModel.matchRFos] copy];
    if (debugMode) NSLog(@"\n时序识别关联 P(%ld条) R(%ld条)",inModel.matchPFos.count,inModel.matchRFos.count);
    
    //2. 关联处理,直接protoFo抽象指向matchFo,并持久化indexDic (参考27177-todo6);
    for (AIMatchFoModel *item in allMatchFos) {
        //4. 识别到时,refPorts -> 更新/加强微信息的引用序列
        AIFoNodeBase *matchFo = [SMGUtils searchNode:item.matchFo];
        [AINetUtils updateRefStrongByIndexDic:item.indexDic2 matchFo:item.matchFo];
        [AINetUtils updateContentStrongByIndexDic:item.indexDic2 matchFo:item.matchFo];
        
        //5. 存储matchFo与protoFo之间的indexDic映射 (参考27177-todo5);
        [protoOrRegroupFo updateIndexDic:matchFo indexDic:item.indexDic2];
        
        //6. 对proto直接抽象指向matchAlg,并增强强度值 (为保证抽象多样性,所以相近的也抽具象关联) (参考27153-3);
        [AINetUtils relateFoAbs:matchFo conNodes:@[protoOrRegroupFo] isNew:false];
        
        //7. 存储protoFo与matchFo之间的匹配度度记录 (存每个alg元素的乘积匹配度) (参考27153-todo2 & 33143-方案1);
        [protoOrRegroupFo updateMatchValue:matchFo matchValue:item.sumNear];
        
        //8. 调试日志;
        if (debugMode) NSLog(@"%ld. %@强度:(%ld)(%ld/%ld)\t> %@->{%.2f} (SP:%@) indexDic:%@ 匹配度 => %.2f",[allMatchFos indexOfObject:item],matchFo.cmvNode_p?@"P":@"",item.sumRefStrong,item.cutIndex,matchFo.count,Fo2FStr(matchFo),[AIScore score4MV_v2FromCache:item],CLEANSTR(matchFo.spDic),CLEANSTR(item.indexDic2),item.matchFoValue);
    }
}

//MARK:===============================================================
//MARK:                     < Canset识别 >
//MARK:===============================================================

/**
 *  MARK:--------------------Canset概念识别--------------------
 *  @desc Canset场景内概念识别算法 (参考3014a-方案 & 3014b);
 *  @param sceneFo : 当前canset所在的sceneFo (cansetAlg识别是要限定于场景内的,sceneFo就是这个场景);
 *  @version
 *      2023.10.26: 废弃 (参考3014a-追加结果);
 */
//+(void) recognitionCansetAlg:(AIAlgNodeBase*)protoAlg sceneFo:(AIFoNodeBase*)sceneFo inModel:(AIShortMatchModel*)inModel {
//    //1. 关于调用者:
//    //  a. 哪里在调用cansetFo识别,哪里就在fo识别前先调用下这个;
//    //  b. 或者再提前点,调用普通alg识别时,结合下工作记忆,顺带把这个也跑了;
//}

/**
 *  MARK:--------------------Canset时序识别--------------------
 *  @desc 功能说明:
 *          1. 识别: 用条件满足来实现类似全含判断功能 (参考28185-todo3);
 *          2. 增强: 识别结果增强sp和eff (参考28185-todo4);
 *        现状说明:
 *          调用者1. newCanset有效时,会调用canset识别,类比,sp+1,eff+1;
 *          调用者2. 反馈canset无效时,会调用canset识别,不类比,sp+1,eff-1;
 *          调用者3. 迁移时,会调用canset识别,类比,sp+0,eff+0;
 *          注: 反馈无效时,sp也会+1的代码是以前的,此处未改,但它是否合理,待测出不合理时再来改正;
 *  @version
 *      2023.03.18: 失败时,也调用Canset识别,并将es计负分 (参考28185-todo5);
 *      2023.03.30: 支持过滤器 (参考29042);
 *      2023.04.04: 将Canset过滤器改为根据indexDic映射数来 (参考29055);
 *      2023.04.07: 因为性能原因,并且newCanset时就识别类比的意义也没找着,所以关闭Canset识别 (后面会改为在迁移时进行懒识别类比) (参考29059-改动 & 29067-todo2);
 *      2023.04.19: TCTransfer迁移后调用Canset识别类比,但不对SPEFF+1 (参考29069-todo12 & todo12.1);
 *      2023.09.01: 因为场景单一时不会触发transfer导致canset识别类比永远不会发生,所以改回newCanset时即刻触发canset识别类比 (参考30124-原则&todo1);
 *      2023.09.01: newCanset触发时,EFF根据"有效或无效",更新+-1,TCTransfer触发时EFF不变 (参考30124-todo2&todo3);
 *      2023.10.23: 关闭canset识别和类比 (参考3014b-方案5 & 3014c-todo2);
 *      2023.10.26: 废弃canset识别 (参考3014c-todo2);
 */
//+(void) recognitionCansetFo:(AIKVPointer*)newCanset_p sceneFo:(AIKVPointer*)sceneFo_p es:(EffectStatus)es {
//    if (!Switch4RecognitionCansetFo) return;
//    //1. 取出旧有候选集;
//    AIFoNodeBase *newCanset = [SMGUtils searchNode:newCanset_p];
//    AIFoNodeBase *sceneFo = [SMGUtils searchNode:sceneFo_p];
//
//    //TODO20231003: 此处为hCanset时: (因canset识别被关闭,此todo先不做)
//    //1. 取oldCanset用的index应该不同 (随后做下处理);
//    //2. 打日志时,把当前是rCanset还是hCanset打出来,以便调试canset的竞争成长相关;
//
//    NSArray *oldCansets = [sceneFo getConCansets:sceneFo.count];
//    NSLog(@"\n----------- Canset识别 (EFF:%@ 候选数:%ld) -----------\nnewCanset:%@\nsceneFo:%@",EffectStatus2Str(es),oldCansets.count,Fo2FStr(newCanset),Fo2FStr(sceneFo));
//    NSMutableArray *matchModels = [[NSMutableArray alloc] init];
//
//    //2. 旧有候选集: 作为识别池;
//    for (AIKVPointer *oldCanset in oldCansets) {
//        //3. 不应期 (不识别自身);
//        if ([newCanset.pointer isEqual:oldCanset]) continue;
//        AIFoNodeBase *oldCansetFo = [SMGUtils searchNode:oldCanset];
//
//        //4. 判断newCanset全含cansetFo (返回全含indexDic) (参考29025-23c);
//        NSDictionary *indexDic = [self checkFoValidMatch_NewCanset:newCanset oldCanset:oldCansetFo sceneFo:sceneFo];
//        if (!DICISOK(indexDic)) continue;
//
//        //5. 收集;
//        [matchModels addObject:[AIMatchCansetModel newWithMatchFo:oldCansetFo indexDic:indexDic]];
//    }
//
//    //6. AIFilter过滤 (参考29042);
//    NSArray *filterModels = [AIFilter recognitionCansetFilter:matchModels sceneFo:sceneFo];
//
//    //7. 日志
//    NSLog(@"\nCanset识别结果: %ld条",filterModels.count);
//    for (AIMatchCansetModel *model in filterModels) {
//        AIEffectStrong *eff = [sceneFo getEffectStrong:model.matchFo.count solutionFo:model.matchFo.pointer];
//        NSLog(@"-->>> %@ SP:%@ EFF:%@",Fo2FStr(model.matchFo),CLEANSTR(model.matchFo.spDic),CLEANSTR(eff));
//    }
//
//    //8. 识别后处理: 外类比 & 增强SP & 增强EFF;
//    for (AIMatchCansetModel *model in filterModels) {
//        //9. 只要全含 & 非无效newCanset => 对二者进行外类比 (参考29025-24 & 29027-方案3);
//        if (es != ES_NoEff) {
//            [AIAnalogy analogyCansetFo:model.indexDic newCanset:newCanset oldCanset:model.matchFo sceneFo:sceneFo es:es];
//        }
//
//        //10. 条件满足的都算识别结果 (更新sp和eff) (参考28185-todo4);
//        if (es != ES_Default) {
//            [model.matchFo updateSPStrong:0 end:model.matchFo.count - 1 type:ATPlus];
//            [sceneFo updateEffectStrong:sceneFo.count solutionFo:model.matchFo.pointer status:es];
//        }
//    }
//}

/**
 *  MARK:--------------------Canset的全含判断 (参考29025-23)--------------------
 *  @desc 全含说明: 要求newCanset包含oldCanset,才返回肯定结果; 
 *          示例: 比如:新[1,3,5,7,9a]和旧[1,5,9b]和场景[1,5] = 是全含的,并最终返回<1:1, 2:3, 3:5>; //其中9a和9b有共同抽象
 *  @version
 *      2023.04.10: 场景包含帧判断全含时,改用mIsC而不是绝对同一个节点 (因为场景内canset可类比抽象) (参考29067-todo1.1);
 *      2023.10.26: 废弃canset识别 (参考3014c-todo2);
 *  @result 全含时,返回二者的indexDic;
 */
//+(NSDictionary*) checkFoValidMatch_NewCanset:(AIFoNodeBase*)newCanset oldCanset:(AIFoNodeBase*)oldCanset sceneFo:(AIFoNodeBase*)sceneFo {
//    //1. 数据准备;
//    NSMutableDictionary *indexDic = [[NSMutableDictionary alloc] init];
//    NSDictionary *newIndexDic = [sceneFo getConIndexDic:newCanset.pointer];
//    NSDictionary *oldIndexDic = [sceneFo getConIndexDic:oldCanset.pointer];
//
//    //3. 说明: 所有帧,都要判断新的全含旧的,只要有一帧失败就全失败 (参考29025-23a);
//    NSInteger protoMin = 0;
//    for (NSInteger oldIndex = 0; oldIndex < oldCanset.count; oldIndex ++) {
//        AIKVPointer *oldAlg = ARR_INDEX(oldCanset.content_ps, oldIndex);
//        BOOL findItem = false;
//        for (NSInteger newIndex = protoMin; newIndex < newCanset.count; newIndex++) {
//            AIKVPointer *newAlg = ARR_INDEX(newCanset.content_ps, newIndex);
//
//            //4. 分别判断old和new这一帧是否被sceneFo场景包含 (参考29025-23b);
//            NSNumber *oldKey = ARR_INDEX([oldIndexDic allKeysForObject:@(oldIndex)], 0);
//            NSNumber *newKey = ARR_INDEX([newIndexDic allKeysForObject:@(newIndex)], 0);
//
//            //5. 如果二者都包含=>即场景包含帧: (因为canset都优先取matchAlg,所以oldAlg和newAlg一般是同一节点) (参考29025-23b);
//            if (oldKey && newKey) {
//                //5. 但因为会类比抽象所以有时不是同一节点: 此时要求new抽象指向old: 算匹配成功 (参考29067-todo1.1);
//                if ([TOUtils mIsC_1:newAlg c:oldAlg]) {
//                    findItem = true;
//                }
//            } else if (oldKey != newKey) {
//                //6. 如果二者有一个包含,则此帧失败 (参考29025-23b2 & 23c3);
//                break;
//            } else {
//                //7. 如果二者都不包含,则判断二者有没有共同的抽象 (参考29025-23c);
//                //2023.10.17: 关闭mc共同抽象为依据 (参考30148-todo1.1);
//                BOOL mcIsBro = false;//[TOUtils mcIsBro:newAlg c:oldAlg];
//                if (mcIsBro) {
//                    //8. 有共同抽象=>则此帧成功 (参考29025-23c);
//                    findItem = true;
//                } else {
//                    //9. 无共同抽象,则继续找newCanset的下帧,看能不能有共同抽象 (参考29025-23c2);
//                }
//            }
//
//            //10. 此帧成功: 记录newIndex & 并记录protoMin (参考29025-23d);
//            if (findItem) {
//                protoMin = newIndex + 1;
//                [indexDic setObject:@(newIndex) forKey:@(oldIndex)];
//                if (Log4SceneIsOk) NSLog(@"\t第%ld帧,条件满足通过 canset:%@ (fromProto:F%ldA%ld)",oldIndex,Pit2FStr(oldAlg),newCanset.pointer.pointerId,newAlg.pointerId);
//                break;
//            }
//        }
//
//        //11. 有一条失败,则全失败 (参考29025-23e);
//        if (!findItem) {
//            if (Log4SceneIsOk) NSLog(@"\t第%ld帧,条件满足未通过 canset:%@ (fromProtoFo:F%ld)",oldIndex,Pit2FStr(oldAlg),newCanset.pointer.pointerId);
//            return nil;
//        }
//    }
//
//    //12. 全找到,则成功;
//    if (Log4SceneIsOk) NSLog(@"条件满足通过:%@ (fromProtoFo:%ld)",Fo2FStr(oldCanset),newCanset.pointer.pointerId);
//    return indexDic;
//}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

//返回protoAlg的索引 (一般是取它的抽象);
+(NSArray*) getProtoAlgAbsPs:(AIFoNodeBase*)protoOrRegroupFo protoIndex:(NSInteger)protoIndex inModel:(AIShortMatchModel*)inModel fromRegroup:(BOOL)fromRegroup {
    //1. 数据准备;
    AIKVPointer *proto_p = ARR_INDEX(protoOrRegroupFo.content_ps, protoIndex);
    
    //2. 每个abs_p分别索引;
    NSArray *protoAlgAbs_ps = nil;
    if (PitIsMv(proto_p)) {
        //3. mv时,直接返回自己就行;
        protoAlgAbs_ps = @[proto_p];
    } else if (protoIndex == protoOrRegroupFo.count - 1 && !fromRegroup) {
        //4. 末帧时,抽具象概念还没关联,不能从absPorts访问到它,所以直接从inModel.matchAlgs来访问 (参考3313b-TODO2);
        protoAlgAbs_ps = [SMGUtils convertArr:inModel.matchAlgs_PS convertBlock:^id(AIMatchAlgModel *obj) {
            return obj.matchAlg;
        }];
    } else {
        //5. 别的,把抽象关联返回;
        AIAlgNodeBase *protoAlg = [SMGUtils searchNode:proto_p];
        protoAlgAbs_ps = Ports2Pits(protoAlg.absPorts);
    }
    return protoAlgAbs_ps;
}


@end
