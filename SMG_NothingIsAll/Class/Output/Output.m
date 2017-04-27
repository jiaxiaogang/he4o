//
//  Output.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Output.h"
#import "SMGHeader.h"

@implementation Output

-(void) output_Text:(NSString*)text{
    if (self.delegate && [self.delegate respondsToSelector:@selector(output_Text:)]) {
        [self.delegate output_Text:STRTOOK(text)];
    }
}

@end
