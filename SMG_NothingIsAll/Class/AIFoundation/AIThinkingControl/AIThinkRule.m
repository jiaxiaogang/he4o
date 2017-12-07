//
//  AIThinkRule.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIThinkRule.h"


@interface AIThinkRule()

@property (strong,nonatomic) id task;

@end

@implementation AIThinkRule

-(id) initWithTask:(id)task{
    self = [super init];
    if (self) {
        self.task = task;
        [self initRun];
    }
    return self;
}


-(void) initRun{
    
}


-(void) think{
    
}

-(void) imagination{
    
}

@end
