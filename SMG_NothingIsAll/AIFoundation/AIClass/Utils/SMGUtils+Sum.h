//
//  SMGUtils+Sum.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/12/30.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------求和工具类--------------------
 *  @desc 从SMGUtils单独出来,因为Sum比较麻烦,得支持值域求和 (参考n21p21);
 */
@interface SMGUtils (Sum)

/**
 *  MARK:--------------------值域求和--------------------
 */
+(NSArray*) sumSPorts:(NSArray*)sPorts pPorts:(NSArray*)pPorts;

/**
 *  MARK:--------------------判断value处在S还是P中--------------------
 */
+(AnalogyType) checkValueSPType:(double)value sumSPModel:(NSArray*)sumSPModel;

@end


//MARK:===============================================================
//MARK:                     < SumModel单点模型 >
//MARK:===============================================================
@interface SumModel : NSObject

//交点值
@property (assign, nonatomic) double dotValue;

//向右的方向类型(S/P)
@property (assign, nonatomic) AnalogyType type;

@end
