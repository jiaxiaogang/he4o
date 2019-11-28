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

-(void) fly:(CGFloat)value{
    value = MAX(MIN(1, value), 0);
    value = value * 2 - 1;
    CGFloat angle = value * M_PI;
    //以右为0度,逆时针为负,顺时针为正;
    //对边Y,邻边X
    NSLog(@"fly >> y:%f x:%f angle:%f",sin(angle),cos(angle),value * 180);
    [self setX:self.x + (cos(angle) * 10.0f)];
    [self setY:self.y + (sin(angle) * 10.0f)];
}

-(void) see:(UIView*)view{
    if (self.delegate && [self.delegate respondsToSelector:@selector(birdView_GetSeeRect)]) {
        //1. 将视觉范围下,的视觉信息输入大脑;
        CGRect rect = [self.delegate birdView_GetSeeRect];
        [AIInput commitView:self targetView:view rect:rect];
    }
}

//被动吃
-(void) touchMouth{
    //1. 吃前视觉
    //[self see:[self.delegate birdView_GetPageView]];
    
    //2. 吃
    [AIReactorControl commitReactor:EAT_RDS];
    
    //3. 吃完视觉
    //[self see:[self.delegate birdView_GetPageView]];
    
    //4. 产生HungerMindValue; (0-10)
    //[AIInput commitIMV:MVType_Hunger from:1.0f to:9.0f];
}

-(void) touchWing{
    //1. 飞前视觉
    [self see:[self.delegate birdView_GetPageView]];
    
    //2. 飞行
    float random = (arc4random() % 8) / 8.0f;
    [AIReactorControl commitReactor:FLY_RDS datas:@[@(random)]];
    
    //3. 飞后视觉
    [self see:[self.delegate birdView_GetPageView]];
}

-(void) dropUp{
    
}

-(void) dropDown{
    
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//无论是主动吃,还是被动吃,都要观察下吃前的视觉,吃后的视觉,以及价值上的影响;
-(void) eat:(CGFloat)value{
    //1. 吃前视觉
    [self see:[self.delegate birdView_GetPageView]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(birdView_GetFoodOnMouth)]) {
        //1. 嘴附近的食物
        FoodView *foodView = [self.delegate birdView_GetFoodOnMouth];
        if (!foodView) return;
        
        //2. 吃掉 (让he以吸吮反射的方式,去主动吃;并将out入网,以抽象出"吃"的节点;参考n15p6-QT1)
        if (foodView.status == FoodStatus_Eat) {
            [foodView removeFromSuperview];
            
            //3. 吃完视觉
            [self see:[self.delegate birdView_GetPageView]];
            
            //4. 产生HungerMindValue;
            [AIInput commitIMV:MVType_Hunger from:1.0f to:9.0f];
        }else if(foodView.status == FoodStatus_Border){
            //坚果带皮时,不仅吃不到,还得嘴疼;
            //3. 吃完视觉
            [self see:[self.delegate birdView_GetPageView]];
            
            //4. 产生HurtMindValue;
            [AIInput commitIMV:MVType_Hurt from:9.0f to:1.0f];
        }
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
        
        //2. 吸吮反射 / 主动吃
        if ([EAT_RDS isEqualToString:rds]) {
            [self eat:[paramNum floatValue]];
        }
        //3. 扇翅膀反射
        else if([FLY_RDS isEqualToString:rds]){
            [self fly:[paramNum floatValue]];
        }
        //4. 焦急反射
        else if([ANXIOUS_RDS isEqualToString:rds]){
            //1. 小鸟焦急时_扇翅膀;
            //[self see:[self.delegate birdView_GetPageView]];
            //CGFloat data = (arc4random() % 8) / 8.0f;
            //[AIReactorControl commitReactor:FLY_RDS datas:@[@(data)]];
            
            //2. 190731由飞改为叫;
            [theApp setTipLog:@"叽叽喳喳叫一叫"];
        }
    }
}

@end

