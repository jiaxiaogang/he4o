//
//  BirdGrowPage.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/13.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "BirdGrowPage.h"
#import "BirdView.h"
#import "FoodView.h"

@interface BirdGrowPage ()

@property (strong,nonatomic) BirdView *birdView;

@end

@implementation BirdGrowPage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void) initView{
    //birdView
    self.birdView = [[BirdView alloc] init];
    [self.view addSubview:self.birdView];
}

- (IBAction)farFeedingBtnOnClick:(id)sender {
    FoodView *foodView = [[FoodView alloc] init];
    [foodView hit];
    [foodView setOrigin:CGPointMake(ScreenWidth * 0.75f, ScreenHeight - 66)];
    [self.view addSubview:foodView];
    CGPoint targetPoint = self.birdView.origin;
    [UIView animateWithDuration:1.0f animations:^{
        [foodView setOrigin:targetPoint];
    }];
}

- (IBAction)nearFeedingBtnOnClick:(id)sender {
    
}


@end
