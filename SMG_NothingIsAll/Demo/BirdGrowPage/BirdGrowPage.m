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
#import "WoodView.h"

@interface BirdGrowPage ()<UIGestureRecognizerDelegate,BirdViewDelegate>

@property (strong,nonatomic) BirdView *birdView;
@property (strong,nonatomic) UITapGestureRecognizer *singleTap;
@property (strong,nonatomic) UITapGestureRecognizer *doubleTap;
@property (weak, nonatomic) IBOutlet UIView *farView;
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak, nonatomic) IBOutlet UIButton *throwWoodBtn;
@property (strong, nonatomic) WoodView *woodView;

@end

@implementation BirdGrowPage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
}

-(void) initView{
    //1. self
    self.title = @"小鸟成长演示";
    
    //2. birdView
    self.birdView = [[BirdView alloc] init];
    [self.view addSubview:self.birdView];
    [self.birdView setCenter:CGPointMake(ScreenWidth / 2.0f, ScreenHeight / 2.0f)];
    self.birdView.delegate = self;
    
    //3. doubleTap
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    self.doubleTap.numberOfTapsRequired = 2;
    self.doubleTap.numberOfTouchesRequired = 1;
    self.doubleTap.delegate = self;
    
    //4. singleTap
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    self.singleTap.numberOfTapsRequired = 1;
    self.singleTap.numberOfTouchesRequired  = 1;
    self.singleTap.delegate = self;
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    
    //4. farView
    [self.farView addGestureRecognizer:self.singleTap];
    
    //5. borderView
    [self.borderView.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.borderView addGestureRecognizer:self.singleTap];
    [self.borderView addGestureRecognizer:self.doubleTap];
    [self.borderView.layer setBorderWidth:20];
    
    //6. woodView
    self.woodView = [[WoodView alloc] init];
    [self.view addSubview:self.woodView];
}

