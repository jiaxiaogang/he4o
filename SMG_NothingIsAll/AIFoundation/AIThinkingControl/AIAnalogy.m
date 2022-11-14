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
 *
 *  @version
 *      20200215: 有序外类比: 将forin循环fo和assFo改为反序,并记录上次类比位置jMax (因出现了[果,果,吃,吃]这样的异常时序) 参考n18p11;
 *      20200831: 支持反省外类比,得出更确切的ATSub原因,参考:20205-步骤4;
 *      20201203: 修复21175BUG (因createAbsAlgBlock忘记调用,导致absAlg和glAlg间未关联) (参考21115);
 *      20210819: 修复长1和长2类比时,类比出长2的BUG (参考23221-BUG2);
 *      20210926: 修复glFo外类比时非末位alg类比构建absAlg时,也使用了GLType的问题 (参考24022-BUG1);
 *      20221028: 用mIsC判断替代sameValue_ps (参考27153-todo4);
 */
+(AINetAbsFoNode*) analogyOutside:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo type:(AnalogyType)type {
    //1. 类比orders的规律
    if (Log4OutAnaType(type)) NSLog(@"\n----------- 外类比(%@) -----------\nfo:%@ \nassFo:%@",ATType2Str(type),Fo2FStr(protoFo),Fo2FStr(assFo));
    NSMutableArray *orderSames = [[NSMutableArray alloc] init];
    if (protoFo && assFo) {

        //2. 外类比有序进行 (记录jMax & 反序)
        NSInteger jMax = assFo.count - 1;
        for (NSInteger i = protoFo.count - 1; i >= 0; i--) {
            for (NSInteger j = jMax; j >= 0; j--) {
                AIKVPointer *protoA_p = protoFo.content_ps[i];
                AIKVPointer *assA_p = assFo.content_ps[j];
                if (Log4OutAna) NSLog(@"ProtoFo I: %ld -> %@",i,Pit2FStr(protoA_p));
                if (Log4OutAna) NSLog(@"AssFo   J: %ld -> %@",j,Pit2FStr(assA_p));
                
                //3. B源于matchFo,此处只判断B是1层抽象 (参考27161-调试1&调试2);
                BOOL mIsC = [TOUtils mIsC_1:protoA_p c:assA_p];
                if (mIsC) {
                    //3. 收集并更新jMax;
                    [orderSames insertObject:assA_p atIndex:0];
                    jMax = j - 1;
                    if (Log4OutAna) NSLog(@"-> 外类比构建概念 Finish: %@ from: ↑↑↑(A%ld:A%ld)",Pit2FStr(assA_p),(long)protoA_p.pointerId,(long)assA_p.pointerId);
                    break;
                }
            }
        }
    }

    //3. 外类比构建
    return [self analogyOutside_Creater:orderSames fo:protoFo assFo:assFo type:type];
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
            if (result.cmvNode_p) [theNet setMvNodeToDirectionReference:[SMGUtils searchNode:result.cmvNode_p] difStrong:1];
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
            
            //5. 构建absFoNode (当GL时,传入at&ds);
            NSArray *conFos = @[fo,assFo];
            NSString *at = DefaultAlgsType,*ds = DefaultDataSource;
            if (type == ATGreater || type == ATLess) {
                ds = [AINetUtils getDSFromConNodes:conFos];
                at = [AINetUtils getATFromConNodes:conFos];
            }
            result = [theNet createAbsFo_NoRepeat:conFos content_ps:orderSames difStrong:foDifStrong at:at ds:ds type:type];
            
            //5. 从fo和conFo.mvDeltaTime中提取mv导致时间隔,在relateFo之前,赋值到result中;
            result.mvDeltaTime = MAX(MAX(fo.mvDeltaTime, assFo.mvDeltaTime), result.mvDeltaTime);
            
            //6. createAbsCmvNode (当正向类比,且result没有cmv指向时);
            if (fo.cmvNode_p && assMv && !result.cmvNode_p) {
                AIAbsCMVNode *resultMv = [theNet createAbsCMVNode_Outside:nil aMv_p:fo.cmvNode_p bMv_p:assMv.pointer];
                [AINetUtils relateFo:result mv:resultMv];//cmv模型连接;
            }
        }
    }
    //调试短时序; (先仅打外类比日志);
    NSInteger foStrong = [AINetUtils getStrong:result atConNode:fo type:type];
    NSInteger assFoStrong = [AINetUtils getStrong:result atConNode:assFo type:type];
    NSString *log = STRFORMAT(@"-> 与ass%@外类比\n\t构建时序 (%@): %@->{%@} from: (protoFo(%ld):assFo(%ld))",Fo2FStr(assFo),ATType2Str(type),Fo2FStr(result),Mvp2Str(result.cmvNode_p),foStrong,assFoStrong);
    NSLog(@"%@",log);
    return result;
}

@end
