//
//  TCFeedbackTOR.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/5.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------feedbackTOR--------------------
 *  @desc 四个feedback分别对应四个rethink反省 (参考25031-12);
 */
@interface TCFeedbackTOR : NSObject

+(void) feedbackTOR:(AIShortMatchModel*)model;

@end
