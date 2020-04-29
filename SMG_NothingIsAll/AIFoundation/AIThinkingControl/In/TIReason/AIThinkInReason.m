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
#import "AIThinkInAnalogy.h"
//temp
#import "NVHeUtil.h"
#import "ThinkingUtils.h"

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
 *  @desc 迭代记录:
 *      20190910: 识别"概念与时序",并构建纵向关联; (190910概念识别,添加了抽象关联)
 *      20191223: 局部匹配支持全含: 对assAlg和protoAlg直接做抽象关联,而不是新构建抽象;
 *      20200307: 迭代支持模糊匹配fuzzy
 *      20200413: 无全含时,支持最相似的seemAlg返回;
 *      20200416: 废除绝对匹配 (因概念全局去重了,绝对匹配匹配没有意义);
 *  @param complete : 共支持三种返回: 匹配效果从高到低分别为:fuzzyAlg,matchAlg,seemAlg;
 */
+(void) TIR_Alg:(AIKVPointer*)algNode_p fromGroup_ps:(NSArray*)fromGroup_ps complete:(void(^)(AIAlgNodeBase *matchAlg,MatchType type))complete{
    //1. 数据准备
    AIAlgNodeBase *algNode = [SMGUtils searchNode:algNode_p];
    if (algNode == nil) return;
    NSLog(@"------------------------------- 概念识别 -------------------------------\n%@",Alg2FStr(algNode));
    
    //2. 对value.refPorts进行检查识别; (noMv信号已输入完毕,识别联想)
    __block AIAlgNodeBase *assAlgNode = nil;
    __block MatchType matchType = MatchType_None;
    ///1. 自身匹配 (Self匹配);
    if ([TIRUtils inputAlgIsOld:algNode]) {
        assAlgNode = algNode;
        matchType = MatchType_Self;
    }
    
    ///3. 局部匹配 -> 内存网络;
    ///19xxxx注掉,不能太过于脱离持久网络做思考,所以先注掉;
    ///190625放开,因采用内存网络后,靠这识别;
    ///200116注掉,因为识别仅是建立抽象关联,此处会极易匹配到内存中大量的具象alg,导致无法建立关联,而在硬盘网络时,这种几率则低许多;
    //if (!assAlgNode) {
    //    assAlgNode = [AINetIndexUtils partMatching_Alg:algNode isMem:true except_ps:fromGroup_ps];
    //}
    
    ///4. 局部匹配 (Abs匹配 和 Seem匹配);
    if (!assAlgNode) {
        [TIRUtils partMatching_Alg:algNode isMem:false except_ps:fromGroup_ps complete:^(AIAlgNodeBase *matchAlg, MatchType type) {
            assAlgNode = matchAlg;
            matchType = type;
        }];
    }
    
    //3. 直接将assAlgNode设置为algNode的抽象; (这样后面TOR理性决策时,才可以直接对当前瞬时实物进行很好的理性评价);
    if (ISOK(assAlgNode, AIAlgNodeBase.class)) {
        //4. 识别到时,value.refPorts -> 更新/加强微信息的引用序列
        [AINetUtils insertRefPorts_AllAlgNode:assAlgNode.pointer content_ps:assAlgNode.content_ps difStrong:1];
        
        //5. 识别且全含时,进行抽具象关联 & 存储 (20200103:测得,algNode为内存节点时,关联也在内存)
        if (matchType == MatchType_Abs) [AINetUtils relateAlgAbs:(AIAbsAlgNode*)assAlgNode conNodes:@[algNode] isNew:false];
    }
    
    //3. 全含时,可进行模糊匹配 (Fuzzy匹配) //因TOR未支持fuzzy,故目前仅将最相似的fuzzy放到AIShortMatchModel中当matchAlg用;
    if (matchType == MatchType_Abs) {
        NSArray *fuzzys = ARRTOOK([TIRUtils matchAlg2FuzzyAlgV2:algNode matchAlg:assAlgNode except_ps:fromGroup_ps]);
        AIAlgNodeBase *fuzzyAlg = ARR_INDEX(fuzzys, 0);
        //a. 模糊匹配有效时,增强关联,并截胡;
        if (fuzzyAlg) {
            [AINetUtils insertRefPorts_AllAlgNode:fuzzyAlg.pointer content_ps:fuzzyAlg.content_ps difStrong:1];
            assAlgNode = fuzzyAlg;
            matchType = MatchType_Fuzzy;
        }
    }
    
    //4. 调试日志
    NSLog(@"STEPKEY----> 识别Alg Finish 类型:%ld 内容:%@",matchType,Alg2FStr(assAlgNode));
    complete(assAlgNode,matchType);
}

