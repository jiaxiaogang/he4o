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
    if (_absPorts == nil) {
        _absPorts = [NSMutableArray new];
    }
    return _absPorts;
}

-(NSMutableArray *)absPorts_All{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObjectsFromArray:self.absPorts];
    [result addObjectsFromArray:ARRTOOK([SMGUtils searchObjectForPointer:self.pointer fileName:kFNMemAbsPorts time:cRTMemPort])];
    return result;
}

-(NSMutableArray *)content_ps{
    if (_content_ps == nil) {
        _content_ps = [[NSMutableArray alloc] init];
    }
    return _content_ps;
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
    [aCoder encodeObject:self.absPorts forKey:@"absPorts"];
    [aCoder encodeObject:self.content_ps forKey:@"content_ps"];
}

@end
