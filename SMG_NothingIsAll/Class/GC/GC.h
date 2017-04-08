//
//  GC.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  MARK:--------------------遗忘器--------------------
 *  1,遗忘策略;(>validTime || >maxSize)
 *  2,把MemStore该忘的忘掉;(从dic破到localDic)
 *  3,把MKStore该忘的忘掉;(从dic破到localDic)
 *  4,心情回复功能;
 */
@interface GC : NSObject

@end