/**
 *  MARK:--------------------重新识别rtAlg方法--------------------
 *  @version 20200406 : 由复用fromMem的识别M再Fuzzy(),改为仅识别硬盘MatchAlg,并返回;
 *  @desc 功能说明:
 *      1. result必须包含mUniqueValue;
 *      2. result必须被rtAlg全含 (代码见partMatching_General());
 *      3. result不进行fuzzy模糊匹配 (因为mUniqueValue并非新输入,并且fuzzy会导致多出杂项码(如:m为经26,fuzzyAlg却包含距20));
 */
+(AIAlgNodeBase*) TIR_Alg_FromRethink:(AIAlgNodeBase*)rtAlg mUniqueV_p:(AIKVPointer*)mUniqueV_p{
    //1. 数据检查
    if (!rtAlg || !mUniqueV_p) return nil;
    NSArray *mUniqueRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Value:mUniqueV_p]];
    NSLog(@"---------- TIR_Alg_FromRT START ----------");
    NSLog(@"----> 特码:%@ 被引:%ld个 RTAlg:%@",[NVHeUtil getLightStr:mUniqueV_p],mUniqueRef_ps.count,Alg2FStr(rtAlg));
    
    //2. 识别
    __block AIAlgNodeBase *matchAlg = nil;
    [TIRUtils partMatching_General:rtAlg.content_ps refPortsBlock:^NSArray *(AIKVPointer *item_p) {
        if (item_p) {
            //1> 数据准备 (value_p的refPorts是单独存储的);
            return ARRTOOK([SMGUtils searchObjectForFilePath:item_p.filePath fileName:kFNRefPorts time:cRTReference]);
        }
        return nil;
    } checkBlock:^BOOL(AIPointer *target_p) {
        if (target_p) {
            //2> 自身 && 包含M特有码;
            return ![target_p isEqual:rtAlg.pointer] && [mUniqueRef_ps containsObject:target_p];
        }
        return false;
    } complete:^(AIAlgNodeBase *outMatchAlg, MatchType type) {
        if (type == MatchType_Abs) {
            matchAlg = outMatchAlg;
        }
    }];
    
    //3. 直接将assAlgNode设置为algNode的抽象; (这样后面TOR理性决策时,才可以直接对当前瞬时实物进行很好的理性评价);
    if (ISOK(matchAlg, AIAlgNodeBase.class)) {
        //4. 识别到时,value.refPorts -> 更新/加强微信息的引用序列
        [AINetUtils insertRefPorts_AllAlgNode:matchAlg.pointer content_ps:matchAlg.content_ps difStrong:1];
        
        //5. 识别到时,进行抽具象 -> 关联 & 存储 (20200103:测得,algNode为内存节点时,关联也在内存)
        [AINetUtils relateAlgAbs:(AIAbsAlgNode*)matchAlg conNodes:@[rtAlg] isNew:false];
    }
    NSLog(@"识别Alg_FromRT Finish:%@",Alg2FStr(matchAlg));
    return matchAlg;
}

//MARK:===============================================================
//MARK:                     < TIR_Fo >
//MARK: @desc : 目前仅支持局部匹配;
//MARK:===============================================================

/**
 *  MARK:--------------------理性时序--------------------
 *  @param protoAlg_ps : RTFo
 *      1. 传入原始瞬时记忆序列 90% ,还是识别后的概念序列 10%;
 *      2. 传入行为化中的rethinkLSP重组fo;
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
 *      20200403 : 将assFoIndexAlg由proto.lastIndex改为replaceMatchAlg来代替 (因为lastAlg索引失败率太高);
 *  @todo :
 *      20200403 TODOTOMORROW: 支持识别到多个时序,并以此得到多个价值预测 (支持更多元的评价);
 *
 */
