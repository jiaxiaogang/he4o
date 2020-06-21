//
//  AIThinkInAnalogy.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/3/20.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkInAnalogy.h"
#import "AIKVPointer.h"
#import "AINetAbsFoNode.h"
#import "AIAbsAlgNode.h"
#import "AIAlgNode.h"
#import "AIPort.h"
#import "AINet.h"
#import "AINetUtils.h"
#import "AIFrontOrderNode.h"
#import "AIAbsCMVNode.h"
#import "AINetIndex.h"
#import "AINetIndexUtils.h"
#import "ThinkingUtils.h"
#import "TIRUtils.h"
#import "AIShortMatchModel.h"
#import "AICMVNode.h"
#import "AINetAbsCMVUtil.h"
//temp
#import "NVHeUtil.h"

@implementation AIThinkInAnalogy

//MARK:===============================================================
//MARK:                     < 外类比部分 >
//MARK:===============================================================

/**
 *  MARK:--------------------fo外类比--------------------
 *  @version
 *      20200215: 有序外类比: 将forin循环fo和assFo改为反序,并记录上次类比位置jMax (因出现了[果,果,吃,吃]这样的异常时序) 参考n18p11;
 */
+(void) analogyOutside:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy type:(AnalogyType)type{
    //1. 类比orders的规律
    NSMutableArray *orderSames = [[NSMutableArray alloc] init];
    if (fo && assFo) {

        //2. 外类比有序进行 (记录jMax & 反序)
        NSInteger jMax = assFo.content_ps.count - 1;
        for (NSInteger i = fo.content_ps.count - 1; i >= 0; i--) {
            for (NSInteger j = jMax; j >= 0; j--) {
                AIKVPointer *algNodeA_p = fo.content_ps[i];
                AIKVPointer *algNodeB_p = assFo.content_ps[j];
                //2. A与B直接一致则直接添加 & 不一致则如下代码;
                if ([algNodeA_p isEqual:algNodeB_p]) {
                    [orderSames insertObject:algNodeA_p atIndex:0];
                    jMax = j - 1;
                    break;
                }else{
                    ///1. 构建时,消耗能量值;
                    if (canAssBlock && !canAssBlock()) {
                        break;
                    }

                    ///2. 取出algNodeA & algNodeB
                    AIAlgNodeBase *algNodeA = [SMGUtils searchNode:algNodeA_p];
                    AIAlgNodeBase *algNodeB = [SMGUtils searchNode:algNodeB_p];

                    ///3. values->absPorts的认知过程
                    if (algNodeA && algNodeB) {
                        NSMutableArray *sameValue_ps = [[NSMutableArray alloc] init];
                        for (AIKVPointer *valueA_p in algNodeA.content_ps) {
                            for (AIKVPointer *valueB_p in algNodeB.content_ps) {
                                if ([valueA_p isEqual:valueB_p] && ![sameValue_ps containsObject:valueB_p]) {
                                    [sameValue_ps addObject:valueB_p];
                                    break;
                                }
                            }
                        }
                        if (ARRISOK(sameValue_ps)) {
                            AIAbsAlgNode *createAbsNode = [theNet createAbsAlg_NoRepeat:sameValue_ps conAlgs:@[algNodeA,algNodeB] isMem:false];
                            if (createAbsNode) {
                                [orderSames insertObject:createAbsNode.pointer atIndex:0];
                                jMax = j - 1;
                                if (type == ATSame) {
                                    if (Log4SameAna) NSLog(@"---> 构建:%@ ConFrom (A%ld,A%ld)",Alg2FStr(createAbsNode),algNodeA.pointer.pointerId,algNodeB.pointer.pointerId);
                                }
                            }
                            ///4. 构建时,消耗能量值;
                            if (updateEnergy) {
                                updateEnergy(-0.1f);
                            }
                        }
                    }
                }
            }
        }
    }

    //3. 外类比构建
    //TODO; 在精细化训练第6步,valueSames长度为7,构建后从可视化去看,其概念长度却是0;
    [self analogyOutside_Creater:orderSames fo:fo assFo:assFo type:type];
}

/**
 *  MARK:--------------------外类比的构建器--------------------
 *  1. 构建absFo
 *  2. 构建absCmv
 *  @todo
 *      20200416 - TODO_NEXT_VERSION:方法中absFo是防重的,如果absFo并非新构建,而又为其构建了absMv,则会有多个mv指向同一个fo的问题;
 */
