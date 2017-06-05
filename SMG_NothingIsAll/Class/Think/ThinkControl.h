//
//  ThinkControl.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------思考控制器--------------------
 */
@class Decision,Understand;
@interface ThinkControl : NSObject

@property (strong,nonatomic) Understand *understand;
@property (strong,nonatomic) Decision *decision;

@end
