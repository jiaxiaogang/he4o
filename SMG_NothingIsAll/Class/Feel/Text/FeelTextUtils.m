//
//  FeelTextUtils.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/1.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "FeelTextUtils.h"

@implementation FeelTextUtils

+(NSInteger) getLength:(NSString*)text{
    if (STRISOK(text)) {
        return text.length;
    }
    return 0;
}

@end
