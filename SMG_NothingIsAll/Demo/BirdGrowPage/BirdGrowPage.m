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
#import "HitItemModel.h"

@interface BirdGrowPage ()<UIGestureRecognizerDelegate,BirdViewDelegate,UICollisionBehaviorDelegate,WoodViewDelegate>

@property (strong,nonatomic) BirdView *birdView;
@property (strong,nonatomic) UITapGestureRecognizer *singleTap;
@property (strong,nonatomic) UITapGestureRecognizer *doubleTap;
@property (weak, nonatomic) IBOutlet UIView *farView;
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak, nonatomic) IBOutlet UIButton *throwWoodBtn;
@property (strong, nonatomic) WoodView *woodView;
@property(nonatomic,strong) UIDynamicAnimator *dyAnimator;
@property (strong, nonatomic) UICollisionBehavior *collision;

@property (assign, nonatomic) BOOL waitHiting; //碰撞检测中 (当扔木棒中时,做碰撞检测);
@property (assign, nonatomic) BOOL isHited; //检测撞到了;
@property (strong, nonatomic) HitItemModel *lastHitModel;

@end

@implementation BirdGrowPage

-(void) initView{
    [super initView];
    //1. self
    self.title = @"小鸟成长演示";
    
    //2. birdView
    self.birdView = [[BirdView alloc] init];
    [self.view addSubview:self.birdView];
    [self.birdView setCenter:[self getBirdBirthPos]];
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
    self.woodView.delegate = self;
    [self.view addSubview:self.woodView];
    
    //7. 创建物理仿真器，设置仿真范围，ReferenceView为参照视图
    self.dyAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

-(void) initData{
    [super initData];
    [theRT regist:kFlySEL target:self selector:@selector(touchWingBlock:)];
    [theRT regist:kWoodLeftSEL target:self selector:@selector(throwWood_Left)];
    [theRT regist:kWoodRdmSEL target:self selector:@selector(throwWood_Rdm)];
    [theRT regist:kHungerSEL target:self selector:@selector(hungerBtnOnClick:)];
    [theRT regist:kFoodRdmSEL target:self selector:@selector(randomThrowFood4Screen)];
    [theRT regist:kFoodRdmNearSEL target:self selector:@selector(randomThrowFood4Near)];
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
    CGFloat targetX = self.birdView.center.x + (arc4random() % 20 - 10);
    CGFloat targetY = self.birdView.center.y + (arc4random() % 20 - 10);
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

/**
 *  MARK:--------------------随机屏内扔个坚果--------------------
 */
-(void) randomThrowFood4Screen {
    //1. 数据准备;
    int randomX = 20 + (arc4random() % (int)(ScreenWidth - 40));//屏内x为20到screenW-20;
    int randomY = 84 + (arc4random() % (int)(ScreenHeight - 168));//屏内y为84到screenW-84;
    
    //2. 投食物
    [self food2Pos:CGPointMake(randomX, randomY) caller4RL:kFoodRdmSEL];
}

/**
 *  MARK:--------------------随机附近扔个坚果--------------------
 *  @desc 在鸟的八个方向,随机3飞距离内投个坚果;
 *          1. 不允许投在鸟身上;
 *          2. 投的位置要随机抖动一些,避免完全的直或斜;
 */
-(void) randomThrowFood4Near {
    //1. 数据准备;
    int random = arc4random() % 8;
    CGPoint birdPos = self.birdView.center;
    int ziDis = 15 + 8 + (arc4random() % 42);//直线时,距离为23 -> 65之间;
    int xieDis = 22 + 8 + (arc4random() % 16);//斜线时,距离为30 -> 46之间;
    int douDon1 = (arc4random() % 6) - 3;//抖动距离正负3;
    int douDon2 = (arc4random() % 6) - 3;//抖动距离正负3;
    
    //2. 随机方向扔食物
    if (random == 0) [self food2Pos:CGPointMake(birdPos.x - ziDis + douDon1, birdPos.y + douDon2) caller4RL:kFoodRdmNearSEL];
    else if (random == 1) [self food2Pos:CGPointMake(birdPos.x - xieDis + douDon1, birdPos.y - xieDis + douDon2) caller4RL:kFoodRdmNearSEL];
    else if (random == 2) [self food2Pos:CGPointMake(birdPos.x + douDon1, birdPos.y - ziDis + douDon2) caller4RL:kFoodRdmNearSEL];
    else if (random == 3) [self food2Pos:CGPointMake(birdPos.x + xieDis + douDon1, birdPos.y - xieDis + douDon2) caller4RL:kFoodRdmNearSEL];
    else if (random == 4) [self food2Pos:CGPointMake(birdPos.x + ziDis + douDon1, birdPos.y + douDon2) caller4RL:kFoodRdmNearSEL];
    else if (random == 5) [self food2Pos:CGPointMake(birdPos.x + xieDis + douDon1, birdPos.y + xieDis + douDon2) caller4RL:kFoodRdmNearSEL];
    else if (random == 6) [self food2Pos:CGPointMake(birdPos.x + douDon1, birdPos.y + ziDis + douDon2) caller4RL:kFoodRdmNearSEL];
    else if (random == 7) [self food2Pos:CGPointMake(birdPos.x - xieDis + douDon1, birdPos.y + xieDis + douDon2) caller4RL:kFoodRdmNearSEL];
}

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
        [self food2Pos:targetPoint caller4RL:nil];
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
    [self food2Pos:CGPointMake(birdPos.x - 65, birdPos.y) caller4RL:nil];
}
- (IBAction)foodLeftUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-左上");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x - 46, birdPos.y - 46) caller4RL:nil];
}
- (IBAction)foodUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-上");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x, birdPos.y - 65) caller4RL:nil];
}
- (IBAction)foodRightUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-右上");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x + 46, birdPos.y - 46) caller4RL:nil];
}
- (IBAction)foodRightOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-右");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x + 65, birdPos.y) caller4RL:nil];
}
- (IBAction)foodRightDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-右下");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x + 46, birdPos.y + 46) caller4RL:nil];
}
- (IBAction)foodDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-下");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x, birdPos.y + 65) caller4RL:nil];
}
- (IBAction)foodLeftDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-左下");
    CGPoint birdPos = self.birdView.center;
    [self food2Pos:CGPointMake(birdPos.x - 46, birdPos.y + 46) caller4RL:nil];
}