+(void)analogyOutside_Creater:(NSArray*)orderSames fo:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo type:(AnalogyType)type{
    //2. 数据检查;
    if (ARRISOK(orderSames) && ISOK(fo, AIFoNodeBase.class) && ISOK(assFo, AIFoNodeBase.class)) {

        //3. fo和assFo本来就是抽象关系时_直接关联即可;
        BOOL samesEqualAssFo = orderSames.count == assFo.content_ps.count && [SMGUtils containsSub_ps:orderSames parent_ps:assFo.content_ps];
        BOOL jumpForAbsAlreadyHav = (ISOK(assFo, AINetAbsFoNode.class) && samesEqualAssFo);
        AINetAbsFoNode *result = nil;
        if (jumpForAbsAlreadyHav) {
            result = (AINetAbsFoNode*)assFo;
            [AINetUtils relateFoAbs:result conNodes:@[fo] isNew:false];
            [AINetUtils insertRefPorts_AllFoNode:result.pointer order_ps:result.content_ps ps:result.content_ps];
        }else{
            //4. 取foDifStrong
            NSInteger foDifStrong = 1;
            AICMVNodeBase *foMv = [SMGUtils searchNode:fo.cmvNode_p];
            AICMVNodeBase *assMv = [SMGUtils searchNode:assFo.cmvNode_p];
            if (foMv && assMv) {
                NSInteger absUrgentTo = [AINetAbsCMVUtil getAbsUrgentTo:@[fo.cmvNode_p,assFo.cmvNode_p]];
                foDifStrong = absUrgentTo;
            }
            
            //5. 构建absFoNode
            NSString *foDS = [ThinkingUtils getAnalogyTypeDS:type];
            result = [ThinkingUtils createAbsFo_NoRepeat_General:@[fo,assFo] content_ps:orderSames ds:foDS difStrong:foDifStrong];
            
            //6. createAbsCmvNode (当正向类比,且result没有cmv指向时);
            if (type == ATSame && assMv && !result.cmvNode_p) {
                AIAbsCMVNode *resultMv = [theNet createAbsCMVNode_Outside:nil aMv_p:fo.cmvNode_p bMv_p:assMv.pointer];
                [AINetUtils relateFo:result mv:resultMv];//cmv模型连接;
            }
        }

        //调试短时序; (先仅打外类比日志);
        if (result) {
            if (type == ATSame) {
                if (Log4SameAna) NSLog(@"--->> 构建时序:%@->%@",Fo2FStr(result),Mvp2Str(result.cmvNode_p));
            }else{
                if (Log4InAna) NSLog(@"----> 内中有外_构建:%@ from(%ld,%ld)",Fo2FStr(result),fo.pointer.pointerId,assFo.pointer.pointerId);
            }
        }
    }
}


//MARK:===============================================================
//MARK:                     < 内类比部分 >
//MARK:===============================================================

/**
 *  MARK:--------------------fo内类比 (内中有外,找不同算法)--------------------
 *  @param checkFo      : 要处理的fo.orders;
 *  @param canAssBlock  : energy判断器 (为null时,无限能量);
 *  @param updateEnergy : energy消耗器 (为null时,不消耗能量值);
 *
 *  1. 此方法对一个fo内的orders进行内类比,并将找到的变化进行抽象构建网络;
 *  2. 如: 绿瓜变红瓜,如远坚果变近坚果;
 *  3. 每发现一个有效变化目标,则构建2个absAlg和2个absFo; (参考n15p18内类比构建图)
 *  注: 目前仅支持一个微信息变化的规律;
 *  TODO: 将内类比的类比部分代码,进行单独PrivateMethod,然后与外类比中调用的进行复用;
 *  @desc 代码说明:
 *      1. "有无"的target需要去重,因为a3.identifier = a4.identifier,而a4需要外类比,所以去重才能联想到同质fo;
 *      2. "有无"在191030改成单具象节点 (因为坚果的抽象不是坚果皮) 参考179_内类比全流程回顾;
 *  @迭代记录:
 *      2020.03.24: 内类比多码支持 (大小支持多个稀疏码变大/小 & 有无支持match.absPorts中多个变有/无);
 */
