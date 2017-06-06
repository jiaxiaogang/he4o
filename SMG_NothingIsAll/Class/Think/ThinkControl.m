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
    //1,字符串时
    if (data && [data isKindOfClass:[NSString class]]) {
        //收集charArr
        NSString *str = (NSString*)data;
        NSMutableArray *charArr = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < str.length; i++) {
            AIChar *c = AIMakeChar([str characterAtIndex:i]);
            [charArr addObject:c];
        }
        //记录规律
        AILaw *law = AIMakeLawByArr(charArr);
        //问mind有没意见
        int moodValue = 0;
        if (self.delegate && [self.delegate respondsToSelector:@selector(thinkControl_GetMoodValue:)]) {
            moodValue = [self.delegate thinkControl_GetMoodValue:law.pointer];
        }
    }
}

-(void) commitUnderstandByDeep:(id)data{
    NSLog(@"深理解");
}

@end
