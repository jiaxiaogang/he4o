//
//  HSBColor.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/28.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "HSBColor.h"

@implementation HSBColor

-(id) init {
    self = [super init];
    if (self) {
        self.h = 0.1f;//默认色相
        self.s = 0.5f;//默认饱和
        self.b = 0.8f;//默认亮度
    }
    return self;
}

-(void) setData:(NSString*)ds value:(CGFloat)value {
    if ([@"hColors" isEqualToString:ds]) {
        self.h = value;
    } else if ([@"sColors" isEqualToString:ds]) {
        self.s = value;
    } else if ([@"bColors" isEqualToString:ds]) {
        self.b = value;
    }
}

-(UIColor*) getColor {
    return UIColorWithHSB(self.h, self.s, self.b);
}

@end
