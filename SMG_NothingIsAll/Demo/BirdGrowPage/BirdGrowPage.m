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
#import "UIView+Extension.h"
#import "DemoHunger.h"
#import "NVViewUtil.h"

@interface BirdGrowPage ()<UIGestureRecognizerDelegate,BirdViewDelegate>

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
    [self.birdView setCenter:CGPointMake(ScreenWidth / 2.0f, ScreenHeight / 2.0f)];
    self.birdView.delegate = self;
    
    //3. tapRecognizer
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(customTapAction:)];
    self.tapRecognizer.delegate = self;
    
    //4. farView
    [self.farView addGestureRecognizer:self.tapRecognizer];
    
    //5. borderView
    [self.borderView.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.borderView addGestureRecognizer:self.tapRecognizer];
    [self.borderView.layer setBorderWidth:30];
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)nearFeedingBtnOnClick:(id)sender {
    [theApp.heLogView addLog:@"直投"];
    FoodView *foodView = [[FoodView alloc] init];
    [foodView hit];
    [foodView setOrigin:CGPointMake(ScreenWidth * 0.75f, ScreenHeight - 66)];
    [self.view addSubview:foodView];
    CGPoint targetPoint = self.birdView.center;
    [UIView animateWithDuration:1.5f animations:^{
        [foodView setCenter:targetPoint];
    }completion:^(BOOL finished) {
        //1. 触碰到鸟嘴;
        [self.birdView touchMouth];
    }];
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
- (void)customTapAction:(UITapGestureRecognizer *)tapRecognizer{
    //1. 计算距离和角度
    UIView *tapView = tapRecognizer.view;
    CGPoint point = [tapRecognizer locationInView:tapView];                 //点击坐标
    CGPoint tapPoint = [tapView convertPoint:point toView:theApp.window];   //点击世界坐标
    CGPoint birdPoint = [self.birdView.superview convertPoint:self.birdView.center toView:theApp.window];//鸟世界坐标
    CGFloat distance = [NVViewUtil distancePoint:birdPoint second:tapPoint];
    CGFloat angle = [NVViewUtil angleZero2OnePoint:birdPoint second:tapPoint];
    NSLog(@"点击: 距离%f,方向%f",distance,angle);
    NSLog(@"tapPoint:(%f,%f),(%f,%f)",point.x,point.y,tapPoint.x,tapPoint.y);
    
    //2. 远投按键,则映射投食;
    if ([self.farView isEqual:tapView]) {
        CGPoint point = [tapRecognizer locationInView:tapView];
        CGFloat xRate = point.x / tapView.width;
        CGFloat yRate = point.y / tapView.height;
        CGFloat targetX = 30 + (ScreenWidth - 60) * xRate;
        CGFloat targetY = 94 + (ScreenHeight - 60 - 128) * yRate;
        NSLog(@"远投:%f,%f",xRate,yRate);
        [theApp.heLogView addLog:STRFORMAT(@"远投:%f,%f",xRate,yRate)];
        CGPoint targetPoint = CGPointMake(targetX, targetY);
        [self food2Pos:targetPoint];
    }else if([self.borderView isEqual:tapView]){
        //3. 全屏触摸_飞行至触摸方向;
        if (distance < 100) {
            int angle_15_14 = (int)(angle * 16 + 1);//angle为左向顺时针0-1,x16则为0-15,再+1则为15,0,1,2...14;
            CGFloat angleValue = (angle_15_14 / 2) / 8.0f;//此时0-1为左上,2-3为上...14,15为左;先除2变成取0-7,再除8.0f,得0-1;
            NSLog(@"飞行至:%f,%f",angle,angleValue);
        }else{
            //4. 全屏触摸_投食至触摸点;
            CGPoint foodTargetPoint = [theApp.window convertPoint:tapPoint toView:self.borderView];
            NSLog(@"投食至:(%f,%f),(%f,%f)",tapPoint.x,tapPoint.y,foodTargetPoint.x,foodTargetPoint.y);
        }
    }
}
- (IBAction)foodLeftOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"远投-左");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x - 100, birdPos.y)];
}
- (IBAction)foodLeftUpOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"远投-左上");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x - 100, birdPos.y - 100)];
}
- (IBAction)foodUpOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"远投-上");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x, birdPos.y - 100)];
}
- (IBAction)foodRightUpOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"远投-右上");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x + 100, birdPos.y - 100)];
}
- (IBAction)foodRightOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"远投-右");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x + 100, birdPos.y)];
}
- (IBAction)foodRightDownOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"远投-右下");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x + 100, birdPos.y + 100)];
}
- (IBAction)foodDownOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"远投-下");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x, birdPos.y + 100)];
}
- (IBAction)foodLeftDownOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"远投-左下");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x - 100, birdPos.y + 100)];
}
- (IBAction)hungerBtnOnClick:(id)sender {
    NSLog(@"马上饿onClick");
    [theApp.heLogView addLog:@"马上饿onClick"];
    [[[DemoHunger alloc] init] commit:0.7 state:UIDeviceBatteryStateUnplugged];
}

