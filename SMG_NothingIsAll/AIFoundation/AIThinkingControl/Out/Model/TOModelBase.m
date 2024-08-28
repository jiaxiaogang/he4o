//
//  TOModelBase.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/26.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"

@implementation TOModelBase

-(id) initWithContent_p:(AIKVPointer*)content_p{
    self = [super init];
    if (self) {
        self.content_p = content_p;
    }
    return self;
}

/**
 *  MARK:--------------------来源标识--------------------
 */
-(NSString *)selfIden{
    if (!_selfIden) {
        _selfIden = STRFORMAT(@"%p",self);
    }
    return _selfIden;
}

/**
 *  MARK:--------------------isEqual--------------------
 *  @version
 *      2022.03.19: content_p为空时,返回super.Equal(),因为Demand的content_p全是空的;
 *      2022.03.23: 改成用selfIden对比,因为它是初次内存唯一,content_p一致并不能说明一致;
 */
-(BOOL) isEqual:(TOModelBase*)object{
    return [self.selfIden isEqualToString:object.selfIden];
}

-(void)setStatus:(TOModelStatus)status{
    _status = status;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.content_p = [aDecoder decodeObjectForKey:@"content_p"];
        self.status = [aDecoder decodeIntegerForKey:@"status"];
        self.baseOrGroup = [aDecoder decodeObjectForKey:@"baseOrGroup"];
        self.selfIden = [aDecoder decodeObjectForKey:@"selfIden"];
        self.actYesed = [aDecoder decodeBoolForKey:@"actYesed"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content_p forKey:@"content_p"];
    [aCoder encodeInteger:self.status forKey:@"status"];
    [aCoder encodeObject:self.baseOrGroup forKey:@"baseOrGroup"];
    [aCoder encodeObject:self.selfIden forKey:@"selfIden"];
    [aCoder encodeBool:self.actYesed forKey:@"actYesed"];
}

@end
