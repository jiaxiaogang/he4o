//
//  TCRealact.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/17.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------realact: 对TCSolution最佳输出的可行性检查--------------------
 *  @desc TCSolution最后输出最佳result之前,检查result如果太抽象(含空概念)则不可行,那么向具象重新找个可行的;
 */
@interface TCRealact : NSObject

/**
 *  MARK:--------------------TCSolution最佳输出的可行性检查--------------------
 */
+(TOFoModel*) checkRealactAndReplaceIfNeed:(TOFoModel*)bestResult fromCansets:(NSArray*)fromCansets;

@end
