//
//  CharStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CharStore : NSObject


/**
 *  MARK:--------------------字符数组->字符串--------------------
 */
+(NSString*) searchString:(NSArray*)charIdArr;

/**
 *  MARK:--------------------字符串->字符数组--------------------
 */
+(NSArray*) insertString:(NSString*)string;

/**
 *  MARK:--------------------创建本地单一的Model--------------------
 */
+(CharModel*) createInstanceModel:(NSString*)value;



@end