+(void) TIR_Fo_FromRethink:(NSArray*)protoAlg_ps replaceMatchAlg:(AIAlgNodeBase*)replaceMatchAlg finishBlock:(void(^)(AIFoNodeBase *curNode,AIFoNodeBase *matchFo,CGFloat matchValue,NSInteger cutIndex))finishBlock{
    //1. 数据检查
    AIKVPointer *last_p = ARR_INDEX_REVERSE(protoAlg_ps, 0);
    AIAlgNodeBase *lastAlg = [SMGUtils searchNode:last_p];
    NSArray *lastAlgRefPorts = [AINetUtils refPorts_All4Alg:lastAlg];
    if (!ARRISOK(protoAlg_ps) || !replaceMatchAlg || !lastAlg) {
        return;
    }
    AIFrontOrderNode *protoFo = [theNet createConFo:protoAlg_ps isMem:true];//将protoAlg_ps构建成时序;
    NSLog(@"-------------------------- 反思时序识别 --------------------------%@",Fo2FStr(protoFo));
    
    //2. 调用通用时序识别方法 (checkItemValid: 可考虑写个isBasedNode()判断,因protoAlg可里氏替换,目前仅支持后两层)
    [self partMatching_Fo:protoFo assFoIndexAlg:replaceMatchAlg assFoBlock:^NSArray *(AIAlgNodeBase *indexAlg) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        if (indexAlg) {
            //a. 只能识别cNormal时序;
            NSArray *normalRefPorts = [SMGUtils filterPorts_Normal:indexAlg.refPorts];
            
            for (AIPort *refPort in normalRefPorts) {;
                NSLog(@"-----> TIR_Fo 索引:(%@) 取得时序:%@",[NVHeUtil getLightStr4Ps:indexAlg.content_ps],FoP2FStr(refPort.target_p));
                //b. rethink时,必须包含replaceMatchAlg的时序才有效;
                if ([SMGUtils containsSub_p:refPort.target_p parentPorts:lastAlgRefPorts]) {
                    NSLog(@"-----> TIR_Fo 取得时序成功");
                    [result addObject:refPort];
                    if (result.count >= cPartMatchingCheckRefPortsLimit) {
                        break;
                    }
                }
            }
        }
        return result;
    } checkItemValid:^BOOL(AIKVPointer *itemAlg_p, AIKVPointer *assAlg_p) {
        //1. rethink需要单matchAlg对多抽象,共两层判断是否isEquals; (1 x N)
        //TODO_TEST_HERE: 本愿是自match层开始,已有去重机制,故使用指针匹配,如无去重且不好加,此处可改为md5匹配;
        AIKVPointer *matchAlg_p = itemAlg_p;
        if (matchAlg_p && assAlg_p) {
            
            //2. 判断 1 (如是否苹果);
            if (![assAlg_p isEqual:matchAlg_p]) {
                
                //3. 判断 N (都不一样,则返回false) (如是否水果);
                AIAlgNodeBase *matchAlg = [SMGUtils searchNode:matchAlg_p];
                if (matchAlg) {
                    if (![SMGUtils containsSub_p:assAlg_p parentPorts:matchAlg.absPorts]) {
                        return false;
                    }
                }
            }
        }
        return true;
    } finishBlock:^(AIFoNodeBase *matchFo, CGFloat matchValue,NSInteger cutIndex) {
        finishBlock(protoFo,matchFo,matchValue,cutIndex);
    }];
}

/**
 *  MARK:--------------------瞬时时序识别--------------------
 *  @param protoFo : MemFo (由瞬时记忆中概念序列组成);
 *  @version
 *      20200414 - protoFo由瞬时proto概念组成,改成瞬时match概念组成 (本方法中,去掉proto概念层到match层的联想);
 */
+(void) TIR_Fo_FromShortMem:(AIFoNodeBase*)protoFo lastMatchAlg:(AIAlgNodeBase*)lastMatchAlg finishBlock:(void(^)(AIFoNodeBase *curNode,AIFoNodeBase *matchFo,CGFloat matchValue,NSInteger cutIndex))finishBlock{
    //1. 数据检查
    if (!protoFo || !lastMatchAlg) {
        return;
    }
    
    NSLog(@"STEPKEY--------------------------------------- 瞬时时序识别 ---------------------------------------\nSTEPKEY%@",Fo2FStr(protoFo));
    //2. 调用通用时序识别方法 (checkItemValid: 可考虑写个isBasedNode()判断,因protoAlg可里氏替换,目前仅支持后两层)
    [self partMatching_Fo:protoFo assFoIndexAlg:lastMatchAlg assFoBlock:^NSArray *(AIAlgNodeBase *indexAlg) {
        if (indexAlg) {
            NSArray *normalRefPorts = [SMGUtils filterPorts_Normal:indexAlg.refPorts];
            return ARR_SUB(normalRefPorts, 0, cPartMatchingCheckRefPortsLimit);
        }
        return nil;
    } checkItemValid:^BOOL(AIKVPointer *itemAlg_p, AIKVPointer *assAlg_p) {
        //1. shortMem需要多matchAlg对多抽象,共两层判断是否isEquals; (N x N) (20200414改为1xN)
        //TODO_TEST_HERE: 本愿是自match层开始,已有去重机制,故使用指针匹配,如无去重且不好加,此处可改为md5匹配;
        if (itemAlg_p && assAlg_p) {
            NSLog(@"-------------- checkAlgValid --------------\n%@\n%@",AlgP2FStr(itemAlg_p),AlgP2FStr(assAlg_p));
            
            //2. 判断 1 (如是否苹果);
            if (![itemAlg_p isEqual:assAlg_p]) {
                //3. 判断N (都不一样,则返回false) (如是否水果/有颜色/有味道/圆的/青的/红的/甜的);
                AIAlgNodeBase *matchAlg = [SMGUtils searchNode:itemAlg_p];
                if (matchAlg) {
                    if (![SMGUtils containsSub_p:assAlg_p parentPorts:[AINetUtils absPorts_All:matchAlg]]) {
                        NSLog(@"---> checkItem无效 (Match.Abs层)");
                        return false;
                    }
                }
                NSLog(@"--->>>> checkItem有效 (Match.Abs层)");
                return true;
            }else{
                NSLog(@"--->>> checkItem有效 (Match层)");
                return true;
            }
        }
        return true;
    } finishBlock:^(AIFoNodeBase *matchFo, CGFloat matchValue,NSInteger cutIndex) {
        finishBlock(protoFo,matchFo,matchValue,cutIndex);
    }];
}


