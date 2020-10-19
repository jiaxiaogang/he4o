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
    if (Log4GetInnerAlg) NSLog(@"--> getInnerAlg:%ld ATDS:%@&%@ 参照:%@(C和参照概念有mIsC关联则成功)",(long)type,vAT,vDS,Alg2FStr(pAlg));
    AIKVPointer *innerValue_p = [theNet getNetDataPointerWithData:@(type) algsType:vAT dataSource:vDS];
    
    //2. 对v.ref和a.abs进行交集,取得有效GLAlg;
    NSArray *gl_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Value:innerValue_p]];
    
    //3. 找出合格的inner1Alg;
    int debugVesion = 1;
    for (AIKVPointer *gl_p in gl_ps) {
        AIAlgNodeBase *glAlg = [SMGUtils searchNode:gl_p];
        
        //4. 根据glAlg,向具象找出真正当时变"大小"的具象概念节点;
        NSArray *glAlgCon_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:glAlg]];
        
        //5. 这些节点中,哪个与pAlg有抽具象关系,就返回哪个;
        for (AIKVPointer *glAlgCon_p in glAlgCon_ps) {
            if (Log4GetInnerAlg) NSLog(@"-> try_getInnerAlg结果B:%@ 结果具象C:%@",Alg2FStr(glAlg),AlgP2FStr(glAlgCon_p));
            if ([TOUtils mIsC_2:glAlgCon_p c:pAlg.pointer] || [TOUtils mIsC_2:pAlg.pointer c:glAlgCon_p]) {
                return glAlg;
            }
            
            //TODOTOMORROW:
            //可视化查2105cBUG时,的节点关系,目前仅调试↙坚果时;
            if (debugVesion > 0 && [AlgP2FStr(glAlgCon_p) containsString:@"↙"]) {
                [theNV setForceMode:true];
                [theNV setNodeData:pAlg.pointer];
                [theNV setNodeData:glAlgCon_p];
                [theNV setForceMode:false];
                debugVesion--;
            }
        }
    }
    return nil;
}

@end
