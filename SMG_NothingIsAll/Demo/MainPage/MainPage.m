//
//  MainPage.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/10/24.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "MainPage.h"
#import "TestHungryPage.h"
#import "BirdLivePage.h"
#import "BirdGrowPage.h"

@interface MainPage()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *miniGrowView;

@end

@implementation MainPage

-(void) initView{
    //1. self
    [super initView];
    self.title = @"和";
    
    //2. 触摸指定扔的位置
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(miniGrowTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired  = 1;
    tap.delegate = self;
    [self.miniGrowView addGestureRecognizer:tap];
}

-(void) initData{
    [super initData];
    [theRT regist:kGrowPageSEL target:self selector:@selector(birdGrowBtnOnClick:)];
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)testHungryOnClick:(id)sender {
    TestHungryPage *page = [[TestHungryPage alloc] init];
    [self.navigationController pushViewController:page animated:true];
}

- (IBAction)birdLiveOnClick:(id)sender {
    BirdLivePage *page = [[BirdLivePage alloc] init];
    [self.navigationController pushViewController:page animated:true];
}

- (IBAction)birdGrowBtnOnClick:(id)sender {
    BirdGrowPage *page = [[BirdGrowPage alloc] init];
    [self.navigationController pushViewController:page animated:true];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [theRT invoked:kGrowPageSEL];
    });
}

- (void)miniGrowTap:(UITapGestureRecognizer *)tap{
    //1. 计算距离和角度
    UIView *tapView = tap.view;
    CGPoint point = [tap locationInView:tapView];                 //点击坐标
    CGPoint targetPoint = CGPointZero;
    
    //2. 远投按键,计算映射坐标;
    CGFloat xRate = point.x / tapView.width;
    CGFloat yRate = point.y / tapView.height;
    CGFloat targetX = 30 + (ScreenWidth - 60) * xRate;
    CGFloat targetY = 94 + (ScreenHeight - 60 - 128) * yRate;
    targetPoint = CGPointMake(targetX, targetY);
    
    //4. 投食 & 打日志;
    if (targetPoint.x != 0 && targetPoint.y != 0) {
        NSLog(@"鸟出生坐标 (X:%.2f Y:%.2f)",targetPoint.x,targetPoint.y);
    }
}


@end