/**
 *  MARK:--------------------饥饿是连续的mv输入 (参考28171-todo2)--------------------
 */
- (IBAction)hungerBtnOnClick:(id)sender {
    ISTitleLog(@"感官输入");
    DemoLog(@"马上饿onClick");
    [theApp.heLogView addDemoLog:@"马上饿onClick"];
    //1. 先感觉到饿: 从0.7饿到0.6 (按0.6计算得迫切度为16);
    [[[DemoHunger alloc] init] commit:0.6 state:UIDeviceBatteryStateUnplugged];
    self.birdView.waitEat = true;
    
    //2. 强训工具需要等待第2次更饿后,才能继续训练下轮;
    [theRT appendPauseNames:@[kMainPageSEL]];
    
    //2. 五秒后更饿: 从0.6饿到0.5 (按0.5计算得迫切度为25);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.birdView.waitEat) {
            [[[DemoHunger alloc] init] commit:0.5 state:UIDeviceBatteryStateUnplugged];
        }
        //3. 第2次饿后,允许强训工具继续;
        [theRT clearPauseNames];
    });
    
    //3. 报强训结束标记;
    [theRT invoked:kHungerSEL];
}

- (IBAction)touchWingBtnOnClick:(id)sender {
    [self touchWingBlock:nil];
}

