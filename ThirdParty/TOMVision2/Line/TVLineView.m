//
//  TVLineView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/21.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TVLineView.h"
#import "NVConfig.h"
#import "NVViewUtil.h"

@interface TVLineView ()

@property (strong,nonatomic) UIView *lineView;

@end

@implementation TVLineView

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
        [self initData];
        [self initDisplay];
    }
    return self;
}

-(void) initView{
    //self
    [self setBackgroundColor:[UIColor clearColor]];
    self.height = 1.0f;
    [self setUserInteractionEnabled:false];
    [self.layer setMasksToBounds:true];
    [self.layer setMasksToBounds:false];
    
    //lineView
    self.lineView = [[UIView alloc] init];
    [self.lineView setBackgroundColor:UIColorWithRGBHex(0xDDDDDD)];
    [self addSubview:self.lineView];
    [self.lineView setAlpha:0.8f];
    [self.lineView.layer setMasksToBounds:false];
}

-(void) initData{
}

-(void) initDisplay{
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) refreshDisplayWithDataA:(UIView*)nodeA nodeB:(UIView*)nodeB{
    //1. 获取两端的坐标
    CGPoint pointA = nodeA.center;
    CGPoint pointB = nodeB.center;
    //pointA = [nodeA.superview convertPoint:nodeA.center toView:self.contentView];
    
    //2. 画线_计算线长度
    float width = [NVViewUtil distancePoint:pointA second:pointB];
    
    //3. 计算线中心位置
    float centerX = (pointA.x + pointB.x) / 2.0f;
    float centerY = (pointA.y + pointB.y) / 2.0f;
    
    //4. 旋转角度
    CGFloat angle = [NVViewUtil anglePIPoint:pointA second:pointB];
    
    //5. 线框长度;
    [self.layer setTransform:CATransform3DMakeRotation(0, 0, 0, 1)];
    self.width = width;
    self.height = (nodeA.height + nodeB.height) * 0.05f;
    
    //6. 线显示长度;
    [self.lineView setFrame:CGRectMake(0, 0, self.width, self.height)];
    
    //7. 旋转指向方向;
    [self.layer setTransform:CATransform3DMakeRotation(angle, 0, 0, 1)];
    self.center = CGPointMake(centerX, centerY);
}

@end
