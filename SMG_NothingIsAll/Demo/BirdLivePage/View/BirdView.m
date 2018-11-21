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


/**
 *  MARK:--------------------视觉--------------------
 *  1. 目前是被动视觉,
 *  2. 随后有需要可以改为主动视觉 (0.3s每桢)
 *  3. 主动视觉可以采用计时器和代理scan来实现;
 */
-(void) see:(UIView*)view{
    //1. 将坚果,的一些信息输入大脑;
    [theInput commitView:self targetView:view];
}

//吃(坚果)
-(void) eat:(FoodView*)foodView{
    if (foodView) {
        //1. 吃掉 (让he以吸吮反射的方式,去主动吃;并将out入网,以抽象出"吃"的节点;参考n15p6-QT1)
        [foodView removeFromSuperview];
        //1) 刺激引发he反射;
        //2) 反射后开吃 (he主动调用eat());
        //3) eat()中, 销毁food,并将产生的mv传回给he;
        
        
        
        
        //2. 产生HungerMindValue; (0-10)
        [theInput commitIMV:MVType_Hunger from:1.0f to:9.0f];
    }
}

-(void) dropUp{
    
}

-(void) dropDown{
    
}

@end

