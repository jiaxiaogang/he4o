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

@end
