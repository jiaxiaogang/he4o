//
//  AIGroupValueNode.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/18.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIGroupValueNode.h"

@implementation AIGroupValueNode

-(NSArray *)xs {
    if (!_xs) _xs = [NSArray new];
    return _xs;
}
-(NSArray *)ys {
    if (!_ys) _ys = [NSArray new];
    return _ys;
}

//内容的md5值，特征以content_ps和level,x,y共同生成。
-(NSString*) getHeaderNotNull {
    if (!STRISOK(self.header)) self.header = [AINetUtils getGroupValueNodeHeader:self.content_ps xs:self.xs ys:self.ys];
    return self.header;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.xs = [aDecoder decodeObjectForKey:@"xs"];
        self.ys = [aDecoder decodeObjectForKey:@"ys"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.xs forKey:@"xs"];
    [aCoder encodeObject:self.ys forKey:@"ys"];
}

@end
