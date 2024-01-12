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
 */
@interface TOMVisionNodeBase : UIView

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UILabel *headerLab;
@property (strong, nonatomic) UIView *statusView;

-(void) initView;
-(void) initData;
-(void) initDisplay;
-(void) refreshDisplay;
-(void) setData:(TOModelBase*)value;
-(TOModelBase *)data;
-(BOOL) isEqualByData:(TOModelBase*)checkData;
-(void) scaleContainer:(CGFloat)scale;
-(NSString*) getNodeDesc;

@end
