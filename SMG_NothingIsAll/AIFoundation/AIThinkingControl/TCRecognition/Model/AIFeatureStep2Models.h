//
//  AIFeatureStep2Models.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------用于记录特征识别step2中，所有的整体特征--------------------
 */
@interface AIFeatureStep2Models : NSObject

@property (strong, nonatomic) NSMutableArray *models;

-(AIFeatureStep2Model*) getModelIfNullCreate:(AIKVPointer*)conT;
-(void) updateItem:(AIKVPointer*)conT absT:(AIKVPointer*)absT absAtConRect:(CGRect)absAtConRect;

/**
 *  MARK:--------------------跑出位置符合度--------------------
 */
-(void) run4MatchDegree:(AIKVPointer*)protoT;

/**
 *  MARK:--------------------跑出综合匹配度--------------------
 */
-(void) run4MatchValue:(AIKVPointer*)protoT;

/**
 *  MARK:--------------------跑出assT和protoT的indexDic--------------------
 */
-(void) run4IndexDic:(AIKVPointer*)protoT;

@end
