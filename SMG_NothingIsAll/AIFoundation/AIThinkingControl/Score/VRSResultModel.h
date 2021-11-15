//
//  VRSResultModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/10/29.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "RSModelBase.h"

/**
 *  MARK:--------------------VRS评价结果模型--------------------
 *  @version
 *      2021.11.01: 废弃pPorts,因为修正目标,不再从pPorts中直接取最近的值 (参考24103-BUG2);
 *      2021.11.01: 将pPercent和margin集成 (参考24103-BUG1);
 *      2021.11.02: 封装RSModelBase,因为修正目标也要继承它;
 */
@interface VRSResultModel : RSModelBase

+(VRSResultModel*) newWithBaseFo:(AIFoNodeBase*)baseFo pScore:(double)pScore sScore:(double)sScore proto:(AIKVPointer*)protoValue_p;
@property (strong, nonatomic) AIKVPointer *protoValue_p; //对谁进行的评价;

@end