+(void) analogyInner_FromTIR:(AIFoNodeBase*)checkFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy{
    //1. 数据检查
    if (ISOK(checkFo, AIFoNodeBase.class) && checkFo.content_ps.count >= 2) {
        //2. 最后一个元素,向前分别与orders后面所有元素进行类比
        NSLog(@"\n\n------------------------------- 内类比 -------------------------------\n%@",Fo2FStr(checkFo));
        for (NSInteger i = checkFo.content_ps.count - 2; i >= 0; i--) {
            [self analogyInner:checkFo aIndex:i bIndex:checkFo.content_ps.count - 1 canAss:canAssBlock updateEnergy:updateEnergy];
        }
    }
}
+(void) analogyInner:(AIFoNodeBase*)checkFo aIndex:(NSInteger)aIndex bIndex:(NSInteger)bIndex canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy{
    //1. 数据检查
    if (!ISOK(checkFo, AIFoNodeBase.class)) {
        return;
    }
    NSArray *orders = ARRTOOK(checkFo.content_ps);

    //3. 检查能量值
    if (canAssBlock && !canAssBlock()) {
        //训练距离-测到问题:发现BUG:小鸟仅发现了速度变化,飞行方向变化,却没有发现距离变化;
        return;
    }

    //4. 取出两个概念
    AIKVPointer *algA_p = ARR_INDEX(orders, aIndex);
    AIKVPointer *algB_p = ARR_INDEX(orders, bIndex);
    AIAlgNode *algNodeA = [SMGUtils searchNode:algA_p];
    AIAlgNode *algNodeB = [SMGUtils searchNode:algB_p];

    //5. 内类比找不同 (比大小:同区不同值 / 有无)
    if (algNodeA && algNodeB){
        //a. 内类比大小;
        if (Log4InAna) NSLog(@"-----------内类比-----------");
        if (Log4InAna) NSLog(@"%ld: %@",(long)aIndex,Alg2FStr(algNodeA));
        if (Log4InAna) NSLog(@"%ld: %@",(long)bIndex,Alg2FStr(algNodeB));
        NSArray *rangeAlg_ps = ARR_SUB(orders, aIndex + 1, bIndex - aIndex - 1);
        [self analogyInner_GL:checkFo algA:algNodeA algB:algNodeB rangeAlg_ps:rangeAlg_ps createdBlock:^(AINetAbsFoNode *createFo,AnalogyType type) {
            //b. 消耗思维活跃度 & 内中有外
            if (updateEnergy) updateEnergy(-0.1f);
            [self analogyInner_Outside:createFo type:type canAss:canAssBlock updateEnergy:updateEnergy];
        }];

        //c. 内类比有无;
        [self analogyInner_HN:checkFo algA:algNodeA algB:algNodeB rangeAlg_ps:rangeAlg_ps createdBlock:^(AINetAbsFoNode *createFo,AnalogyType type) {
            //d. 消耗思维活跃度 & 内中有外
            if (updateEnergy) updateEnergy(-0.1f);
            [self analogyInner_Outside:createFo type:type canAss:canAssBlock updateEnergy:updateEnergy];
        }];
    }
}

/**
 *  MARK:--------------------内类比大小--------------------
 */
+(void) analogyInner_GL:(AIFoNodeBase*)checkFo algA:(AIAlgNodeBase*)algA algB:(AIAlgNodeBase*)algB rangeAlg_ps:(NSArray*)rangeAlg_ps createdBlock:(void(^)(AINetAbsFoNode *createFo,AnalogyType type))createdBlock{
    //1. 数据检查
    rangeAlg_ps = ARRTOOK(rangeAlg_ps);
    if (!algA || !algB) {
        return;
    }

    //2. 取a差集和b差集;
    NSArray *aSub_ps = [SMGUtils removeSub_ps:algB.content_ps parent_ps:algA.content_ps];
    NSArray *bSub_ps = [SMGUtils removeSub_ps:algA.content_ps parent_ps:algB.content_ps];

    //3. 找出ab同标识字典;
    NSMutableDictionary *sameIdentifier = [SMGUtils filterSameIdentifier_ps:aSub_ps b_ps:bSub_ps];

    //4. 分别进行比较大小并构建变化;
    for (NSData *key in sameIdentifier.allKeys) {
        AIKVPointer *a_p = DATA2OBJ(key);
        AIKVPointer *b_p = [sameIdentifier objectForKey:key];
        //a. 对比微信息 (MARK_VALUE:如微信息去重功能去掉,此处要取值再进行对比)
        AnalogyType type = [ThinkingUtils compare:a_p valueB_p:b_p];
        //b. 调试a_p和b_p是否合格,应该同标识,同文件夹名称,不同pId;
        if (Log4InAnaGL) NSLog(@"内类比大小: %@ -> %@ From(前:A%ld后:A%ld)",Pit2FStr(a_p),Pit2FStr(b_p),algA.pointer.pointerId,algB.pointer.pointerId);
        //d. 构建小/大;
        if (type != ATDefault) {
            AINetAbsFoNode *create = [self analogyInner_Creater:type algsType:a_p.algsType dataSource:a_p.dataSource frontConAlg:algA backConAlg:algB rangeAlg_ps:rangeAlg_ps conFo:checkFo];
            if (createdBlock) createdBlock(create,type);
        }
    }
}