- (IBAction)touchWingBtnOnClick:(id)sender {
    NSLog(@"摸翅膀onClick");
    [theApp.heLogView addLog:@"摸翅膀onClick"];
    int random = (arc4random() % 8);
    [self.birdView touchWing:random];
}
- (IBAction)touchWingLeftOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"摸翅膀onClick-左");
    [self.birdView touchWing:0];
}
- (IBAction)touchWingLeftUpOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"摸翅膀onClick-左上");
    [self.birdView touchWing:1];
}
- (IBAction)touchWingUpOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"摸翅膀onClick-上");
    [self.birdView touchWing:2];
}
- (IBAction)touchWingRightUpOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"摸翅膀onClick-右上");
    [self.birdView touchWing:3];
}
- (IBAction)touchWingRightOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"摸翅膀onClick-右");
    [self.birdView touchWing:4];
}
- (IBAction)touchWingRightDownOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"摸翅膀onClick-右下");
    [self.birdView touchWing:5];
}
- (IBAction)touchWingDownOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"摸翅膀onClick-下");
    [self.birdView touchWing:6];
}
- (IBAction)touchWingLeftDownOnClick:(id)sender {
    [self animationFlash:sender];
    NSLog(@"摸翅膀onClick-左下");
    [self.birdView touchWing:7];
}

/**
 *  MARK:--------------------BirdViewDelegate--------------------
 */
-(FoodView *)birdView_GetFoodOnMouth{
    NSArray *foods = ARRTOOK([self.view subViews_AllDeepWithClass:FoodView.class]);
    for (FoodView *food in foods) {
        //判断触碰到的食物 & 并返回;
        if (fabs(food.center.x - self.birdView.center.x) < 15.0f && fabs(food.center.y - self.birdView.center.y) < 15.0f) {
            return food;
        }
    }
    return nil;
}

-(UIView*) birdView_GetPageView{
    return self.view;
}

-(CGRect)birdView_GetSeeRect{
    return CGRectMake(0, 64, ScreenWidth, ScreenHeight - 128);
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
- (void) food2Pos:(CGPoint)targetPoint{
    FoodView *foodView = [[FoodView alloc] init];
    [foodView hit];
    [foodView setOrigin:CGPointMake(ScreenWidth * 0.25f, ScreenHeight - 66)];
    [self.view addSubview:foodView];
    [UIView animateWithDuration:1.0f animations:^{
        [foodView setOrigin:targetPoint];
    }completion:^(BOOL finished) {
        //1. 视觉输入
        [self.birdView see:self.view];
    }];
}

-(void) animationFlash:(UIView*)view{
    if (view) {
        [UIView animateWithDuration:0.2 animations:^{
            view.alpha = 0.3f;
        }completion:^(BOOL finished) {
            view.alpha = 1.0f;
        }];
    }
}

@end
