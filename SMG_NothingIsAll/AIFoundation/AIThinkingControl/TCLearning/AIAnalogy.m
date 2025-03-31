//
//  AIAnalogy.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/3/20.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIAnalogy.h"
#import "AINetAbsCMVUtil.h"

@implementation AIAnalogy

//MARK:===============================================================
//MARK:                     < 外类比时序 >
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
 *  _param noRepeatArea_ps : 类比结果absFo的防重范围 (默认传nil时,会全局防重);
 *
 *  @version
 *      20200215: 有序外类比: 将forin循环fo和assFo改为反序,并记录上次类比位置jMax (因出现了[果,果,吃,吃]这样的异常时序) 参考n18p11;
 *      20200831: 支持反省外类比,得出更确切的ATSub原因,参考:20205-步骤4;
 *      20201203: 修复21175BUG (因createAbsAlgBlock忘记调用,导致absAlg和glAlg间未关联) (参考21115);
 *      20210819: 修复长1和长2类比时,类比出长2的BUG (参考23221-BUG2);
 *      20210926: 修复glFo外类比时非末位alg类比构建absAlg时,也使用了GLType的问题 (参考24022-BUG1);
 *      20221028: 用mIsC判断替代sameValue_ps (参考27153-todo4);
 *      20230322: 打开外类比,支持(根据相近度将主要责任的码抽象掉)共同点抽象 (参考29025-11);
 *      20230327: 支持得出protoFo/assFo 与 absFo的indexDic映射 (参考29032-todo1.2);
 */
+(AINetAbsFoNode*) analogyOutside:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo type:(AnalogyType)type {
    return [self analogyOutside:protoFo assFo:assFo type:type noRepeatArea_ps:nil];
}
+(AINetAbsFoNode*) analogyOutside:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo type:(AnalogyType)type noRepeatArea_ps:(NSArray*)noRepeatArea_ps {
    //1. 类比orders的规律
    if (Log4Ana) NSLog(@"\n----------- 外类比(%@) -----------\nfo:%@ \nassFo:%@",ATType2Str(type),Fo2FStr(protoFo),Fo2FStr(assFo));
    NSMutableArray *orderSames = [[NSMutableArray alloc] init];
    NSMutableDictionary *protoAssIndexDic = [NSMutableDictionary new];//收集proto和ass的映射;
    if (protoFo && assFo) {

        //2. 外类比有序进行 (记录jMax & 反序)
        NSInteger jMax = assFo.count - 1;
        for (NSInteger i = protoFo.count - 1; i >= 0; i--) {
            for (NSInteger j = jMax; j >= 0; j--) {
                AIKVPointer *protoA_p = protoFo.content_ps[i];
                AIKVPointer *assA_p = assFo.content_ps[j];
                
                //3. B源于matchFo,此处只判断B是1层抽象 (参考27161-调试1&调试2);
                //此处proto抽象仅指向刚识别的matchAlgs,所以与contains等效;
                BOOL mIsC = [TOUtils mIsC_1:protoA_p c:assA_p];
                if (Log4Ana) NSLog(@"proto的第%ld: A%ld 类比 ass的第%ld: A%ld (%@)",i,protoA_p.pointerId,j,assA_p.pointerId,mIsC?@"成功":@"失败");
                if (mIsC) {
                    
                    //4. 即使mIsC匹配,也要进行共同点抽象 (参考29025-11);
                    AIAlgNodeBase *absA = [self analogyAlg:protoA_p assA:assA_p];
                    
                    //TODOTOMORROW20240801: 查下此处为什么M1(饥饿)和A3955(皮果)会有mIsC关系? (参考32132);
                    //日志: alg类比 ===> M1{↑饿-16} : A3955(向90,距13,皮果) = A9585()
                    //日志: alg类比 ===> A4467(向92,距12,果) : A3967(飞↑) = A8471()
                    if (Log4Ana) NSLog(@"alg类比 ===> %@ : %@ = %@",Pit2FStr(protoA_p),Pit2FStr(assA_p),Alg2FStr(absA));
                    
                    //5. 收集并更新jMax;
                    [protoAssIndexDic setObject:@(i) forKey:@(j)];
                    [orderSames insertObject:absA.pointer atIndex:0];
                    jMax = j - 1;
                    break;
                }
            }
        }
    }

    //6. 生成protoIndexDic 和 assIndexDic  (参考29032-todo1.2);
    NSDictionary *assAbsIndexDic = [AINetUtils getIndexDic4AnalogyAbsFo:protoAssIndexDic.allKeys];
    NSDictionary *protoAbsIndexDic = [AINetUtils getIndexDic4AnalogyAbsFo:protoAssIndexDic.allValues];
    
    //7. 外类比构建
    return [self analogyOutside_Creater:orderSames protoFo:protoFo assFo:assFo type:type protoIndexDic:protoAbsIndexDic assIndexDic:assAbsIndexDic noRepeatArea_ps:noRepeatArea_ps];
}

