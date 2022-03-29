//
//  TVContentView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/29.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TVContentView.h"

@implementation TVContentView

- (void)drawRect:(CGRect)rect {
    //1. 数据准备;
    [super drawRect:rect];
    self.bezierPoints = ARRTOOK(self.bezierPoints);
    [UIColor.redColor set];
    
    //2. 生成贝塞尔曲线
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (NSInteger i = 0; i < self.bezierPoints.count; i++) {
        NSValue *item = self.bezierPoints[i];
        CGPoint point = [item CGPointValue];
        if (i == 0) {
            [path moveToPoint:point];
        }else{
            [path addLineToPoint:point];
        }
    }
    
    //3. 绘制
    path.lineWidth = 2.0;
    path.lineCapStyle = kCGLineCapRound; //终点处理
    path.lineJoinStyle = kCGLineJoinBevel; //线条拐角
    [path stroke];
}

@end
