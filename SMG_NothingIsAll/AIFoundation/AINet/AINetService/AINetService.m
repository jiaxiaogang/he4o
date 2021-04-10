//
//  AINetService.m
//  SMG_NothingIsAll
//
//  Created by air on 2020/5/21.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "AINetService.h"
#import "AINetUtils.h"
#import "AIAlgNodeBase.h"
#import "TOUtils.h"
#import "AINetIndex.h"
#import "AIScore.h"

@implementation AINetService

/**
 *  MARK:--------------------获取GLAlg--------------------
 *  @desc SP经历的啥时反向反馈类比,所以大概念上,无法找到GL,我们需要从两条线出发:
 *          1. SP的生成线 (可记录下针对地址);
 *          2. GL的生成线 (可记录下针对地址);
 *        从中,找出交叠,比如,看下SP中的坚果,与GL生成时的坚果,之间的网络关系是什么? (可用网络可视化查);
 *  @bug
 *      2020.06.16: 找不到glAlg的bug;
 *      2020.12.03: 修复联想只有太具象概念的BUG,修复后,可以顺利从glAlgCon_p中找到较抽象的absAlg (如A87(速0,高5,皮0)) (参考21175);
 *      2020.12.10: 修复glAlg.conAlg被引用始终是0条的BUG (参考21192);
 *  @todo
 *      2020.06.24: 对alg指引联想,取同层+多层abs,比如,我没洗过西瓜,但我洗过苹果,或者洗过水果,那我可以试下用水洗西瓜;
 *      2020.11.07: 返回结果,按短时记忆局部匹配度排序 (比如饿了,优先想到几秒前看到过的香蕉);
 *                  注:这步未必需要,因为太复杂,况且在决策循环中,也会有类似实现,且是分解后的;
 *      2020.12.03: 支持多路glAlgCon_ps返回,或者判断理性稳定性,比如太抽象概念,向任何方向飞都有可能更远或更近;
 *  @version
 *      2020.11.06: 核对21115逻辑没问题 & 直接取返回relativeFo_ps;
 *      2020.12.12: 为GL返回结果做流程控制action._Fo (输出行为时,要走ActYes流程);
 *      2020.12.12: 为GL返回结果做流程控制action._Fo (Failure时,要递归过来继续GL);
 *      2020.12.12: 行为化失败_ActYes反省类比触发后,要判断是否GL修正有效/符合预期 (并构建SP) (参考ActYes);
 *      2020.12.12: 行为化成功_OutterPushMidd中,当完成时,要转到PM_GL()中进行理性评价 (以对比是否需要继续修正GL) (参考OPushM);
 *      2020.12.14: 支持except_ps不应期 (参考21183);
 *      2020.12.17: 将relativeFos返回,改为仅返回一条有效的relativeFo (逐个返回);
 *      2020.12.25: 当relativeFo末位为glConAlg_p时,结果才有效 (参考21183-3);
 *      2020.12.28: 返回前,直接进行未发生理性评价 (以简化流程控制,且"未发生"本来就是指未行为化前);
 *  @result : 返回relativeFo_ps,用backConAlg节点,由此节点取refPorts,再筛选type,可取到glFo经历;
 */
