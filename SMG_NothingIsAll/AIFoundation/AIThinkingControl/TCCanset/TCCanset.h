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
 *  MARK:--------------------将sceneModel转成canset_ps (override算法) (参考29069-todo5)--------------------
 */
+(NSArray*) getOverrideCansets:(AISceneModel*)sceneModel;

/**
 *  MARK:--------------------将canset_p转成cansetModel--------------------
 */
+(AICansetModel*) convert2CansetModel:(AIKVPointer*)cansetFo_p sceneFo:(AIKVPointer*)sceneFo_p basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel ptAleardayCount:(NSInteger)ptAleardayCount isH:(BOOL)isH sceneModel:(AISceneModel*)sceneModel;

@end
