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
            
            //a. 前一点
            CGPoint startPt = [[self.bezierPoints objectAtIndex: i-1] CGPointValue];
            
            //b. 控制点
            CGPoint cPt1, cPt2;
            if(ABS(startPt.x - point.x) > ABS(startPt.y - point.y)) {
                cPt1 = (CGPoint){(startPt.x + point.x)/2, startPt.y};
                cPt2 = (CGPoint){cPt1.x, point.y};
            } else {
                cPt1 = (CGPoint){startPt.x, (startPt.y + point.y)/2};
                cPt2 = (CGPoint){point.x, cPt1.y};
            }
            
            //3. 添加曲线点
            [path addCurveToPoint:point controlPoint1:cPt1 controlPoint2:cPt2];
        }
    }
    
    //TODOTOMORROW20220330:
    //1. 此处在缩放时,未自动更新;
    //2. 在出屏范围的可能绘制不到;
    //3. 建议查下当contentView.frame改变时,自动重绘的那个方法叫什么调用一下;
    
    
    
    
    //3. 绘制
    path.lineWidth = 2.0;
    path.lineCapStyle = kCGLineCapRound; //终点处理
    path.lineJoinStyle = kCGLineJoinBevel; //线条拐角
    [path stroke];
}

@end
