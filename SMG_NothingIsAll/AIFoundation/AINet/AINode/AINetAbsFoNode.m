//
//  AINetAbsFoNode.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbsFoNode.h"
#import "XGRedisUtil.h"
#import "AIPort.h"
#import "AIKVPointer.h"
#import "AIFrontOrderNode.h"

@implementation AINetAbsFoNode


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

-(NSMutableArray *)conPorts{
    if (_conPorts == nil) {
        _conPorts = [[NSMutableArray alloc] init];
    }
    return _conPorts;
}

//废弃此方法,按强度排序
//-(void) addConPort:(AIPort*)conPort{
//    if (ISOK(conPort, AIPort.class) && ISOK(conPort.target_p, AIKVPointer.class)) {
//        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
//            AIPort *checkPort = ARR_INDEX(self.conPorts, checkIndex);
//            return [SMGUtils comparePointerA:conPort.target_p pointerB:checkPort.target_p];
//        } startIndex:0 endIndex:self.conPorts.count success:^(NSInteger index) {
//            //省略
//        } failure:^(NSInteger index) {
//            //省略
//        }];
//    }
//}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.conPorts = [aDecoder decodeObjectForKey:@"conPorts"];
        self.absValue_p = [aDecoder decodeObjectForKey:@"absValue_p"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.conPorts forKey:@"conPorts"];
    [aCoder encodeObject:self.absValue_p forKey:@"absValue_p"];
}

@end
