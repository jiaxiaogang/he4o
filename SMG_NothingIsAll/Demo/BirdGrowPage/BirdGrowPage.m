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

@interface BirdGrowPage ()<UIGestureRecognizerDelegate>

@property (strong,nonatomic) BirdView *birdView;
@property (strong,nonatomic) UITapGestureRecognizer *farTapRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *farLab;

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
    
    //farTapRecognizer
    self.farTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(farTapAction:)];
    [self.farLab addGestureRecognizer:self.farTapRecognizer];
    self.farTapRecognizer.delegate = self;
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)farFeedingBtnOnClick:(id)sender {
    FoodView *foodView = [[FoodView alloc] init];
    [foodView hit];
    [foodView setOrigin:CGPointMake(ScreenWidth * 0.25f, ScreenHeight - 66)];
    [self.view addSubview:foodView];
    CGPoint targetPoint = CGPointMake(ScreenWidth * 0.5f, ScreenHeight * 0.5f);
    [UIView animateWithDuration:1.0f animations:^{
        [foodView setOrigin:targetPoint];
    }];
}

- (IBAction)nearFeedingBtnOnClick:(id)sender {
    FoodView *foodView = [[FoodView alloc] init];
    [foodView hit];
    [foodView setOrigin:CGPointMake(ScreenWidth * 0.75f, ScreenHeight - 66)];
    [self.view addSubview:foodView];
    CGPoint targetPoint = self.birdView.center;
    [UIView animateWithDuration:2.0f animations:^{
        [foodView setOrigin:targetPoint];
    }completion:^(BOOL finished) {
        //1. 视觉输入
        
        
        //2. 吃掉;
        [theInput commitIMV:MVType_Hunger from:1.0f to:9.0f];
    }];
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
- (void)farTapAction:(UITapGestureRecognizer *)tapRecognizer{
    NSLog(@"远投");
    //CGPoint point = [tapRecognizer locationInView:tapRecognizer.view];
}

@end
