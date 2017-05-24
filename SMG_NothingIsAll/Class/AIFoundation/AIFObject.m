//
//  AIFObject.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFObject.h"

@implementation AIFObject

+(void)initialize{
    [self removePropertyWithColumnName:@"pointer"];
}

+(id) initWithContent:(id)content{
    return [[AIFObject alloc] init];
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
    if (obj && [obj isKindOfClass:[AIFObject class]]) {
        return [self.pointer isEqual:((AIFObject*)obj).pointer];//对比指针地址
    }
    return false;
}

-(void) print{
    NSLog(@"%@",self);
}


@end
