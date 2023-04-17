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
 *  MARK:--------------------overrideCansets算法 (参考29069-todo5)--------------------
 */
+(NSArray*) getOverrideCansets:(AISceneModel*)sceneModel;

@end
