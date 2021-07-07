//
//  AIThinkInReason.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/2.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkInReason.h"
#import "AINetUtils.h"
#import "AIKVPointer.h"
#import "NVHeader.h"
#import "NSString+Extension.h"
#import "AIPort.h"
#import "AINetIndexUtils.h"
#import "AIAlgNode.h"
#import "AICMVNode.h"
#import "AINetAbsFoNode.h"
#import "AIFrontOrderNode.h"
#import "AIAbsAlgNode.h"
#import "AINetIndex.h"
#import "TIRUtils.h"
#import "AIAnalogy.h"
#import "AIShortMatchModel.h"
#import "ShortMatchManager.h"
#import "ThinkingUtils.h"
#import "TOUtils.h"
#import "AITime.h"
#import "AIMatchFoModel.h"
#import "ReasonDemandModel.h"

@implementation AIThinkInReason

//MARK:===============================================================
//MARK:                     < TIR_Alg >
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
    NSLog(@"\n\n------------------------------- 概念识别 -------------------------------\n%@",Alg2FStr(protoAlg));
    
    //2. 对value.refPorts进行检查识别; (noMv信号已输入完毕,识别联想)
    __block NSMutableArray *matchAlgs = [[NSMutableArray alloc] init];
    __block NSArray *partAlg_ps = nil;
    ///1. 自身匹配 (Self匹配);
    if ([TIRUtils inputAlgIsOld:protoAlg]) {
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
    [TIRUtils partMatching_Alg:protoAlg isMem:false except_ps:fromGroup_ps complete:^(NSArray *_matchAlgs, NSArray *_partAlg_ps) {
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
        AIAlgNodeBase *seemProtoAbs = [theNet createAbsAlg_NoRepeat:same_ps conAlgs:@[firstPartAlg,protoAlg] isMem:false];
        NSLog(@"构建相似抽象:%@",Alg2FStr(seemProtoAbs));
        
        //7. 关联处理_对seemProtoAbs与matchAlg建立抽具象关联 (参考21091-黄线);
        if (seemProtoAbs && firstMatchAlg) {
            NSArray *same_ps = [SMGUtils filterSame_ps:seemProtoAbs.content_ps parent_ps:firstMatchAlg.content_ps];
            AIAlgNodeBase *topAbs = [theNet createAbsAlg_NoRepeat:same_ps conAlgs:@[seemProtoAbs,firstMatchAlg] isMem:false];
            NSLog(@"构建TopAbs抽象:%@",Alg2FStr(topAbs));
        }
    }
    
    //3. 全含时,可进行模糊匹配 (Fuzzy匹配) //因TOR未支持fuzzy,故目前仅将最相似的fuzzy放到AIShortMatchModel中当matchAlg用;
    //if (matchType == MatchType_Abs) {
    //    NSArray *fuzzys = ARRTOOK([TIRUtils matchAlg2FuzzyAlgV2:algNode matchAlg:assAlgNode except_ps:fromGroup_ps]);
    //    AIAlgNodeBase *fuzzyAlg = ARR_INDEX(fuzzys, 0);
    //    //a. 模糊匹配有效时,增强关联,并截胡;
    //    if (fuzzyAlg) {
    //        [AINetUtils insertRefPorts_AllAlgNode:fuzzyAlg.pointer content_ps:fuzzyAlg.content_ps difStrong:1];
    //        assAlgNode = fuzzyAlg;
    //        matchType = MatchType_Fuzzy;
    //    }
    //}
    
    //4. 调试日志
    NSLog(@"概念识别: Finish >>>\n全含:%@\n局部:%@",Pits2FStr(Nodes2Pits(matchAlgs)),Pits2FStr(ARR_SUB(partAlg_ps, 0, 3)));
    complete(matchAlgs,partAlg_ps);
}

/**
 *  MARK:--------------------重新识别rtAlg方法--------------------
 *  @version 20200406 : 由复用fromMem的识别M再Fuzzy(),改为仅识别硬盘MatchAlg,并返回;
 *  @desc 功能说明:
 *      1. result必须包含mUniqueValue;
 *      2. result必须被rtAlg全含 (代码见partMatching_General());
 *      3. result不进行fuzzy模糊匹配 (因为mUniqueValue并非新输入,并且fuzzy会导致多出杂项码(如:m为经26,fuzzyAlg却包含距20));
 */
//+(AIAlgNodeBase*) TIR_Alg_FromRethink:(AIAlgNodeBase*)rtAlg mUniqueV_p:(AIKVPointer*)mUniqueV_p{
//    //1. 数据检查
//    if (!rtAlg || !mUniqueV_p) return nil;
//    NSArray *mUniqueRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Value:mUniqueV_p]];
//    NSLog(@"---------- TIR_Alg_FromRT START ----------");
//    NSLog(@"----> 特码:%@ 被引:%ld个 RTAlg:%@",[NVHeUtil getLightStr:mUniqueV_p],mUniqueRef_ps.count,Alg2FStr(rtAlg));
//
//    //2. 识别
//    __block AIAlgNodeBase *matchAlg = nil;
//    [TIRUtils partMatching_General:rtAlg.content_ps refPortsBlock:^NSArray *(AIKVPointer *item_p) {
//        if (item_p) {
//            //1> 数据准备 (value_p的refPorts是单独存储的);
//            return ARRTOOK([SMGUtils searchObjectForFilePath:item_p.filePath fileName:kFNRefPorts time:cRTReference]);
//        }
//        return nil;
//    } checkBlock:^BOOL(AIPointer *target_p) {
//        if (target_p) {
//            //2> 自身 && 包含M特有码;
//            return ![target_p isEqual:rtAlg.pointer] && [mUniqueRef_ps containsObject:target_p];
//        }
//        return false;
//    } complete:^(AIAlgNodeBase *outMatchAlg, MatchType type) {
//        if (type == MatchType_Abs) {
//            matchAlg = outMatchAlg;
//        }
//    }];
//
//    //3. 直接将assAlgNode设置为algNode的抽象; (这样后面TOR理性决策时,才可以直接对当前瞬时实物进行很好的理性评价);
//    if (ISOK(matchAlg, AIAlgNodeBase.class)) {
//        //4. 识别到时,value.refPorts -> 更新/加强微信息的引用序列
//        [AINetUtils insertRefPorts_AllAlgNode:matchAlg.pointer content_ps:matchAlg.content_ps difStrong:1];
//
//        //5. 识别到时,进行抽具象 -> 关联 & 存储 (20200103:测得,algNode为内存节点时,关联也在内存)
//        [AINetUtils relateAlgAbs:(AIAbsAlgNode*)matchAlg conNodes:@[rtAlg] isNew:false];
//    }
//    NSLog(@"识别Alg_FromRT Finish:%@",Alg2FStr(matchAlg));
//    return matchAlg;
//}

//MARK:===============================================================
//MARK:                     < TIR_Fo >
//MARK: @desc : 目前仅支持局部匹配;
//MARK:===============================================================

/**
 *  MARK:--------------------理性时序--------------------
 *  _param protoAlg_ps : RTFo
 *      1. 传入原始瞬时记忆序列 90% ,还是识别后的概念序列 10%;
 *      2. 传入行为化中的rethinkLSP重组fo;
 *  @param baseDemand : 参数fo所处的r任务 (有可能非R任务,或者为nil,所以此参数用前需先做防错判断);
 *  @desc 向性:
 *      1. ↑
 *      2. →
 *
 *  @desc 代码步骤:
 *      1. 用内类比的方式,发现概念的变化与有无; (理性结果)
 *      2. 用外类比的方式,匹配出靠前limit个中最相似抽象时序,并取到预测mv结果; (感性结果)
 *      3. 根据时序相似性 与 微信息差异度 得出 修正mv的紧迫度; (综合预测)
 *      4. 将fixMv添加到任务序列demandManager,做TOR处理;
 *
 *  @desc 举例步骤:
 *      1. 通过,内类比发现有一物体:方向不变 & 越来越近;
 *      2. 通过,识别概念,发现此物体是汽车; (注:已识别过,可以直接查看抽象指向);
 *      3. 通过,外类比,发现以此下去,"汽车距离变0"会撞到疼痛;
 *      4. 通过,"车-0-撞-疼"来计算时序相似度x% 与 通过"车距"y 计算= zMv;
 *      5. 将zMv提交给demandManager,做TOR处理;
 *  @version
 *      2020.04.03 : 将assFoIndexAlg由proto.lastIndex改为replaceMatchAlg来代替 (因为lastAlg索引失败率太高);
 *      2020.07.17 : 换上新版partMatching_FoV2时序识别算法;
 *      2021.04.13 : 将装饰AIShortMatchModel改为result返回 & 参数由order直接改为fo传入;
 *      2021.07.07 : 反思时,cutIndex全部返-1 (参考23156);
 *  @todo :
 *      2020.04.03: 支持识别到多个时序 T;
 *      2020.04.03: 以识别到的多个时序,得到多个价值预测 (支持更多元的评价);
 *
 */
+(AIShortMatchModel*) TIR_Fo_FromRethink:(AIFoNodeBase*)fo baseDemand:(ReasonDemandModel*)baseDemand{
    //1. 数据检查
    AIShortMatchModel *result = [[AIShortMatchModel alloc] init];
    if (!fo || !ARRISOK(fo.content_ps)) return result;
    NSLog(@"\n\n=============================== 反思时序识别 ===============================\n%@",Fo2FStr(fo));
    
    //2. 调用通用时序识别方法 (checkItemValid: 可考虑写个isBasedNode()判断,因protoAlg可里氏替换,目前仅支持后两层)
    [self partMatching_FoV1Dot5:fo except_ps:@[fo.pointer] decoratorInModel:result findCutIndex:^NSInteger(AIFoNodeBase *matchFo, NSInteger lastMatchIndex) {
        return -1;
    }];
    NSLog(@"反思时序: Finish >> %@",Fo2FStr(result.matchFo));
    return result;
}

/**
 *  MARK:--------------------瞬时时序识别--------------------
 *  @param inModel : 当前帧输入期短时记忆;
 *  @version
 *      20200414 - protoFo由瞬时proto概念组成,改成瞬时match概念组成 (本方法中,去掉proto概念层到match层的联想);
 *      20200717 - 换上新版partMatching_FoV2时序识别算法;
 *      20210119 - 支持预测-触发器和反向反馈类比 (22052-1&3);
 *      20210124 - In反省类比触发器,支持多时序识别matchFos (参考22073-todo3);
 *      20210413 - TIRFoFromShortMem的参数由matchAFo改为protoFo (参考23014-分析2);
 *      20210414 - 将TIRFo参数改为matchAlg有效则protoFo,否则matchAFo (参考23015);
 *      20210421 - 加强RFos的抽具象关联,对rFo与protoFo进行类比抽象;
 *      20210422 - 将absRFo收集到inModel中 (用于GL联想assFo时方便使用,参考23041-示图);
 *  @bug
 *      2020.11.10: 在21141训练第一步,发现外类比不执行BUG,因为传入无用的matchAlg参数判空return了 (参考21142);
 */
+(void) TIR_Fo_FromShortMem:(NSArray*)except_ps decoratorInModel:(AIShortMatchModel*)inModel{
    //1. 数据检查
    if (!inModel) return;
    AIFoNodeBase *maskFo = ARRISOK(inModel.matchAlgs) ? inModel.protoFo : inModel.matchAFo;
    
    NSLog(@"\n\n------------------------------- 瞬时时序识别 -------------------------------\n%@:%@->%@",ARRISOK(inModel.matchAlgs) ? @"protoFo" : @"matchAFo",Fo2FStr(maskFo),Mvp2Str(maskFo.cmvNode_p));
    //2. 调用通用时序识别方法 (checkItemValid: 可考虑写个isBasedNode()判断,因protoAlg可里氏替换,目前仅支持后两层)
    [self partMatching_FoV1Dot5:maskFo except_ps:except_ps decoratorInModel:inModel findCutIndex:^NSInteger(AIFoNodeBase *matchFo, NSInteger lastMatchIndex) {
        //3. 当fromTIM时,cutIndex=lastAssIndex;
        return lastMatchIndex;
    }];
    
    //3. 加强RFos的抽具象关联;
    for (AIMatchFoModel *item in inModel.matchRFos) {
        AIFoNodeBase *absRFo = [AIAnalogy analogyOutside:maskFo assFo:item.matchFo type:ATSame createAbsAlgBlock:nil];
        if (Log4AnalogyAbsRFo) NSLog(@">>> 抽象absRFo: %@\t\tFrom MatchRFo: %@",Fo2FStr(absRFo),Fo2FStr(item.matchFo));
        if (absRFo && ![inModel.absRFos containsObject:absRFo]) [inModel.absRFos addObject:absRFo];
    }
}


/**
 *  MARK:--------------------时序局部匹配算法V1--------------------
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
 *  MARK:--------------------时序局部匹配算法V1.5--------------------
 *  @desc
 *      1. 由v1整理而来,逻辑与v1一致 (将v1中checkItemValid和assFoBlock回调,直接写在方法中,而不由外界传入);
 *      2. 时序识别v1.5 (在V1的基础上改的,与V2最大的区别,是其未按照索引计数排序);
 *
 *  @status 启用,因为v2按照countDic排序的方式,不利于找出更确切的抽象结果;
 *
 *  MARK:--------------------时序全含匹配算法v2--------------------
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
            [TIRUtils TIR_Fo_CheckFoValidMatch:maskFo assFo:assFo success:^(NSInteger lastAssIndex, CGFloat matchValue) {
                if (Log4MFo) NSLog(@"时序识别item SUCCESS 完成度:%f %@->%@",matchValue,Fo2FStr(assFo),Mvp2Str(assFo.cmvNode_p));
                NSInteger cutIndex = findCutIndex(assFo,lastAssIndex);
                AIMatchFoModel *newMatchFo = [AIMatchFoModel newWithMatchFo:assFo matchFoValue:matchValue lastMatchIndex:lastAssIndex cutIndex:cutIndex];
                if (assFo.cmvNode_p) {
                    [inModel.matchPFos addObject:newMatchFo];
                }else{
                    [inModel.matchRFos addObject:newMatchFo];
                }
            }];
        }
    }
    NSLog(@"\n=====> 时序识别Finish (PFos数:%lu)",(unsigned long)inModel.matchPFos.count);
    for (AIMatchFoModel *item in inModel.matchPFos)
        NSLog(@"> %@->{%@} (匹配度:%@)",Fo2FStr(item.matchFo),Mvp2Str(item.matchFo.cmvNode_p),Double2Str_NDZ(item.matchFoValue));
    NSLog(@"\n=====> 时序识别Finish (RFos数:%lu)",(unsigned long)inModel.matchRFos.count);
    for (AIMatchFoModel *item in inModel.matchRFos)
        NSLog(@"> %@ (匹配度:%@)",Fo2FStr(item.matchFo),Double2Str_NDZ(item.matchFoValue));
}

/**
 *  MARK:--------------------预测--------------------
 *  @desc
 *      1. 对预测的处理,进行生物钟触发器;
 *      2. 支持:
 *          a.HNGL(因为时序识别处关闭,所以假启用状态);
 *          b.MV(启用);
 *  @version
 *      2021.01.27: 非末位也支持mv触发器 (参考22074-BUG2);
 *      2021.02.01: 支持反向反馈外类比 (参考22107);
 *      2021.02.04: 虚mv不会触发In反省,否则几乎永远为逆 (因为本来虚mv就不会有输入的);
 *      2021.02.04: 虚mv也要支持In反省,否则无法形成对R-模式助益 (参考22108);
 *  @todo
 *      2021.03.22: 迭代提高预测的准确性(1.以更具象为准(猴子怕虎,悟空不怕) 2.以更全面为准(猴子有麻醉枪不怕虎)) (参考22182);
 *  @status
 *      1. 后半部分"有mv判断"生效中;
 *      2. 前半部分"HNGL末位判断"未启用 (因为matchFos中未涵盖HNGL类型);
 */
+(void) tir_Forecast:(AIShortMatchModel*)inModel{
    //1. 数据检查;
    if (!inModel) return;
    AIFoNodeBase *protoFo = inModel.protoFo;
    
    //3. 预测处理_反向反馈类比_生物钟触发器;
    for (AIMatchFoModel *item in inModel.matchPFos) {
        AIFoNodeBase *matchFo = item.matchFo;
        BOOL isHNGL = [TOUtils isHNGL:matchFo.pointer];
        if (isHNGL) {
            //末位判断;
            if (item.cutIndex2 == matchFo.count - 2) {
                item.status = TIModelStatus_LastWait;
                double deltaTime = [NUMTOOK(ARR_INDEX_REVERSE(matchFo.deltaTimes, 0)) doubleValue];
                [AITime setTimeTrigger:deltaTime trigger:^{
                    //4. 反向反馈类比(成功/未成功)的主要原因;
                    AnalogyType type = (item.status == TIModelStatus_LastWait) ? ATSub : ATPlus;
                    NSLog(@"---//触发器HNGL_触发: %@ (%@)",Fo2FStr(matchFo),ATType2Str(type));
                    [AIAnalogy analogy_InRethink:item shortFo:protoFo type:type];
                    
                    //5. 失败状态标记;
                    if (item.status == TIModelStatus_LastWait) item.status = TIModelStatus_OutBackNone;
                }];
            }
        }else{
            //有mv判断;
            if (matchFo.cmvNode_p) {
                item.status = TIModelStatus_LastWait;
                double deltaTime = [TOUtils getSumDeltaTime2Mv:matchFo cutIndex:item.cutIndex2];
                [AITime setTimeTrigger:deltaTime trigger:^{
                    //4. 反向反馈类比(成功/未成功)的主要原因 (参考tip_OPushM());
                    AnalogyType type = ATDefault;
                    if ([AINetUtils isVirtualMv:matchFo.cmvNode_p]) {
                        //a. 虚mv反馈反向:S,未反馈:P;
                        type = (item.status == TIModelStatus_OutBackDiffDelta) ? ATSub : ATPlus;
                    }else{
                        //b. 实mv反馈正向:P,未反馈:S;
                        type = (item.status == TIModelStatus_OutBackSameDelta) ? ATPlus : ATSub;
                    }
                    
                    NSLog(@"---//触发器Mv_触发: %@ (%@ | %@)",Fo2FStr(matchFo),TIStatus2Str(item.status),ATType2Str(type));
                    
                    //4. 输入期反省类比 (有OutBack,SP类型时执行);
                    [AIAnalogy analogy_InRethink:item shortFo:protoFo type:type];
                    
                    //5. 反向反馈外类比 (无OutBack,为Wait时执行);
                    if (item.status == TIModelStatus_LastWait) {
                        [AIAnalogy analogy_Feedback_Diff:protoFo matchFo:matchFo];
                    }
                    
                    //5. 失败状态标记;
                    if (item.status == TIModelStatus_LastWait) item.status = TIModelStatus_OutBackNone;
                }];
            }
        }
    }
}

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 决策--------------------
 *  @title 外层输入对In短时记忆的影响处理 (参考22052-2);
 *  @version
 *      2021.01.24: 多时序识别支持,使之更全面的支持每个matchFo的status更新 (参考22073-todo6);
 *  @status 非启动状态,因为时序识别中,未涵盖HNGL类型,所以并未对HNGL进行预测;
 */
+(void) tir_OPushM:(AIShortMatchModel*)newInModel{
    //1. 数据检查
    NSArray *inModels = theTC.inModelManager.models;
    if (!newInModel) return;
    if (Log4TIROPushM) NSLog(@"\n\n=============================== tir_OPushM ===============================\n输入M:%@\n输入P:%@",Alg2FStr(newInModel.matchAlg),Alg2FStr(newInModel.protoAlg));
    
    //2. 判断最近一次input是否与等待中outModel相匹配 (匹配,比如吃,确定自己是否真吃了);
    for (AIShortMatchModel *inModel in inModels) {
        for (AIMatchFoModel *waitModel in inModel.matchPFos) {
            //3. 取出等待中的_非wait状态的,不处理;
            if (waitModel.status != TIModelStatus_LastWait) continue;
            AIFoNodeBase *waitMatchFo = waitModel.matchFo;
            if (Log4TIROPushM) NSLog(@"==> checkTIModel=MatchFo: %@",Fo2FStr(waitMatchFo));
            AIKVPointer *waitLastAlg_p = ARR_INDEX_REVERSE(waitMatchFo.content_ps, 0);
            if (!waitLastAlg_p) continue;
            
            //4. 对H和GL分别做处理;
            if([TOUtils isH:waitMatchFo.pointer]){
                //2. 直接判断H是否mIsC,是则OutBackYes;
                BOOL mIsC = [TOUtils mIsC_1:newInModel.protoAlg.pointer c:waitLastAlg_p];
                if (mIsC) {
                    waitModel.status = TIModelStatus_OutBackReason;
                    NSLog(@"tir_OPushM: H有效");
                }
            }else if([TOUtils isG:waitMatchFo.pointer] || [TOUtils isL:waitMatchFo.pointer]){
                //3. 根据matchFo,找到glAlg (参考21115) (waitLastAlg相当于21115中的backConAlg);
                NSArray *glAlgPorts = [AINetUtils absPorts_All:[SMGUtils searchNode:waitLastAlg_p]];
                glAlgPorts = [SMGUtils filterPorts:glAlgPorts havTypes:@[@(ATGreater),@(ATLess)] noTypes:nil];
                NSArray *glAlgs = Ports2Pits(glAlgPorts);
                
                //4. 根据glAlg取出glValue,以根据其identifier分辨当前符合变化的稀疏码标识;
                for (AIKVPointer *item in glAlgs) {
                    AIAlgNodeBase *glAlg = [SMGUtils searchNode:item];
                    AIKVPointer *glValue = ARR_INDEX(glAlg.content_ps, 0);
                    
                    //5. 取出hope和real
                    AIKVPointer *hopeValue_p = [SMGUtils filterSameIdentifier_p:glValue b_ps:inModel.protoAlg.content_ps];
                    AIKVPointer *realValue_p = [SMGUtils filterSameIdentifier_p:glValue b_ps:newInModel.protoAlg.content_ps];
                    if (!hopeValue_p || !realValue_p) continue;
                    
                    //e. mIsC判断 (20201226:在21204BUG修复后训练时,发现mIsC有时是cIsM,所以都判断下);
                    NSArray *newInMatchAlg_ps = Nodes2Pits(newInModel.matchAlgs);
                    BOOL mIsC = [TOUtils mIsC_1:@[waitLastAlg_p] cs:newInMatchAlg_ps];
                    if (!mIsC) mIsC = [TOUtils mIsC_1:newInMatchAlg_ps cs:@[waitLastAlg_p]];
                    if (Log4TIROPushM) NSLog(@"GL有效判断_mIsC:(M=MFo末位 C=%@) 结果:%d", Pits2FStr(newInMatchAlg_ps),mIsC);
                    if (!mIsC) continue;
                    
                    //c. 对期望与实际稀疏码比较得到实际ATType;
                    //d. 当实际ATType与等待中的ATType一致时,符合预期 (20201226改为判断bFo,因为只有bFo才携带了waitTypeDS,参考21204);
                    AnalogyType realType = [ThinkingUtils compare:hopeValue_p valueB_p:realValue_p];
                    AnalogyType waitType = [ThinkingUtils convertDS2AnalogyType:waitMatchFo.pointer.dataSource];
                    
                    //e. 只有符合变化时,才改为OuterBack,否则不改,使之反省类比时,可以发现不符合问题;
                    if (realType == waitType){
                        waitModel.status = TIModelStatus_OutBackReason;
                        NSLog(@"tir_OPushM: GL有效");
                    }
                }
            }
        }
    }
}

@end