/**
 *  MARK:--------------------内类比有无--------------------
 *  @param checkFo : 从TIR传过来时,为瞬时组成的protoFo (当前protoFo由每桢的matchAlg构建);
 *  @version
 *      20200421 - 将a/bFocusAlg改成直接使用algA/algB (因为现在protoFo的元素即直接是matchAlg);
 */
+(void) analogyInner_HN:(AIFoNodeBase*)checkFo algA:(AIAlgNodeBase*)algA algB:(AIAlgNodeBase*)algB rangeAlg_ps:(NSArray*)rangeAlg_ps createdBlock:(void(^)(AINetAbsFoNode *createFo,AnalogyType type))createdBlock{
    //1. 数据检查
    if (!algA || !algB) return;
    rangeAlg_ps = ARRTOOK(rangeAlg_ps);
    //AIAlgNodeBase *aFocusAlg = [ThinkingUtils getMatchAlgWithProtoAlg:algA];if (aFocusAlg == nil) aFocusAlg = algA;
    //AIAlgNodeBase *bFocusAlg = [ThinkingUtils getMatchAlgWithProtoAlg:algB];if (bFocusAlg == nil) bFocusAlg = algB;
    AIAlgNodeBase *aFocusAlg = algA;
    AIAlgNodeBase *bFocusAlg = algB;
    
    
    //2. 收集a和b的概念辐射合集 (取自身 + 自身的一层抽象);
    NSMutableArray *aSum_ps = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:aFocusAlg]];
    [aSum_ps addObject:aFocusAlg.pointer];
    NSMutableArray *bSum_ps = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:bFocusAlg]];
    [bSum_ps addObject:bFocusAlg.pointer];

    //2. 取a差集和b差集;
    NSArray *aSub_ps = [SMGUtils removeSub_ps:bSum_ps parent_ps:aSum_ps];
    NSArray *bSub_ps = [SMGUtils removeSub_ps:aSum_ps parent_ps:bSum_ps];

    //3. a变无
    if (Log4InAnaHN) NSLog(@"--------------内类比 (有无) 前: [%@] -> [%@]",Pits2FStr(aSub_ps),Pits2FStr(bSub_ps));
    for (AIKVPointer *sub_p in aSub_ps) {
        AIAlgNodeBase *target = [SMGUtils searchNode:sub_p];
        AINetAbsFoNode *create = [self analogyInner_Creater:ATNone algsType:sub_p.algsType dataSource:sub_p.dataSource frontConAlg:target backConAlg:target rangeAlg_ps:rangeAlg_ps conFo:checkFo];
        if (createdBlock) createdBlock(create,ATNone);
    }

    //4. b变有
    for (AIKVPointer *sub_p in bSub_ps) {
        AIAlgNodeBase *target = [SMGUtils searchNode:sub_p];
        AINetAbsFoNode *create = [self analogyInner_Creater:ATHav algsType:sub_p.algsType dataSource:sub_p.dataSource frontConAlg:target backConAlg:target rangeAlg_ps:rangeAlg_ps conFo:checkFo];
        if (createdBlock) createdBlock(create,ATHav);
    }
}

