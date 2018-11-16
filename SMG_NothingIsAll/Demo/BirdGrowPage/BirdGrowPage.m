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
@property (strong,nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (weak, nonatomic) IBOutlet UIView *farView;
@property (weak, nonatomic) IBOutlet UIView *borderView;

@end

@implementation BirdGrowPage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void) initView{
    //1. self
    self.title = @"小鸟成长演示";
    
    //2. birdView
    self.birdView = [[BirdView alloc] init];
    [self.view addSubview:self.birdView];
    
    //3. farTapRecognizer
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(customTapAction:)];
    [self.farView addGestureRecognizer:self.tapRecognizer];
    self.tapRecognizer.delegate = self;
    
    //4. borderView
    [self.borderView.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.borderView.layer setBorderWidth:30];
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)nearFeedingBtnOnClick:(id)sender {
    FoodView *foodView = [[FoodView alloc] init];
    [foodView hit];
    [foodView setOrigin:CGPointMake(ScreenWidth * 0.75f, ScreenHeight - 66)];
    [self.view addSubview:foodView];
    CGPoint targetPoint = self.birdView.center;
    [UIView animateWithDuration:1.5f animations:^{
        [foodView setOrigin:targetPoint];
    }completion:^(BOOL finished) {
        //1. 视觉输入
        [theInput commitView:self.birdView targetView:foodView];
        
        //2. 吃掉;
        [theInput commitIMV:MVType_Hunger from:1.0f to:9.0f];
    }];
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
- (void)customTapAction:(UITapGestureRecognizer *)tapRecognizer{
    UIView *tapView = tapRecognizer.view;
    CGPoint point = [tapRecognizer locationInView:tapView];
    CGFloat xRate = point.x / tapView.width;
    CGFloat yRate = point.y / tapView.height;
    CGFloat targetX = 30 + (ScreenWidth - 60) * xRate;
    CGFloat targetY = 94 + (ScreenHeight - 60 - 128) * yRate;
    NSLog(@"远投:%f,%f",xRate,yRate);
    
    FoodView *foodView = [[FoodView alloc] init];
    [foodView hit];
    [foodView setOrigin:CGPointMake(ScreenWidth * 0.25f, ScreenHeight - 66)];
    [self.view addSubview:foodView];
    CGPoint targetPoint = CGPointMake(targetX, targetY);
    
    [UIView animateWithDuration:1.0f animations:^{
        [foodView setOrigin:targetPoint];
    }completion:^(BOOL finished) {
        //1. 视觉输入
        
    }];
}

@end
