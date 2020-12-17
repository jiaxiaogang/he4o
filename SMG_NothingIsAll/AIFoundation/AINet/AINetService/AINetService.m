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
 *      2020.12.14: 支持except_ps不应期 (参考21183);
 *      2020.12.17: 将relativeFos返回,改为仅返回一条有效的relativeFo;
 *  @result : 返回relativeFo_ps,用backConAlg节点,由此节点取refPorts,再筛选type,可取到glFo经历;
 */
+(AIKVPointer*) getInner1Alg:(AIAlgNodeBase*)pAlg vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type except_ps:(NSArray*)except_ps{
    //1. 数据检查hAlg_根据type和value_p找ATHav
    BOOL debugMode = type == ATLess;
    if (Log4GetInnerAlg) NSLog(@"--> getInnerAlg:%@ ATDS:%@&%@ 参照:%@",[NVHeUtil getLightStr_Value:type algsType:@"" dataSource:@""],vAT,vDS,Alg2FStr(pAlg));
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
                    NSLog(@"===== glConAlg_Item: %@",AlgP2FStr(glConAlg_p));
                    for (AIKVPointer *item in relativeFo_ps) {
                        NSLog(@">> fos: %@ == %@",FoP2FStr(item),item.identifier);
                    }
                }
            }
            NSLog(@"");
        }
        
        for (AIKVPointer *glConAlg_p in glConAlg_ps) {
            if (Log4GetInnerAlg) NSLog(@"-> try_getInnerAlg结果B:%@ 结果具象C:%@",Alg2FStr(glAlg),AlgP2FStr(glConAlg_p));
            if ([TOUtils mIsC_2:glConAlg_p c:pAlg.pointer] || [TOUtils mIsC_2:pAlg.pointer c:glConAlg_p]) {
                
                //6. 用mIsC有效的glAlg具象指向节点,向refPorts取到relativeFos返回;
                AIAlgNodeBase *glConAlg = [SMGUtils searchNode:glConAlg_p];
                NSArray *relativeFoPorts = [SMGUtils filterPorts:[AINetUtils refPorts_All4Alg:glConAlg] havTypes:@[@(type)] noTypes:nil];
                NSArray *relativeFo_ps = [SMGUtils convertPointersFromPorts:ARR_SUB(relativeFoPorts, 0, cHavNoneAssFoCount)];
                
                //TODOTOMORROW20201212:
                //1. 将relativeFo改为逐个返回
                //2. 并加上不应期
                //3. 并且判断glConAlg必须在末位时,才有效;
                
                //4. 为GL返回结果做流程控制 (输出行为时,要走ActYes流程);
                //5. 为GL返回结果做流程控制 (Failure时,要递归过来继续GL);
                //6. ActYes反省类比触发后,要判断是否GL修正有效/符合预期 (并构建SP);
                //7. OutterPushMidd中,当完成时,要转到PM_GL()中进行理性评价 (以对比是否需要继续修正GL);
                
                relativeFo_ps = [SMGUtils removeSub_ps:except_ps parent_ps:relativeFo_ps];
                if (ARRISOK(relativeFo_ps)) {
                    return ARR_INDEX(relativeFo_ps, 0);
                }
            }
        }
    }
    return nil;
}

@end
