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
#import "AIReactorControl.h"

#define EAT_RDS @"eatReactorDataSource" //吸吮反射标识

@interface BirdView ()

@property (strong,nonatomic) IBOutlet UIView *containerView;

@end

@implementation BirdView

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
        [self initDisplay];
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

-(void) initDisplay{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputObserver:) name:kOutputObserver object:nil];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

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

-(void) touchMouth{
    //代码思路...
    //1) 刺激引发he反射;
    //2) 反射后开吃 (he主动调用eat());
    //3) eat()中, 销毁food,并将产生的mv传回给he;
    
    //代码实践...
    //1) 定义一个"反射标识";
    //2) 在output中,写eat()的调用; (参考outputText())
    //3) "反射码"可被canOut判定true,并指向output.eat();
    
    [[AIReactorControl shareInstance] commitReactor:EAT_RDS];
}

-(void) dropUp{
    
}

-(void) dropDown{
    
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) eat{
    if (self.delegate && [self.delegate respondsToSelector:@selector(birdView_GetFoodOnMouth)]) {
        //1. 嘴附近的食物
        FoodView *foodView = [self.delegate birdView_GetFoodOnMouth];
        if (!foodView) return;
        
        //2. 视觉输入
        [self see:foodView];
        
        //3. 吃掉 (让he以吸吮反射的方式,去主动吃;并将out入网,以抽象出"吃"的节点;参考n15p6-QT1)
        [foodView removeFromSuperview];
        
        //4. 产生HungerMindValue; (0-10)
        [theInput commitIMV:MVType_Hunger from:1.0f to:9.0f];
    }
    
    
    
}

//MARK:===============================================================
//MARK:                     < outputObserver >
//MARK:===============================================================
-(void) outputObserver:(NSNotification*)notification{
    if (notification) {
        //1. 取数据
        NSDictionary *obj = DICTOOK(notification.object);
        NSString *rds = STRTOOK([obj objectForKey:@"rds"]);
        NSNumber *paramNum = NUMTOOK([obj objectForKey:@"paramNum"]);
        
        //2. 吸吮反射
        if ([EAT_RDS isEqualToString:rds]) {
            [self eat];
        }
        
        
    }
}

@end