/**
 *  MARK:--------------------外类比的构建器--------------------
 *  1. 构建absFo
 *  2. 构建absCmv
 *  @todo
 *      20200416 - TODO_NEXT_VERSION:方法中absFo是防重的,如果absFo并非新构建,而又为其构建了absMv,则会有多个mv指向同一个fo的问题;
 *  @version
 *      2020.07.22: 在外类比无需构建时 (即具象和抽象一致时),其方向索引强度+1;
 *      2021.08.10: 在RFos的再抽象调用时,有可能将防重的带mvDeltaTime的值重置为0的BUG (参考23212-问题2);
 *      2021.09.23: 构建fo时,新增type参数,废弃原foDS(typeStr)的做法 (参考24019-时序部分);
 *      2021.09.26: 仅构建glFo时才从conNodes取at&ds值,避免SFo也有值的问题 (参考24022-BUG2);
 *      2021.09.28: ATSame和ATDiff两个type是描述是否包含cmv指向的,改为传ATDefault过来 (参考24022-BUG5);
 *      2023.07.28: 把mvDeltaTime改成偏移修正方式 (参考30087-分析1);
 */
+(AINetAbsFoNode*)analogyOutside_Creater:(NSArray*)orderSames protoFo:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo type:(AnalogyType)type protoIndexDic:(NSDictionary*)protoIndexDic assIndexDic:(NSDictionary*)assIndexDic noRepeatArea_ps:(NSArray*)noRepeatArea_ps{
    //2. 数据检查;
    AINetAbsFoNode *result = nil;
    if (ARRISOK(orderSames) && ISOK(protoFo, AIFoNodeBase.class) && ISOK(assFo, AIFoNodeBase.class)) {

        //3. fo和assFo本来就是抽象关系时_直接关联即可;
        BOOL samesEqualAssFo = orderSames.count == assFo.count && [SMGUtils containsSub_ps:orderSames parent_ps:assFo.content_ps];
        BOOL jumpForAbsAlreadyHav = (ISOK(assFo, AINetAbsFoNode.class) && samesEqualAssFo);
        if (jumpForAbsAlreadyHav) {
            result = (AINetAbsFoNode*)assFo;
            [AINetUtils relateFoAbs:result conNodes:@[protoFo] isNew:false];
            [AINetUtils insertRefPorts_AllFoNode:result.pointer order_ps:result.content_ps ps:result.content_ps];
            
            //3. 存储protoFo与matchFo之间的匹配度 (参考33143-方案1);
            [protoFo updateMatchValue:result matchValue:1];
            
            if (result.cmvNode_p) [theNet setMvNodeToDirectionReference:[SMGUtils searchNode:result.cmvNode_p] difStrong:1];
        }else{
            //4. 取foDifStrong
            NSInteger foDifStrong = 1;
            AICMVNodeBase *foMv = [SMGUtils searchNode:protoFo.cmvNode_p];
            AICMVNodeBase *assMv = [SMGUtils searchNode:assFo.cmvNode_p];
            if (foMv && assMv) {
                NSArray *conMvs = [SMGUtils searchNodes:@[protoFo.cmvNode_p,assFo.cmvNode_p]];
                NSInteger absUrgentTo = [AINetAbsCMVUtil getAbsUrgentTo:conMvs];
                foDifStrong = absUrgentTo;
            }
            
            //5. 构建absFoNode (当GL时,传入at&ds);
            HEResult *heResult = [theNet createAbsFo_NoRepeat:orderSames protoFo:protoFo assFo:assFo difStrong:foDifStrong type:type protoIndexDic:protoIndexDic assIndexDic:assIndexDic outConAbsIsRelate:nil noRepeatArea_ps:noRepeatArea_ps];
            result = heResult.data;
            
            //6. 算出具象总强度,其和已经是累计了此次类比的新关联强度 (参考30087-todo6);
            NSArray *conPorts = [AINetUtils conPorts_All:result];
            NSInteger sumStrong = 0;
            for (AIPort *item in conPorts) sumStrong += item.strong.value;
            [AITest test30:sumStrong];
            CGFloat frontMvDeltaTime4Log = result.mvDeltaTime;
            
            //6.1. 将protoFo的mvDeltaTime偏移量计入 (参考30087-todo5&6);
            result.mvDeltaTime += (protoFo.mvDeltaTime - result.mvDeltaTime) / (sumStrong - 1);
            
            //6.2. 将assFo的mvDeltaTime偏移量计入 (参考30087-todo5&6);
            result.mvDeltaTime += (assFo.mvDeltaTime - result.mvDeltaTime) / sumStrong;
            //NSLog(@"偏移mvDeltaTime (从%.2f到%.2f) (总强度:%ld con1:%.2f con2:%.2f) ",frontMvDeltaTime4Log,result.mvDeltaTime,sumStrong,protoFo.mvDeltaTime,assFo.mvDeltaTime);
            
            //6. createAbsCmvNode (当正向类比,且result没有cmv指向时);
            if (protoFo.cmvNode_p && assMv && !result.cmvNode_p) {
                AIAbsCMVNode *resultMv = [theNet createAbsCMVNode_Outside:nil aMv_p:protoFo.cmvNode_p bMv_p:assMv.pointer];
                [AINetUtils relateFo:result mv:resultMv];//cmv模型连接;
            }
        }
    }
    //调试短时序; (先仅打外类比日志);
    NSInteger foStrong = [AINetUtils getStrong:result atConNode:protoFo type:type];
    NSInteger assFoStrong = [AINetUtils getStrong:result atConNode:assFo type:type];
    if (Log4Ana) NSLog(@"1. 新proto: %@\n2. 与ass: %@ \n3. 外类比构建时序: %@->{%@} from: (protoFo(%ld):assFo(%ld))",Fo2FStr(protoFo),Fo2FStr(assFo),Fo2FStr(result),Mvp2Str(result.cmvNode_p),foStrong,assFoStrong);
    return result;
}