+(AIKVPointer*) getInner1Alg:(AIAlgNodeBase*)pAlg vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type except_ps:(NSArray*)except_ps{
    //1. 数据检查hAlg_根据type和value_p找ATHav
    BOOL debugMode = Log4GetInnerAlg;//type == ATLess;
    NSLog(@"-------------- getInnerAlg (%@) --------------\nATDS:%@&%@ 参照:%@\n不应期:%@",ATType2Str(type),vAT,vDS,Alg2FStr(pAlg),Pits2FStr(except_ps));
    AIKVPointer *innerValue_p = [theNet getNetDataPointerWithData:@(type) algsType:vAT dataSource:vDS];
    
    //2. 对v.ref和a.abs进行交集,取得有效GLAlg;
    NSArray *gl_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Value:innerValue_p]];
    
    //3. 找出合格的inner1Alg;
    for (AIKVPointer *gl_p in gl_ps) {
        AIAlgNodeBase *glAlg = [SMGUtils searchNode:gl_p];
        
        //4. 根据glAlg,向具象找出真正当时变"大小"的具象概念节点;
        NSArray *glConAlg_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:glAlg]];
        
        //5. 这些节点中,哪个与pAlg有抽具象关系,就返回哪个;
        if (debugMode) {
            for (AIKVPointer *glConAlg_p in glConAlg_ps) {
                BOOL mIsC = ([TOUtils mIsC_2:glConAlg_p c:pAlg.pointer] || [TOUtils mIsC_2:pAlg.pointer c:glConAlg_p]);
                AIAlgNodeBase *item = [SMGUtils searchNode:glConAlg_p];
                if (mIsC) {
                    NSArray *relativeFo_ps = Ports2Pits([SMGUtils filterPorts:[AINetUtils refPorts_All4Alg:item] havTypes:@[@(type)] noTypes:nil]);
                    NSLog(@"===== glConAlg_Item: %@ 共%lu个",AlgP2FStr(glConAlg_p),(unsigned long)relativeFo_ps.count);
                    for (NSInteger i = 0; i < 10; i++) {
                        AIKVPointer *item = ARR_INDEX(relativeFo_ps, i);
                        AIFoNodeBase *itemFo = [SMGUtils searchNode:item];
                        BOOL score = [AIScore FRS:itemFo];
                        if (item) NSLog(@">> fos: %@ == %@",FoP2FStr(item),score ? @"通过" : @"未通过");
                    }
                }
            }
        }
        
        for (AIKVPointer *glConAlg_p in glConAlg_ps) {
            if ([TOUtils mIsC_2:glConAlg_p c:pAlg.pointer] || [TOUtils mIsC_2:pAlg.pointer c:glConAlg_p]) {
                
                //6. 用mIsC有效的glAlg具象指向节点,向refPorts取到relativeFos返回;
                AIAlgNodeBase *glConAlg = [SMGUtils searchNode:glConAlg_p];
                NSArray *relativeFoPorts = [SMGUtils filterPorts:[AINetUtils refPorts_All4Alg:glConAlg] havTypes:@[@(type)] noTypes:nil];
                NSArray *relativeFo_ps = [SMGUtils convertPointersFromPorts:ARR_SUB(relativeFoPorts, 0, cHavNoneAssFoCount)];
                
                //7. 去掉不应期;
                relativeFo_ps = [SMGUtils removeSub_ps:except_ps parent_ps:relativeFo_ps];
                for (AIKVPointer *item in relativeFo_ps) {
                    
                    //8. 当relativeFo末位为glConAlg_p时,结果才有效 (参考21183-3);
                    AIFoNodeBase *itemFo = [SMGUtils searchNode:item];
                    if (![glConAlg_p isEqual:ARR_INDEX_REVERSE(itemFo.content_ps, 0)]) continue;
                    
                    //9. 未发生理性评价 (空S评价);
                    if (![AIScore FRS:itemFo]) continue;
                    
                    //10. 全部通过,返回;
                    return item;
                }
            }
        }
    }
    return nil;
}

/**
 *  MARK:--------------------联想GL经验--------------------
 *  @version
 *      2021.04.06: v3嵌套GL迭代: 联想方式由glValue索引向宏观,改为反过来:从maskFo场景取嵌套GL经验 (参考22204&R-V4模式联想方式);
 *      2021.04.10: 将从maskAlg出发联想,改成从maskFo出发联想 (参考22211);
 */
+(AIKVPointer*) getInnerAlgV3:(AIFoNodeBase*)maskFo vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type except_ps:(NSArray*)except_ps{
    //1. 数据检查hAlg_根据type和value_p找ATHav
    NSLog(@"-------------- getInnerAlg (%@) --------------\nATDS:%@&%@ 参照:%@\n不应期:%@",ATType2Str(type),vAT,vDS,Fo2FStr(maskFo),Pits2FStr(except_ps));
    
    //2. 取glConAlg_ps;
    NSArray *glConAlg_ps = [self getHNGLConAlg_ps:type vAT:vAT vDS:vDS];
    
    //3. 根据(pAlg & pAlg.abs & pAlg.abs.abs)抽象路径,取分别尝试联想(hnglAlg.refPorts)经验;
    NSMutableArray *curMasks = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < cGetInnerAbsLayer; i++) {
        //4. 取当前层的所有参考Alg_curMaskAlgs;
        if (i == 0) {
            //5. 第0层时,收集pAlg即可;
            [curMasks addObject:maskFo.pointer];
        }else{
            //6. 非0层时,根据上层获取下层,并收集 (即上层全不应期掉了,向着pAlg抽象方向继续尝试);
            curMasks = [TOUtils collectAbsPorts:curMasks singleLimit:cGetInnerAbsCount havTypes:nil noTypes:@[@(ATGreater),@(ATLess),@(ATHav),@(ATNone),@(ATPlus),@(ATSub)]];
        }
        
        //7. 从当前层curMasks逐个尝试取hnglAlg.refPorts;
        for (AIKVPointer *item in curMasks) {
            AIKVPointer *result = [self getInner_Single:item type:type except_ps:except_ps glConAlg_ps:glConAlg_ps];
            if (result) return result;
        }
        //8. 当前层失败_curMaskAlgs统统失败_循环继续下层;
    }
    return nil;
}

