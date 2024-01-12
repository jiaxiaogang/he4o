//
//  TVTimeLine.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/29.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  MARK:--------------------树生长时间线--------------------
 */
@interface TVTimeLine : UIView

/**
 *  MARK:--------------------曲线流程 List<NSValue(CGPoint)>--------------------
 *  @desc 用于绘制"树"生长时间线;
 */
@property (strong, nonatomic) NSArray *bezierPoints;
-(void)setData:(CGFloat)scale;

@end
