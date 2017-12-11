//
//  AIMindValue.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/10.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIMindValue.h"

@interface AIMindValue()

@property (assign, nonatomic) MVRuleType ruleType;
@property (assign, nonatomic) CGFloat duration;
@property (assign, nonatomic) MVCurveType curveType;
@property (assign, nonatomic) double createTime;

@end

@implementation AIMindValue

-(id) initWithRuleType:(MVRuleType)ruleType duration:(CGFloat)duration curveType:(MVCurveType)curveType{
    self = [super init];
    if (self) {
        self.ruleType = ruleType;
        self.duration = MAX(CGFLOAT_MIN, duration);
        self.curveType = curveType;
        [self initData];
    }
    return self;
}

-(void) initData{
    self.createTime = [[NSDate date] timeIntervalSince1970];
}

-(void) requestRule:(void(^)(CGFloat value))success failure:(void(^)())failure {
    //1. duration不得<0
    self.duration = MAX(CGFLOAT_MIN, self.duration);
    //2. 百分比
    double now = [[NSDate date] timeIntervalSince1970];
    CGFloat progress = (now - self.createTime) / self.duration;
    //3. 超时则无效
    if (progress > 1 || progress < 0) {
        if (failure) {
            failure();
        }
    }else{
        if (success) {
            CGFloat curValue = [AIMindValueCurve getValueWithCurveType:self.curveType progress:0];
            success(curValue);
        }
    }
}

@end


/**
 *  MARK:--------------------曲线算法--------------------
 */
@implementation AIMindValueCurve :NSObject

+(CGFloat) getValueWithCurveType:(MVCurveType)curveType progress:(CGFloat)progress{
    progress = MAX(0, MIN(1, progress));
    if (curveType == MVCurveType_LinearH) {
        
    }else if(curveType == MVCurveType_HAH){
        
    }
    return 0;
}

@end
