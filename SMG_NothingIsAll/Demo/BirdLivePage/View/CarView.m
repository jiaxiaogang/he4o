//
//  CarView.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "CarView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "FoodView.h"

@interface CarView ()

@property (strong,nonatomic) IBOutlet UIView *containerView;

@end

@implementation CarView

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
    [self setFrame:CGRectMake(ScreenWidth * 0.5f - 50, 0, 50, 150)];
    [self setBackgroundColor:[UIColor clearColor]];
    self.tag = visibleTag;
    
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
    
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) run{
    if (self.delegate && [self.delegate respondsToSelector:@selector(carView_CanRun)]) {
        if ([self.delegate carView_CanRun]) {
            //1. 行驶
            [UIView animateWithDuration:2.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.x += ScreenWidth * 0.5f;
            } completion:^(BOOL finished) {
                self.x = -50;
                [UIView animateWithDuration:2.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    self.x += ScreenWidth * 0.5f;
                } completion:^(BOOL finished) {
                    [self run];
                }];
            }];
            
            //2. 碾压
            if ([self.delegate respondsToSelector:@selector(carView_GetFoodInLoad)]) {
                NSArray *foods = [self.delegate carView_GetFoodInLoad];
                if (ARRISOK(foods)) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        for (FoodView *food in foods) {
                            [food hit];
                        }
                    });
                }
            }
        }
    }
}

@end

