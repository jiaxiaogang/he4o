//
//  AIFeatureNode.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/18.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AINodeBase.h"

/**
 *  MARK:--------------------特征节点--------------------
 */
@interface AIFeatureNode : AINodeBase

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
