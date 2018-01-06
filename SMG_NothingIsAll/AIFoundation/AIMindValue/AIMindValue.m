//
//  AIMindValue.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/10.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIMindValue.h"

@interface AIMindValue()

@property (assign, nonatomic) MVRuleType ruleType;      //mv规则(约束思维规则)
@property (assign, nonatomic) CGFloat duration;         //持续时间(作用于思维的时间)
@property (assign, nonatomic) MVUpCurveType upType;     //input->感受oriValue
@property (assign, nonatomic) MVDownCurveType downType; //oriValue->curValue
@property (assign, nonatomic) double createTime;        //
@property (assign, nonatomic) CGFloat inputValue;

@end

@implementation AIMindValue

-(id) initFromModel_RuleType:(MVRuleType)ruleType duration:(CGFloat)duration downType:(MVDownCurveType)downType{
    self = [super init];
    if (self) {
        self.ruleType = ruleType;
        self.duration = MAX(CGFLOAT_MIN, duration);
        self.downType = downType;
        [self initData];
    }
    return self;
}

-(id) initFromInput_RuleType:(MVRuleType)ruleType duration:(CGFloat)duration upType:(MVUpCurveType)upType inputValue:(CGFloat)inputValue downType:(MVDownCurveType)downType{
    self = [super init];
    if (self) {
        self.ruleType = ruleType;
        self.duration = MAX(CGFLOAT_MIN, duration);
        self.upType = upType;
        self.inputValue = inputValue;
        self.downType = downType;
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
            CGFloat curValue = [AIMindValueCurve getValueWithType:self.downType progress:0];
            success(curValue);
        }
    }
}

@end


/**
 *  MARK:--------------------曲线算法--------------------
 */
@implementation AIMindValueCurve :NSObject

+(CGFloat) getValueWithType:(MVDownCurveType)downType progress:(CGFloat)progress{
    progress = MAX(0, MIN(1, progress));
    if (downType == MVDownCurveType_LINEAR) {
        
    }else if(downType == MVDownCurveType_AND){
        
    }
    return 0;
}

@end
