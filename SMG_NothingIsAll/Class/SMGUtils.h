//
//  SMGUtils.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/19.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMGUtils : NSObject

@end


/**
 *  MARK:--------------------比较--------------------
 */
@interface SMGUtils (Compare)
+(BOOL) compareItemA:(id)itemA itemB:(id)itemB;
@end
