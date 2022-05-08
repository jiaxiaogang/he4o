//
//  TVTimeLine.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/29.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TVTimeLine.h"

#define MaxLineWidth 2.0f
#define MinLineWidth 0.2f

@interface TVTimeLine ()

@property (assign, nonatomic) CGFloat lineWidth;

@end

@implementation TVTimeLine

- (void)drawRect:(CGRect)rect {
    //1. 数据准备;
    [super drawRect:rect];
    self.bezierPoints = ARRTOOK(self.bezierPoints);
    [UIColor.greenColor set];
    
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
    
    //3. 绘制
    path.lineWidth = self.lineWidth > 0 ? self.lineWidth : MaxLineWidth;
    path.lineCapStyle = kCGLineCapRound; //终点处理
    path.lineJoinStyle = kCGLineJoinBevel; //线条拐角
    [path stroke];
}

-(void)setData:(CGFloat)scale{
    self.lineWidth = MAX(MinLineWidth, MIN(MaxLineWidth, 6.0f / scale));
    [self refreshDisplay];
}

-(void) refreshDisplay{
    [self setNeedsDisplay];
}

@end
