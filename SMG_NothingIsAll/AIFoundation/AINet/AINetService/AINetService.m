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

@implementation AINetService

+(AIAlgNodeBase*) getInnerAlg:(AIAlgNodeBase*)alg vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type{
    //4. 数据检查hAlg_根据type和value_p找ATHav
    AIKVPointer *innerValue_p = [theNet getNetDataPointerWithData:@(type) algsType:vAT dataSource:vDS];
    
    //3. 对v.ref和a.abs进行交集,取得有效GLAlg;
    NSArray *vRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Value:innerValue_p]];
    NSArray *aAbs_ps = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:alg type:type]];
    AIKVPointer *innerAlg_p = ARR_INDEX([SMGUtils filterSame_ps:vRef_ps parent_ps:aAbs_ps], 0);
    AIAlgNodeBase *innerAlg = [SMGUtils searchNode:innerAlg_p];
    return innerAlg;
}


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
+(AIAlgNodeBase*) getInnerAlg_GL:(AIAlgNodeBase*)alg vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type{
    //4. 数据检查hAlg_根据type和value_p找ATHav
    AIKVPointer *innerValue_p = [theNet getNetDataPointerWithData:@(type) algsType:vAT dataSource:vDS];
    
    for (AIKVPointer *p1 in [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:alg]]) {
        AIAlgNodeBase *a1 = [SMGUtils searchNode:p1];
        NSLog(@"-----1级:%@",Alg2FStr(a1));
        
        for (AIKVPointer *p2 in [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:a1]]) {
            AIAlgNodeBase *a2 = [SMGUtils searchNode:p2];
            NSLog(@"--2级:%@",Alg2FStr(a2));
        }
    }
    
    //3. 对v.ref和a.abs进行交集,取得有效GLAlg;
    NSArray *vRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Value:innerValue_p]];
    NSArray *aAbs_ps = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:alg type:type]];
    AIKVPointer *innerAlg_p = ARR_INDEX([SMGUtils filterSame_ps:vRef_ps parent_ps:aAbs_ps], 0);
    AIAlgNodeBase *innerAlg = [SMGUtils searchNode:innerAlg_p];
    return innerAlg;
}

@end
