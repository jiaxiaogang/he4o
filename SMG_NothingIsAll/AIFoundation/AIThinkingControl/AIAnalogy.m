//
//  AIAnalogy.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/3/20.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIAnalogy.h"
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
#import "TOFoModel.h"
#import "TOAlgModel.h"
#import "TOUtils.h"
//temp
#import "NVHeUtil.h"

@implementation AIAnalogy

//MARK:===============================================================
//MARK:                     < 外类比部分 >
//MARK:===============================================================

/**
 *  MARK:--------------------fo外类比--------------------
 *  @version
 *      20200215: 有序外类比: 将forin循环fo和assFo改为反序,并记录上次类比位置jMax (因出现了[果,果,吃,吃]这样的异常时序) 参考n18p11;
 *      20200831: 支持反省外类比,得出更确切的ATSub原因,参考:20205-步骤4;
 */
+(void) analogyOutside:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy type:(AnalogyType)type createAbsAlgBlock:(void(^)(AIAlgNodeBase *createAlg,NSInteger foIndex,NSInteger assFoIndex))createAbsAlgBlock{
    //1. 类比orders的规律
    NSMutableArray *orderSames = [[NSMutableArray alloc] init];
    if (fo && assFo) {

        //2. 外类比有序进行 (记录jMax & 反序)
        NSInteger jMax = assFo.count - 1;
        for (NSInteger i = fo.count - 1; i >= 0; i--) {
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
                                    if (Log4SameAna) NSLog(@"---> 构建:%@ ConFrom (A%ld,A%ld)",Alg2FStr(createAbsNode),(long)algNodeA.pointer.pointerId,(long)algNodeB.pointer.pointerId);
                                }else{
                                    NSLog(@"---> type:%ld_外类比_构建:%@ ConFrom (A%ld,A%ld)",(long)type,Alg2FStr(createAbsNode),(long)algNodeA.pointer.pointerId,(long)algNodeB.pointer.pointerId);
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
 *  @version
 *      2020.07.22: 在外类比无需构建时 (即具象和抽象一致时),其方向索引强度+1;
 */
+(void)analogyOutside_Creater:(NSArray*)orderSames fo:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo type:(AnalogyType)type{
    //2. 数据检查;
    if (ARRISOK(orderSames) && ISOK(fo, AIFoNodeBase.class) && ISOK(assFo, AIFoNodeBase.class)) {

        //3. fo和assFo本来就是抽象关系时_直接关联即可;
        BOOL samesEqualAssFo = orderSames.count == assFo.count && [SMGUtils containsSub_ps:orderSames parent_ps:assFo.content_ps];
        BOOL jumpForAbsAlreadyHav = (ISOK(assFo, AINetAbsFoNode.class) && samesEqualAssFo);
        AINetAbsFoNode *result = nil;
        if (jumpForAbsAlreadyHav) {
            result = (AINetAbsFoNode*)assFo;
            [AINetUtils relateFoAbs:result conNodes:@[fo] isNew:false];
            [AINetUtils insertRefPorts_AllFoNode:result.pointer order_ps:result.content_ps ps:result.content_ps];
            if (type == ATSame) [theNet setMvNodeToDirectionReference:[SMGUtils searchNode:result.cmvNode_p] difStrong:1];
        }else{
            //4. 取foDifStrong
            NSInteger foDifStrong = 1;
            AICMVNodeBase *foMv = [SMGUtils searchNode:fo.cmvNode_p];
            AICMVNodeBase *assMv = [SMGUtils searchNode:assFo.cmvNode_p];
            if (foMv && assMv) {
                NSArray *conMvs = [SMGUtils searchNodes:@[fo.cmvNode_p,assFo.cmvNode_p]];
                NSInteger absUrgentTo = [AINetAbsCMVUtil getAbsUrgentTo:conMvs];
                foDifStrong = absUrgentTo;
            }
            
            //5. 构建absFoNode
            NSString *foDS = [ThinkingUtils getAnalogyTypeDS:type];
            result = [ThinkingUtils createAbsFo_NoRepeat_General:@[fo,assFo] content_ps:orderSames ds:foDS difStrong:foDifStrong];
            
            //5. 从fo和conFo.mvDeltaTime中提取mv导致时间隔,在relateFo之前,赋值到result中;
            result.mvDeltaTime = MAX(fo.mvDeltaTime, assFo.mvDeltaTime);
            
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
            }else {
                if (Log4InOutAna) NSLog(@"----> type:%ld_外类比_构建:%@ from(%ld,%ld)",type,Fo2FStr(result),(long)fo.pointer.pointerId,(long)assFo.pointer.pointerId);
            }
        }
    }
}


//MARK:===============================================================
//MARK:                     < 内类比部分 >
//MARK:===============================================================

/**
 *  MARK:--------------------fo内类比 (内中有外,找不同算法)--------------------
 *  _param checkFo      : 要处理的fo.orders;
 *  _param canAssBlock  : energy判断器 (为null时,无限能量);
 *  _param updateEnergy : energy消耗器 (为null时,不消耗能量值);
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
 *      2020.07.30: 对matchAFo的AB元素进行内类比有无时,构建其抽象概念;
 *      2020.07.30: 内类比大小用protoFo,内类比有无用matchAFo (参考20151-BUG4 & n20p15-todo5);
 */
+(void) analogyInner:(AIShortMatchModel*)mModel{
    if (!mModel) return;
    AIFoNodeBase *matchAFo = mModel.matchAFo;
    AIFoNodeBase *protoFo = mModel.protoFo;
    NSLog(@"\n\n------------------------------- 内类比 -------------------------------\nP:%@\nM:%@",Fo2FStr(protoFo),Fo2FStr(matchAFo));
    
    //1. 用protoFo做内类比大小;
    if (ISOK(protoFo, AIFoNodeBase.class) && protoFo.count >= 2) {
        
        //2. 最后一个元素,向前分别与orders后面所有元素进行类比
        for (NSInteger i = protoFo.count - 2; i >= 0; i--) {
            
            //3. 取出两个概念
            NSInteger lastIndex = protoFo.count - 1;
            AIAlgNode *algA = [SMGUtils searchNode:ARR_INDEX(protoFo.content_ps, i)];
            AIAlgNode *algB = [SMGUtils searchNode:ARR_INDEX(protoFo.content_ps, lastIndex)];
            
            //4. 内类比找不同 (比大小:同区不同值)
            if (algA && algB){
                if (Log4InAna) NSLog(@"-----------内类比大小-----------\n%ld: %@\n%ld: %@",(long)i,Alg2FStr(algA),(long)lastIndex,Alg2FStr(algB));
                
                //5. 内类比大小;
                NSArray *rangeAlg_ps = ARR_SUB(protoFo.content_ps, i + 1, lastIndex - i - 1);
                [self analogyInner_GL:protoFo algA:algA algB:algB rangeAlg_ps:rangeAlg_ps partAlg_ps:mModel.partAlg_ps];
            }
        }
    }
    
    //6. 用matchAFo,做内类比有无;
    if (ISOK(matchAFo, AIFoNodeBase.class) && matchAFo.count >= 2) {
        
        //7. 最后一个元素,向前分别与orders后面所有元素进行类比
        for (NSInteger i = matchAFo.count - 2; i >= 0; i--) {
            
            //8. 取出两个概念
            NSInteger lastIndex = matchAFo.count - 1;
            AIAlgNode *algA = [SMGUtils searchNode:ARR_INDEX(matchAFo.content_ps, i)];
            AIAlgNode *algB = [SMGUtils searchNode:ARR_INDEX(matchAFo.content_ps, lastIndex)];
            
            //9. 内类比找不同 (比有无)
            if (algA && algB){
                if (Log4InAna) NSLog(@"-----------内类比有无-----------\n%ld: %@\n%ld: %@",(long)i,Alg2FStr(algA),(long)lastIndex,Alg2FStr(algB));
                
                //10. 取a和b交集,并构建抽象概念;
                NSArray *same_ps = [SMGUtils filterSame_ps:algA.content_ps parent_ps:algB.content_ps];
                if (ARRISOK(same_ps)) {
                    AIAbsAlgNode *createAbsAlg = [theNet createAbsAlg_NoRepeat:same_ps conAlgs:@[algA,algB] isMem:false];
                    if (Log4InAna) NSLog(@"抽象出: %@",Alg2FStr(createAbsAlg));
                }
                
                //11. 内类比有无;
                NSArray *rangeAlg_ps = ARR_SUB(matchAFo.content_ps, i + 1, lastIndex - i - 1);
                [self analogyInner_HN:matchAFo algA:algA algB:algB rangeAlg_ps:rangeAlg_ps partAlg_ps:mModel.partAlg_ps];
            }
        }
    }
}

/**
 *  MARK:--------------------内类比大小--------------------
 *  @param checkFo : 内类比大小时,应该使用protoFo来做,因为内含了完善而原生的稀疏码信息;
 */
+(void) analogyInner_GL:(AIFoNodeBase*)checkFo algA:(AIAlgNodeBase*)algA algB:(AIAlgNodeBase*)algB rangeAlg_ps:(NSArray*)rangeAlg_ps partAlg_ps:(NSArray*)partAlg_ps{
    //1. 数据检查
    rangeAlg_ps = ARRTOOK(rangeAlg_ps);
    if (!algA || !algB) {
        return;
    }

    //2. 取a差集和b差集;
    NSArray *aSub_ps = [SMGUtils removeSub_ps:algB.content_ps parent_ps:algA.content_ps];
    NSArray *bSub_ps = [SMGUtils removeSub_ps:algA.content_ps parent_ps:algB.content_ps];

    //3. 找出ab同标识字典;
    NSMutableDictionary *sameIdentifier = [SMGUtils filterSameIdentifier_Dic:aSub_ps b_ps:bSub_ps];

    //4. 分别进行比较大小并构建变化;
    for (NSData *key in sameIdentifier.allKeys) {
        AIKVPointer *a_p = DATA2OBJ(key);
        AIKVPointer *b_p = [sameIdentifier objectForKey:key];
        //a. 对比微信息 (MARK_VALUE:如微信息去重功能去掉,此处要取值再进行对比)
        AnalogyType type = [ThinkingUtils compare:a_p valueB_p:b_p];
        //b. 调试a_p和b_p是否合格,应该同标识,同文件夹名称,不同pId;
        if (Log4InAnaGL) NSLog(@"------ 内类比大小 ------\n%@ -> %@ From(前:A%ld后:A%ld)",Pit2FStr(a_p),Pit2FStr(b_p),(long)algA.pointer.pointerId,(long)algB.pointer.pointerId);
        //d. 构建小/大;
        if (type != ATDefault) {
            [self analogyInner_Creater:type algsType:a_p.algsType dataSource:a_p.dataSource frontConAlg:algA backConAlg:algB rangeAlg_ps:rangeAlg_ps conFo:checkFo partAlg_ps:partAlg_ps];
        }
    }
}

/**
 *  MARK:--------------------内类比有无--------------------
 *  @param checkFo : TIR传过来mModel的最后一帧时序:
 *          2020.07.30前: 由每桢的matchAlg构建;
 *          2020.07.30后: 使用mModel.matchAFo来做;
 *  @version
 *      20200421 - 将a/bFocusAlg改成直接使用algA/algB (因为现在protoFo的元素即直接是matchAlg);
 */
+(void) analogyInner_HN:(AIFoNodeBase*)checkFo algA:(AIAlgNodeBase*)algA algB:(AIAlgNodeBase*)algB rangeAlg_ps:(NSArray*)rangeAlg_ps partAlg_ps:(NSArray*)partAlg_ps{
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
    if (Log4InAnaHN) NSLog(@"------ 内类比有无 ------\n[%@] -> [%@]",Pits2FStr(aSub_ps),Pits2FStr(bSub_ps));
    for (AIKVPointer *sub_p in aSub_ps) {
        AIAlgNodeBase *target = [SMGUtils searchNode:sub_p];
        [self analogyInner_Creater:ATNone algsType:sub_p.algsType dataSource:sub_p.dataSource frontConAlg:target backConAlg:target rangeAlg_ps:rangeAlg_ps conFo:checkFo partAlg_ps:partAlg_ps];
    }

    //4. b变有
    for (AIKVPointer *sub_p in bSub_ps) {
        AIAlgNodeBase *target = [SMGUtils searchNode:sub_p];
        [self analogyInner_Creater:ATHav algsType:sub_p.algsType dataSource:sub_p.dataSource frontConAlg:target backConAlg:target rangeAlg_ps:rangeAlg_ps conFo:checkFo partAlg_ps:partAlg_ps];
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
 *      2020.03.29: 将frontAlg去掉,只保留backAlg (以使方便TOR中联想使用);
 *      2020.04.19: 将构建alg和fo指定ds为:backData的值 (以便此后取absPorts时,可以根据指针进行类型筛选);
 *      2020.11.05: 将glFo改为[range+backConAlg] (参考21115);
 *  @bug
 *      2020.06.19: 调试找不到glAlg的bug (经查,内类比的两个概念中,其中一个没有"距离"稀疏码,导致无法类比出"距离"GL节点,查为什么n20p2BUG3会有距50的节点参与到内类比中来?) (过期BUG,不必再改);
 */
+(AINetAbsFoNode*)analogyInner_Creater:(AnalogyType)type algsType:(NSString*)algsType dataSource:(NSString*)dataSource frontConAlg:(AIAlgNodeBase*)frontConAlg backConAlg:(AIAlgNodeBase*)backConAlg rangeAlg_ps:(NSArray*)rangeAlg_ps conFo:(AIFoNodeBase*)conFo partAlg_ps:(NSArray*)partAlg_ps{
    //1. 数据检查
    rangeAlg_ps = ARRTOOK(rangeAlg_ps);
    algsType = STRTOOK(algsType);
    dataSource = STRTOOK(dataSource);
    if (!frontConAlg || !backConAlg || !conFo) return nil;

    //2. 获取front&back稀疏码值;
    NSInteger backData = type;

    //3. 构建微信息;
    AIKVPointer *backValue_p = nil;
    backValue_p = [theNet getNetDataPointerWithData:@(backData) algsType:algsType dataSource:dataSource];

    //4. 构建抽象概念 (20190809注:此处可考虑,type为大/小时,不做具象指向,因为大小概念,本来就是独立的节点);
    NSString *afDS = [ThinkingUtils getAnalogyTypeDS:type];
    AIAlgNodeBase *backAlg = [theNet createAbsAlg_NoRepeat:@[backValue_p] conAlgs:@[backConAlg] isMem:false ds:afDS];
    
    //TODOTOMORROW:
    //GL时,将GL的构建,延伸至支持abs; (至少涉及到两个absAlg,参考21091绿黄指向的A66&A8);
    
    
    

    //5. 构建抽象时序; (小动致大 / 大动致小) (之间的信息为balabala)
    AINetAbsFoNode *result = [TIRUtils createInnerAbsFo:backConAlg rangeAlg_ps:rangeAlg_ps conFo:conFo ds:afDS];

    //6. 调试;
    if (type == ATHav || type == ATNone) {
        if (Log4InAnaHN) NSLog(@"--> 构建:%@ ConFrom:%@ 构建Fo:%@",Alg2FStr(backAlg),Alg2FStr(backConAlg),Fo2FStr(result));
    }else if (type == ATGreater || type == ATLess) {
        if (Log4InAnaGL) NSLog(@"--> 构建:%@ ConFrom:A%ld 构建Fo:%@",Alg2FStr(backAlg),(long)backConAlg.pointer.pointerId,Fo2FStr(result));
    }
    
    //7. 内中有外
    [self analogyInner_Outside_V2:result type:type partAlg_ps:partAlg_ps backAlg:backAlg];
    return result;
}

/**
 *  MARK:--------------------内类比的内中有外--------------------
 *  1. 根据abFo联想assAbFo并进行外类比 (根据微信息来索引查找assAbFo)
 *  2. 复用外类比方法;
 *  3. 一个抽象了a1-range-a2的时序,必然是抽象的,必然是硬盘网络中的;所以此处不必考虑联想内存网络中的assAbFo;
 *  @param backAlg : 即glhn节点,根据之索引取conPorts,可取到所有"有无大小"概念经历;
 *  @param partAlg_ps : protoAlg识别到的局部匹配大全 (亦有全含的,排前面);
 *  @version
 *      2020.03.29: 将assFo依range来联想,而非"有/无/大/小";以解决类比抽象时容易过度收束的问题;
 *      2020.10.27: 新增partAlg_ps参数,找出最相似的assFo,再进行类比 (旧做法是只限Inner同类) (参考21102);
 *      2020.11.02: V2_使之按照range反序优先索引,改为partAlgs优先索引 (参考:21113);
 *      2020.11.05: 解决assFoPorts永远为0条的问题 (因为原先conFo不是gl时序),改为range+backConAlg后没此问题了 (参考21115);
 *      2020.11.06: 内中外类比,backConAlg的抽象节点newAbsA,使之抽象指向backAlg(glAlg) (参考21115);
 */
+(void)analogyInner_Outside_V2:(AINetAbsFoNode*)abFo type:(AnalogyType)type partAlg_ps:(NSArray*)partAlg_ps backAlg:(AIAlgNodeBase*)backAlg{
    
    //1. 取所有GL经历 & 与此次类似GL经历;
    NSArray *backConAlg_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:backAlg]];
    NSArray *validBackConAlg_ps = [SMGUtils filterSame_ps:partAlg_ps parent_ps:backConAlg_ps];
    
    //2. 类比准备_对与此次类似的前(3-4/*有可能与abFo重复一条*/)条;
    validBackConAlg_ps = ARR_SUB(validBackConAlg_ps, 0, 3);
    if (Log4InOutAna) NSLog(@"--------- 内中外 ---------\n%@ 经验数:%ld",Fo2FStr(abFo),(long)validBackConAlg_ps.count);
    
    //3. 类比准备_依次取出有效的fo;
    for (AIKVPointer *validBackCon_p in validBackConAlg_ps) {
        NSArray *assFoPorts = [AINetUtils refPorts_All4Alg:[SMGUtils searchNode:validBackCon_p]];
        assFoPorts = [SMGUtils filterPorts:assFoPorts havTypes:@[@(type)] noTypes:nil];
        if (Log4InOutAna) NSLog(@"------ 内中外:%@ 引用同类数:%lu",AlgP2FStr(validBackCon_p),(long)assFoPorts.count);
        
        //4. 类比准备_取出assFo (不能是abFo);
        for (AIPort *assFoPort in assFoPorts) {
            if (![assFoPort.target_p isEqual:abFo.pointer]) {
                AIFoNodeBase *assFo = [SMGUtils searchNode:assFoPort.target_p];
                
                //5. 对abFo和assAbFo进行类比;
                if (Log4InOutAna) NSLog(@"--- 内中外类比fo:%@ ass:%@",Fo2FStr(abFo),Fo2FStr(assFo));
                [self analogyOutside:abFo assFo:assFo canAss:nil updateEnergy:nil type:type createAbsAlgBlock:^(AIAlgNodeBase *createAlg, NSInteger foIndex, NSInteger assFoIndex) {
                    
                    //6. 当abFo.lastAlg和assFo.lastAlg类比抽象得到absA后,应该让absA抽象指向glAlg (参考21115);
                    if (foIndex == abFo.count - 1 && assFoIndex == assFo.count - 1) {
                        [AINetUtils relateAlgAbs:(AIAbsAlgNode*)backAlg conNodes:@[createAlg] isNew:false];
                    }
                }];
            }
        }
    }
}

@end


//MARK:===============================================================
//MARK:                     < 反馈类比 >
//MARK:===============================================================
@implementation AIAnalogy (Feedback)

/**
 *  MARK:--------------------反向反馈类比--------------------
 *  @version
 *      20200416 - 原先ms和ps都导致{mv-},改为ms导致{mmv*rate},ps导致{pmv*rate};
 *      20200419 - 构建alg/fo都新增了与analogyType相对应的ds,以方便MC_Value使用;
 *      20200421 - 新增构建sameAbsAlg节点 (如无距果),如:都是苹果,怎么1甜2苦?此处构建"都是苹果",可用于MC_V3中判断M零距果和C远距果的关系;
 *      20200421 - 取消构建sameAbsAlg,因为MC算法不需要同级MC判定,所以此处也没用,关于MC有效性检查可参考:19102;
 *  @todo
 *      20200823 - 一直以来,反向类比触发条件太苛刻的问题,通过反省类比迭代之;
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
    BOOL isDiff = [ThinkingUtils diffOfScore1:mScore score2:pScore];
    if (isDiff) NSLog(@"\n\n------------------------ 反向反馈类比 ------------------------\n%@->%@ \n%@->%@",Fo2FStr(mModel.matchFo),Mvp2Str(mMv_p),Fo2FStr(shortFo),Mvp2Str(pMv_p));
    if (!isDiff) return;

    //3. 提供类比收集"缺乏和多余"所需的两个数组;
    NSMutableArray *ms = [[NSMutableArray alloc] init];
    NSMutableArray *ps = [[NSMutableArray alloc] init];

    //4. 正向有序类比 (从protoFo中找mAlg_p的踪迹);
    NSInteger jStart = 0;
    for (NSInteger i = 0; i < mModel.matchFo.count; i++) {
        //A. 类比_数据准备;
        AIKVPointer *mAlg_p = mModel.matchFo.content_ps[i];
        BOOL findM = false;
        for (NSInteger j = jStart; j < shortFo.count; j++) {
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
    [ps addObjectsFromArray:ARR_SUB(shortFo.content_ps, jStart, shortFo.count - jStart)];
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
    CGFloat rate = 1.0f;//(float)count / conFo.count;
    
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
    
    //4. 从conFo.mvDeltaTime中提取mv导致时间隔,在relateFo之前,赋值到createFo中;
    createFo.mvDeltaTime = conFo.mvDeltaTime;
    
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
    BOOL isSame = [ThinkingUtils sameScoreOfMV1:mModel.matchFo.cmvNode_p mv2:shortFo.cmvNode_p];
    if(isSame) NSLog(@"\n\n------------------------ 正向反馈类比 ------------------------\n短时MatchFo:%@->%@ \n输入ProtoFo:%@->%@",Fo2FStr(mModel.matchFo),Mvp2Str(mModel.matchFo.cmvNode_p),Fo2FStr(shortFo),Mvp2Str(shortFo.cmvNode_p));
    if (!isSame) return;
    
    //3. 类比 (与当前的analogy_Outside()较相似,所以暂不写,随后写时,也是将原有的_outside改成此_same类比方法);
    [self analogyOutside:shortFo assFo:mModel.matchFo canAss:nil updateEnergy:nil type:ATSame createAbsAlgBlock:nil];
}

@end


//MARK:===============================================================
//MARK:                     < Out阶段类比 >
//MARK:===============================================================
@implementation AIAnalogy (Out)

/**
 *  MARK:--------------------反省类比--------------------
 *  @desc
 *      1. 其实并不真正进行类比,而是对决策中未PM修正的部分,直接构建Sub节点;
 *      2. 对已发生的 (cutIndex < algIndex) 的部分每一帧,收集未被PM修正的sub稀疏码,构建ATSubAlg (当前的两个调用者,都是全序列);
 *      3. 对上述ATSubAlgs构建成ATSub时序;
 *      4. 根据ATSubFo,从稀疏码向概念,再向时序索引查找,同样foNode的另外的assSubFo,并进行外类比 (目前仅简单的取时序的ATSub抽象);
 *      5. 外类比构建更确切的S时序,如果已存在,则加强;
 *
 *  @callers
 *      1. ActYes流程控制的HNGL调用时,生物钟触发器触发成功时,理性分析什么导致了未成功 (cutIndex无用,因为全部用);
 *      2. ActYes流程控制的Demand调用时,生物钟触发器触发成功时,理性分析什么导致了未成功 (cutIndex无用,因为全部用);
 *  @version
 *      2020.09.03: 支持ATPlus反省类比;
 *  @bug
 *      2020.09.18: 因为数据结构取错,导致取不到justPValues的BUG (参考:21027) T;
 *      2020.09.29: except_ps取错,导致反省类比的稀疏码内容经常为空 (参考21055描述及示图);
 */
+(void) analogy_ReasonRethink:(TOFoModel*)foModel cutIndex:(NSInteger)cutIndex type:(AnalogyType)type{
    //1. 数据准备
    if (!foModel || (type != ATSub && type != ATPlus)) return;
    AIFoNodeBase *foNode = [SMGUtils searchNode:foModel.content_p];
    NSMutableArray *spFoContent = [[NSMutableArray alloc] init];
    NSString *spDS = [ThinkingUtils getAnalogyTypeDS:type];
    NSLog(@"\n\n=============================== 反省类比 ===============================\n%ld:时序:%@",(long)type,Fo2FStr(foNode));
    
    //2. 构建SPAlg (触发反省类比_实际fo数据收集 (不用收集realFo,而是直接对未修正部分构建,参考20205-原则1));
    for (TOAlgModel *toAlgModel in foModel.subModels) {
        if (!ISOK(toAlgModel, TOAlgModel.class)) WLog(@"查下此处,为何fo的subModel不是algModel类型,如果2020.10之前未见过此警告,可取消打印此日志;");
        if (!ISOK(toAlgModel, TOAlgModel.class)) continue;
        
        //2. 取出reModel;
        TOAlgModel *reModel = ARR_INDEX(toAlgModel.subModels, 0);
        if (toAlgModel.subModels.count > 1) WLog(@"--------->>> 反省类比取reModel时,subModels长度>1,看是否需要更全面处理>1的情况");
        if (!reModel) continue;
        
        //3. 排除掉Finish的;
        NSArray *except_ps = [TOUtils convertPointersFromTOValueModelSValue:reModel.subModels validStatus:@[@(TOModelStatus_Finish)]];
        
        //3. 剩下 "未修正(无需修正NoNeedAct/修正失败ActNo)的稀疏码" (参考20205-原则2);
        NSArray *notFinish_ps = [SMGUtils removeSub_ps:except_ps parent_ps:reModel.justPValues];
        NSLog(@"item--> justPValues:(%@) - excepts:(%@) = (%@)",Pits2FStr(reModel.justPValues),Pits2FStr(except_ps),Pits2FStr(notFinish_ps));
        
        //4. 未修正部分构建为: "SP概念"
        AIAlgNodeBase *curAlg = [SMGUtils searchNode:toAlgModel.content_p];
        if (!ARRISOK(notFinish_ps)) continue;
        AIAbsAlgNode *spAlg = [theNet createAbsAlg_NoRepeat:notFinish_ps conAlgs:@[curAlg] isMem:false ds:spDS];
        NSLog(@"createAlg:%@ from:%@",Alg2FStr(spAlg),AlgP2FStr(toAlgModel.content_p));
        
        //5. 收集SP概念_用于构建SP时序;
        [spFoContent addObject:spAlg.pointer];
    }
    
    //6. 构建SPFo
    if (ARRISOK(spFoContent)) {
        AINetAbsFoNode *spFo = [theNet createAbsFo_General:@[foNode] content_ps:spFoContent difStrong:1 ds:spDS];
        NSLog(@"createFo:%@ con:%@",Fo2FStr(spFo),Fo2FStr(foNode));
        
        //7. 向性左向右,以当前foNode为交集指引,找assSPFo,以进行外类比 (参考20205-原则3);
        NSArray *assSPFos = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:foNode type:type]];
        assSPFos = [SMGUtils removeSub_p:spFo.pointer parent_ps:assSPFos];
        assSPFos = ARR_SUB(assSPFos, 0, cRethinkActBack_AssSPFoLimit);
        
        //8. 外类比;
        if (spFo && ARRISOK(assSPFos)) {
            for (AIKVPointer *item in assSPFos) {
                AINetAbsFoNode *assSPFo = [SMGUtils searchNode:item];
                [AIAnalogy analogyOutside:spFo assFo:assSPFo canAss:nil updateEnergy:nil type:type createAbsAlgBlock:nil];
            }
        }
    }
}

@end
