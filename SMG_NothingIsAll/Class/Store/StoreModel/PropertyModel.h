//
//  PropertyModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/5.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------pvm格式来存储物体的属性--------------------
 *  //搞清人类与"小赤"的关系;//xxx
 */
@interface PropertyModel : NSObject

@property (assign, nonatomic) int property;
@property (assign, nonatomic) int value;
@property (assign, nonatomic) int mindValue;

@end
