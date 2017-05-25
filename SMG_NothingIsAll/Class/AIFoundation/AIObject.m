//
//  AIObject.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

@implementation AIObject

+(void)initialize{
    [self removePropertyWithColumnName:@"pointer"];
}

+(id) initWithContent:(id)content{
    return [[AIObject alloc] init];
}

-(PointerModel*) pointer{
    if (_pointer == nil) {
        _pointer = [[PointerModel alloc] init];
        _pointer.pointerClass = NSStringFromClass(self.class);
        _pointer.pointerId = self.rowid;
    }
    return _pointer;
}

-(BOOL) isEqual:(id)obj{
    if (obj && [obj isKindOfClass:[AIObject class]]) {
        return [self.pointer isEqual:((AIObject*)obj).pointer];//对比指针地址
    }
    return false;
}

-(void) print{
    NSLog(@"%@",self);
}


@end
