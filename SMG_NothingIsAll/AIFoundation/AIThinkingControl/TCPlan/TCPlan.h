//
//  TCPlan.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/15.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------TCPlan规划--------------------
 *  @desc 即旧架构中的dataOut方法 (参考24195);
 *  @version
 *      2021.11.28: 将dataOut迁移到TCSolution中做为入口方法;
 *      2021.12.15: 再将它迁移到TCPlan独立出来;
 */
@interface TCPlan : NSObject

+(void) planFromIfTCNeed;
+(TCResult*) planFromTOQueue;

@end