/**
 *  MARK:--------------------内类比构建器--------------------
 *  @param type : 内类比类型,大小有无; (必须为四值之一,否则构建未知节点)
 *  @param rangeAlg_ps  : 在i-j之间的orders; (如 "a1 balabala a2" 中,balabala就是rangeOrders)
 *  @param algsType & dataSource : 构建"有无大小"稀疏码的at&ds  (有无时为概念地址,大小时为稀疏码地址);
 *      1. 构建有无时,与变有/无的概念的标识相同;
 *      2. 构建大小时,与a_p/b_p标识相同 (因为只是使用at&ds,所以用哪个都行);
 *  @param frontConAlg  :
 *      1. 构建有无时,以变有/无的概念为frontConAlg;
 *      2. 构建大小时,以"微信息所在的概念algA为frontConAlg;
 *  @param backConAlg   :
 *      1. 构建有无时,以变有/无的概念为backConAlg;
 *      2. 构建大小时,以"微信息所在的概念algB为backConAlg;
 *  @param conFo : 用来构建抽象具象时序时,作为具象节点使用;
 *  @作用
 *      1. 构建动态微信息 (有去重);
 *      2. 构建动态概念 (有去重);
 *      3. 构建abFoNode时序 (未去重);
 *  @注意: 此处algNode和algNode_Inner应该是组分关系,但先保持抽具象关系,看后面测试,有没别的影响,再改 (参考179_内类比全流程回顾)
 *  @version
 *      20200329: 将frontAlg去掉,只保留backAlg (以使方便TOR中联想使用);
 *      20200419: 将构建alg和fo指定ds为:backData的值 (以便此后取absPorts时,可以根据指针进行类型筛选);
 */
+(AINetAbsFoNode*)analogyInner_Creater:(AnalogyType)type algsType:(NSString*)algsType dataSource:(NSString*)dataSource frontConAlg:(AIAlgNodeBase*)frontConAlg backConAlg:(AIAlgNodeBase*)backConAlg rangeAlg_ps:(NSArray*)rangeAlg_ps conFo:(AIFoNodeBase*)conFo{
    //1. 数据检查
    rangeAlg_ps = ARRTOOK(rangeAlg_ps);
    algsType = STRTOOK(algsType);
    dataSource = STRTOOK(dataSource);
    if (!frontConAlg || !backConAlg || !conFo) return nil;

    //2. 获取front&back稀疏码值;
    NSInteger backData = type;

    //3. 构建微信息;
    AIKVPointer *backValue_p = [theNet getNetDataPointerWithData:@(backData) algsType:algsType dataSource:dataSource];

    //4. 构建抽象概念 (20190809注:此处可考虑,type为大/小时,不做具象指向,因为大小概念,本来就是独立的节点);
    NSString *afDS = [ThinkingUtils getAnalogyTypeDS:type];
    AIAlgNodeBase *backAlg = [theNet createAbsAlg_NoRepeat:@[backValue_p] conAlgs:@[backConAlg] isMem:false ds:afDS];

    //5. 构建抽象时序; (小动致大 / 大动致小) (之间的信息为balabala)
    AINetAbsFoNode *result = [TIRUtils createInnerAbsFo:backAlg rangeAlg_ps:rangeAlg_ps conFo:conFo ds:afDS];

    //TODOTOMORROW: 调试找不到glAlg的bug;
    //1. 经查,内类比的两个概念中,其中一个没有"距离"稀疏码,导致无法类比出"距离"GL节点;
    //2. 通过此处,查为什么n20p2BUG3会有距50的节点参与到内类比中来?

    //6. 调试;
    if (type == ATHav || type == ATNone) {
        if (Log4InAnaHN) NSLog(@"--> 构建:%@ ConFrom:%@ 构建Fo:%@",Alg2FStr(backAlg),Alg2FStr(backConAlg),Fo2FStr(result));
    }else if (type == ATGreater || type == ATLess) {
        if (Log4InAnaGL) NSLog(@"--> 构建:%@ ConFrom:A%ld 构建Fo:%@",Alg2FStr(backAlg),backConAlg.pointer.pointerId,Fo2FStr(result));
    }
    return result;
}

/**
 *  MARK:--------------------内类比的内中有外--------------------
 *  1. 根据abFo联想assAbFo并进行外类比 (根据微信息来索引查找assAbFo)
 *  2. 复用外类比方法;
 *  3. 一个抽象了a1-range-a2的时序,必然是抽象的,必然是硬盘网络中的;所以此处不必考虑联想内存网络中的assAbFo;
 *  @version
 *      20200329: 将assFo依range来联想,而非"有/无/大/小";以解决类比抽象时容易过度收束的问题;
 */
