//
//  VRSTargetModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/2.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "VRSModelBase.h"

/**
 *  MARK:--------------------VRS修正目标模型--------------------
 */
@interface VRSTargetModel : VRSModelBase

+(VRSTargetModel*) newWithBaseFo:(AIFoNodeBase*)baseFo pScore:(double)pScore sScore:(double)sScore target:(AIKVPointer*)targetValue_p;
@property (strong, nonatomic) AIKVPointer *targetValue_p; //修正目标;

@end