- (void)touchWingBlock:(NSNumber*)direction {
    ISTitleLog(@"现实世界");
    DemoLog(@"摸翅膀onClick");
    [theApp.heLogView addDemoLog:@"摸翅膀onClick"];
    //1. 计算random
    long random = 0;
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
    
    //7. 指定方向参数时;
    if (direction) {
        random = NUMTOOK(direction).longValue;
        NSLog(@"强训fly >> %@",[NVHeUtil getLightStr_Value:random / 8.0f algsType:FLY_RDS dataSource:@""]);
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
 *      2022.06.04: 支持随机点扔出木棒 (参考26196-方案2);
 */
- (IBAction)throwWoodOnClick:(id)sender {
    [self throwWood_Left];
}
-(void) throwWood_Rdm{
    int randomX = arc4random() % (int)ScreenWidth;
    [self throwWood:randomX invoked:^{
        [theRT invoked:kWoodRdmSEL];
    }];
}
-(void) throwWood_Left{
    [self throwWood:0 invoked:^{
        [theRT invoked:kWoodLeftSEL];
    }];
}

/**
 *  MARK:--------------------扔木棒--------------------
 *  @version
 *      xxxx.xx.xx: v1版本,分前后两段扔;
 *      2023.05.19: 迭代v2,改为用物理仿真碰撞检测,因为原来的二段式判断太简略且可能判错 (参考29096-问题2);
 *      2023.05.21: 废弃v2物理仿真: "飞行卡循环,木棒扔不全" (参考29097);
 *      2023.05.21: 迭代v3,将动画改为count个step来执行 (后测count越多,一顿一顿的,改成v4) (参考29097-新方案);
 *      2023.05.21: 迭代v4,碰撞检测交由setFrame来完成,step动画仅执行一轮 (参考29098-方案3-步骤1 & 步骤4);
 *      2023.06.02: 调慢扔的速度_因为v4,一次动画全跑完,有点太顺当,导致鸟经常来不急反应飞躲开,所以调慢,从5秒调整成8秒 (参考29109-测得1);
 */
-(void) throwWood:(CGFloat)x invoked:(void(^)())invoked {
    [self throwWoodV4:x invoked:invoked];
}

-(void) throwWoodV2:(CGFloat)x invoked:(void(^)())invoked{
    //0. 鸟不在,则跳过;
    if ([self birdOut]) {
        invoked();
        return;
    }
    
    //1. 复位木棒
    [self.woodView reset:false x:x];
    
    //2. 扔前木棒视觉帧
    DemoLog(@"木棒扔前视觉");
    [self.birdView see:self.woodView];
    
    //3. 预计撞到的时间 (撞需距离 / 总扔距离 * 总扔时间);
    [self.dyAnimator removeAllBehaviors];
    CGFloat allDistance = ScreenWidth - self.woodView.x;
    CGFloat allTime = allDistance / ScreenWidth * ThrowTime;
    CGFloat speed = allTime > 0 ? allDistance / allTime : 0;
    
    //4. 自定义力 及 item属性
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.woodView]];
    itemBehavior.allowsRotation = false; //禁止被撞的旋转
    itemBehavior.density = 0; //密度 (默认1,设为0时也能撞到,不知道啥意思);
    itemBehavior.friction = 0; //摩擦力
    itemBehavior.resistance = 0; //线性阻力
    [itemBehavior addLinearVelocity:CGPointMake(speed, 0) forItem:self.woodView]; //线性速度
    [self.dyAnimator addBehavior:itemBehavior];
    
    //5. 碰撞
    self.collision = [[UICollisionBehavior alloc] initWithItems:@[self.woodView,self.birdView]];
    [self.collision setTranslatesReferenceBoundsIntoBoundary:true];
    self.collision.collisionDelegate = self;
    self.collision.collisionMode = UICollisionBehaviorModeItems;
    [self.dyAnimator addBehavior:self.collision];
    
    //6. 执行完成报告;
    itemBehavior.action = ^{
        if (self.woodView.x > ScreenWidth) {
            [self.dyAnimator removeAllBehaviors];
            [self.woodView reset:true x:0];
            invoked();
        }
    };
}

