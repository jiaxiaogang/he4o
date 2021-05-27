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
#import "AIScore.h"
#import "AIMatchFoModel.h"
#import "AINetService.h"
#import "NSArray+Extension.h"

@implementation AIAnalogy

//MARK:===============================================================
//MARK:                     < 外类比部分 >
//MARK:===============================================================

/**
 *  MARK:--------------------fo外类比 (找相同算法)--------------------
 *  @desc                   : orderSames用于构建absFo
 *  @callers
 *      1. analogy_Feedback_Same()  : 同向反馈类比
 *      2. analogyInner()           : 内类比
 *      3. reasonRethink()          : 反省类比
 *
 *  1. 连续信号中,找重复;(连续也是拆分,多事务处理的)
 *  2. 两条信息中,找交集;
 *  3. 在连续信号的处理中,实时将拆分单信号存储到内存区,并提供可检索等,其形态与最终存硬盘是一致的;
 *  4. 类比处理(瓜是瓜)
 *  注: 类比的处理,是足够细化的,对思维每个信号作类比操作;(而将类比到的最基本的结果,输出给thinking,以供为构建网络的依据,最终是以网络为目的的)
 *  注: 随后可以由一个sames改为多个sames并实时使用block抽象 (并消耗energy);
 *
 *  @version
 *      20200215: 有序外类比: 将forin循环fo和assFo改为反序,并记录上次类比位置jMax (因出现了[果,果,吃,吃]这样的异常时序) 参考n18p11;
 *      20200831: 支持反省外类比,得出更确切的ATSub原因,参考:20205-步骤4;
 *      20201203: 修复21175BUG (因createAbsAlgBlock忘记调用,导致absAlg和glAlg间未关联) (参考21115);
 */
+(AINetAbsFoNode*) analogyOutside:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo type:(AnalogyType)type createAbsAlgBlock:(void(^)(AIAlgNodeBase *createAlg,NSInteger foIndex,NSInteger assFoIndex))createAbsAlgBlock{
    //1. 类比orders的规律
    if (Log4OutAna) NSLog(@"\n----------- 外类比(%@) -----------\nfo:%@ \nassFo:%@",ATType2Str(type),Fo2FStr(fo),Fo2FStr(assFo));
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
                    ///1. 构建时,消耗能量值; if (!canAssBlock()) 
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
                                //3. 收集并更新jMax;
                                [orderSames insertObject:createAbsNode.pointer atIndex:0];
                                jMax = j - 1;
                                if (Log4OutAna) NSLog(@"-> 外类比构建概念 Finish: %@ from: ↑↑↑(A%ld:A%ld)",Alg2FStr(createAbsNode),(long)algNodeA.pointer.pointerId,(long)algNodeB.pointer.pointerId);
                                
                                //3. 构建absAlg时,回调构建和glhnAlg的关联 (参考21115);
                                if (createAbsAlgBlock) createAbsAlgBlock(createAbsNode,i,j);
                            }
                            ///4. 构建时,消耗能量值; updateEnergy(-0.1f);
                        }
                    }
                }
            }
        }
    }

    //3. 外类比构建
    return [self analogyOutside_Creater:orderSames fo:fo assFo:assFo type:type];
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
+(AINetAbsFoNode*)analogyOutside_Creater:(NSArray*)orderSames fo:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo type:(AnalogyType)type{
    //2. 数据检查;
    AINetAbsFoNode *result = nil;
    if (ARRISOK(orderSames) && ISOK(fo, AIFoNodeBase.class) && ISOK(assFo, AIFoNodeBase.class)) {

        //3. fo和assFo本来就是抽象关系时_直接关联即可;
        BOOL samesEqualAssFo = orderSames.count == assFo.count && [SMGUtils containsSub_ps:orderSames parent_ps:assFo.content_ps];
        BOOL jumpForAbsAlreadyHav = (ISOK(assFo, AINetAbsFoNode.class) && samesEqualAssFo);
        if (jumpForAbsAlreadyHav) {
            result = (AINetAbsFoNode*)assFo;
            [AINetUtils relateFoAbs:result conNodes:@[fo] isNew:false];
            [AINetUtils insertRefPorts_AllFoNode:result.pointer order_ps:result.content_ps ps:result.content_ps];
            if (type == ATSame || type == ATDiff) [theNet setMvNodeToDirectionReference:[SMGUtils searchNode:result.cmvNode_p] difStrong:1];
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
            result = [theNet createAbsFo_NoRepeat:@[fo,assFo] content_ps:orderSames difStrong:foDifStrong ds:foDS];
            
            //5. 从fo和conFo.mvDeltaTime中提取mv导致时间隔,在relateFo之前,赋值到result中;
            result.mvDeltaTime = MAX(fo.mvDeltaTime, assFo.mvDeltaTime);
            
            //6. createAbsCmvNode (当正向类比,且result没有cmv指向时);
            if ((type == ATSame || type == ATDiff) && assMv && !result.cmvNode_p) {
                AIAbsCMVNode *resultMv = [theNet createAbsCMVNode_Outside:nil aMv_p:fo.cmvNode_p bMv_p:assMv.pointer];
                [AINetUtils relateFo:result mv:resultMv];//cmv模型连接;
            }
        }
    }
    //调试短时序; (先仅打外类比日志);
    NSString *log = STRFORMAT(@"-> 外类比构建时序 Finish: %@->{%@} from: ↑↑↑(fo:assFo)",Fo2FStr(result),Mvp2Str(result.cmvNode_p));
    if (Log4InAnaHN(type)) NSLog(@"%@",log);
    if (Log4InAnaGL(type)) NSLog(@"%@",log);
    if (Log4OutAnaDiff(type)) NSLog(@"%@",log);
    if (Log4OutAnaDefault(type)) NSLog(@"%@",log);
    if (Log4OutAnaSame(type)) NSLog(@"%@",log);
    return result;
}

