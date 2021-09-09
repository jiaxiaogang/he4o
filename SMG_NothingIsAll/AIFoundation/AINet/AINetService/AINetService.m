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
#import "AIShortMatchModel.h"
#import "AIMatchFoModel.h"

@implementation AINetService

/**
 *  MARK:--------------------联想GL经验--------------------
 *  @desc SP经历的啥时反向反馈类比,所以大概念上,无法找到GL,我们需要从两条线出发 (向性:上):
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
 *      2021.04.06: v3嵌套GL迭代: 联想方式由glValue索引向宏观,改为反过来:从maskFo场景取嵌套GL经验 (参考22204&R-V4模式联想方式);
 *      2021.04.10: 将从maskAlg出发联想,改成从maskFo出发联想 (参考22211);
 *      2021.04.10: GL主方向为抽象,HN主方向为具象 (参考22213);
 *      2021.05.17: 将mask改为收集protoFo+absRFos来联想GL经验 (参考23078);
 *      2021.05.21: curMasks不收集protoFo,因为protoFo太具象,且稳定性差 (参考2307a);
 *  @result : 返回relativeFo_ps,用backConAlg节点,由此节点取refPorts,再筛选type,可取到glFo经历;
 */
+(AIKVPointer*) getInnerV3_GL:(AIShortMatchModel*)maskInModel vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type except_ps:(NSArray*)except_ps{
    //1. 数据检查hAlg_根据type和value_p找ATHav
    if (!maskInModel) return nil;
    
    //2. 取glConAlg_ps;
    NSArray *glConAlg_ps = [self getHNGLConAlg_ps:type vAT:vAT vDS:vDS];
    
    //3. 收集absRFos为masks (参考absRFos字段注释: callers2);
    NSMutableArray *curMasks = [[NSMutableArray alloc] init];
    [curMasks addObjectsFromArray:maskInModel.absRFos];
    NSLog(@"-------------- getInnerAlg (%@) --------------\nATDS:%@&%@ mask数:%lu 参照:%@\n不应期:%@",ATType2Str(type),vAT,vDS,curMasks.count,Fo2FStr(maskInModel.protoFo),Pits2FStr(except_ps));
    
    
    //TODOTOMORROW20210909:
    //使curMasks扩展支持maskInModel.matchRFos (参考23229-方案3);
    
    
    
    
    
    
        
    //7. 从当前层curMasks逐个尝试取hnglAlg.refPorts;
    for (AIFoNodeBase *item in curMasks) {
        AIKVPointer *result = [self getInnerByFo_Single:item type:type except_ps:except_ps glConAlg_ps:glConAlg_ps];
        if (result) return result;
    }
    return nil;
}

/**
 *  MARK:--------------------getInnerHN--------------------
 *  @desc 获取HN经验 (参考n23p03) (向性:下);
 *  @example 比如:P-解决方案,想吃桃,步骤如下:
 *          a. 此方法取得hn经验: [超市,买得到桃],返回决策;
 *          b. 又需要找到超市,再到此取hn经验: [出发点,去超市],返回决策;
 *          c. 出发点在瞬时记忆中发现自己在家,找到具象时序: [家出发,去X路美特好超市];
 */
