//
//  RoadView.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "RoadView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "LightView.h"
#import "CarView.h"

@interface RoadView ()<CarViewDelegate,LightViewDelegate>

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (strong,nonatomic) LightView *lightView;
@property (strong,nonatomic) CarView *carView;

@end

@implementation RoadView

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
    //1. self
    [self setFrame:CGRectMake(0, ScreenHeight - 200, ScreenWidth, 150)];
    [self setBackgroundColor:[UIColor clearColor]];
    self.tag = visibleTag;
    
    //2. containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    
    //3. carView
    self.carView = [[CarView alloc] init];
    [self addSubview:self.carView];
    self.carView.delegate = self;
    
    //4. lightView
    self.lightView = [[LightView alloc] init];
    [self addSubview:self.lightView];
    self.lightView.delegate = self;
}

-(void) initData{
    
}

-(void) initDisplay{
    [self refreshDisplay];
    [self.carView run];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) refreshDisplay{
    
}

/**
 *  MARK:--------------------CarViewDelegate--------------------
 */
- (BOOL)carView_CanRun{
    return self.lightView.curLightIsGreen;
}

-(NSArray*) carView_GetFoodInLoad{
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    if (self.delegate && [self.delegate respondsToSelector:@selector(roadView_GetFoodInLoad)]) {
        NSArray *foods = ARRTOOK([self.delegate roadView_GetFoodInLoad]);
        for (UIView *food in foods) {
            if (food.y >= 200 && food.y <= 345) {
                [mArr addObject:food];
            }
        }
    }
    return mArr;
}

/**
 *  MARK:--------------------LightViewDelegate--------------------
 */
- (void)lightView_ChangeToGreen{
    [self.carView run];
}

@end
