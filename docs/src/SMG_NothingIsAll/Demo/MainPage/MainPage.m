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
    [self pushBrowPage:CGPointZero];
}

//MARK:===============================================================
//MARK:                     < block >
//MARK:===============================================================
- (void)miniGrowTap:(UITapGestureRecognizer *)tap{
    //1. 计算距离和角度
    UIView *tapView = tap.view;
    CGPoint point = [tap locationInView:tapView];                 //点击坐标
    CGFloat xRate = point.x / tapView.width;
    CGFloat yRate = point.y / tapView.height;
    
    //2. 实际路的上中下高宽;
    CGFloat topH = (ScreenHeight - 128 - 100) / 2.0f, btmH = topH, roadH = 100, roadW = ScreenWidth - 32;
    
    //3. 计算映射坐标 (mini图的中间0.4是路中,路上下各0.3);
    CGFloat targetX = 16 + xRate * roadW;
    if (yRate < 0.3f) {
        //a. 路上坐标计算
        CGFloat topRate = yRate / 0.3f;
        CGFloat targetY = 64 + topRate * topH;
        [self pushBrowPage:CGPointMake(targetX, targetY)];
    }else if (yRate < 0.7f) {
        //b. 路中坐标计算
        CGFloat roadRate = (yRate - 0.3f) / 0.4f;
        CGFloat targetY = 64 + topH + roadRate * roadH;
        [self pushBrowPage:CGPointMake(targetX, targetY)];
    }else {
        //c. 路下坐标计算
        CGFloat btmRate = (yRate - 0.7f) / 0.3f;
        CGFloat targetY = 64 + topH + roadH + btmRate * btmH;
        [self pushBrowPage:CGPointMake(targetX, targetY)];
    }
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
-(void) pushBrowPage:(CGPoint)birdPos {
    //1. 到成长页;
    BirdGrowPage *page = [[BirdGrowPage alloc] init];
    [self.navigationController pushViewController:page animated:true];
    
    //2. 指定小鸟出生地点;
    page.birdBirthPos = birdPos;
    
    //3. 标记训练器步骤;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [theRT invoked:kGrowPageSEL];
    });
}

@end
