//
//  AIFeatureStep1Model.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/5/7.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------局部特征识别V2算法模型：二级--------------------
 */
@interface AIFeatureStep1Model : NSObject

//refPort.target。
@property (strong, nonatomic) AIKVPointer *assT_p;
//每个assT在proto中的rect（用于整体特征识别）。
@property (assign, nonatomic) CGRect assTAtProtoTRect;
//每条最佳gv的数据：List<AIFeatureStep1Item>
@property (strong, nonatomic) NSMutableArray *bestGVs;

@end
