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

@end