-(void) initData{
    [theRT regist:kFlySEL target:self selector:@selector(touchWingBtnOnClick:)];
    [theRT regist:kWoodSEL target:self selector:@selector(throwWoodOnClick:)];
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================

/**
 *  MARK:--------------------直投--------------------
 *  @version
 *      2021.01.24: 使直投到乌鸦身上的坚果位置更随机些 (参考视觉DisY算法中20210124注释);
 */
- (IBAction)nearFeedingBtnOnClick:(id)sender {
    [theApp.heLogView addDemoLog:@"直投"];
    DemoLog(@"直投")
    FoodView *foodView = [[FoodView alloc] init];
    [foodView hit];
    [foodView setOrigin:CGPointMake(ScreenWidth * 0.375f, ScreenHeight - 66)];
    [self.view addSubview:foodView];
    CGFloat targetX = self.birdView.center.x + (random() % 20 - 10);
    CGFloat targetY = self.birdView.center.y + (random() % 20 - 10);
    CGPoint targetPoint = CGPointMake(targetX, targetY);
    [UIView animateWithDuration:0.3f animations:^{
        [foodView setCenter:targetPoint];
    }completion:^(BOOL finished) {
        //1. 吃前视觉
        [self.birdView see:self.view];
        //2. 触碰到鸟嘴;
        [self.birdView touchMouth];
    }];
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
//单击投食
- (void)singleTap:(UITapGestureRecognizer *)tapRecognizer{
    //1. 计算距离和角度
    UIView *tapView = tapRecognizer.view;
    CGPoint point = [tapRecognizer locationInView:tapView];                 //点击坐标
    CGPoint targetPoint = CGPointZero;
    ISTitleLog(@"现实世界");
    
    //2. 远投按键,计算映射坐标;
    if ([self.farView isEqual:tapView]) {
        CGFloat xRate = point.x / tapView.width;
        CGFloat yRate = point.y / tapView.height;
        CGFloat targetX = 30 + (ScreenWidth - 60) * xRate;
        CGFloat targetY = 94 + (ScreenHeight - 60 - 128) * yRate;
        targetPoint = CGPointMake(targetX, targetY);
    }else if([self.borderView isEqual:tapView]){
        //3. 全屏触摸_计算触摸点世界坐标 (self.view本来就是全屏,所以不用转换坐标);
        targetPoint = [tapView convertPoint:point toView:theApp.window];   //点击世界坐标
    }
    
    //4. 投食 & 打日志;
    if (targetPoint.x != 0 && targetPoint.y != 0) {
        DemoLog(@"远投 (X:%.2f Y:%.2f)",targetPoint.x,targetPoint.y);
        [theApp.heLogView addDemoLog:STRFORMAT(@"远投 (X:%.2f Y:%.2f)",targetPoint.x,targetPoint.y)];
        [self food2Pos:targetPoint];
    }
}

//双击飞行
- (void)doubleTap:(UITapGestureRecognizer *)tapRecognizer{
    //1. 计算距离和角度
    UIView *tapView = tapRecognizer.view;
    CGPoint point = [tapRecognizer locationInView:tapView];                 //点击坐标
    CGPoint tapPoint = [tapView convertPoint:point toView:theApp.window];   //点击世界坐标
    CGPoint birdPoint = [self.birdView.superview convertPoint:self.birdView.center toView:theApp.window];//鸟世界坐标
    CGFloat angle = [NVViewUtil angleZero2OnePoint:birdPoint second:tapPoint];
    
    //2. 飞行
    angle = [NVViewUtil convertAngle2Direction_8:angle];
    int direction = (int)(angle * 8.0f);
    [self.birdView touchWing:direction];
}
- (IBAction)foodLeftOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-左");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x - 100, birdPos.y)];
}
- (IBAction)foodLeftUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-左上");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x - 100, birdPos.y - 100)];
}
- (IBAction)foodUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-上");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x, birdPos.y - 100)];
}
- (IBAction)foodRightUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-右上");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x + 100, birdPos.y - 100)];
}
- (IBAction)foodRightOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-右");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x + 100, birdPos.y)];
}
- (IBAction)foodRightDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-右下");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x + 100, birdPos.y + 100)];
}
- (IBAction)foodDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-下");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x, birdPos.y + 100)];
}
- (IBAction)foodLeftDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-左下");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x - 100, birdPos.y + 100)];
}
- (IBAction)hungerBtnOnClick:(id)sender {
    ISTitleLog(@"感官输入");
    DemoLog(@"马上饿onClick");
    [theApp.heLogView addDemoLog:@"马上饿onClick"];
    [[[DemoHunger alloc] init] commit:0.6 state:UIDeviceBatteryStateUnplugged];
}

- (IBAction)touchWingBtnOnClick:(id)sender {
    ISTitleLog(@"现实世界");
    DemoLog(@"摸翅膀onClick");
    [theApp.heLogView addDemoLog:@"摸翅膀onClick"];
    //1. 计算random
    int random = 0;
    if ([self birdLeftOut]) {
        //2. 左屏外,仅向3,4,5飞;
        random = arc4random() % 3 + 3;
    }else if([self birdRightOut]){
        //3. 右屏外,仅向7,0,1飞;
        random = ((arc4random() % 3) + 7) % 8;
    }else if([self birdTopOut]) {
        //4. 上屏外,仅向5,6,7飞;
        random = arc4random() % 3 + 5;
    }else if([self birdBottomOut]){
        //5. 下屏外,仅向1,2,3飞;
        random = arc4random() % 3 + 1;
    }else {
        //6. 屏中,任意方向;
        random = arc4random() % 8;
    }
    [self.birdView touchWing:random];
}
- (IBAction)touchWingLeftOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸翅膀onClick-左");
    [self.birdView touchWing:0];
}
- (IBAction)touchWingLeftUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸翅膀onClick-左上");
    [self.birdView touchWing:1];
}
- (IBAction)touchWingUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸翅膀onClick-上");
    [self.birdView touchWing:2];
}
- (IBAction)touchWingRightUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸翅膀onClick-右上");
    [self.birdView touchWing:3];
}
- (IBAction)touchWingRightOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸翅膀onClick-右");
    [self.birdView touchWing:4];
}
- (IBAction)touchWingRightDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸翅膀onClick-右下");
    [self.birdView touchWing:5];
}
- (IBAction)touchWingDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸翅膀onClick-下");
    [self.birdView touchWing:6];
}
- (IBAction)touchWingLeftDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸翅膀onClick-左下");
    [self.birdView touchWing:7];
}

