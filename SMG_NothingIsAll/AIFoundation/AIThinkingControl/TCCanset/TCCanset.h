//
//  TCCanset.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/17.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCCanset : NSObject

/**
 *  MARK:--------------------将canset_p转成cansetModel--------------------
 */
+(TOFoModel*) convert2CansetModel:(AIKVPointer*)cansetFo_p sceneFo:(AIKVPointer*)sceneFo_p basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel ptAleardayCount:(NSInteger)ptAleardayCount isH:(BOOL)isH sceneModel:(AISceneModel*)sceneModel demand:(DemandModel*)demand;

/**
 *  MARK:--------------------HSolution转CansetModel--------------------
 */
+(TOFoModel*) convert2HCansetModel:(AIKVPointer*)hCanset_p hDemand:(HDemandModel*)hDemand rCanset:(TOFoModel*)rCanset;

@end