+(void)analogyInner_Outside:(AINetAbsFoNode*)abFo type:(AnalogyType)type canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy{
    //1. 数据检查
    if (ISOK(abFo, AINetAbsFoNode.class) && abFo.content_ps.count > 1) {
        //2. 取backAlg (用来判断取正确的"变有/无/大/小");
        AIPointer *back_p = ARR_INDEX(abFo.content_ps, abFo.content_ps.count - 1);
        AIAlgNodeBase *backAlg = [SMGUtils searchNode:back_p];
        NSArray *backRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Alg:backAlg]];
        AIFoNodeBase *assFo = nil;

        //3. 根据range联想,从倒数第2个,开始向前逐一联想refPorts;
        for (NSInteger i = abFo.content_ps.count - 2; i >= 0; i--) {
            AIKVPointer *item_p = ARR_INDEX(abFo.content_ps, i);
            AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item_p];
            NSArray *itemRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Alg:itemAlg]];

            //4. assAbFo的条件为: (包含item & 包含back & 不是abFo)
            for (AIKVPointer *itemRef_p in itemRef_ps) {
                if (![itemRef_p isEqual:abFo.pointer] && [backRef_ps containsObject:itemRef_p]) {
                    assFo = [SMGUtils searchObjectForPointer:itemRef_p fileName:kFNNode time:cRTNode];
                    break;
                }
            }

            //5. 取一条有效即break;
            if (assFo) break;
        }

        //6. 对abFo和assAbFo进行类比;
        [self analogyOutside:abFo assFo:assFo canAss:canAssBlock updateEnergy:updateEnergy type:type];
    }
}

@end

@implementation AIThinkInAnalogy (Feedback)

/**
 *  MARK:--------------------反向反馈类比--------------------
 *  @version
 *      20200416 - 原先ms和ps都导致{mv-},改为ms导致{mmv*rate},ps导致{pmv*rate};
 *      20200419 - 构建alg/fo都新增了与analogyType相对应的ds,以方便MC_Value使用;
 *      20200421 - 新增构建sameAbsAlg节点 (如无距果),如:都是苹果,怎么1甜2苦?此处构建"都是苹果",可用于MC_V3中判断M零距果和C远距果的关系;
 *      20200421 - 取消构建sameAbsAlg,因为MC算法不需要同级MC判定,所以此处也没用,关于MC有效性检查可参考:19102;
 */