-(void) throwWoodV4:(CGFloat)x invoked:(void(^)())invoked{
    //0. 鸟不在,则跳过;
    if ([self birdOut]) {
        invoked();
        return;
    }
    
    //1. 复位木棒
    [self.woodView reset:false x:x];
    
    //2. 扔前木棒视觉帧
    DemoLog(@"木棒扔前视觉");
    [self.birdView see:self.woodView];
    
    //3. 扔前数据准备
    CGFloat allDistance = ScreenWidth - self.woodView.x; //动画扔多远;
    CGFloat allTime = allDistance / ScreenWidth * ThrowTime; //动画总时长
    DemoLog(@"扔木棒 (时:%.2f 距:%.2f)",allTime,allDistance);
    self.waitHiting = true;
    
    //4. 扔出: step动画仅执行一轮 (参考29098-方案3-步骤4);
    [self.woodView throwV4:x time:allTime distance:allDistance invoked:invoked];
}

- (IBAction)stopWoodBtnOnClick:(id)sender {
    CGRect frame = [self.woodView showFrame];
    [self.woodView.layer removeAllAnimations];
    [self.woodView setFrame:frame];
}
- (IBAction)miniResetBtnClick:(id)sender {
    [theTC clear];
}
- (IBAction)miniBackBtnClick:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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

-(UIDynamicAnimator*) birdView_GetDyAnimator {
    return self.dyAnimator;
}

//2023.06.04: 废弃_将setFramed换成动画开始,二者是同时触发的,但setFramed有两个问题,1是无法传过来动画时间,2是它会触发两次;
-(void)birdView_SetFramed {
    //[self runCheckHit:@"鸟位置变化"];
}

-(void)birdView_FlyAnimationFinish {
    [self runCheckHit:0 hiterDesc:@"鸟飞结束"];//动画执行完后,要调用下碰撞检测,因为UIView动画后不会立马更新frame (参考29098-追BUG1);
}

-(void) birdView_FlyAnimationBegin:(CGFloat)aniDuration {
    [self runCheckHit:aniDuration hiterDesc:@"鸟飞开始"];
}

/**
 *  MARK:--------------------UICollisionBehaviorDelegate--------------------
 */
- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2 atPoint:(CGPoint)p {
    NSLog(@"---> success 撞到了");
    [self.collision removeItem:self.birdView];//防止被撞飞;
    [self.birdView hurt];
}

/**
 *  MARK:--------------------WoodViewDelegate--------------------
 */

//2023.06.04: 废弃_将setFramed换成动画开始,二者是同时触发的,但setFramed有两个问题,1是无法传过来动画时间,2是它会触发两次;
-(void)woodView_SetFramed {
    //[self runCheckHit:@"棒扔位置变化"];
}

-(void) woodView_WoodAnimationFinish {
    [self runCheckHit:0 hiterDesc:@"棒扔结束"];//动画执行完后,要调用下碰撞检测,因为UIView动画后不会立马更新frame (参考29098-追BUG1);
    self.waitHiting = false;//木棒动画结束时,同时碰撞检测也结束;
}

