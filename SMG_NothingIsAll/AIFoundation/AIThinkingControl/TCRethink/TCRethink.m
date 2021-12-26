//
//  TCRethink.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/25.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCRethink.h"

@implementation TCRethink

+(void) reasonInRethink:(AIMatchFoModel*)model type:(AnalogyType)type{
    [model.matchFo updateSPStrong:model.cutIndex2 + 1 type:type];
}

+(void) perceptInRethink:(AIMatchFoModel*)model type:(AnalogyType)type{
    [model.matchFo updateSPStrong:model.matchFo.count type:type];
}

+(void) reasonOutRethink:(TOFoModel*)model type:(AnalogyType)type{
    AIFoNodeBase *fo = [SMGUtils searchNode:model.content_p];
    [fo updateSPStrong:model.targetSPIndex type:type];
}

+(void) perceptOutRethink:(TOFoModel*)model type:(AnalogyType)type{
    AIFoNodeBase *fo = [SMGUtils searchNode:model.content_p];
    [fo updateSPStrong:fo.count type:type];
}

@end