/**
 *  MARK:--------------------概念类比--------------------
 *  @desc 概念类比: 将相近度低的(负主要责任的)过滤掉 (参考29025-12);
 *        作用范围: 仅适用于protoA和assA有抽具象关系时的概念类比;
 *  @version
 *      2023.05.10: 修复此处抽具象匹配度未储存,导致复用时取不到的问题 (参考29091);
 *      2024.06.12: 修复M1和M1类比出A13的问题 (因为根据sameValue_ps去进行createAbsAlg_NoRepeat)最终输出的一定是A节点而不是M节点 (参考31187);
 *                  另: M1和M2还是可能生成为Axx,这个是难免的,随后看全部重新训练时: 彻底废弃Mv节点;
 */
+(AIAlgNodeBase*) analogyAlg:(AIKVPointer*)protoA_p assA:(AIKVPointer*)assA_p {
    //0. 如果本就一致;
    if ([protoA_p isEqual:assA_p]) return [SMGUtils searchNode:protoA_p];
    
    //1. 数据准备;
    AIAlgNodeBase *protoA = [SMGUtils searchNode:protoA_p];
    AIAlgNodeBase *assA = [SMGUtils searchNode:assA_p];
    NSMutableArray *sameValue_ps = [[NSMutableArray alloc] init];
    AIMatchAlgModel *protoAbsModel4MatchValue = [[AIMatchAlgModel alloc] init];//此模型仅用于收集proto和abs的相近度,用于计算matchValue;
    
    //2. 数据检查（当前有主责，直接剔除）（时序全含，概念以mIsC来剔除，不做责任计算）。
    CGFloat curMatchValue = [protoA getAbsMatchValue:assA_p];
    //if (![TCLearningUtil noZeRenForCenJi:curMatchValue bigerMatchValue:1]) return nil;//识别时序全含，此处默认匹配度为1。
    
    //2. 分别对protoA和assA的稀疏码进行对比;
    for (AIKVPointer *protoV_p in protoA.content_ps) {
        for (AIKVPointer *assV_p in assA.content_ps) {
            
            //3. 二者同区时;
            if ([protoV_p.dataSource isEqualToString:assV_p.dataSource] && [protoV_p.algsType isEqualToString:assV_p.algsType]) {
                
                //4. ======== 兼容新版组码特征 ========
                if (PitIsFeature(protoV_p) || PitIsFeature(assV_p)) {
                    AIFeatureNode *absT = [self analogyFeature:protoV_p ass:assV_p bigerMatchValue:curMatchValue];
                    if (!absT) continue;
                    CGFloat valueMatchValue = [absT getConMatchValue:protoA_p];
                    [sameValue_ps addObject:absT.p];
                    
                    //6. 相近度个数nearCount & 相近度sumNear
                    protoAbsModel4MatchValue.nearCount++;
                    protoAbsModel4MatchValue.sumNear *= valueMatchValue;
                    continue;
                }
                
                //4. ======== 保留旧版单码特征 ========
                //4. 二者相似度较高时 (计算当前码的责任比例: 比如:1*0.8*0.7时,当前码=0.7时,它的责任比例=(1-0.7)/(1-0.8 + 1-0.7)=60%) (参考29025-13);
                MapModel *analogyValueResult = [self analogyValue:protoV_p assV:assV_p bigerMatchValue:curMatchValue];
                
                //5. 当前码责任<50%时 (次要责任时,免责);
                if (analogyValueResult) {
                    AIKVPointer *absV_p = analogyValueResult.v1;
                    CGFloat valueMatchValue = NUMTOOK(analogyValueResult.v2).floatValue;
                    [sameValue_ps addObject:absV_p];
                    
                    //6. 相近度个数nearCount & 相近度sumNear
                    protoAbsModel4MatchValue.nearCount++;
                    protoAbsModel4MatchValue.sumNear *= valueMatchValue;
                } else {
                    if (Log4Ana) NSLog(@"> 当前A%ld<%@>比A%ld<%@>",(long)protoA_p.pointerId,Pit2FStr(protoV_p),(long)assA_p.pointerId,Pit2FStr(assV_p));
                }
                
                //6. break继续判断proto的下个V码;
                break;
            }
        }
    }
    
    //7. 将相近度善可的构建成抽象概念返回;
    [AITest test29:protoA assA:assA];
    AIAbsAlgNode *absA = [theNet createAbsAlg_NoRepeat:sameValue_ps conAlgs:@[protoA,assA]];
    
    //8. 将抽象概念与具象的匹配度存下来 (参考29091BUG);
    [protoA updateMatchValue:absA matchValue:protoAbsModel4MatchValue.matchValue];
    [assA updateMatchValue:absA matchValue:1];
    [AITest test25:absA conNodes:@[protoA,assA]];
    return absA;
}

