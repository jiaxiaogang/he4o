//
//  TOMVisionItemModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/15.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------用于存单帧TOModel数据--------------------
 */
@interface TOMVisionItemModel : NSObject <NSCoding>

@property (assign, nonatomic) NSInteger loopId; //当前循环Id (自增);
@property (strong, nonatomic) NSArray *roots;   //当前帧在DemandManager中的loopCache快照;

@end
