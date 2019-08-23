//
//  TreeView.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "TreeView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "FoodView.h"

@interface TreeView ()

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (strong,nonatomic) NSTimer *timer;            //计时器(3s)
@property (assign,nonatomic) CGFloat dropY;             //果实掉落位置(75,125,175,225,275)

@end

@implementation TreeView

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
    [self setFrame:CGRectMake((ScreenWidth * 0.5f - 100) / 2 + ScreenWidth * 0.5f, 64, 100, 50)];
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
    [self.containerView.layer setCornerRadius:15];
    [self.containerView.layer setMasksToBounds:true];
}

-(void) initData{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
    self.dropY = 75;
}

-(void) initDisplay{
    [self refreshDisplay];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) refreshDisplay{
    
}

- (void)notificationTimer{
    //掉落果实 (3s掉一个)
    FoodView *foodView = [[FoodView alloc] init];
    foodView.x = 50 - 2.5f;
    self.dropY += 50;
    if (self.dropY > 275) {
        self.dropY = 75;
    }
    [self addSubview:foodView];
    [UIView animateWithDuration:self.dropY / 275.0f animations:^{
        foodView.y = self.dropY;
    }];
}

@end