/**
 *  MARK:--------------------特征类比--------------------
 *  @version
 *      2025.03.21: 使用mIsC正序双循环来实现特征类比 (参考34062-方案1);
 *      2025.03.21: 改用indexDic映射来实现特征类比 (参考34062-方案2);
 *      2025.03.31: 改为调用组码类比v2。
 */
+(AIFeatureNode*) analogyFeature:(AIKVPointer*)protoT_p ass:(AIKVPointer*)assT_p bigerMatchValue:(CGFloat)bigerMatchValue {
    //1. 类比orders的规律
    NSMutableArray *absGVModels = [[NSMutableArray alloc] init];
    AIFeatureNode *protoFeature = [SMGUtils searchNode:protoT_p];
    AIFeatureNode *assFeature = [SMGUtils searchNode:assT_p];
    CGFloat featureMatchValue = 1;
    
    //2. 数据检查（当前有主责，直接剔除）。
    //BUG-2025.03.24: 先关掉，不然信息量大的特征，因为能者多错（像HSB里，HS全是躺赢狗，只有B信息量大，同时差异性也大，这里会判B全责）。
    //思路-除非引入信息量，即HSB不同信息量时，各自责任占比也不同，不然很难判准，先注掉吧，后续确实需要修此BUG时再来搞。
    CGFloat curMatchValue = [protoFeature getAbsMatchValue:assT_p];
    //BOOL noZeRen = [TCLearningUtil noZeRenForCenJi:curMatchValue bigerMatchValue:bigerMatchValue];
    //if (!noZeRen) return nil;
    NSDictionary *degreeDic = DICTOOK([protoFeature getDegreeDic:assT_p.pointerId]);
    
    //3. 生成protoIndexDic 和 assIndexDic  (参考29032-todo1.2);
    //备忘: 如果以后特征要支持indexDic,这里可以打开并存上映射支持下 (但短时间内应该不需要,连alg也没支持映射);
    NSMutableDictionary *assAbsIndexDic = [NSMutableDictionary new];
    NSMutableDictionary *protoAbsIndexDic = [NSMutableDictionary new];
    
    //11. 外类比有序进行 (记录jMax & 正序)
    NSDictionary *indexDic = [protoFeature getAbsIndexDic:assT_p];
    for (NSNumber *key in indexDic) {
        NSNumber *value = [indexDic objectForKey:key];
        NSInteger assIndex = key.integerValue;
        NSInteger protoIndex = value.integerValue;
        AIKVPointer *protoG_p = ARR_INDEX(protoFeature.content_ps, protoIndex);
        AIKVPointer *assG_p = ARR_INDEX(assFeature.content_ps, assIndex);
        if (![degreeDic objectForKey:@(assIndex)]) {
            ELog(@"查下为什么没存上符合度，没符合度会导致protoG和assG的匹配度算成0。");
        }
        CGFloat curDegree = NUMTOOK([degreeDic objectForKey:@(assIndex)]).floatValue;
        
        //12. B源于matchFo,此处只判断B是1层抽象 (参考27161-调试1&调试2);
        //此处proto抽象仅指向刚识别的matchAlgs,所以与contains等效;
        if (Log4Ana) NSLog(@"proto的第%ld: G%ld 类比 ass的第%ld: G%ld",protoIndex,protoG_p.pointerId,assIndex,assG_p.pointerId);
        
        //================= GV类比V1 =================
        //13. 调用GV类比V1: 即使mIsC匹配,也要进行共同点抽象 (参考29025-11);
        //AIGroupValueNode *absG = [self analogyGroupValue:protoG_p assG:assG_p curDegree:curDegree bigerMatchValue:curMatchValue];
        //if (!absG) continue;
        //featureMatchValue *= [absG getConMatchValue:protoG_p];
        //14. 类比后,尽量保留大图,即以level小的主准存level,x,y;
        //NSInteger protoLevel = NUMTOOK(ARR_INDEX(protoFeature.levels, protoIndex)).integerValue;
        //NSInteger protoX = NUMTOOK(ARR_INDEX(protoFeature.xs, protoIndex)).integerValue;
        //NSInteger protoY = NUMTOOK(ARR_INDEX(protoFeature.ys, protoIndex)).integerValue;
        //NSInteger absLevel = assLevel < protoLevel ? assLevel : protoLevel;
        //NSInteger absX = assLevel < protoLevel ? assX : protoX;
        //NSInteger absY = assLevel < protoLevel ? assY : protoY;
        //[absGVModels addObject:[InputGroupValueModel new:nil groupValue:absG.p level:absLevel x:absX y:absY]];
        
        //================= GV类比V2 =================
        //15. 调用GV类比V2: 即使mIsC匹配,也要进行共同点抽象 (参考29025-11);
        MapModel *analogyGVResult = [self analogyGroupValueV2:protoG_p assG:assG_p curDegree:curDegree bigerMatchValue:curMatchValue];
        if (!analogyGVResult) continue;
        featureMatchValue *= NUMTOOK(analogyGVResult.v2).floatValue;
        
        //16. 类比后,以ass为主,存level,x,y;
        NSInteger assLevel = NUMTOOK(ARR_INDEX(assFeature.levels, assIndex)).integerValue;
        NSInteger assX = NUMTOOK(ARR_INDEX(assFeature.xs, assIndex)).integerValue;
        NSInteger assY = NUMTOOK(ARR_INDEX(assFeature.ys, assIndex)).integerValue;
        [absGVModels addObject:[InputGroupValueModel new:nil groupValue:analogyGVResult.v1 level:assLevel x:assX y:assY]];
        
        //17. 把ass和proto分别与 abs的映射记下来。
        [assAbsIndexDic setObject:@(assIndex) forKey:@(assAbsIndexDic.count)];
        [protoAbsIndexDic setObject:@(protoIndex) forKey:@(protoAbsIndexDic.count)];
    }
    
    //21. 外类比构建
    AIFeatureNode *absT = [AIGeneralNodeCreater createFeatureNode:absGVModels conNodes:@[protoFeature,assFeature] at:protoT_p.algsType ds:protoT_p.dataSource isOut:protoT_p.isOut logDesc:STRFORMAT(@"(%@:%@)",protoFeature.logDesc,assFeature.logDesc)];
    
    //22. 更新匹配度 & 映射;
    [protoFeature updateMatchValue:absT matchValue:featureMatchValue];
    [assFeature updateMatchValue:absT matchValue:1];
    [protoFeature updateIndexDic:absT indexDic:protoAbsIndexDic];
    [assFeature updateIndexDic:absT indexDic:assAbsIndexDic];
    
    //TODOTOMORROW20250331: 然后测下能不能把局部特征抽象出来，比如0的转弯部分。
    NSLog(@"特征类比结果 => Proto特征：(%@)\n%@Ass特征：(%@)\n%@抽象特征：(%@)\n%@",protoFeature.logDesc,FeatureDesc(protoFeature.p),assFeature.logDesc,FeatureDesc(assFeature.p),absT.logDesc,FeatureDesc(absT.p));
    return absT;
}

