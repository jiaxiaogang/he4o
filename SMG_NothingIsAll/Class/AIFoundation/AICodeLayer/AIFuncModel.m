//
//  AIFuncModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFuncModel.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "RuntimeInvoker.h"

@implementation AIFuncModel

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    //在init时检查此神经元是否存于神经网络,若没有,则存;
}

//MARK:===============================================================
//MARK:                     < Method >
//MARK:===============================================================
/**
 *  MARK:--------------------参数类型--------------------
 */
-(Class) paramClass{
    return nil;
}


/**
 *  MARK:--------------------返回值类型--------------------
 */
-(Class) valueClass{
    return nil;
}


/**
 *  MARK:--------------------执行--------------------
 */
-(id) invoke:(id)arg,...{
    if (/*ISOK(param, self.paramClass)*/true) {
        //判断funcClass的返回值 & 参数 是否与paramClass和valueClass一致;
        if (self.funcClass != NULL && self.funcSel != NULL) {
            if (self.funcClass && self.funcSel) {
                NSUInteger length = [[self.funcClass invoke:NSStringFromSelector(self.funcSel) args:@"asDda",nil] unsignedIntegerValue];
                NSLog(@"");
            }
        }
    }
    return nil;
    
    
}

-(id) run:(NSArray*)args{
    if (self.funcClass != NULL && self.funcSel != NULL) {
        return [self.funcClass invoke:NSStringFromSelector(self.funcSel) arguments:args];
    }
    return nil;
}
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


//@property (assign, nonatomic) Class paramClass; //参数类型
//@property (assign, nonatomic) Class valueClass; //返回值类型
