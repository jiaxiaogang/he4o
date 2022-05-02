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
+(void) TIR_Alg:(AIKVPointer*)algNode_p except_ps:(NSArray*)except_ps inModel:(AIShortMatchModel*)inModel;


//MARK:===============================================================
//MARK:                     < 时序识别 >
//MARK:===============================================================
+(void) partMatching_FoV1Dot5:(AIFoNodeBase*)maskFo except_ps:(NSArray*)except_ps decoratorInModel:(AIShortMatchModel*)inModel fromRegroup:(BOOL)fromRegroup;


/**
 *  MARK:--------------------获取某帧shortModel的matchAlgs+partAlgs--------------------
 */
+(NSArray*) getMatchAndPartAlgPs:(NSInteger)frameIndex;
+(NSArray*) getMatchAndPartAlgPsByModel:(AIShortMatchModel*)frameModel;

@end
