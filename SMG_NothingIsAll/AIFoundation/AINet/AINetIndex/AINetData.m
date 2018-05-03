//
//  AINetData.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/3.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetData.h"
#import "AIPort.h"

@implementation AINetData

@end


//MARK:===============================================================
//MARK:                     < itemDataModel (一条数据) >
//MARK:===============================================================
@implementation AINetDataModel : NSObject

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.value = [aDecoder decodeObjectForKey:@"value"];
        self.ports = [aDecoder decodeObjectForKey:@"ports"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.ports forKey:@"ports"];
}

@end
