//
//  PointerModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "PointerModel.h"

@implementation PointerModel

+(PointerModel*) initWithClass:(Class)c withId:(NSInteger)i {
    PointerModel *model = [[PointerModel alloc] init];
    model.pointerClass = NSStringFromClass(c);
    model.pointerId = i;
    return model;
}

/**
 *  MARK:--------------------public--------------------
 */
-(BOOL) isEqual:(id)object{//重写指针对比地址方法;
    if (object && [object isKindOfClass:[PointerModel class]]) {
        BOOL classIsEqual = [STRTOOK(self.pointerClass) isEqual:((PointerModel*)object).pointerClass];
        BOOL idIsEqual = self.pointerId == ((PointerModel*)object).pointerId;
        return classIsEqual && idIsEqual;
    }
    return true;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.pointerClass forKey:NSStringFromSelector(@selector(pointerClass))];
    [aCoder encodeInteger:self.pointerId forKey:NSStringFromSelector(@selector(pointerId))];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.pointerClass = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(pointerClass))];
        self.pointerId = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(pointerId))];
    }
    return self;
}

@end
