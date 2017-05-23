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

-(void) print{
    NSLog(@"%@",self);
}


@end