/**
 *  MARK:--------------------时序的局部匹配--------------------
 *  参考: n17p7 TIR_FO模型到代码
 *  @param assFoIndexAlg    : 用来联想fo的索引概念 (shortMem的第3层 或 rethink的第1层) (match层,参考n18p2)
 *  @param assFoBlock       : 联想fos (联想有效的5个)
 *  @param checkItemValid   : 检查item(fo.alg)的有效性 notnull (可考虑写个isBasedNode()判断,因protoAlg可里氏替换,目前仅支持后两层)
 *  @param finishBlock      : 完成 notnull
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
 *  @测试BUG/迭代记录:
 *      20191231: 测试到,点击饥饿,再点击乱投,返回matchFo:nil matchValue:0;所以针对此识别失败问题,发现了_fromShortMem和_fromRethink的不同,且支持了两层assFo,与全含;(参考:n18p2)
 *
 */
+(void) partMatching_Fo:(AIFoNodeBase*)protoFo
          assFoIndexAlg:(AIAlgNodeBase*)assFoIndexAlg
             assFoBlock:(NSArray*(^)(AIAlgNodeBase *indexAlg))assFoBlock
         checkItemValid:(BOOL(^)(AIKVPointer *itemAlg_p,AIKVPointer *assAlg_p))checkItemValid
            finishBlock:(void(^)(AIFoNodeBase *matchFo,CGFloat matchValue,NSInteger cutIndex))finishBlock{
    //1. 数据准备
    if (!ISOK(protoFo, AIFoNodeBase.class) || !assFoIndexAlg) {
        finishBlock(nil,0,0);
        return;
    }
    __block BOOL successed = false;
    
    //2. 取assIndexes (取递归两层)
    NSMutableArray *assIndexes = [[NSMutableArray alloc] init];
    [assIndexes addObject:assFoIndexAlg.pointer];
    [assIndexes addObjectsFromArray:[SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:assFoIndexAlg]]];
    
    //3. 递归进行assFos
    NSLog(@"------------ TIR_Fo ------------索引数:%lu",(unsigned long)assIndexes.count);
    for (AIKVPointer *assIndex_p in assIndexes) {
        AIAlgNodeBase *indexAlg = [SMGUtils searchNode:assIndex_p];
        
        //4. indexAlg.refPorts; (取识别到过的抽象节点(如苹果));
        NSArray *assFoPorts = ARRTOOK(assFoBlock(indexAlg));
        NSLog(@"-----> TIR_Fo 索引到有效时序数:%lu",(unsigned long)assFoPorts.count);
        
        //5. 依次对assFos对应的时序,做匹配度评价; (参考: 160_TIRFO单线顺序模型)
        for (AIPort *assFoPort in assFoPorts) {
            AIFoNodeBase *assFo = [SMGUtils searchNode:assFoPort.target_p];
            
            //6. 对assFo做匹配判断;
            [TIRUtils TIR_Fo_CheckFoValidMatch:protoFo assFo:assFo checkItemValid:checkItemValid success:^(NSInteger lastAssIndex, CGFloat matchValue) {
                NSLog(@"STEPKEY时序识别: SUCCESS >>> matchValue:%f %@->%@",matchValue,Fo2FStr(assFo),Mvp2Str(assFo.cmvNode_p));
                successed = true;
                finishBlock(assFo,matchValue,lastAssIndex);
            } failure:^(NSString *msg) {
                NSLog(@"%@",msg);
            }];
            
            //7. 成功一条即return
            if (successed) return;
        }
    }
}

/**
 *  MARK:--------------------内类比--------------------
 *  @desc 在理性中进行内类比;
 *  @支持: 目前理性内类比不支持energy,待以后版本再考虑支持;
 */
+(void) analogyInner:(AIFoNodeBase*)protoFo{
    [AIThinkInAnalogy analogyInner_FromTIR:protoFo canAss:^BOOL{
        return true;
    } updateEnergy:nil];
}

@end