@end


//MARK:===============================================================
//MARK:                     < 内类比部分 >
//MARK:===============================================================
@implementation AIAnalogy (In)

/**
 *  MARK:--------------------fo内类比 (内中有外,找不同算法)--------------------
 *  @desc 在理性中进行内类比;
 *  @支持: 目前理性内类比不支持energy,待以后版本再考虑支持 (目前仅在TO阶段支持energy,TI阶段先用配置参数控制);
 *
 *  _param checkFo      : 要处理的fo.orders;
 *  _param canAssBlock  : energy判断器 (为null时,无限能量);
 *  _param updateEnergy : energy消耗器 (为null时,不消耗能量值);
 *
 *  1. 此方法对一个fo内的orders进行内类比,并将找到的变化进行抽象构建网络;
 *  2. 如: 绿瓜变红瓜,如远坚果变近坚果;
 *  3. 每发现一个有效变化目标,则构建2个absAlg和2个absFo; (参考n15p18内类比构建图)
 *  注: 目前仅支持一个微信息变化的规律;
 *  @todo
 *      xxxx.xx.xx: 将内类比的类比部分代码,进行单独PrivateMethod,然后与外类比中调用的进行复用;
 *      2020.12.01: 向内类比传的partAlg_ps永远都是当前这一帧的,可能导致无法触发"内中外类比",从而导致决策联想不到稳定的GL抽象节点 (参考21172);
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
                if (Log4InAna) NSLog(@"\n----------------内类比大小----------------\n%ld: %@\n%ld: %@",(long)i,Alg2FStr(algA),(long)lastIndex,Alg2FStr(algB));
                
                //5. 内类比大小;
                NSArray *rangeAlg_ps = ARR_SUB(protoFo.content_ps, i + 1, lastIndex - i - 1);
                [self analogyInner_GL:protoFo algA:algA algB:algB rangeAlg_ps:rangeAlg_ps mModel:mModel];
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
                if (Log4InAna) NSLog(@"\n----------------内类比有无----------------\n%ld: %@\n%ld: %@",(long)i,Alg2FStr(algA),(long)lastIndex,Alg2FStr(algB));
                
                //10. 取a和b交集,并构建抽象概念;
                NSArray *same_ps = [SMGUtils filterSame_ps:algA.content_ps parent_ps:algB.content_ps];
                if (ARRISOK(same_ps)) {
                    AIAbsAlgNode *createAbsAlg = [theNet createAbsAlg_NoRepeat:same_ps conAlgs:@[algA,algB] isMem:false];
                    if (Log4InAna) NSLog(@"抽象出: %@",Alg2FStr(createAbsAlg));
                }
                
                //11. 内类比有无;
                NSArray *rangeAlg_ps = ARR_SUB(matchAFo.content_ps, i + 1, lastIndex - i - 1);
                [self analogyInner_HN:matchAFo algA:algA algB:algB rangeAlg_ps:rangeAlg_ps mModel:mModel];
            }
        }
    }
}

/**
 *  MARK:--------------------内类比大小--------------------
 *  @param checkFo : 内类比大小时,应该使用protoFo来做,因为内含了完善而原生的稀疏码信息;
 */
