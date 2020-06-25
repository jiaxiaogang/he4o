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
 *  @todo
 *      2020.06.24: 对alg指引联想,取同层+多层abs,比如,我没洗过西瓜,但我洗过苹果,或者洗过水果,那我可以试下用水洗西瓜;
 */
+(AIAlgNodeBase*) getInner1Alg:(AIAlgNodeBase*)pAlg vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type{
    //1. 数据检查hAlg_根据type和value_p找ATHav
    AIKVPointer *innerValue_p = [theNet getNetDataPointerWithData:@(type) algsType:vAT dataSource:vDS];
    
    //2. 对v.ref和a.abs进行交集,取得有效GLAlg;
    NSArray *vRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Value:innerValue_p]];
    
    //用可视化调试glAlg和pAlg的关系;
    [theNV setForceMode:true];
    [theNV setNodeData:pAlg.pointer lightStr:@"P"];
    for (NSInteger i = 0; i < vRef_ps.count; i++) {
        AIAlgNodeBase *glAbsAlg = [SMGUtils searchNode:ARR_INDEX(vRef_ps, i)];
        NSArray *glAlgs = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:glAbsAlg]];
        for (NSInteger j = 0; j < glAlgs.count; j++) {
            [theNV setNodeData:ARR_INDEX(glAlgs, i) lightStr:(STRFORMAT(@"GL%ld-%ld",(long)i,(long)j))];
        }
    }
    [theNV setForceMode:false];
    
    //3. 找出合格的inner1Alg;
    for (AIKVPointer *gl1_p in vRef_ps) {
        AIAlgNodeBase *gl1Alg = [SMGUtils searchNode:gl1_p];
        NSArray *gl0_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:gl1Alg]];
        for (AIKVPointer *gl0_p in gl0_ps) {
            if ([TOUtils mIsC_2:gl0_p c:pAlg.pointer] || [TOUtils mIsC_2:pAlg.pointer c:gl0_p]) {
                return gl1Alg;
            }
        }
    }
    return nil;
}

@end
