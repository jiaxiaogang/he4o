//
//  TOMVisionNodeBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/16.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  MARK:--------------------nodeView--------------------
 *  @version
 *      2022.03.20: 将containerView由Constraints改成重写frame (因为nodeView要缩放就不能用autoLayout);
 *  @todo
 *      2022.03.19: 将nodeView下显示出pointerId;
 */
@interface TOMVisionNodeBase : UIView

-(void) initView;
-(void) initData;
-(void) initDisplay;
-(void) refreshDisplay;

-(void) setData:(TOModelBase*)value;
-(TOModelBase *)data;
-(BOOL) isEqualByData:(TOModelBase*)checkData;
-(void) scaleContainer:(CGFloat)scale;

@end
