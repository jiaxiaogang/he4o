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
    NSString *spFrom = STRFORMAT(@"%@",[matchFo.spDic objectForKey:@(cutIndex + 1)]);
    [matchFo updateSPStrong:cutIndex + 1 type:type];
    if (Log4Rethink) IFTitleLog(@"IR反省", @"\nspIndex:%ld -> (%@) %@->%@ %@",cutIndex + 1,ATType2Str(type),spFrom,[matchFo.spDic objectForKey:@(cutIndex + 1)],Fo2FStr(matchFo));
    
    //2. 抽象也更新 (参考29069-todo11.4);
    //2024.11.08: 佐证: 子即父 (参考33111-TODO2);
    [TCRethinkUtil spEff4Abs:matchFo curFoIndex:cutIndex + 1 itemRunBlock:^(AIFoNodeBase *absFo, NSInteger absIndex) {
        [absFo updateSPStrong:absIndex type:type];
    }];
    DebugE();
}

+(void) perceptInRethink:(AIMatchFoModel*)model type:(AnalogyType)type{
    AIFoNodeBase *matchFo = [SMGUtils searchNode:model.matchFo];
    [theTC updateOperCount:kFILENAME];
    Debug();
    NSString *spFrom = STRFORMAT(@"%@",[matchFo.spDic objectForKey:@(matchFo.count)]);
    [matchFo updateSPStrong:matchFo.count type:type];
    if (Log4Rethink) IFTitleLog(@"IP反省", @"\nspIndex:%ld -> (%@) %@->%@ %@",matchFo.count,ATType2Str(type),spFrom,[matchFo.spDic objectForKey:@(matchFo.count)],Fo2FStr(matchFo));
    
    //2. 抽象也更新 (参考29069-todo11.4);
    [TCRethinkUtil spEff4Abs:matchFo curFoIndex:matchFo.count itemRunBlock:^(AIFoNodeBase *absFo, NSInteger absIndex) {
        [absFo updateSPStrong:absIndex type:type];
    }];
    DebugE();
}

@end
