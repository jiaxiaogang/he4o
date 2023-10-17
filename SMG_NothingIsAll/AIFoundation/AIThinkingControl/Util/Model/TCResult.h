//
//  TCResult.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/7/22.
//  Copyright © 2023 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------TO执行结果--------------------
 *  @desc 用于TO执行结果的数据返回 (是否成功,消息,是否需等待会);
 *  @version
 *      2023.07.22: 初版 (参考30084-todo3);
 */
@interface TCResult : NSObject

+(TCResult*) new:(BOOL)success;

@property (assign, nonatomic) BOOL success;
@property (strong, nonatomic) NSString *msg;
@property (assign, nonatomic) CGFloat delay;
@property (assign, nonatomic) NSInteger step;

/**
 *  MARK:--------------------装饰方法--------------------
 */
-(TCResult*) mkMsg:(NSString*)msg;
-(TCResult*) mkDelay:(CGFloat)delay;
-(TCResult*) mkStep:(NSInteger)step;

@end
