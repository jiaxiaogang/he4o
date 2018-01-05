//
//  AINetCache.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2018/1/5.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------内存缓存--------------------
 */
@interface AINetCache : NSObject

+(AINetCache*) sharedInstance;
-(id) objectForKey:(AIPointer*)key;

@end
