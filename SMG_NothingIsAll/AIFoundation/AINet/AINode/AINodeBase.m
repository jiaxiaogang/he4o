//
//  AINodeBase.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINodeBase.h"
#import "AIKVPointer.h"

@implementation AINodeBase

-(NSMutableArray *)absPorts{
    if (!ISOK(_absPorts, NSMutableArray.class)) {
        _absPorts = [[NSMutableArray alloc] initWithArray:_absPorts];
    }
    return _absPorts;
}

-(NSMutableArray *)content_ps{
    if (_content_ps == nil) {
        _content_ps = [[NSMutableArray alloc] init];
    }
    return _content_ps;
}

-(NSInteger) count{
    return self.content_ps.count;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.absPorts = [aDecoder decodeObjectForKey:@"absPorts"];
        self.content_ps = [aDecoder decodeObjectForKey:@"content_ps"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:[self.absPorts copy] forKey:@"absPorts"];
    [aCoder encodeObject:self.content_ps forKey:@"content_ps"];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
-(BOOL)isEqual:(AINodeBase*)object{
    return [self.pointer isEqual:object.pointer];
}

@end
