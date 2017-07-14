//
//  AIMindValueModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/5.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

/**
 *  MARK:--------------------AIMindValueModel变化的意识流--------------------
 *  与意识流相关联;
 */
@interface AIMindValueModel : AIObject

+(AIMindValueModel*) initWithType:(MindType)type value:(CGFloat)value sourcePointer:(AIPointer*)pointer;
@property (assign, nonatomic) CGFloat value;//饱合度(-10-10)(MindValueDelta)
@property (assign, nonatomic) MindType type;
@property (strong,nonatomic) AIPointer *sourcePointer;     //引起变化的来源(一个AIPointer或者一个PointerArr)(这会增加复杂度,增加无限bug,应该结构化最简解决,随后考虑与Awareness和其它表结合)

@end
