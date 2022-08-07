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
    AIFoNodeBase *matchFo = [SMGUtils searchNode:model.matchFo];
    [theTC updateOperCount:kFILENAME];
    Debug();
    IFTitleLog(@"IR反省", @"\n%@ spIndex:%ld -> (%@)",Fo2FStr(matchFo),model.cutIndex2 + 1,ATType2Str(type));
    [matchFo updateSPStrong:model.cutIndex2 + 1 type:type];
    DebugE();
}

+(void) perceptInRethink:(AIMatchFoModel*)model type:(AnalogyType)type{
    AIFoNodeBase *matchFo = [SMGUtils searchNode:model.matchFo];
    [theTC updateOperCount:kFILENAME];
    Debug();
    IFTitleLog(@"IP反省", @"\n%@ spIndex:%ld -> (%@)",Fo2FStr(matchFo),matchFo.count,ATType2Str(type));
    [matchFo updateSPStrong:matchFo.count type:type];
    DebugE();
}

+(void) reasonOutRethink:(TOFoModel*)model type:(AnalogyType)type{
    AIFoNodeBase *fo = [SMGUtils searchNode:model.content_p];
    [theTC updateOperCount:kFILENAME];
    Debug();
    IFTitleLog(@"OR反省", @"\n%@ spIndex:%ld -> (%@)",FoP2FStr(model.content_p),model.actionIndex,ATType2Str(type));
    [fo updateSPStrong:model.actionIndex type:type];
    DebugE();
}

+(void) perceptOutRethink:(TOFoModel*)model type:(AnalogyType)type{
    AIFoNodeBase *fo = [SMGUtils searchNode:model.content_p];
    [theTC updateOperCount:kFILENAME];
    Debug();
    IFTitleLog(@"OP反省", @"\n%@ spIndex:%ld -> (%@)",FoP2FStr(model.content_p),fo.count,ATType2Str(type));
    [fo updateSPStrong:fo.count type:type];
    DebugE();
}

@end
