//
//  BirdView.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/7.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "BirdView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "FoodView.h"

@interface BirdView ()

@property (strong,nonatomic) IBOutlet UIView *containerView;

@end

@implementation BirdView

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
    }
    return self;
}

-(void) initView{
    //self
    [self setBackgroundColor:[UIColor clearColor]];
    [self setFrame:CGRectMake(100, 100, 30, 30)];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
}

-(void) fly:(CGFloat)x y:(CGFloat)y{
    [self setX:self.x + x];
    [self setY:self.y + y];
}

//视觉
-(void) see:(UIView*)view{
    //1. 将坚果,的一些信息输入大脑;
    [theInput commitView:self targetView:view];
}

//吃(坚果)
-(void) eat:(FoodView*)foodView{
    if (foodView) {
        //1. 吃掉
        [foodView removeFromSuperview];
        
        //2. 产生HungerMindValue; (0-10)
        [theInput commitIMV:MVType_Hunger from:1.0f to:9.0f];
    }
}

-(void) dropUp{
    
}

-(void) dropDown{
    
}

@end

