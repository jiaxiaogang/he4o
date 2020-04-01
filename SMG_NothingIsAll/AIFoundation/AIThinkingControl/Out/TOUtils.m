//
//  TOUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/2.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "TOUtils.h"

@implementation TOUtils

+(void) debugMC_Alg:(AIAlgNodeBase*)mAlg cAlg:(AIAlgNodeBase*)cAlg mcs:(NSArray*)mcs ms:(NSArray*)ms cs:(NSArray*)cs{
    if (mAlg && cAlg && mcs && ms && cs) {
        NSLog(@"MC---------->M 地址:%d 内容:[%@]",mAlg.pointer.pointerId,[NVHeUtil getLightStr4Ps:mAlg.content_ps]);
        NSLog(@"MC---------->C 地址:%d 内容:[%@]",cAlg.pointer.pointerId,[NVHeUtil getLightStr4Ps:cAlg.content_ps]);
        [theNV setNodeData:mAlg.pointer lightStr:@"M"];
        [theNV setNodeData:cAlg.pointer lightStr:@"C"];
        for (AIKVPointer *mc in mcs) {
            AIAlgNodeBase *mcAlg = [SMGUtils searchNode:mc];
            NSLog(@"--->mcs:[%@]",[NVHeUtil getLightStr4Ps:mcAlg.content_ps]);
        }
        for (AIKVPointer *m in ms) {
            AIAlgNodeBase *mAlg = [SMGUtils searchNode:m];
            NSLog(@"-->ms:[%@]",[NVHeUtil getLightStr4Ps:mAlg.content_ps]);
        }
        for (AIKVPointer *c in cs) {
            AIAlgNodeBase *cAlg = [SMGUtils searchNode:c];
            NSLog(@"-->cs:[%@]",[NVHeUtil getLightStr4Ps:cAlg.content_ps]);
        }
    }
}

@end
