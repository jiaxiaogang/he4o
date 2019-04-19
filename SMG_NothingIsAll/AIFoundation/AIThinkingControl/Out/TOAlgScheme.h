//
//  TOAlgScheme.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/19.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------TO中,对于祖母的判定部分--------------------
 */
@interface TOAlgScheme : NSObject


/**
 *  MARK:--------------------多个祖母rangeOrder行为化;--------------------
 *  代码步骤: (发现->距离->飞行)
 *  1. 比如找到坚果,由有无时序来解决"有无"问题; (cNone,cHav) (有无)
 *  2. 找到的坚果与fo中进行类比;(找出坚果距离的不同,或者坚果带皮儿的不同) (cLess,cGreater) (变化)
 *  3. 将距离与带皮转化成行为,条件的行为化; (如飞行,或去皮); (actionScheme) (行为)
 */
+(NSArray*) convert2Out:(NSArray*)curAlg_ps;


@end