/**
 *  MARK:--------------------扔木棒--------------------
 *  @version
 *      2021.01.16: 用NSTimer替代after延时,因为after时间不准,总会推后150ms左右,而timer非常准时;
 *      2021.02.26: NSTimer改为SEL方式,因为block方式在模拟器运行闪退;
 *      2022.04.27: 将扔出木棒速度变慢 (参考25222);
 */
- (IBAction)throwWoodOnClick:(id)sender {
    //0. 鸟不在,则跳过;
    if ([self birdOut]) {
        return;
    }
    
    //1. 复位木棒
    [self.woodView reset:false];
    
    //2. 扔前木棒视觉帧
    DemoLog(@"木棒扔前视觉");
    [self.birdView see:self.woodView];
    
    //3. 预计撞到的时间 (撞需距离 / 总扔距离 * 总扔时间);
    CGFloat hitTime = ((self.birdView.showMinX - self.woodView.showMaxX) / ScreenWidth) * ThrowTime;
    
    //4. 扔出
    DemoLog(@"扔木棒 (预撞hitTime:%f)",hitTime);
    [self.woodView throw:hitTime hitBlock:^BOOL{
        BOOL xHited = self.woodView.showMaxX >= self.birdView.showMinX;
        BOOL YHited = self.birdView.showMinY < self.woodView.showMaxY && self.birdView.showMaxY > self.woodView.showMinY;
        if (xHited && YHited) {
            //5. 触发疼痛感;
            NSLog(@"---> success 撞到了 鸟左:%f 木右:%f",self.birdView.showMinX,self.woodView.showMaxX);
            [self.birdView hurt];
            return true;
        }
        NSLog(@"---> failure 没撞到 鸟左:%f 木右:%f",self.birdView.showMinX,self.woodView.showMaxX);
        return false;
    }];
}

- (IBAction)stopWoodBtnOnClick:(id)sender {
    CGRect frame = [self.woodView showFrame];
    [self.woodView.layer removeAllAnimations];
    [self.woodView setFrame:frame];
}

/**
 *  MARK:--------------------BirdViewDelegate--------------------
 */
-(FoodView *)birdView_GetFoodOnMouth{
    NSArray *foods = ARRTOOK([self.view subViews_AllDeepWithClass:FoodView.class]);
    for (FoodView *food in foods) {
        //判断触碰到的食物 & 并返回;
        if (fabs(food.center.x - self.birdView.center.x) <= 15.0f && fabs(food.center.y - self.birdView.center.y) <= 15.0f) {
            return food;
        }
    }
    return nil;
}

-(UIView*) birdView_GetPageView{
    return self.view;
}

-(CGRect)birdView_GetSeeRect{
    return CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64 - 64);//naviBar和btmBtn
}


//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
- (void) food2Pos:(CGPoint)targetPoint{
    FoodView *foodView = [[FoodView alloc] init];
    [foodView hit];
    [foodView setOrigin:CGPointMake(ScreenWidth * 0.375f, ScreenHeight - 66)];
    [self.view addSubview:foodView];
    [UIView animateWithDuration:0.3f animations:^{
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

-(BOOL) birdOut{
    return [self birdLeftOut] || [self birdRightOut] || [self birdTopOut] || [self birdBottomOut];
}
-(BOOL) birdLeftOut{
    return self.birdView.showX < 0;
}
-(BOOL) birdRightOut{
    return self.birdView.showMaxX > ScreenWidth;
}
-(BOOL) birdTopOut{
    return self.birdView.y < 64;
}
-(BOOL) birdBottomOut{
    return self.birdView.showMaxY > ScreenHeight;
}

@end
