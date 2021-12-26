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
+(double) getValueDataFromFo:(AIKVPointer*)fo_p valueIdentifier:(NSString*)valueIdentifier{
    //1. 数据准备;
    AIKVPointer *value_p = [self getValuePFromFo:fo_p valueIdentifier:valueIdentifier];
    
    //2. 空时,返回0;
    return value_p ? [NUMTOOK([AINetIndex getData:value_p]) doubleValue] : 0;
}
+(AIKVPointer*) getValuePFromFo:(AIKVPointer*)fo_p valueIdentifier:(NSString*)valueIdentifier{
    //1. 数据准备;
    AIFoNodeBase *fo = [SMGUtils searchNode:fo_p];
    if (!fo) return nil;
    
    //2. 分别对alg元素进行找value同区码;
    for (AIKVPointer *alg_p in fo.content_ps) {
        AIAlgNodeBase *alg = [SMGUtils searchNode:alg_p];
        if (!alg) continue;
        
        //3. 找到一个同区码时即返回;
        AIKVPointer *value_p = ARR_INDEX([SMGUtils filterPointers:alg.content_ps identifier:valueIdentifier], 0);
        if (value_p) {
            return value_p;
        }
    }
    
    //4. 全找不到时,返回0;
    return nil;
}

@end