+(void) analogy_Feedback_Diff:(AIShortMatchModel*)mModel shortFo:(AIFoNodeBase*)shortFo{
    //1. 数据检查 (MMv和PMV有效,且同区);
    if (!mModel || !mModel.matchFo || !shortFo) return;
    AIKVPointer *mMv_p = mModel.matchFo.cmvNode_p;
    AIKVPointer *pMv_p = shortFo.cmvNode_p;
    if (!mMv_p || !pMv_p || ![mMv_p.algsType isEqualToString:pMv_p.algsType] || ![mMv_p.dataSource isEqualToString:pMv_p.dataSource]) {
        return;
    }

    //2. 判断mModel.mv和protoFo.mv是否不相符 (一正一负);
    CGFloat mScore = [ThinkingUtils getScoreForce:mMv_p ratio:mModel.matchFoValue];
    CGFloat pScore = [ThinkingUtils getScoreForce:pMv_p ratio:1.0f];
    AnalogyType mType = [ThinkingUtils getInnerTypeWithScore:mScore];
    AnalogyType pType = [ThinkingUtils getInnerTypeWithScore:pScore];
    NSString *mDS = [ThinkingUtils getAnalogyTypeDS:mType];
    NSString *pDS = [ThinkingUtils getAnalogyTypeDS:pType];
    BOOL isDiff = ((mScore > 0 && pScore < 0) || (mScore < 0 && pScore > 0));
    if (Log4DiffAna) if (isDiff) NSLog(@"\n\n------------------------ 反向反馈类比 ------------------------\n%@->%@ \n%@->%@",Fo2FStr(mModel.matchFo),Mvp2Str(mMv_p),Fo2FStr(shortFo),Mvp2Str(pMv_p));
    if (!isDiff) return;

    //3. 提供类比收集"缺乏和多余"所需的两个数组;
    NSMutableArray *ms = [[NSMutableArray alloc] init];
    NSMutableArray *ps = [[NSMutableArray alloc] init];

    //4. 正向有序类比 (从protoFo中找mAlg_p的踪迹);
    NSInteger jStart = 0;
    for (NSInteger i = 0; i < mModel.matchFo.content_ps.count; i++) {
        //A. 类比_数据准备;
        AIKVPointer *mAlg_p = mModel.matchFo.content_ps[i];
        BOOL findM = false;
        for (NSInteger j = jStart; j < shortFo.content_ps.count; j++) {
            AIKVPointer *pAlg_p = shortFo.content_ps[j];
            BOOL findP = false;

            //B. 一级类比概念层 (匹配则说明jStart->j之间所有pAlg_p为多余 (含jStart,不含j"因为j本身匹配,无需收集));
            if ([mAlg_p isEqual:pAlg_p]) {
                [ps addObjectsFromArray:ARR_SUB(shortFo.content_ps, jStart, j-jStart)];
                findP = true;
            }else{
                //C. 二级类比稀疏码层-数据准备;
                AIAlgNodeBase *mAlg = [SMGUtils searchNode:mAlg_p];
                AIAlgNodeBase *pAlg = [SMGUtils searchNode:pAlg_p];
                if (!mAlg_p || !pAlg_p) continue;

                //a. 二级类比-进行类比;
                NSArray *sameValue_ps = [SMGUtils filterSame_ps:mAlg.content_ps parent_ps:pAlg.content_ps];
                NSArray *mSub_ps = [SMGUtils removeSub_ps:sameValue_ps parent_ps:mAlg.content_ps];
                NSArray *pSub_ps = [SMGUtils removeSub_ps:sameValue_ps parent_ps:pAlg.content_ps];
                AIAbsAlgNode *createAbsAlg = [theNet createAbsAlg_NoRepeat:sameValue_ps conAlgs:@[mAlg,pAlg] isMem:false];
                if (Log4DiffAna) NSLog(@"--> MP 抽象概念节点 %@",Alg2FStr(createAbsAlg));

                //b. 二级类比-部分有效
                if (sameValue_ps.count > 0) {
                    
                    //c. 匹配则说明jStart->j之间所有pAlg_p为多余 (含jStart,不含j"因为j在下面被二级收集);
                    [ps addObjectsFromArray:ARR_SUB(shortFo.content_ps, jStart, j-jStart)];
                    findP = true;

                    //d. 二级类比-收集缺乏 (都是苹果,怎么一个甜一个涩呢->"甜");
                    if (mSub_ps.count > 0) {
                        AIAbsAlgNode *createAbsAlg = [theNet createAbsAlg_NoRepeat:mSub_ps conAlgs:@[mAlg] isMem:false ds:mDS];
                        if (createAbsAlg) [ms addObject:createAbsAlg.pointer];
                        if (Log4DiffAna) NSLog(@"--> M.PS节点 %@",Alg2FStr(createAbsAlg));
                    }

                    //e. 二级类比-收集多余 (都是苹果,怎么一个甜一个涩呢->"涩");
                    if (pSub_ps.count > 0) {
                        AIAbsAlgNode *createAbsAlg = [theNet createAbsAlg_NoRepeat:pSub_ps conAlgs:@[pAlg] isMem:false ds:pDS];
                        if (createAbsAlg) [ps addObject:createAbsAlg.pointer];
                        if (Log4DiffAna) NSLog(@"--> P.PS节点 %@",Alg2FStr(createAbsAlg));
                    }
                    
                    //f. 构建共同抽象概念 (都是苹果,怎么一个甜一个涩呢->"苹果");
                    //AIAbsAlgNode *sameAbsAlg = [theNet createAbsAlg_NoRepeat:sameValue_ps conAlgs:@[mAlg,pAlg] isMem:false];
                    //NSLog(@"--> MP.Sames节点 %@",Alg2FStr(sameAbsAlg));
                }
            }
            //D. 无论一级还是二级,只要找到了jStart从下一个开始,标记finM=true;
            if (findP) {
                jStart = j + 1;
                findM = true;
                break;
            }
        }

        //4. 所有j中未找到m,将m收集为缺乏;
        if (!findM) {
            [ms addObject:mAlg_p];
        }
    }

    //5. 将最终都没收集的shortFo剩下的部分打包进多余 (jStart到end之间的pAlg_p(含jStart,含end));
    [ps addObjectsFromArray:ARR_SUB(shortFo.content_ps, jStart, shortFo.content_ps.count - jStart)];
    if (Log4DiffAna) NSLog(@"---> 反向反馈类比 ms:%@ ps:%@",Pits2FStr(ms),Pits2FStr(ps));
    
    //6. 构建ms & ps
    AIFoNodeBase *mSPFo = [self analogy_Feedback_Diff_Creater:mMv_p conFo:mModel.matchFo content_ps:ms type:mType];
    AIFoNodeBase *pSPFo = [self analogy_Feedback_Diff_Creater:pMv_p conFo:shortFo content_ps:ps type:pType];
    
    //7. 关联兄弟节点
    [AINetUtils relateBrotherFoA:mSPFo foB:pSPFo];
}

