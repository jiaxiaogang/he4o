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
 *  MARK:--------------------inSP更新器--------------------
 *  @version
 *      2023.03.04: 修复反省未保留以往帧cutIndex (参考28144-另外);
 */
+(void) reasonInRethink:(AIMatchFoModel*)model cutIndex:(NSInteger)cutIndex type:(AnalogyType)type except4SP2F:(NSMutableArray*)except4SP2F {
    AIFoNodeBase *matchFo = [SMGUtils searchNode:model.matchFo];
    [theTC updateOperCount:kFILENAME];
    Debug();
    NSString *spFrom = STRFORMAT(@"%@",[matchFo.spDic objectForKey:@(cutIndex + 1)]);
    [AINetUtils updateInSPStrong_4IF:matchFo conSPIndex:cutIndex + 1 type:type except4SP2F:except4SP2F];
    if (Log4Rethink) IFTitleLog(@"IR反省", @"\nspIndex:%ld -> (%@) %@->%@ %@",cutIndex + 1,ATType2Str(type),spFrom,[matchFo.spDic objectForKey:@(cutIndex + 1)],Fo2FStr(matchFo));
    DebugE();
}

+(void) perceptInRethink:(AIMatchFoModel*)model type:(AnalogyType)type except4SP2F:(NSMutableArray*)except4SP2F {
    AIFoNodeBase *matchFo = [SMGUtils searchNode:model.matchFo];
    [theTC updateOperCount:kFILENAME];
    Debug();
    NSString *spFrom = STRFORMAT(@"%@",[matchFo.spDic objectForKey:@(matchFo.count)]);
    [AINetUtils updateInSPStrong_4IF:matchFo conSPIndex:matchFo.count type:type except4SP2F:except4SP2F];
    if (Log4Rethink) IFTitleLog(@"IP反省", @"\nspIndex:%ld -> (%@) %@->%@ %@",matchFo.count,ATType2Str(type),spFrom,[matchFo.spDic objectForKey:@(matchFo.count)],Fo2FStr(matchFo));
    DebugE();
}

@end
