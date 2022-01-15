//
//  TIUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/27.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIUtils : NSObject

//MARK:===============================================================
//MARK:                     < 概念识别 >
//MARK:===============================================================
+(void) TIR_Alg:(AIKVPointer*)algNode_p fromGroup_ps:(NSArray*)fromGroup_ps complete:(void(^)(NSArray *matchAlgs,NSArray *partAlgs))complete;


//MARK:===============================================================
//MARK:                     < 时序识别 >
//MARK:===============================================================
+(void) partMatching_FoV1Dot5:(AIFoNodeBase*)maskFo except_ps:(NSArray*)except_ps decoratorInModel:(AIShortMatchModel*)inModel findCutIndex:(NSInteger(^)(AIFoNodeBase *matchFo,NSInteger lastMatchIndex))findCutIndex;

@end
