//
//  BorderLabel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/8/7.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "BorderLabel.h"

@implementation BorderLabel

-(void)drawTextInRect:(CGRect)rect {
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, _borderWidth);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = _borderColor;
    [super drawTextInRect:rect];
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    self.shadowOffset = shadowOffset;
}

@end
