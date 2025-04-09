//
//  AIGroupFeatureNode.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/9.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AINodeBase.h"

/**
 *  MARK:--------------------组特征--------------------
 *  @desc 主要用于表征各块局部抽象特征，以及互相的位置关系（参考n34p13）。
 */
@interface AIGroupFeatureNode : AINodeBase

@property (strong, nonatomic) NSArray *levels;
@property (strong, nonatomic) NSArray *xs;
@property (strong, nonatomic) NSArray *ys;

//根据level,x,y找下标，找不到时返-1。
-(NSInteger) indexOfLevel:(NSInteger)level x:(NSInteger)x y:(NSInteger)y;

//MARK:===============================================================
//MARK:                     < degree组 >
//MARK:===============================================================
@property (strong, nonatomic) NSMutableDictionary *degreeDDic; // <K=assT.pId, V=<K=assIndex, V=与之映射的位置符合度matchDegree>>
-(void) updateDegreeDic:(NSInteger)assPId degreeDic:(NSDictionary*)degreeDic;
-(NSDictionary*) getDegreeDic:(NSInteger)assPId;

@end
