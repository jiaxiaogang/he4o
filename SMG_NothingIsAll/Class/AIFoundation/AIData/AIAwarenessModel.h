//
//  AIAwarenessModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

/**
 *  MARK:--------------------意识流--------------------
 *  AIMemoryModel的升层;(参考N3P5)
 *  Think的指针流;
 */
@interface AIAwarenessModel : AIObject

@property (strong,nonatomic) AIPointer *pointer;    //意识流可能只存一个指针

@end
