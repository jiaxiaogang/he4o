//
//  CortexAlgorithmsUtil.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/3/13.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CortexAlgorithmsUtil : NSObject

+(double) maxOfLoopValue:(NSString*)at ds:(NSString*)ds itemIndex:(NSInteger)itemIndex;

//稀疏码的相近度（返回两个值的差值）
+(double) nearDeltaOfValue:(CGFloat)protoNum assNum:(CGFloat)assNum max:(CGFloat)max;

/**
 *  MARK:--------------------取子粒度层9格--------------------
 *  @desc 即更细粒度下层。 参数说明：根据当前层的curLevel,curRow,curColumn来取。
 */
+(NSArray*) getSub9DotFromSplitDic:(NSInteger)curLevel curRow:(NSInteger)curRow curColumn:(NSInteger)curColumn splitDic:(NSDictionary*)splitDic;

@end
