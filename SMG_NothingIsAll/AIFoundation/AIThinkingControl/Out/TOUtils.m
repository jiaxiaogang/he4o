//
//  TOUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/2.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "TOUtils.h"
#import "AIAlgNodeBase.h"
#import "NVHeUtil.h"
#import "AINetUtils.h"

@implementation TOUtils

+(void) debugMC:(AIAlgNodeBase*)mAlg cAlg:(AIAlgNodeBase*)cAlg mcs:(NSArray*)mcs ms:(NSArray*)ms cs:(NSArray*)cs{
    if (mAlg && cAlg && mcs && ms && cs) {
        NSLog(@"===========MC START=========");
        NSLog(@"MC---------->M 地址:%@=%ld 内容:[%@]",mAlg.pointer.identifier,mAlg.pointer.pointerId,[NVHeUtil getLightStr4Ps:mAlg.content_ps]);
        NSLog(@"MC---------->C 地址:%@=%ld 内容:[%@]",cAlg.pointer.identifier,cAlg.pointer.pointerId,[NVHeUtil getLightStr4Ps:cAlg.content_ps]);
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

+(void) findConAlg_StableMV:(AIAlgNodeBase*)curAlg curFo:(AIFoNodeBase*)curFo itemBlock:(BOOL(^)(AIAlgNodeBase* validAlg))itemBlock{
    //1. 取概念和时序的具象端口;
    if (!itemBlock) return;
    NSArray *conAlg_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:curAlg]];
    NSArray *conFo_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:curFo]];
    
    //2. 筛选具象概念,将合格的回调返回;
    for (AIKVPointer *conAlg_p in conAlg_ps) {
        //a. 根据具象概念,取被哪些时序引用了;
        AIAlgNodeBase *conAlg = [SMGUtils searchNode:conAlg_p];
        NSArray *conAlgRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Alg:conAlg]];
        
        //b. 被引用的时序是curFo的具象时序,则有效;
        NSArray *validRef_ps = [SMGUtils filterSame_ps:conAlgRef_ps parent_ps:conFo_ps];
        if (validRef_ps.count > 0) {
            BOOL goOn = itemBlock(conAlg);
            if (!goOn) return;
        }
    }
}

@end