/**
 *  MARK:--------------------组码类比--------------------
 */
+(AIGroupValueNode*) analogyGroupValue:(AIKVPointer*)protoG_p assG:(AIKVPointer*)assG_p curDegree:(CGFloat)curDegree bigerMatchValue:(CGFloat)bigerMatchValue {
    //1. 如果本就一致;
    if ([protoG_p isEqual:assG_p]) return [SMGUtils searchNode:protoG_p];
    
    //2. 数据准备;
    AIGroupValueNode *protoG = [SMGUtils searchNode:protoG_p];
    AIGroupValueNode *assG = [SMGUtils searchNode:assG_p];
    if (!protoG || !assG) return nil;
    NSMutableArray *sameSubDots = [[NSMutableArray alloc] init];
    AIMatchAlgModel *protoAbsModel4MatchValue = [[AIMatchAlgModel alloc] init];//此模型仅用于收集proto和abs的相近度,用于计算matchValue;
    
    //3. 数据检查（当前有主责，直接剔除）。
    CGFloat curMatchValue = [protoG getAbsMatchValue:assG_p] * curDegree;
    BOOL noZeRen = [TCLearningUtil noZeRenForPingJun:curMatchValue bigerMatchValue:bigerMatchValue];
    if (!noZeRen) return nil;
    
    //3. 分别对protoA和assA的稀疏码进行对比;
    for (NSInteger i = 0; i < protoG.count; i++) {
        
        //11. 找出proto子单码的数据
        NSInteger protoX = NUMTOOK(ARR_INDEX(protoG.xs, i)).integerValue;
        NSInteger protoY = NUMTOOK(ARR_INDEX(protoG.ys, i)).integerValue;
        AIKVPointer *protoV_p = ARR_INDEX(protoG.content_ps, i);
        
        //12. 根据protoX,protoY到ass里，找对应的ass子单码的数据。
        AIKVPointer *assV_p = nil;
        for (NSInteger j = 0; j < assG.count; j++) {
            NSInteger assX = NUMTOOK(ARR_INDEX(assG.xs, j)).integerValue;
            NSInteger assY = NUMTOOK(ARR_INDEX(assG.ys, j)).integerValue;
            if (assX == protoX && assY == protoY) {
                assV_p = ARR_INDEX(assG.content_ps, j);
                break;
            }
        }
        
        //21. 过滤器1、如果未找到对应的assV，则直接跳过不类比这一条（这一条以前已被ass抽象掉了）。
        if (!assV_p) continue;
        
        //22. 过滤器2、二者非同区，也直接跳过（它本就不该有抽具象关联，查下当时识别后构建抽具象关联时就有问题）。
        if (![protoV_p.dataSource isEqualToString:assV_p.dataSource] || ![protoV_p.algsType isEqualToString:assV_p.algsType]) continue;
            
        //31. 二者相似度较高时 (计算当前码的责任比例: 比如:1*0.8*0.7时,当前码=0.7时,它的责任比例=(1-0.7)/(1-0.8 + 1-0.7)=60%) (参考29025-13);
        MapModel *analogyValueResult = [self analogyValue:protoV_p assV:assV_p bigerMatchValue:curMatchValue];
        
        //32. 当前码责任<50%时 (次要责任时,免责);
        if (analogyValueResult) {
            AIKVPointer *absV_p = analogyValueResult.v1;
            CGFloat valueMatchValue = NUMTOOK(analogyValueResult.v2).floatValue;
            [sameSubDots addObject:[MapModel newWithV1:absV_p v2:@(protoX) v3:@(protoY)]];
            
            //6. 相近度个数nearCount & 相近度sumNear
            protoAbsModel4MatchValue.nearCount++;
            protoAbsModel4MatchValue.sumNear *= valueMatchValue;
        } else {
            if (Log4Ana) NSLog(@"> 当前A%ld<%@>比A%ld<%@>",(long)protoG_p.pointerId,Pit2FStr(protoV_p),(long)assG_p.pointerId,Pit2FStr(assV_p));
        }
    }
    
    //7. 将相近度善可的构建成抽象返回;
    AIGroupValueNode *absG = [AIGeneralNodeCreater createGroupValueNode:sameSubDots conNodes:@[protoG,assG] at:protoG_p.algsType ds:protoG_p.dataSource isOut:protoG_p.isOut];
    
    //8. 将抽象概念与具象的匹配度存下来 (参考29091BUG);
    [protoG updateMatchValue:absG matchValue:protoAbsModel4MatchValue.matchValue];
    [assG updateMatchValue:absG matchValue:1];
    [AITest test25:absG conNodes:@[protoG,assG]];
    if (Log4Ana) NSLog(@"G类比 ===> %@ : %@ = %@",Pit2FStr(protoG_p),Pit2FStr(assG_p),Pit2FStr(absG.p));
    return absG;
}