+(AIKVPointer*) getInnerV3_HN:(AIAlgNodeBase*)maskAlg vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type except_ps:(NSArray*)except_ps{
    //1. 数据检查hAlg_根据type和value_p找ATHav
    NSLog(@"-------------- getInnerHN (%@) --------------\nATDS:%@&%@ 参照:%@\n不应期:%@",ATType2Str(type),vAT,vDS,Alg2FStr(maskAlg),Pits2FStr(except_ps));
    
    //2. 取glConAlg_ps;
    NSArray *glConAlg_ps = [self getHNGLConAlg_ps:type vAT:vAT vDS:vDS];
    
    //3. 根据(pAlg & pAlg.abs & pAlg.abs.abs)抽象路径,取分别尝试联想(hnglAlg.refPorts)经验;
    NSMutableArray *curMasks = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < cGetInnerAbsLayer; i++) {
        //4. 取当前层的所有参考Alg_curMaskAlgs;
        if (i == 0) {
            //5. 第0层时,收集pAlg即可;
            [curMasks addObject:maskAlg.pointer];
        }else{
            //6. 非0层时,根据上层获取下层,并收集 (即上层全不应期掉了,向着pAlg抽象方向继续尝试);
            curMasks = [TOUtils collectConPorts:curMasks singleLimit:cGetInnerAbsCount havTypes:nil noTypes:@[@(ATGreater),@(ATLess),@(ATHav),@(ATNone),@(ATPlus),@(ATSub)]];
        }
        
        //7. 从当前层curMasks逐个尝试取hnglAlg.refPorts;
        for (AIKVPointer *item in curMasks) {
            AIKVPointer *result = [self getInnerByAlg_Single:item type:type except_ps:except_ps glConAlg_ps:glConAlg_ps];
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
 *  @desc byFo联想路径 (向性为右至左) (参考23031);
 *  @param glConAlg_ps : 所有可用的glConAlg (参考21115);
 *  @todo 改为用maskFo获取inner经验
 *  @version
 *      2021.05.09: 无论空S评价是否通过,最多取前cGetInnerByFoCount条 (否则经验多的没完没了);
 *      2021.05.23: 不应期也算在3条内,避免每次排除不应期后,重取又补成3条,没完了还;
 */
+(AIKVPointer*) getInnerByFo_Single:(AIFoNodeBase*)maskFo type:(AnalogyType)type except_ps:(NSArray*)except_ps glConAlg_ps:(NSArray*)glConAlg_ps{
    //1. 数据检查;
    except_ps = ARRTOOK(except_ps);
    glConAlg_ps = ARRTOOK(glConAlg_ps);
    if (!maskFo) return nil;
    
    //2. 根据maskAlg,取gl嵌套 (目前由absPorts+type取);
    NSArray *hnglFo_ps = Ports2Pits([AINetUtils absPorts_All:maskFo type:type]);
    if (Log4GetInnerAlg) NSLog(@"Group Of MaskFo:%@ 粗方案共%lu个 ↓↓↓",Fo2FStr(maskFo),(unsigned long)hnglFo_ps.count);
    
    //3. 与glConAlg_ps取交集,取出有效的前limit个;
    hnglFo_ps = [SMGUtils filterArr:hnglFo_ps checkValid:^BOOL(AIKVPointer *item) {
        AIFoNodeBase *hnglFo = [SMGUtils searchNode:item];
        //4. 当relativeFo末位为glConAlg_p时,结果才有效 (参考21183-3);
        if (![SMGUtils containsSub_p:ARR_INDEX_REVERSE(hnglFo.content_ps, 0) parent_ps:glConAlg_ps]) return false;
        
        //6. 全部通过,收集;
        return true;
    } limit:cGetInnerByFoCount];
    
    //3. 去掉不应期;
    hnglFo_ps = [SMGUtils removeSub_ps:except_ps parent_ps:hnglFo_ps];
    
    //8. 将空S评价通过的首条返回;
    AIKVPointer *result = nil;
    for (AIKVPointer *item in hnglFo_ps) {
        //5. 未发生理性评价 (空S评价);
        AIFoNodeBase *hnglFo = [SMGUtils searchNode:item];
        if ([AIScore FRS:hnglFo]) {
            result = item;
            break;
        }
    }
    
    //4. 调试;
    if (Log4GetInnerAlg) {
        //TODOTOMORROW20210521: 调试sp跨场景误杀 (参考2307b);
        BOOL logAny = true;//result;
        if (logAny) {
            int scoreNoCount = 0,scoreYesCount = 0;
            for (AIKVPointer *item_p in hnglFo_ps) {
                AIFoNodeBase *item = [SMGUtils searchNode:item_p];
                BOOL reasonScore =  [AIScore FRS:item];
                if (!reasonScore) scoreNoCount++;
                if (reasonScore) scoreYesCount++;
                NSLog(@"[%@] item方案:%@",reasonScore ? @"✔" : @"✘",Fo2FStr(item));
            }
            NSLog(@"FINISH: 通过%d 不通过%d\n",scoreYesCount,scoreNoCount);
        }else{
            NSLog(@"FINISH: 全不通过:%lu\n",(unsigned long)hnglFo_ps.count);
        }
    }
    
    //8. 逐个尝试作为解决方案返回;
    return result;
}

/**
 *  MARK:--------------------指定单条maskAlg获取inner经验--------------------
 *  @desc byAlg联想路径 (向性为右至右) (参考23031);
 *  @param glConAlg_ps : 所有可用的glConAlg (参考21115);
 *  @todo 改为用maskFo获取inner经验
 */
+(AIKVPointer*) getInnerByAlg_Single:(AIKVPointer*)maskAlg_p type:(AnalogyType)type except_ps:(NSArray*)except_ps glConAlg_ps:(NSArray*)glConAlg_ps{
    //1. 数据检查;
    AIAlgNodeBase *maskAlg = [SMGUtils searchNode:maskAlg_p];
    except_ps = ARRTOOK(except_ps);
    glConAlg_ps = ARRTOOK(glConAlg_ps);
    if (!maskAlg) return nil;
    
    //2. 根据maskAlg,取gl嵌套 (目前由absPorts+type取);
    NSArray *hnglAlg_ps = Ports2Pits([AINetUtils absPorts_All:maskAlg type:type]);
    
    //3. 与glConAlg_ps取交集,取出有效的前limit个;
    hnglAlg_ps = [SMGUtils filterSame_ps:hnglAlg_ps parent_ps:glConAlg_ps];
    hnglAlg_ps = ARR_SUB(hnglAlg_ps, 0, cGetInnerByAlgCount);
    
    //4. 从type_ps逐个尝试取.refPorts;
    for (AIKVPointer *hnglAlg_p in hnglAlg_ps) {
        //6. 用mIsC有效的glAlg具象指向节点,向refPorts取到relativeFos返回;
        AIAlgNodeBase *hnglAlg = [SMGUtils searchNode:hnglAlg_p];
        NSArray *relativeFoPorts = [SMGUtils filterPorts:[AINetUtils refPorts_All4Alg:hnglAlg] havTypes:@[@(type)] noTypes:nil];
        NSArray *relativeFo_ps = [SMGUtils convertPointersFromPorts:ARR_SUB(relativeFoPorts, 0, cHavNoneAssFoCount)];
        
        //7. 去掉不应期;
        relativeFo_ps = [SMGUtils removeSub_ps:except_ps parent_ps:relativeFo_ps];
        for (AIKVPointer *item in relativeFo_ps) {
            
            //8. 当relativeFo末位为glConAlg_p时,结果才有效 (参考21183-3);
            AIFoNodeBase *itemFo = [SMGUtils searchNode:item];
            if (![hnglAlg_p isEqual:ARR_INDEX_REVERSE(itemFo.content_ps, 0)]) continue;
            
            //9. 未发生理性评价 (空S评价);
            if (![AIScore FRS:itemFo]) continue;
            
            //10. 全部通过,返回;
            return item;
        }
    }
    return nil;
}

@end
