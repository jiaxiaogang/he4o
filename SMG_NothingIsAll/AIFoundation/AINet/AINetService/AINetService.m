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
    
    //3. 找出合格的inner1Alg;
    for (AIKVPointer *vRef_p in vRef_ps) {
        AIAlgNodeBase *glAlg = [SMGUtils searchNode:vRef_p];
        
        //4. 根据glAlg,向具象找出真正当时变"大小"的具象概念节点;
        NSArray *glAlgCon_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:glAlg]];
        
        //5. 这些节点中,哪个与pAlg有抽具象关系,就返回哪个;
        for (AIKVPointer *glAlgCon_p in glAlgCon_ps) {
            if ([TOUtils mIsC_2:glAlgCon_p c:pAlg.pointer] || [TOUtils mIsC_2:pAlg.pointer c:glAlgCon_p]) {
                return glAlg;
            }
        }
    }
    return nil;
}

@end
