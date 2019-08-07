//
//  NVHeUtil.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/7/2.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NVHeUtil : NSObject

/**
 *  MARK:--------------------判断是否节点尺寸为height--------------------
 */
+(BOOL) isHeight:(CGFloat)height fromContent_ps:(NSArray*)fromContent_ps;


/**
 *  MARK:--------------------获取value微信息的light描述--------------------
 */
+(NSString*) getLightStr:(AIKVPointer*)value_p;

@end
