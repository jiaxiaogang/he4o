//
//  TCJiCenModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2024/1/17.
//  Copyright © 2024 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------继承数据模型--------------------
 */
@interface TCJiCenModel : NSObject

@property (strong, nonatomic) NSArray *iCansetOrders;
@property (strong, nonatomic) NSDictionary *iSceneCansetIndexDic;//R时为iRScene和rCansetTo的映射 H时为iHScene和hCansetTo的映射;
@property (assign, nonatomic) NSInteger iSceneTargetIndex;

@end
