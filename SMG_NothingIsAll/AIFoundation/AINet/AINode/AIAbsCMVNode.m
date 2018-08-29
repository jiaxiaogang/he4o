//
//  AIAbsCMVNode.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAbsCMVNode.h"
#import "AIPort.h"
#import "AIPointer.h"

//MARK:===============================================================
//MARK:                     < AIAbsCMVNode >
//MARK:===============================================================
@interface AIAbsCMVNode()

@property (strong, nonatomic) NSMutableArray *conPorts; //具象方向端口;

@end

@implementation AIAbsCMVNode

- (NSMutableArray *)conPorts{
    if (_conPorts == nil) {
        _conPorts = [NSMutableArray new];
    }
    return _conPorts;
}

/**
 *  MARK:--------------------添加具象关联--------------------
 *  注:从大到小(5,4,3,2,1)
 */
-(void) addConPorts:(AIPort*)conPort{
    //1. 数据检查
    if (conPort == nil) {
        return;
    }
    
    //2. 去重
    for (NSInteger i = 0; i < self.conPorts.count; i++) {
        AIPort *checkPort = self.conPorts[i];
        if (checkPort.target_p) {
            if ([checkPort.target_p isEqual:conPort.target_p]) {
                [self.conPorts removeObjectAtIndex:i];
                break;
            }
        }
    }
    
    //3. 插入合适位置
    BOOL find = false;
    for (NSInteger i = 0; i < self.conPorts.count; i++) {
        AIPort *checkPort = self.conPorts[i];
        if (checkPort.strong.value < conPort.strong.value) {
            [self.conPorts insertObject:conPort atIndex:i];
            find = true;
            break;
        }
    }
    if (!find) {
        [self.conPorts addObject:conPort];
    }
}

-(AIPort*) getConPort:(NSInteger)index{
    return ARR_INDEX(self.conPorts, index);
}


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.urgentTo_p = [aDecoder decodeObjectForKey:@"urgentTo_p"];
        self.delta_p = [aDecoder decodeObjectForKey:@"delta_p"];
        self.conPorts = [aDecoder decodeObjectForKey:@"conPorts"];
        self.absNode_p = [aDecoder decodeObjectForKey:@"absNode_p"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.urgentTo_p forKey:@"urgentTo_p"];
    [aCoder encodeObject:self.delta_p forKey:@"delta_p"];
    [aCoder encodeObject:self.conPorts forKey:@"conPorts"];
    [aCoder encodeObject:self.absNode_p forKey:@"absNode_p"];
}

@end
