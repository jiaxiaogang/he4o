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

+(SumModel*)newWithDotValue:(double)dotValue type:(AnalogyType)type;

/**
 *  MARK:--------------------交点值--------------------
 *  @desc 表征从左至右的稀疏码值的横轴上,交点至右到下一交点的起点值;
 *        比如:[floatMin,1,8,20]中: 1表示1到8, 20表示20到floatMax;
 */
@property (assign, nonatomic) double dotValue;

/**
 *  MARK:--------------------向右的方向类型--------------------
 *  @desc 只有S和P两个值,标示dotValue右侧区间内是S还是P;
 */
@property (assign, nonatomic) AnalogyType type;

@end
