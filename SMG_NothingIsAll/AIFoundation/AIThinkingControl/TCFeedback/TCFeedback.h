//
//  TCFeedback.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/2.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------反馈--------------------
 *  @desc 四个feedback分别对应四个rethink反省 (参考25031-12);
 *  @version
 *      2021.12.02: 把四个OPushM反馈方法移过来 (先移了三个,tor有PM算法调用,先不移,后面脱离了PM再移);
 *      2022.11.23: 把最后一个TOR也移过来 (为了放一块容易看和改代码);
 */
@interface TCFeedback : NSObject

+(void) feedbackTIR:(AIShortMatchModel*)model;
+(void) feedbackTIP:(AIFoNodeBase*)protoFo cmvNode:(AICMVNode*)cmvNode;
+(void) feedbackTOR:(AIShortMatchModel*)model;
+(void) feedbackTOP:(AICMVNodeBase*)cmvNode;

@end
