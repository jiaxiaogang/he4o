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

//-(NSMutableArray *)absPorts:(BOOL)saveDB{
//    if (saveDB) {
//        return [self absPorts];
//    }else{
//        return [[NSMutableArray alloc] initWithArray:ARRISOK([SMGUtils searchObjectForPointer:self.pointer fileName:FILENAME_MemAbsPorts])];
//    }
//}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.absPorts = [aDecoder decodeObjectForKey:@"absPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.absPorts forKey:@"absPorts"];
}

@end
