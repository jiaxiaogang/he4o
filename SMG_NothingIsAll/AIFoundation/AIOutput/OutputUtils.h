//
//  OutputUtils.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/20.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIKVPointer;
@interface OutputUtils : NSObject

/**
 *  MARK:--------------------转换数据类型为"输出算法标识"--------------------
 *  注:目前仅支持一一对应,随后支持多个后,return改为Array;
 */
+(NSString*) convertOutType2dataSource:(NSString*)dataType;


/**
 *  MARK:--------------------检查执行微信息的输出--------------------
 */
+(BOOL) checkAndInvoke:(AIKVPointer*)micro_p;


@end