/**
 *  MARK:--------------------从Alg中获取指定标识稀疏码的值--------------------
 */
+(double) getValueDataFromAlg:(AIKVPointer*)alg_p valueIdentifier:(NSString*)valueIdentifier{
    AIAlgNodeBase *alg = [SMGUtils searchNode:alg_p];
    if (alg) {
        AIKVPointer *value_p = ARR_INDEX([SMGUtils filterPointers:alg.content_ps identifier:valueIdentifier], 0);
        return [NUMTOOK([AINetIndex getData:value_p]) doubleValue];
    }
    return 0;
}

/**
 *  MARK:--------------------获取glConAlg_ps--------------------
 *  @desc 联想路径说明: (glConAlg_ps = glValue.refPorts->glAlg.conPorts->glConAlgs) (参考22211示图);
 */
+(NSArray*) getHNGLConAlg_ps:(AnalogyType)type vAT:(NSString*)vAT vDS:(NSString*)vDS{
    AIKVPointer *innerValue_p = [theNet getNetDataPointerWithData:@(type) algsType:vAT dataSource:vDS];
    NSArray *gl_ps = Ports2Pits([AINetUtils refPorts_All4Value:innerValue_p]);
    AIKVPointer *gl_p = ARR_INDEX(gl_ps, 0);//glAlg唯一
    AIAlgNodeBase *glAlg = [SMGUtils searchNode:gl_p];
    NSArray *glConAlg_ps = Ports2Pits([AINetUtils conPorts_All:glAlg]);
    return glConAlg_ps;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------指定单条maskAlg获取inner经验--------------------
 *  @param glConAlg_ps : 所有可用的glConAlg (参考21115);
 *  @todo 改为用maskFo获取inner经验
 */
+(AIKVPointer*) getInner_Single:(AIKVPointer*)maskFo_p type:(AnalogyType)type except_ps:(NSArray*)except_ps glConAlg_ps:(NSArray*)glConAlg_ps{
    //1. 数据检查;
    AIFoNodeBase *maskFo = [SMGUtils searchNode:maskFo_p];
    except_ps = ARRTOOK(except_ps);
    glConAlg_ps = ARRTOOK(glConAlg_ps);
    if (!maskFo) return nil;
    
    //2. 根据maskAlg,取gl嵌套 (目前由absPorts+type取);
    NSArray *hnglFo_ps = Ports2Pits([AINetUtils absPorts_All:maskFo type:type]);
    
    //3. 与glConAlg_ps取交集,取出有效的前limit个;
    [SMGUtils filterArr:hnglFo_ps checkValid:^BOOL(AIKVPointer *item) {
        AIFoNodeBase *hnglFo = [SMGUtils searchNode:item];
        //4. 当relativeFo末位为glConAlg_p时,结果才有效 (参考21183-3);
        if (![SMGUtils containsSub_p:ARR_INDEX_REVERSE(hnglFo.content_ps, 0) parent_ps:glConAlg_ps]) return false;
        
        //5. 未发生理性评价 (空S评价);
        if (![AIScore FRS:hnglFo]) return false;
        
        //6. 全部通过,收集;
        return true;
        
    } limit:cGetInnerHNGLCount];
    
    //7. 去掉不应期;
    hnglFo_ps = [SMGUtils removeSub_ps:except_ps parent_ps:hnglFo_ps];
    
    //8. 逐个尝试作为解决方案返回;
    return ARR_INDEX(hnglFo_ps, 0);
}

@end
