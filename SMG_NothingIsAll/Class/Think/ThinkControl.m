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
-(void) commitDemand:(id)demand withType:(MindType)type{
    NSLog(@"提交需求...To...Think");
    [self.decision commitDemand:demand withType:type];
}

-(void) commitUnderstandByShallow:(id)data{
    NSLog(@"浅理解");
    AIPointer *pointer = [self.understand commitOutAttention:data];
    //问mind有没意见
    int moodValue = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(thinkControl_GetMoodValue:)]) {
        moodValue = [self.delegate thinkControl_GetMoodValue:pointer];
    }
    //2,将mind的意见记到logic和law里;
    //1,判断是否无聊;
    //2,判断是否需要注意力;
    //3,作为火花塞点燃mind;
    //xxx
}

-(void) commitUnderstandByDeep:(id)data{
    NSLog(@"深理解");
}

@end
