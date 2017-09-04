//
//  AIFuncModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFuncModel.h"

@implementation AIFuncModel


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.funcClass = NSClassFromString([aDecoder decodeObjectForKey:@"funcClass"]);
        self.funcSel = NSSelectorFromString([aDecoder decodeObjectForKey:@"funcSel"]);
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:NSStringFromClass(self.funcClass) forKey:@"funcClass"];
    [aCoder encodeObject:NSStringFromSelector(self.funcSel) forKey:@"funcSel"];
}


@end
