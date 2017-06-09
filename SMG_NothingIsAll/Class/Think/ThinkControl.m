//
//  ThinkControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "ThinkControl.h"
#import "ThinkHeader.h"

@interface ThinkControl ()



@end

@implementation ThinkControl

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.understand = [[Understand alloc] init];
    self.decision = [[Decision alloc] init];
}

/**
 *  MARK:--------------------method--------------------
 */
-(void) commitDecisionByDemand:(id)demand withType:(MindType)type{
    NSLog(@"提交需求...To...Think");
    [self.decision commitDemand:demand withType:type];
}

-(void) commitUnderstandByShallow:(id)data{
    NSLog(@"浅理解");
    AIPointer *pointer = [self.understand commitOutAttention:data];
    //让SMG转交给mindControl;
    if (self.delegate && [self.delegate respondsToSelector:@selector(thinkControl_CommitOutAttention:)]) {
        [self.delegate thinkControl_CommitOutAttention:pointer];
    }
}

-(void) commitUnderstandByDeep:(id)data{
    NSLog(@"深理解");
}

@end
