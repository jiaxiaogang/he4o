//
//  AIMindValue.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/10.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------mindValue--------------------
 */
@interface AIMindValue : NSObject

-(id) initWithRuleType:(MVRuleType)ruleType duration:(CGFloat)duration curveType:(MVCurveType)curveType;
-(void) requestRule:(void(^)(CGFloat value))success failure:(void(^)())failure;

@end



/**
 *  MARK:--------------------曲线算法--------------------
 */
@interface AIMindValueCurve :NSObject

+(CGFloat) getValueWithCurveType:(MVCurveType)curveType progress:(CGFloat)progress;

@end
