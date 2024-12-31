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
    
    //2. 分别对protoA和assA的稀疏码进行对比;
    for (AIKVPointer *protoV_p in protoA.content_ps) {
        for (AIKVPointer *assV_p in assA.content_ps) {
            
            //3. 二者同区时;
            if ([protoV_p.dataSource isEqualToString:assV_p.dataSource] && [protoV_p.algsType isEqualToString:assV_p.algsType]) {
                
                //4. 二者相似度较高时 (计算当前码的责任比例: 比如:1*0.8*0.7时,当前码=0.7时,它的责任比例=(1-0.7)/(1-0.8 + 1-0.7)=60%) (参考29025-13);
                CGFloat algMatchValue = [protoA getAbsMatchValue:assA_p];
                CGFloat valueMatchValue = [AIAnalyst compareCansetValue:protoV_p protoValue:assV_p vInfo:nil];
                CGFloat otherValueMatchValue = valueMatchValue > 0 ? algMatchValue / valueMatchValue : 1;   //别的码相乘是0.xx;
                CGFloat otherQueKou = 1 - otherValueMatchValue;                                             //别的码缺口;
                CGFloat curQueKou = 1 - valueMatchValue;                                                    //当前码缺口;
                CGFloat sumQueKou = otherQueKou + curQueKou;                                                //总缺口;
                CGFloat curRate = sumQueKou > 0 ? curQueKou / sumQueKou : 0;                                //算出当前码责任比例;
                
                //5. 当前码责任<50%时 (次要责任时,免责);
                if (curRate < 0.5) {
                    [sameValue_ps addObject:assV_p];
                    
                    //6. 相近度个数nearCount & 相近度sumNear
                    protoAbsModel4MatchValue.nearCount++;
                    protoAbsModel4MatchValue.sumNear *= valueMatchValue;
                } else {
                    if (Log4Ana) NSLog(@"> 当前A%ld<%@>比A%ld<%@>的缺口:%.2f / 总缺口%.2f = 当前责任%.2f",(long)protoA_p.pointerId,Pit2FStr(protoV_p),(long)assA_p.pointerId,Pit2FStr(assV_p),curQueKou,sumQueKou,curRate);
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
    [AITest test25:absA conAlgs:@[protoA,assA]];
    return absA;
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
 */
+(HEResult*) analogyCansetFo:(NSDictionary*)realCansetToIndexDic newCanset:(AIFoNodeBase*)newCanset oldCanset:(AIFoNodeBase*)oldCanset noRepeatArea_ps:(NSArray*)noRepeatArea_ps {
    //1. 类比orders的规律
    NSMutableArray *orderSames = [[NSMutableArray alloc] init];

    //2. 根据新旧的映射indexDic分别进行概念类比 (参考29025-24a);
    //2024.10.07: dic是无序的,所以先给key排下序,避免类比结果乱序 (参考33092);
    //2024.10.07: 其实压根不用类比,打开前段条件满足后,orderSames就等于canset的前段 (不过先不改,以后前段条件满足万一再关了呢) (参考33053);
    NSArray *sortKeys = [SMGUtils sortSmall2Big:realCansetToIndexDic.allKeys compareBlock:^double(NSNumber *obj) {
        return obj.integerValue;
    }];
    for (NSNumber *key in sortKeys) {
        NSInteger oldIndex = key.integerValue;
        AIKVPointer *oldAlg_p = ARR_INDEX(oldCanset.content_ps, oldIndex);
        [orderSames addObject:oldAlg_p];
    }

    //6. 取得newIndexDic和oldIndexDic (参考29032-todo1.1);
    NSDictionary *newIndexDic = [AINetUtils getIndexDic4AnalogyAbsFo:realCansetToIndexDic.allValues];
    NSDictionary *oldIndexDic = [AINetUtils getIndexDic4AnalogyAbsFo:realCansetToIndexDic.allKeys];

    //7. 外类比构建
    BOOL outConAbsIsRelate = true;
    HEResult *heResult = [theNet createAbsFo_NoRepeat:orderSames protoFo:newCanset assFo:oldCanset difStrong:1 type:ATDefault protoIndexDic:newIndexDic assIndexDic:oldIndexDic outConAbsIsRelate:&outConAbsIsRelate noRepeatArea_ps:noRepeatArea_ps];
    AIFoNodeBase *absFo = heResult.data;
    if (Log4OutCansetAna) NSLog(@"\n----------- Canset类比 -----------\nnew:%@\nold:%@\nbyIndexDic:%@\nabs:%@",Fo2FStr(newCanset),Fo2FStr(oldCanset),CLEANSTR(realCansetToIndexDic),Fo2FStr(absFo));
    return heResult;
}

@end