/**
 *  MARK:--------------------反向反馈类比构建器--------------------
 *  @version
 *      20200426 - 担责,责任元素担下所有责任 (计算mv的rate直接为1.0); //注:责任元素的平均担责,在MC_V3的badScore时计算;
 */
+(AIFoNodeBase*) analogy_Feedback_Diff_Creater:(AIKVPointer*)conMv_p conFo:(AIFoNodeBase*)conFo content_ps:(NSArray*)content_ps type:(AnalogyType)type{
    //1. 数据检查
    NSString *ds = [ThinkingUtils getAnalogyTypeDS:type];
    AICMVNodeBase *conMv = [SMGUtils searchNode:conMv_p];
    if(!conMv || !ARRISOK(content_ps) || !conFo) return nil;
    CGFloat rate = 1.0f;//(float)content_ps.count / conFo.content_ps.count;
    
    //2. 计算ms的价值变化量 (基准 x rate);
    NSInteger pUrgentTo = [NUMTOOK([AINetIndex getData:conMv.urgentTo_p]) integerValue];
    NSInteger pDelta = [NUMTOOK([AINetIndex getData:conMv.delta_p]) integerValue];
    NSInteger ms_UrgentTo = (float)pUrgentTo * rate;
    NSInteger ms_Delta = (float)pDelta * rate;

    //3. 构建mvNode
    AIKVPointer *urgent_p = [theNet getNetDataPointerWithData:@(ms_UrgentTo) algsType:conMv_p.algsType dataSource:conMv_p.dataSource];
    AIKVPointer *delta_p = [theNet getNetDataPointerWithData:@(ms_Delta) algsType:conMv_p.algsType dataSource:conMv_p.dataSource];
    AICMVNodeBase *createMv = [theNet createAbsMv:nil conMvs:@[conMv] at:conMv_p.algsType ds:conMv_p.dataSource urgentTo_p:urgent_p delta_p:delta_p];
    
    //4. 构建foNode
    AIFoNodeBase *createFo = [ThinkingUtils createAbsFo_NoRepeat_General:@[conFo] content_ps:content_ps ds:ds difStrong:ms_UrgentTo];
    
    //5. 连接mv基本模型;
    [AINetUtils relateFo:createFo mv:createMv];
    NSLog(@"----> 反向反馈类比 CreateFo内容:%@->%@",Fo2FStr(createFo),Mvp2Str(createMv.pointer));
    
    //6. 加强conMv方向索引和conFo索引强度;
    [theNet setMvNodeToDirectionReference:conMv difStrong:1];
    [AINetUtils insertRefPorts_AllFoNode:conFo.pointer order_ps:conFo.content_ps ps:conFo.content_ps];
    return createFo;
}

+(void) analogy_Feedback_Same:(AIShortMatchModel*)mModel shortFo:(AIFoNodeBase*)shortFo{
    //1. 数据检查;
    if (!mModel || !mModel.matchFo || !shortFo) return;
    
    //2. 检查同向;
    CGFloat mScore = [ThinkingUtils getScoreForce:mModel.matchFo.cmvNode_p ratio:mModel.matchFoValue];
    CGFloat sScore = [ThinkingUtils getScoreForce:shortFo.cmvNode_p ratio:1.0f];
    BOOL isSame = ((mScore > 0 && sScore > 0) || (mScore < 0 && sScore < 0));
    if (Log4SameAna) if(isSame) NSLog(@"\n\n------------------------ 正向反馈类比 ------------------------\n%@->%@ \n%@->%@",Fo2FStr(mModel.matchFo),Mvp2Str(mModel.matchFo.cmvNode_p),Fo2FStr(shortFo),Mvp2Str(shortFo.cmvNode_p));
    if (!isSame) return;
    
    //3. 类比 (与当前的analogy_Outside()较相似,所以暂不写,随后写时,也是将原有的_outside改成此_same类比方法);
    [self analogyOutside:shortFo assFo:mModel.matchFo canAss:^BOOL{
        return true;
    } updateEnergy:nil type:ATSame];
}

@end