-(void) woodView_FlyAnimationBegin:(CGFloat)aniDuration {
    [self runCheckHit:aniDuration hiterDesc:@"棒扔开始"];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

-(void)setWaitHiting:(BOOL)value {
    //1. 检测碰撞开始或结束时: 重置lastModel记录 & isHited检测结果;
    NSLog(@"碰撞检测: %@",value ? @"开始 >>>>>>>" : @"结束 <<<<<<<");
    self.lastHitModel = nil;
    self.isHited = false;
    
    //2. 开关更新;
    _waitHiting = value;
}

/**
 *  MARK:--------------------碰撞检测算法 (参考29098)--------------------
 *  @param duration : 当前触发的动画到结束所需动画时长 (用来计算碰撞检测,比如鸟飞的很快,下次触发时却过了很久,不能均匀的认为它飞了这么久);
 *  @callers 检查中状态时,只要木棒或小鸟的位置有变化,就调用:
 *          1. 无论是木棒还是小鸟的frame变化都调用 (参考29098-方案3-步骤1);
 *          2. 无论是木棒还是小鸟的动画结束时,都手动调用下 (因为UIView动画后不会立马更新frame);
 */
-(void) runCheckHit:(CGFloat)duration hiterDesc:(NSString*)hiterDesc {
    //1. 非检查中 或 已检测到碰撞 => 返回;
    if (!self.waitHiting || self.isHited) return;
    
    //TODOTOMORROW20230604: 根据动画持续时间,修复30012的BUG;
    
    
    
    
    //2. 当前帧model;
    HitItemModel *curHitModel = [[HitItemModel alloc] init];
    curHitModel.woodFrame = self.woodView.showFrame;
    curHitModel.birdFrame = self.birdView.showFrame;
    curHitModel.time = [[NSDate date] timeIntervalSince1970] * 1000;
    
    //3. 上帧为空时,直接等于当前帧;
    if (self.lastHitModel == nil) {
        self.lastHitModel = curHitModel;
    }
    
    //4. 分10帧,检查每帧棒鸟是否有碰撞 (参考29098-方案3-步骤3);
    NSInteger frameCount = 2;
    for (NSInteger i = 0; i < frameCount; i++) {
        //5. 取上下等份的Rect取并集,避免两等份间距过大,导致错漏检测问题 (参考29098-测BUG2);
        CGRect wr1 = [MathUtils radioRect:self.lastHitModel.woodFrame endRect:curHitModel.woodFrame radio:(float)i / frameCount];
        CGRect br1 = [MathUtils radioRect:self.lastHitModel.birdFrame endRect:curHitModel.birdFrame radio:(float)i / frameCount];
        CGRect wr2 = [MathUtils radioRect:self.lastHitModel.woodFrame endRect:curHitModel.woodFrame radio:(float)(i+1) / frameCount];
        CGRect br2 = [MathUtils radioRect:self.lastHitModel.birdFrame endRect:curHitModel.birdFrame radio:(float)(i+1) / frameCount];
        CGRect wrUnion = [MathUtils collectRectA:wr1 rectB:wr2];
        CGRect brUnion = [MathUtils collectRectA:br1 rectB:br2];
        if (!CGRectIsNull([MathUtils filterRectA:wrUnion rectB:brUnion])) {
            self.isHited = true;
            break;
        }
    }
    
    //5. 保留lastHitModel & 撞到时触发痛感 (参考29098-方案3-步骤2);
    NSLog(@"碰撞检测: %@ 棒(%.0f -> %.0f) 鸟(%.0f,%.0f -> %.0f,%.0f) from:%@",self.isHited ? @"撞到了" : @"没撞到",
          self.lastHitModel.woodFrame.origin.x,curHitModel.woodFrame.origin.x,
          self.lastHitModel.birdFrame.origin.x,self.lastHitModel.birdFrame.origin.y,
          curHitModel.birdFrame.origin.x,curHitModel.birdFrame.origin.y,hiterDesc);
    self.lastHitModel = curHitModel;
    if (self.isHited) {
        [self.birdView hurt];
    }
}

- (void) food2Pos:(CGPoint)targetPoint caller4RL:(NSString*)caller4RL{
    FoodView *foodView = [[FoodView alloc] init];
    [foodView hit];
    [foodView setOrigin:CGPointMake(ScreenWidth * 0.375f, ScreenHeight - 66)];
    [self.view addSubview:foodView];
    [UIView animateWithDuration:0.3f animations:^{
        [foodView setOrigin:targetPoint];
    }completion:^(BOOL finished) {
        //1. 视觉输入
        [self.birdView see:self.view];
        
        //2. 投食碰撞检测 (参考28172-todo2.2);
        if ([self birdView_GetFoodOnMouth]) {
            
            //3. 如果扔到鸟身上,则触发吃掉 (参考28172-todo2.1);
            [self.birdView touchMouth];
        }
        
        //4. 报强训结束标记 (投果结束);
        [theRT invoked:caller4RL];
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

//MARK:===============================================================
//MARK:                     < 小鸟出生地点 >
//MARK:===============================================================

//获取坐标;
-(CGPoint) getBirdBirthPos{
    if (self.birdBirthPos.x > 0 || self.birdBirthPos.y > 0) {
        return self.birdBirthPos;
    }else if (theApp.birthPosMode == 1) {
        return [self getBirdBirthPos_RandomCenter];
    }else if(theApp.birthPosMode == 2){
        return [self getBirdBirthPos_Center];
    }else{
        return [self getBirdBirthPos_Random];
    }
}

/**
 *  MARK:--------------------随机--------------------
 *  @desc 取值范围为离中心-80到80 (X和Y都是这范围);
 *  @desc 优缺点:
 *          1. 优点是: 限定的范围固定,不会离谱;
 *          2. 缺点是: 限定范围内每个位置的概率都一样;
 */
-(CGPoint) getBirdBirthPos_Random{
    //1. 取随机值 (范围-80到80);
    NSInteger areaW = ScreenWidth;
    NSInteger areaH = ScreenHeight - 100;
    float randomX = (arc4random() % areaW) - areaW * 0.5f;
    float randomY = (arc4random() % areaH) - areaH * 0.5f;
    
    //2. 转成左上角锚点;
    float x = randomX + ScreenWidth * 0.5f;
    float y = randomY + ScreenHeight * 0.5f;
    return CGPointMake(x, y);
}

/**
 *  MARK:--------------------随机偏中--------------------
 *  @desc 先根号,再平方,使使其离屏幕中心更近的概率更大,步骤举例如下:
 *          1. 限制出生范围 (比如宽200范围内);
 *          2. 我们要先取根号随机值 (取值范围为-10到10);
 *          3. 然后再二次方 (取值范围为-100到100);
 *          4. 再转换成绝对坐标返回 (ios锚点坐标系);
 *  @desc 优点:
 *          1. 限定的范围固定,不会离谱;
 *          2. 限定范围内离屏中心概率更大;
 *  @version
 *      2023.03.14: 缩小防撞第2步训练出生范围 (参考28174-试解);
 */
-(CGPoint) getBirdBirthPos_RandomCenter{
    //1. 取根值10;
    CGFloat areaW = 280;
    CGFloat areaH = 140;
    float modW = sqrtf(areaW * 0.5f);
    float modH = sqrtf(areaH * 0.5f);
    
    //2. 取随机值 (范围-10到10);
    float randomW = (arc4random() % (int)(modW * 2 + 0.5f)) - modW;
    float randomH = (arc4random() % (int)(modH * 2 + 0.5f)) - modH;
    
    //3. 求二次方,得出相对XY坐标 (范围-100到100);
    float relativeX = randomW * randomW * (randomW < 0 ? -1 : 1);
    float relativeY = randomH * randomH * (randomH < 0 ? -1 : 1);
    
    //4. 转成绝对XY坐标 (左上角锚点坐标系);
    float x = relativeX + ScreenWidth * 0.5f;
    float y = relativeY + ScreenHeight * 0.5f;
    return CGPointMake(x, y);
}

/**
 *  MARK:--------------------中心--------------------
 */
-(CGPoint) getBirdBirthPos_Center{
    return CGPointMake(ScreenWidth * 0.5f, ScreenHeight * 0.5f);
}

@end
