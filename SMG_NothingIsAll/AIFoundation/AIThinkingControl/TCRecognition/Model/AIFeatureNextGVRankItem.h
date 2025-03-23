//
//  AIFeatureNextGVRankItem.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/23.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------特征识别中，每一条GV的refPort计算位置符合度 的 结果模型--------------------
 */
@interface AIFeatureNextGVRankItem : NSObject

@property (strong, nonatomic) AIPort *refPort;
@property (assign, nonatomic) CGFloat gMatchValue;
@property (assign, nonatomic) CGFloat gMatchDegree;

@end
