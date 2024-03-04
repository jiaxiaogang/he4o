//
//  TCTransferXvModel.h
//  SMG_NothingIsAll
//
//  Created by mac on 2024/3/3.
//  Copyright © 2024年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------TypeI DemandH迁移模型--------------------
 */
@interface TCTransferXvModel : NSObject

@property (strong, nonatomic) NSArray *cansetToOrders;//表示迁移目标的方案时序的内容;
@property (strong, nonatomic) NSDictionary *sceneToCansetToIndexDic;//表示迁移目标canset和scene之间的映射;
@property (assign, nonatomic) NSInteger sceneToTargetIndex;//表示迁移目标sceneTo的目标;

@end