+(void) analogyInner_GL:(AIFoNodeBase*)checkFo algA:(AIAlgNodeBase*)algA algB:(AIAlgNodeBase*)algB rangeAlg_ps:(NSArray*)rangeAlg_ps mModel:(AIShortMatchModel*)mModel{
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
        if (Log4InAnaGL(type)) NSLog(@"> 比到大小: %@ -> %@ From(前:A%ld后:A%ld)",Pit2FStr(a_p),Pit2FStr(b_p),(long)algA.pointer.pointerId,(long)algB.pointer.pointerId);
        //d. 构建小/大;
        if (type != ATDefault) {
            [self analogyInner_Creater:type algsType:a_p.algsType dataSource:a_p.dataSource frontConAlg:algA backConAlg:algB rangeAlg_ps:rangeAlg_ps conFo:checkFo mModel:mModel];
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
+(void) analogyInner_HN:(AIFoNodeBase*)checkFo algA:(AIAlgNodeBase*)algA algB:(AIAlgNodeBase*)algB rangeAlg_ps:(NSArray*)rangeAlg_ps mModel:(AIShortMatchModel*)mModel{
    //1. 数据检查
    if (!algA || !algB) return;
    rangeAlg_ps = ARRTOOK(rangeAlg_ps);
    //AIAlgNodeBase *aFocusAlg = [ThinkingUtils getMatchAlgWithProtoAlg:algA];if (aFocusAlg == nil) aFocusAlg = algA;
    //AIAlgNodeBase *bFocusAlg = [ThinkingUtils getMatchAlgWithProtoAlg:algB];if (bFocusAlg == nil) bFocusAlg = algB;
    AIAlgNodeBase *aFocusAlg = algA;
    AIAlgNodeBase *bFocusAlg = algB;
    
    //2. 收集a和b的概念辐射合集 (取自身 + 自身的一层抽象);
    NSMutableArray *aSum_ps = Ports2Pits([SMGUtils filterPorts_Normal:[AINetUtils absPorts_All:aFocusAlg]]);
    [aSum_ps addObject:aFocusAlg.pointer];
    NSMutableArray *bSum_ps = Ports2Pits([SMGUtils filterPorts_Normal:[AINetUtils absPorts_All:bFocusAlg]]);
    [bSum_ps addObject:bFocusAlg.pointer];

    //2. 取a差集和b差集;
    NSArray *aSub_ps = [SMGUtils removeSub_ps:bSum_ps parent_ps:aSum_ps];
    NSArray *bSub_ps = [SMGUtils removeSub_ps:aSum_ps parent_ps:bSum_ps];

    //3. a变无
    if (Log4InAnaHN(ATHav)) NSLog(@"------ 内类比有无 ------\n[%@] -> [%@]",Pits2FStr(aSub_ps),Pits2FStr(bSub_ps));
    for (AIKVPointer *sub_p in aSub_ps) {
        AIAlgNodeBase *target = [SMGUtils searchNode:sub_p];
        [self analogyInner_Creater:ATNone algsType:sub_p.algsType dataSource:sub_p.dataSource frontConAlg:target backConAlg:target rangeAlg_ps:rangeAlg_ps conFo:checkFo mModel:mModel];
    }

    //4. b变有
    for (AIKVPointer *sub_p in bSub_ps) {
        AIAlgNodeBase *target = [SMGUtils searchNode:sub_p];
        [self analogyInner_Creater:ATHav algsType:sub_p.algsType dataSource:sub_p.dataSource frontConAlg:target backConAlg:target rangeAlg_ps:rangeAlg_ps conFo:checkFo mModel:mModel];
    }
}

/**
 *  MARK:--------------------内类比构建器--------------------
 *  @desc 参考21115彩图;
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
 *  @todo
 *      2020.10.23: GL时,将GL的构建,延伸至支持abs (至少涉及到两个absAlg,参考21091绿黄指向的A66&A8) (由内中外类比实现,参考21115) T;
 *  @bug
 *      2020.06.19: 调试找不到glAlg的bug (经查,内类比的两个概念中,其中一个没有"距离"稀疏码,导致无法类比出"距离"GL节点,查为什么n20p2BUG3会有距50的节点参与到内类比中来?) (过期BUG,不必再改);
 */
+(AINetAbsFoNode*)analogyInner_Creater:(AnalogyType)type algsType:(NSString*)algsType dataSource:(NSString*)dataSource frontConAlg:(AIAlgNodeBase*)frontConAlg backConAlg:(AIAlgNodeBase*)backConAlg rangeAlg_ps:(NSArray*)rangeAlg_ps conFo:(AIFoNodeBase*)conFo mModel:(AIShortMatchModel*)mModel{
    //1. 数据检查
    rangeAlg_ps = ARRTOOK(rangeAlg_ps);
    algsType = STRTOOK(algsType);
    dataSource = STRTOOK(dataSource);
    if (!frontConAlg || !backConAlg || !conFo) return nil;

    //2. 获取front&back稀疏码值;
    NSInteger backData = type;

    //3. 构建微信息;
    AIKVPointer *glValue_p = nil;
    glValue_p = [theNet getNetDataPointerWithData:@(backData) algsType:algsType dataSource:dataSource];

    //4. 构建抽象概念 (20190809注:此处可考虑,type为大/小时,不做具象指向,因为大小概念,本来就是独立的节点);
    NSString *afDS = [ThinkingUtils getAnalogyTypeDS:type];
    AIAlgNodeBase *glAlg = [theNet createAbsAlg_NoRepeat:@[glValue_p] conAlgs:@[backConAlg] isMem:false ds:afDS];
    
    //5. 构建抽象时序; (小动致大 / 大动致小) (之间的信息为balabala)
    AINetAbsFoNode *result = [TIRUtils createInnerAbsFo:backConAlg rangeAlg_ps:rangeAlg_ps conFo:conFo ds:afDS];

    //6. 调试;
    if (Log4InAnaHN(type)) NSLog(@"--> 构建:%@ ConFrom:%@ 构建Fo:%@",Alg2FStr(glAlg),Alg2FStr(backConAlg),Fo2FStr(result));
    if (Log4InAnaGL(type)) NSLog(@"--> 构建:%@ ConFrom:A%ld 构建Fo:%@",Alg2FStr(glAlg),(long)backConAlg.pointer.pointerId,Fo2FStr(result));
    
    //7. 内中有外
    [self analogyInner_Outside_V4:result type:type mModel:mModel glhnAlg:glAlg vAT:algsType vDS:dataSource];
    return result;
}

/**
 *  MARK:--------------------内类比的内中有外--------------------
 *  1. 根据abFo联想assAbFo并进行外类比 (根据微信息来索引查找assAbFo)
 *  2. 复用外类比方法;
 *  3. 一个抽象了a1-range-a2的时序,必然是抽象的,必然是硬盘网络中的;所以此处不必考虑联想内存网络中的assAbFo;
 *  @param glhnAlg : 即glhn节点,根据之索引取conPorts,可取到所有"有无大小"概念经历;
 *  @param mModel : 最后一帧短时InModel (主要使用protoAlg识别到的局部匹配大全 (亦有全含的,排前面));
 *  @version
 *      2020.03.29: 将assFo依range来联想,而非"有/无/大/小";以解决类比抽象时容易过度收束的问题;
 *      2020.10.27: 新增partAlg_ps参数,找出最相似的assFo,再进行类比 (旧做法是只限Inner同类) (参考21102);
 *      2020.11.02: V2_使之按照range反序优先索引,改为partAlgs优先索引 (参考:21113);
 *      2020.11.05: 解决assFoPorts永远为0条的问题 (因为原先conFo不是gl时序),改为range+backConAlg后没此问题了 (参考21115);
 *      2020.11.06: 内中外类比,backConAlg的抽象节点newAbsA,使之抽象指向backAlg(glAlg) (参考21115);
 *      2020.12.12: 将partAlg_ps取交集,改成matchAlg_ps取交集,即索引参考变了 (索引参考21113,本次改动参考21194)
 *      2020.12.13: 使partAlg_ps/matchAlg_ps与conAlg_ps取交集时,保持原概念匹配的有序 (参考21194-todo2);
 *      2020.12.13: 同时支持parts和matchs,各取三条进行assFo联想 (参考21194-todo1);
 *      2020.12.13: assFo中,索引alg不在最后一位时,跳过不进行内中外类比 (因为调试测得有非末位被联想到的情况,参考代码valid非末位);
 *      2021.04.08: v3_assFo联想方式:由左向右alg.refPorts,改为下向上protoFo.absPorts路径联想,这样更场景理性避免混乱 (参考22212);
 *      2021.04.22: v4_assFo联想方式:由absFo向具象,分别联想hngls (参考23041-TODO2);
 *      2021.04.28: 右果嵌套GL始终为0条的BUG,调整配置参数后ok (参考23058);
 */
+(void)analogyInner_Outside_V4:(AINetAbsFoNode*)abFo type:(AnalogyType)type mModel:(AIShortMatchModel*)mModel glhnAlg:(AIAlgNodeBase*)glhnAlg vAT:(NSString*)vAT vDS:(NSString*)vDS{
    //1. 取glConAlg_ps;
    NSArray *glConAlg_ps = [AINetService getHNGLConAlg_ps:type vAT:vAT vDS:vDS];
    BOOL debugMode = Log4InAnaGL(type) || Log4InAnaHN(type);
    NSInteger analogyLimit = 20;//最多类比5个assFo;
    if (debugMode) NSLog(@"\n--------- 内中外类比 ---------\nABFo:%@ vAT:%@ vDS:%@",Fo2FStr(abFo),vAT,vDS);
    
    //2. ass结果收集: assDic<assPort,absFos>,其中absFos用于嵌套到absFo时用 (参考23041-TODO2);
    NSMutableDictionary *assDic = [[NSMutableDictionary alloc] init];
    
    //3. 从absRFos与其具象,联想hngl经验做为assFo;
    for (AIFoNodeBase *absFo in mModel.absRFos) {
        
        //4. 直接收集absFo;
        NSMutableArray *base_ps = [[NSMutableArray alloc] init];
        [base_ps addObject:absFo.pointer];
        
        //5. 向具象收集conFo (前3条);
        NSArray *conFo_ps = Ports2Pits([AINetUtils conPorts_All:absFo]);
        conFo_ps = ARR_SUB(conFo_ps, 0, 3);
        [base_ps addObjectsFromArray:conFo_ps];
        
        //6. 分别取hngls,收集到allHNGLs中 (每item的前2条);
        int curHnglCount = 0;
        for (AIKVPointer *item in base_ps) {
            AIFoNodeBase *base = [SMGUtils searchNode:item];
            NSArray *hnglPorts = [AINetUtils absPorts_All:base type:type];
            hnglPorts = ARR_SUB(hnglPorts, 0, 2);
            
            //7. 将hnglPorts存到allHNGLDic中 (hnglPort作为key,absFo收集到value中);
            for (AIPort *item in hnglPorts) {
                NSData *key = OBJ2DATA(item);
                NSMutableArray *absFos = [[NSMutableArray alloc] initWithArray:[assDic objectForKey:key]];
                if (![absFos containsObject:absFo]) [absFos addObject:absFo];
                [assDic setObject:absFos forKey:key];
            }
            curHnglCount += hnglPorts.count;
        }
        //if (debugMode) NSLog(@"--> 当前absFo:%@ 取得hngl个数:%d",Fo2FStr(absFo),curHnglCount);
    }
    if (debugMode) NSLog(@">>> 从%ld条absRFos中取assFo=>总联想assDic%ld条",mModel.absRFos.count,assDic.count);
    
    //8. 根据allHNGLs取出assFo,并进行外类比;
    int analogCount = 0;
    for (id key in assDic.allKeys) {
        AIPort *assPort = DATA2OBJ(key);
        NSArray *absFos = ARRTOOK([assDic objectForKey:key]);
        
        //9. 排除abFo自身 (不可与abFo重复);
        if ([assPort.target_p isEqual:abFo.pointer]) continue;
        
        //10. 有效检查_与glConAlg_ps的元素有引用关系 (用末位是否包含在glConAlgs中判断,如:必须为距小时序才可);
        AIFoNodeBase *assFo = [SMGUtils searchNode:assPort.target_p];
        if (![SMGUtils containsSub_p:ARR_INDEX_REVERSE(assFo.content_ps, 0) parent_ps:glConAlg_ps]) continue;
        
        //11. 对abFo和assAbFo进行类比;
        if (debugMode) NSLog(@"\n------ item外类比 ------\nASSFo:%@",Fo2FStr(assFo));
        AINetAbsFoNode *absHNGLFo = [self analogyOutside:abFo assFo:assFo type:type createAbsAlgBlock:^(AIAlgNodeBase *createAlg, NSInteger foIndex, NSInteger assFoIndex) {
            
            //12. 当abFo.lastAlg和assFo.lastAlg类比抽象得到absA后,应该让absA抽象指向glAlg (参考21115);
            if (foIndex == abFo.count - 1 && assFoIndex == assFo.count - 1) {
                if (debugMode) NSLog(@"-> 内中外类比_关联:%@ ABSTO:%@",Alg2FStr(createAlg),Alg2FStr(glhnAlg));
                [AINetUtils relateAlgAbs:(AIAbsAlgNode*)glhnAlg conNodes:@[createAlg] isNew:false];
            }
        }];
        if (!absHNGLFo) continue;
        
        //13. 将外类比抽象时做嵌套关联 & 指定强度 (目前由absPort+type表征);
        //此处strongPorts只传assPort是因为abFo嵌套于protoFo,强度仅为初始;
        //此处不将absFo嵌套于protoFo&assFo下,因为一般protoFo的嵌套经验用不着,并且在getInnerV3向抽象取同样可取到;
        if (debugMode) NSLog(@"==== 结果:%@ 嵌套到absFos下: ↓↓↓↓↓↓\n%@",Fo2FStr(absHNGLFo),Pits2FStr_MultiLine(Nodes2Pits(absFos)));
        [AINetUtils relateFoAbs:absHNGLFo conNodes:absFos isNew:false strongPorts:@[assPort]];
        
        //14. 限制类比条数;
        if (++analogCount >= analogyLimit) break;
    }
}

@end


//MARK:===============================================================
//MARK:                     < 反馈类比 >
//MARK:===============================================================
@implementation AIAnalogy (Feedback)

/**
 *  MARK:--------------------正向反馈外类比--------------------
 *  @use : 用于P-任务取解决方案;
 */
+(void) analogy_Feedback_Same:(AIFoNodeBase*)matchFo shortFo:(AIFoNodeBase*)shortFo{
    //1. 数据检查;
    if (!matchFo || !shortFo || !matchFo.cmvNode_p || !shortFo.cmvNode_p) return;
    
    //2. 检查同向;
    BOOL isSame = [AIScore sameIdenSameScore:matchFo.cmvNode_p mv2:shortFo.cmvNode_p];
    NSLog(@"\n\n------------------------------- 正向反馈外类比 (%@) -------------------------------\n短时MatchFo:%@->%@ \n输入ProtoFo:%@->%@",isSame ? @"执行" : @"未执行", Fo2FStr(matchFo),Mvp2Str(matchFo.cmvNode_p),Fo2FStr(shortFo),Mvp2Str(shortFo.cmvNode_p));
    if (!isSame) return;
    
    //3. 类比 (与当前的analogy_Outside()较相似,所以暂不写,随后写时,也是将原有的_outside改成此_same类比方法);
    [self analogyOutside:shortFo assFo:matchFo type:ATSame createAbsAlgBlock:nil];
}

/**
 *  MARK:--------------------反向反馈外类比--------------------
 *  @use : 用于R-任务取解决方案;
 *  @caller : 由预测触发器触发,当mv未发生时,构建虚mv时序,并进行外类比;
 *  @desc : 主要用于R-模式决策时使用 (参考22107);
 *  @param matchFo : protoFo是嵌套于matchFo之下的,要求matchFo.cmv_p不为空 (matchFo携带了实mv);
 *  @bug
 *      2021.02.02: 虚mv逻辑判反,导致执行不了 (修复后正常) T;
 *      2021.04.02: dsPorts循环中,进行relate时删除item了,导致闪退,解决:copy一份进行循环 T;
 *  @version
 *      2021.03.25: 嵌套关联 & 外类比assFo改为使用嵌套关联来联想;
 *  @todo
 *      2021.04.08: 考虑支持从抽象protoFo.absPorts.dsPorts中找assFo;
 */
+(void) analogy_Feedback_Diff:(AIFoNodeBase*)protoFo matchFo:(AIFoNodeBase*)matchFo{
    //1. 数据检查 (本身就是虚mv则返回:此方法仅对实mv做处理,本身就是虚mv则不做任何处理);
    if (!protoFo || !matchFo || [AINetUtils isVirtualMv:matchFo.cmvNode_p]) return;
    
    //2. 取出实mv的值;
    AICMVNodeBase *baseMv = [SMGUtils searchNode:matchFo.cmvNode_p];
    AIKVPointer *baseDelta_p = baseMv.delta_p;
    AIKVPointer *baseUrgentTo_p = baseMv.urgentTo_p;
    NSInteger baseDelta = [NUMTOOK([AINetIndex getData:baseDelta_p]) integerValue];
    //NSInteger baseUrgentTo = [NUMTOOK([AINetIndex getData:baseUrgentTo_p]) integerValue];
    
    //3. 根据实mv构建虚mv节点 (虚mv不产生迫切度);
    NSInteger delta = -baseDelta;
    AIKVPointer *delta_p = [AINetIndex getDataPointerWithData:@(delta) algsType:baseDelta_p.algsType dataSource:baseDelta_p.dataSource isOut:false];
    AIKVPointer *urgentTo_p = [AINetIndex getDataPointerWithData:@(0) algsType:baseUrgentTo_p.algsType dataSource:baseUrgentTo_p.dataSource isOut:false];
    //[theNet createAbsMv:nil conMvs:nil at:nil ds:nil urgentTo_p:nil delta_p:nil];//20210328此处全是空什么鬼,注掉先;
    AICMVNode *mvNode = [theNet createConMv:urgentTo_p delta_p:delta_p at:matchFo.cmvNode_p.algsType isMem:false];
    if (!mvNode) return;
    
    //4. 互指向 (将虚mv指定给protoFo & 嵌套互指向);
    [AINetUtils relateFo:protoFo mv:mvNode];
    [AINetUtils relateDiff:protoFo baseNode:matchFo strongPorts:nil];
    
    NSLog(@"\n\n------------------------------- 反向反馈外类比 -------------------------------\nprotoFo:%@->%@", Fo2FStr(protoFo),Mv2FStr(mvNode));
    
    //5. 取嵌套前3条subFo,进行外类比;
    AIPort *protoPort = [AINetUtils findPort:protoFo.pointer fromPorts:matchFo.diffSubPorts];
    int analogyCount = 0;
    NSArray *dsPorts = [[NSArray alloc] initWithArray:matchFo.diffSubPorts];
    for (AIPort *subPort in dsPorts) {
        //6. 不可与proto重复;
        if ([subPort.target_p isEqual:protoPort.target_p]) continue;
        
        //7. 进行外类比
        AIFoNodeBase *assFo = [SMGUtils searchNode:subPort.target_p];
        if (Log4DiffAna) NSLog(@"\nassFo:%@->%@",Fo2FStr(assFo),Mvp2Str(assFo.cmvNode_p));
        AINetAbsFoNode *absFo = [self analogyOutside:protoFo assFo:assFo type:ATDiff createAbsAlgBlock:nil];
        if (!absFo) continue;
        
        //8. 将外类比抽象时做嵌套关联 & 指定强度;
        [AINetUtils relateDiff:absFo baseNode:matchFo strongPorts:@[protoPort,subPort]];
        
        //9. 类比三条;
        analogyCount ++;
        if (analogyCount >= 3) break;
    }
    
    ////5. 根据虚mv,联想同区虚mv们;
    //MVDirection direction = [ThinkingUtils getMvReferenceDirection:delta];
    //NSArray *assMvRefs = [theNet getNetNodePointersFromDirectionReference:mvNode.pointer.algsType direction:direction isMem:false filter:nil];
    //
    ////6. 根据虚mv们,筛选出normal且防重的assFo;
    //NSMutableArray *assFos = [[NSMutableArray alloc] init];
    //for (AIPort *item in assMvRefs) {
    //    AICMVNodeBase *itemMV = [SMGUtils searchNode:item.target_p];
    //    AnalogyType type = DS2ATType(itemMV.foNode_p.dataSource);
    //    if (type != ATPlus && type != ATSub && ![protoFo.pointer isEqual:itemMV.foNode_p]) {
    //        AIFoNodeBase *assFo = [SMGUtils searchNode:itemMV.foNode_p];
    //        if (assFo) [assFos addObject:assFo];
    //    }
    //    //7. 最多取三条assFo;
    //    if (assFos.count >= 3) break;
    //}
    //
    ////8. 使protoFo与assFo外类比;
    //for (AIFoNodeBase *assFo in assFos) {
    //    if (Log4DiffAna) NSLog(@"\nassFo:%@->%@",Fo2FStr(assFo),Mvp2Str(assFo.cmvNode_p));
    //    [self analogyOutside:protoFo assFo:assFo type:ATDiff createAbsAlgBlock:nil];
    //}
}

@end


//MARK:===============================================================
//MARK:                     < 反省类比 >
//MARK:===============================================================
@implementation AIAnalogy (Rethink)

/**
 *  MARK:--------------------In反省类比--------------------
 *  @desc In反省: 不符合预测的反省类比;
 *      1. 类比找出预测与实际中不符的特征部分;
 *      2. 取P独特码(P-M差集) (M应该不存在多出来的,因为M本来就是被P全含的);
 *      3. 用独特码集构建S/P节点;
 *  @use : 用于PM对Alg评价;
 *  @param matchFoModel : M_预测fo为matchFo;
 *  @param shortFo : P_实际fo为shortFo;
 *  @version
 *      20200416 - 原先ms和ps都导致{mv-},改为ms导致{mmv*rate},ps导致{pmv*rate};
 *      20200419 - 构建alg/fo都新增了与analogyType相对应的ds,以方便MC_Value使用;
 *      20200421 - 新增构建sameAbsAlg节点 (如无距果),如:都是苹果,怎么1甜2苦?此处构建"都是苹果",可用于MC_V3中判断M零距果和C远距果的关系;
 *      20200421 - 取消构建sameAbsAlg,因为MC算法不需要同级MC判定,所以此处也没用,关于MC有效性检查可参考:19102;
 *      20210121 - 迭代为In反省类比 (参考22052);
 *      20210121 - P.Alg在M中未发现时,也要收集到P-M的差集中 T;
 *      20210507 - 暂停IRT (参考23063);
 *  @todo
 *      20200823 - 一直以来,反向类比触发条件太苛刻的问题,通过反省类比迭代之,支持正与平也可触发 T;
 *      20210120 - 此处取mType和pType的SPType有误,S不表示负价值评分,而是表示不符合当前父场景的hope预期 (已废弃,改为直接传入type);
 */
+(void) analogy_InRethink:(AIMatchFoModel*)matchFoModel shortFo:(AIFoNodeBase*)shortFo type:(AnalogyType)type{
    //1. 数据准备;
    BOOL tirSwitch = false;
    if (!tirSwitch || !matchFoModel || !matchFoModel.matchFo || !shortFo || (type != ATPlus && type != ATSub)) return;
    AIFoNodeBase *matchFo = matchFoModel.matchFo;
    NSString *ds = [ThinkingUtils getAnalogyTypeDS:type];
    
    //2. 取有效的matchFo部分 (HNGL取range部分 | MV取所有);
    NSMutableArray *matchContent = [[NSMutableArray alloc] init];
    if ([TOUtils isHNGL:matchFo.pointer]) {
        [matchContent addObjectsFromArray:ARR_SUB(matchFo.content_ps, 0, matchFo.count - 1)];
    }else{
        [matchContent addObjectsFromArray:matchFo.content_ps];
    }
    NSLog(@"\n\n------------------------------- In反省类比 (%@) -------------------------------\nM:%@\nP:%@",ATType2Str(type),Fo2FStr(matchFo),Fo2FStr(shortFo));
    
    //3. 正向有序取差集 = M-P;
    NSMutableArray *justPs = [[NSMutableArray alloc] init];
    NSInteger nextStartJ = 0;
    for (NSInteger i = 0; i < shortFo.count; i++) {
        BOOL findShortAlg = false;
        AIKVPointer *shortAlg_p = ARR_INDEX(shortFo.content_ps, i);
        for (NSInteger j = nextStartJ; j < matchContent.count; j++) {
            //4. 判断mIsC是否成立;
            AIKVPointer *matchAlg_p = ARR_INDEX(matchContent, j);
            BOOL mIsC = [TOUtils mIsC_1:shortAlg_p c:matchAlg_p];
            
            //5. shortAlg和matchAlg判断mIsC成立,则取差值;
            if (mIsC) {
                AIAlgNodeBase *matchAlg = [SMGUtils searchNode:matchAlg_p];
                AIAlgNodeBase *shortAlg = [SMGUtils searchNode:shortAlg_p];
                NSArray *pSubM = [SMGUtils removeSub_ps:matchAlg.content_ps parent_ps:shortAlg.content_ps];
                if (!ARRISOK(pSubM)) continue;
                
                //6. 差值有效,则构建新SPAlg节点;
                AIAbsAlgNode *spAlg = [theNet createAbsAlg_NoRepeat:pSubM conAlgs:@[matchAlg] isMem:false ds:ds];
                if (Log4InRethink) NSLog(@"--> IRT构建SPAlg:%@ base:%@",Alg2FStr(spAlg),Alg2FStr(matchAlg));
                
                //7. 收集spAlg并更新nextStartJ & findShortAlg;
                [justPs addObject:spAlg.pointer];
                nextStartJ = j + 1;
                findShortAlg = true;
            }
        }
        
        //8. P在M中未找到时,也要收集 (比如乌鸦带了交警时,车不敢撞);
        if (!findShortAlg) [justPs addObject:shortAlg_p];
    }
    
    //9. 构建SPFo;
    AIFoNodeBase *spFo = [theNet createAbsFo_NoRepeat:@[matchFo] content_ps:justPs difStrong:1 ds:ds];
    if (Log4InRethink) NSLog(@"--> IRT构建SPFo:%@ base:%@",Fo2FStr(spFo),Fo2FStr(matchFo));
}

/**
 *  MARK:--------------------Out反省类比--------------------
 *  @desc Out反省 (参考20205);
 *      1. 其实并不真正进行类比,而是对决策中未PM修正的部分,直接构建Sub节点;
 *      2. 对已发生的 (cutIndex < algIndex) 的部分每一帧,收集未被PM修正的sub稀疏码,构建ATSubAlg (当前的两个调用者,都是全序列);
 *      3. 对上述ATSubAlgs构建成ATSub时序;
 *      4. 根据ATSubFo,从稀疏码向概念,再向时序索引查找,同样foNode的另外的assSubFo,并进行外类比 (目前仅简单的取时序的ATSub抽象);
 *      5. 外类比构建更确切的S时序,如果已存在,则加强;
 *  @use : 用于PM中对Alg评价;
 *
 *  @callers
 *      1. ActYes流程控制的HNGL调用时,生物钟触发器触发成功时,理性分析什么导致了未成功 (cutIndex无用,因为全部用);
 *      2. ActYes流程控制的Demand调用时,生物钟触发器触发成功时,理性分析什么导致了未成功 (cutIndex无用,因为全部用);
 *      3. ActYes流程控制的isOut调用时,生物钟触发器触发成功时,理性分析什么导致了行为未成功 (cutIndex有用) (未启用);
 *  @version
 *      2020.09.03: 支持ATPlus反省类比;
 *      2020.12.18: 支持GL反省类比 (本来就支持) (参考20205 & 21187);
 *      2020.12.24: 在spContent为0时,也构建spFo (构建空SP) (参考21202);
 *      2021.05.08: 将sp外类比结果直接嵌套在同层fo下,以使其参与到VRS评价中,以及参与到今后的再外类比 (参考23064);
 *  @todo
 *      2020.12.23: 支持构建空SP (参考21188);
 *  @bug
 *      2020.09.18: 因为数据结构取错,导致取不到justPValues的BUG (参考:21027) T;
 *      2020.09.29: except_ps取错,导致反省类比的稀疏码内容经常为空 (参考21055描述及示图);
 *      2021.01.11: 有时baseAlg没有reModel,子节点直接就是value,导致取reModel..subModels闪退 (改为无reModel时直接用baseAlg);
 */
+(void) analogy_OutRethink:(TOFoModel*)foModel cutIndex:(NSInteger)cutIndex type:(AnalogyType)type{
    //1. 数据准备
    if (!foModel || (type != ATSub && type != ATPlus)) return;
    AIFoNodeBase *foNode = [SMGUtils searchNode:foModel.content_p];
    NSMutableArray *spFoContent = [[NSMutableArray alloc] init];
    NSString *spDS = [ThinkingUtils getAnalogyTypeDS:type];
    NSLog(@"\n\n=============================== Out反省类比 (%@) ===============================\n时序:%@->%@",ATType2Str(type),Fo2FStr(foNode),Mvp2Str(foNode.cmvNode_p));
    
    //2. 构建SPAlg (触发反省类比_实际fo数据收集 (不用收集realFo,而是直接对未修正部分构建,参考20205-原则1));
    for (TOAlgModel *toAlgModel in foModel.subModels) {
        if (!ISOK(toAlgModel, TOAlgModel.class)) WLog(@"查下此处,为何fo的subModel不是algModel类型,如果2020.10之前未见过此警告,可取消打印此日志;");
        if (!ISOK(toAlgModel, TOAlgModel.class)) continue;
        
        //2. 取出reModel;
        TOAlgModel *reModel = [ThinkingUtils analogyReasonRethink_GetFirstReModelIfHav:toAlgModel];
        
        //3. 排除掉Finish的;
        //TODOTOMORROW20210507:此处责任在于gl修正失败的,而不是所有非finish全负责 (参考23061);
        NSArray *except_ps = [TOUtils convertPointersFromTOValueModelSValue:reModel.subModels validStatus:@[@(TOModelStatus_Finish)]];
        
        //3. 剩下 "未修正(无需修正NoNeedAct/修正失败ActNo)的稀疏码" (参考20205-原则2);
        NSArray *notFinish_ps = [SMGUtils removeSub_ps:except_ps parent_ps:reModel.justPValues];
        NSLog(@"item--> justPValues:(%@) - excepts:(%@) = (%@)",Pits2FStr(reModel.justPValues),Pits2FStr(except_ps),Pits2FStr(notFinish_ps));
        
        //4. 未修正部分构建为: "SP概念"
        AIAlgNodeBase *curAlg = [SMGUtils searchNode:toAlgModel.content_p];
        if (!ARRISOK(notFinish_ps)) continue;
        AIAbsAlgNode *spAlg = [theNet createAbsAlg_NoRepeat:notFinish_ps conAlgs:@[curAlg] isMem:false ds:spDS];
        if (Log4OutRethink) NSLog(@"--> ORT构建SPAlg:%@ base:%@",Alg2FStr(spAlg),AlgP2FStr(curAlg.pointer));
        
        //调试分析"定责" (参考23065);
        //3. S定罚 (未加工的全责 或 加工失败的那一条全责) (参考23066);
        for (AIKVPointer *item in notFinish_ps) {
            if (type == ATSub) {
                if (![item.dataSource isEqualToString:@"distance"]) {
                    NSLog(@"非距进入S,查为什么? (%@) %@",ATType2Str(type),Pit2FStr(item));
                    NSLog(@"");
                }
            }
        }
        
        
        //5. 收集SP概念_用于构建SP时序;
        [spFoContent addObject:spAlg.pointer];
    }
    
    //6. 构建SPFo
    AINetAbsFoNode *spFo = [theNet createAbsFo_NoRepeat:@[foNode] content_ps:spFoContent difStrong:1 ds:spDS];
    if (Log4OutRethink) NSLog(@"--> ORT构建SPFo:%@ base:%@",Fo2FStr(spFo),Fo2FStr(foNode));
    if (spFo && ARRISOK(spFo.content_ps)) {
        //7. 向性左向右,以当前foNode为交集指引,找assSPFo,以进行外类比 (参考20205-原则3);
        NSArray *spAbsPorts = [AINetUtils absPorts_All:foNode type:type];
        NSArray *assSPFos = Ports2Pits(spAbsPorts);
        assSPFos = [SMGUtils removeSub_p:spFo.pointer parent_ps:assSPFos];
        assSPFos = ARR_SUB(assSPFos, 0, cRethinkActBack_AssSPFoLimit);
        
        //8. 外类比;
        if (spFo && ARRISOK(assSPFos)) {
            for (AIKVPointer *item in assSPFos) {
                AINetAbsFoNode *assSPFo = [SMGUtils searchNode:item];
                AINetAbsFoNode *absSPFo = [AIAnalogy analogyOutside:spFo assFo:assSPFo type:type createAbsAlgBlock:nil];
                
                //9. 将absSP与foNode建立嵌套关联;
                AIPort *spPort = [AINetUtils findPort:spFo.pointer fromPorts:spAbsPorts];
                AIPort *assPort = [AINetUtils findPort:assSPFo.pointer fromPorts:spAbsPorts];
                NSMutableArray *strongPorts = [[[[NSMutableArray alloc] init] append:spPort] append:assPort];
                [AINetUtils relateFoAbs:absSPFo conNodes:@[foNode] isNew:false strongPorts:strongPorts];
            }
        }
    }
}

@end