/**
 *  MARK:--------------------组码类比V2--------------------
 *  @version
 *      2025.03.31: v2-因组码索引迭代为三个索引后，这里也改下，不再向单码探进了，直接参考单码类比，在组码类比这儿把assG返回就行了。
 */
+(MapModel*) analogyGroupValueV2:(AIKVPointer*)protoG_p assG:(AIKVPointer*)assG_p curDegree:(CGFloat)curDegree bigerMatchValue:(CGFloat)bigerMatchValue {
    //1. 如果本就一致;
    if ([protoG_p isEqual:assG_p]) return [SMGUtils searchNode:protoG_p];
    
    //2. 数据准备;
    AIGroupValueNode *protoG = [SMGUtils searchNode:protoG_p];
    if (!protoG || !assG_p) return nil;
    
    //3. 数据检查（当前有主责，直接剔除）。
    CGFloat curMatchValue = [protoG getAbsMatchValue:assG_p];
    BOOL noZeRen = [TCLearningUtil noZeRenForPingJun:curMatchValue * curDegree bigerMatchValue:bigerMatchValue];
    if (!noZeRen) return nil;
    
    //32. 当前码责任<50%时 (次要责任时,免责);
    return [MapModel newWithV1:assG_p v2:@(curMatchValue) v3:@(curDegree)];
}

