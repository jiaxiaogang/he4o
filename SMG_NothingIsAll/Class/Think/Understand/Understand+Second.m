//
//  Understand+Second.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Understand+Second.h"

@implementation Understand (Second)

-(AIPointer*) commitOutAttention:(id)data{
    NSLog(@"无意分析");
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
        return law.pointer;
    }
    return nil;
}

-(void) commitInAttension:(id)data{
    NSLog(@"有意分析");
}

-(void) commitInDream:(id)data{
    NSLog(@"梦境整理分析");
}

@end
