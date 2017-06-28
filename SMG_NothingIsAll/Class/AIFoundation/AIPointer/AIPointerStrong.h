//
//  AIPointerStrong.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------指针强度--------------------
 */
@class AIPointerDampingStrategy;
@interface AIPointerStrong : NSObject

@property (assign, nonatomic) CGFloat value;    //当前强度值
@property (assign, nonatomic) NSInteger count;  //计数器
@property (strong, nonatomic) AIPointerDampingStrategy *dampingStrategy; //衰减策略

@end