/**
 *  MARK:--------------------单码类比--------------------
 */
+(MapModel*) analogyValue:(AIKVPointer*)protoV_p assV:(AIKVPointer*)assV_p bigerMatchValue:(CGFloat)bigerMatchValue {
    //31. 二者相似度较高时 (计算当前码的责任比例: 比如:1*0.8*0.7时,当前码=0.7时,它的责任比例=(1-0.7)/(1-0.8 + 1-0.7)=60%) (参考29025-13);
    CGFloat valueMatchValue = [AIAnalyst compareCansetValue:protoV_p protoValue:assV_p vInfo:nil];
    BOOL noZeRen = [TCLearningUtil noZeRenForCenJi:valueMatchValue bigerMatchValue:bigerMatchValue];
    
    //32. 当前码责任<50%时 (次要责任时,免责);
    if (noZeRen) {
        return [MapModel newWithV1:assV_p v2:@(valueMatchValue)];
    }
    return nil;
}

/**
 *  MARK:--------------------Canset类比 --------------------
 *  @noRepeatArea_ps 防重(一般取sceneTo以前的cansets);
 *  @version
 *      xxxx.xx.xx: 初版 (参考29025-24 & 29027-方案3);
 *      2023.03.27: 支持得出newCansetFo/oldCansetFo 与 absCansetFo的indexDic映射 (参考29032-todo1.1);
 *      2023.04.07: 关闭Canset类比 (参考29059-改动);
 *      2023.04.10: 场景包含帧的类比用mIsC判断成立后,直接采用absAlg (参考29067-todo1.1);
 *      2023.04.19: 取消EFF+1,因为迁移完成不表示已正向发生 (参考29069-todo12.1);
 *      2023.04.29: 得出absCanset和scene的indexDic (参考29076-todo2);
 *      2023.09.01: 迁移完成时EFF不变(参数传ES_Default),但newCanset有用时+1,无用时-1 (参考30124-todo2 & todo3);
 *      2023.09.03: 修复dic.keys无序会导致此处生成的absFo序列也错乱的问题;
 *      2023.10.26: 废弃canset类比 (参考3014c-todo2);
 *      2024.09.13: 启用canset类比: 直接用反馈映射realCansetToIndexDic,来生成Canset类比结果 (参考33052-TODO1);
 *      2025.03.13: 迭代V3：用new和old两个orders得出absOrders（参考33174-TODO1）。
 */
