//
//  AIFuncModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFuncModel.h"

@implementation AIFuncModel


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
-(id) run:(id)param{
    if (ISOK(param, self.paramClass)) {
        //判断funcClass的返回值 & 参数 是否与paramClass和valueClass一致;
        if (self.funcClass) {
            
        }
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
