//
//  DirectIndexDic.h
//  SMG_NothingIsAll
//
//  Created by jia on 2024/2/29.
//  Copyright © 2024 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------带方向的indexDic--------------------
 */
@interface DirectIndexDic : NSObject

+(id) newOkToAbs:(NSDictionary*)indexDic;
+(id) newNoToAbs:(NSDictionary*)indexDic;

@property (strong, nonatomic) NSDictionary *indexDic;
@property (assign, nonatomic) BOOL toAbs;//标记当前item的下一步走向;

@end