+(HEResult*) analogyCansetFoV3:(NSArray*)newCansetOrders oldCansetOrders:(NSArray*)oldCansetOrders oldCansetISceneIndexDic:(NSDictionary*)oldCansetISceneIndexDic {
    //1. 类比orders的规律
    NSMutableArray *absCansetOrders = [[NSMutableArray alloc] init];
    NSMutableDictionary *absCansetOldCansetIndexDic = [NSMutableDictionary new];//收集abs和old的映射;

    //2. 外类比有序进行 (记录jMax & 反序)
    NSInteger jStart = 0;
    for (NSInteger i = 0; i < newCansetOrders.count; i++) {
        for (NSInteger j = jStart; j < oldCansetOrders.count; j++) {
            AIShortMatchModel_Simple *newItem = ARR_INDEX(newCansetOrders, i);
            AIShortMatchModel_Simple *oldItem = ARR_INDEX(oldCansetOrders, j);
            
            //3. B源于matchFo,此处只判断B是1层抽象 (参考27161-调试1&调试2);
            //此处proto抽象仅指向刚识别的matchAlgs,所以与contains等效;
            BOOL mIsC = [TOUtils mIsC_1:newItem.alg_p c:oldItem.alg_p];
            if (mIsC) {
                //4. 收集并更新j进度;
                [absCansetOrders addObject:oldItem];
                [absCansetOldCansetIndexDic setObject:@(j) forKey:@(absCansetOrders.count - 1)];
                jStart = j + 1;
                break;
            }
        }
    }
    
    //5. 计算出absCansetFo的和iScene之间的indexDic (参考27207-7至11 & 33174-TODO2);
    //2024.04.16: 此处简化了下,把用convertOldIndexDic2NewIndexDic()取映射,改成用zonHeDic来计算;
    //2025.03.xx: 从iScene -> iCanset -> iAbsCanset
    NSDictionary *iAbsCansetISceneIndexDic = [TOUtils zonHeIndexDic:@[[DirectIndexDic newNoToAbs:oldCansetISceneIndexDic],[DirectIndexDic newOkToAbs:absCansetOldCansetIndexDic]]];
    if (Log4OutCansetAna) NSLog(@"\n----------- Canset类比 -----------\nold:%@\nnew:%@ absOldIndexDic:%@\nabs:%@",Pits2FStr(Simples2Pits(oldCansetOrders)),Pits2FStr(Simples2Pits(newCansetOrders)),CLEANSTR(iAbsCansetISceneIndexDic),Pits2FStr(Simples2Pits(absCansetOrders)));
    return [[[[HEResult newSuccess] mkData:absCansetOrders] mk:@"absISceneDic" v:iAbsCansetISceneIndexDic] mk:@"absOldDic" v:absCansetOldCansetIndexDic];
}

@end
