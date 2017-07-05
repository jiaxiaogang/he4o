//
//  ThinkControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "ThinkControl.h"
#import "ThinkHeader.h"

@interface ThinkControl ()<UnderstandDelegate>
@end

@implementation ThinkControl

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
        [self initRun];
    }
    return self;
}

-(void) initData{
    self.understand = [[Understand alloc] init];
    self.decision = [[Decision alloc] init];
}

-(void) initRun{
    self.understand.delegata = self;
}

/**
 *  MARK:--------------------method--------------------
 */
-(void) commitDecisionByDemand:(id)demand withType:(MindType)type{
    //权衡当前的Task;并以mindValue来决定是否执行;
    if (type == MindType_Hunger) {
        CGFloat mindValueDelta = [NUMTOOK(demand) floatValue];
        BOOL win = true;//实现插队;self.taskArr
        if (win) {
            [self.decision commitDemand:demand withType:type];
        }
    }
}

-(void) commitUnderstandByShallow:(id)data{
    NSLog(@"浅理解");
    id understandValue = [self.understand commitOutAttention:data];//返回理解的结果;
    
}

-(void) commitUnderstandByDeep:(id)data{
    NSLog(@"深理解");
}

/**
 *  MARK:--------------------UnderstandDelegate--------------------
 */
-(id)understand_GetMindValue:(AIPointer *)pointer{
    //让SMG转交给mindControl;
    if (self.delegate && [self.delegate respondsToSelector:@selector(thinkControl_GetMindValue:)]) {
        return [self.delegate thinkControl_GetMindValue:pointer];
    }
    return nil;
}

@end
