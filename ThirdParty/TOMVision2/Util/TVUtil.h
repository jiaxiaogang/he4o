//
//  TVUtil.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/26.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVUtil : NSObject

/**
 *  MARK:--------------------获取两帧工作记忆的更新处--------------------
 */
+(NSArray*) getChanges:(NSArray*)firstRoots secondRoots:(NSArray*)secondRoots;

@end
