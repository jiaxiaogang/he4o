//
//  TIRUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/1/10.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIRUtils : NSObject

/**
 *  MARK:--------------------时序识别之: protoFo&assFo匹配判断--------------------
 */
+(void) TIR_Fo_CheckFoValidMatch:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo checkItemValid:(BOOL(^)(AIKVPointer *itemAlg,AIKVPointer *assAlg))checkItemValid success:(void(^)(NSInteger lastAssIndex,CGFloat matchValue))success failure:(void(^)(NSString *msg))failure;

@end
