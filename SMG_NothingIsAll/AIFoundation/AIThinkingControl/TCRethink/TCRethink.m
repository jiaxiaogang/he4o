//
//  TCRethink.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/25.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCRethink.h"

@implementation TCRethink

/**
 *  MARK:--------------------IR反省器--------------------
 *  @version
 *      2023.03.04: 修复反省未保留以往帧cutIndex (参考28144-另外);
 */
+(void) reasonInRethink:(AIMatchFoModel*)model cutIndex:(NSInteger)cutIndex type:(AnalogyType)type{
    AIFoNodeBase *matchFo = [SMGUtils searchNode:model.matchFo];
    [theTC updateOperCount:kFILENAME];
    Debug();
    IFTitleLog(@"IR反省", @"\n%@ spIndex:%ld -> (%@)",Fo2FStr(matchFo),cutIndex + 1,ATType2Str(type));
    [matchFo updateSPStrong:cutIndex + 1 type:type];
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

/**
 *  MARK:--------------------OR反省器--------------------
 *  @version
 *      2023.03.04: 修复反省未保留以往帧actionIndex,导致反省时错误的BUG (参考28144-todo);
 */
+(void) reasonOutRethink:(TOFoModel*)model actionIndex:(NSInteger)actionIndex type:(AnalogyType)type{
    AIFoNodeBase *fo = [SMGUtils searchNode:model.content_p];
    [theTC updateOperCount:kFILENAME];
    Debug();
    IFTitleLog(@"OR反省", @"\n%@ spIndex:%ld -> (%@)",FoP2FStr(model.content_p),actionIndex,ATType2Str(type));
    [fo updateSPStrong:actionIndex type:type];
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
