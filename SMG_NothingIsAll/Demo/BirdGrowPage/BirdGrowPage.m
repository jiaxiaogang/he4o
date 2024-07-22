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

@interface BirdGrowPage ()<UIGestureRecognizerDelegate,BirdViewDelegate,WoodViewDelegate>

@property (strong,nonatomic) BirdView *birdView;
@property (strong,nonatomic) UITapGestureRecognizer *singleTap;
@property (strong,nonatomic) UITapGestureRecognizer *doubleTap;
@property (strong,nonatomic) UITapGestureRecognizer *threeTap;
@property (weak, nonatomic) IBOutlet UIView *farView;
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak, nonatomic) IBOutlet UIButton *throwWoodBtn;
@property (strong, nonatomic) WoodView *woodView;

@property (assign, nonatomic) BOOL waitHiting; //碰撞检测中 (当扔木棒中时,做碰撞检测);
@property (assign, nonatomic) BOOL isHited; //检测撞到了;
@property (strong, nonatomic) HitItemModel *lastHitModel;
@property (assign, nonatomic) CGRect lastWoodFrame;//用于木棒食物碰撞检测

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
    self.birdView.userInteractionEnabled = false;
    
    //3. threeTap
    self.threeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(threeTap:)];
    self.threeTap.numberOfTapsRequired = 3;
    self.threeTap.numberOfTouchesRequired = 1;
    self.threeTap.delegate = self;
    
    //3. doubleTap
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    self.doubleTap.numberOfTapsRequired = 2;
    self.doubleTap.numberOfTouchesRequired = 1;
    self.doubleTap.delegate = self;
    [self.doubleTap requireGestureRecognizerToFail:self.threeTap];
    
    //4. singleTap
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    self.singleTap.numberOfTapsRequired = 1;
    self.singleTap.numberOfTouchesRequired  = 1;
    self.singleTap.delegate = self;
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    [self.singleTap requireGestureRecognizerToFail:self.threeTap];
    
    //4. farView
    [self.farView addGestureRecognizer:self.singleTap];
    
    //5. borderView
    [self.borderView.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.borderView addGestureRecognizer:self.singleTap];
    [self.borderView addGestureRecognizer:self.doubleTap];
    [self.borderView addGestureRecognizer:self.threeTap];
    [self.borderView.layer setBorderWidth:20];
    
    //6. woodView
    self.woodView = [[WoodView alloc] init];
    self.woodView.delegate = self;
    [self.view addSubview:self.woodView];
}

-(void) initData{
    [super initData];
    [theRT regist:kFlySEL target:self selector:@selector(touchWingBlock:)];
    [theRT regist:kWoodLeftSEL target:self selector:@selector(throwWood_Left)];
    [theRT regist:kWoodRdmSEL target:self selector:@selector(throwWood_Rdm)];
    [theRT regist:kHungerSEL target:self selector:@selector(rtHungerBlock)];
    [theRT regist:kFoodRdmSEL target:self selector:@selector(randomThrowFood4Screen:)];
    [theRT regist:kFoodRdmNearSEL target:self selector:@selector(randomThrowFood4Near)];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.birdView.waitEat = false;
    [self.birdView viewWillDisappear];
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
        //0. 扔后判断能吃到哪些坚果;
        self.birdView.hitFoods = [self birdView_GetFoodOnHit:self.birdView.frame birdEnd:self.birdView.frame status:FoodStatus_Eat];
        //1. 吃前视觉
        [self.birdView see:self.view fromObserver:false];
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
-(void) randomThrowFood4Screen:(NSNumber*)statusNum {
    //1. 数据准备;
    int randomX = 20 + (arc4random() % (int)(ScreenWidth - 40));//屏内x为20到screenW-20;
    int randomY = 84 + (arc4random() % (int)(ScreenHeight - 168));//屏内y为84到screenW-84;
    FoodStatus status = NUMTOOK(statusNum).intValue;
    
    //2. 投食物
    [self food2Pos:CGPointMake(randomX, randomY) caller4RL:kFoodRdmSEL status:status];
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
    
    //2. 随机方向扔食物
    [self food2Pos:[self convertDirection2FoodPos:random] caller4RL:kFoodRdmNearSEL status:FoodStatus_Eat];
}

/**
 *  MARK:--------------------坚果方向转成坚果坐标--------------------
 *  @version
 *      2023.06.16: 坚果扔近些 (参考30024-修复);
 */
-(CGPoint) convertDirection2FoodPos:(int)direction {
    //1. 数据准备;
    CGPoint birdPos = self.birdView.center;
    int ziDis = 15 + 8 + (arc4random() % 14);//直线时,距离为23 -> 37之间;
    int xieDis = 15 + 8 + (arc4random() % 5);//斜线时,距离为23 -> 28之间;
    int douDon1 = (arc4random() % 6) - 3;//抖动距离正负3;
    int douDon2 = (arc4random() % 6) - 3;//抖动距离正负3;
    
    //2. 随机方向扔食物
    if (direction == 0) return CGPointMake(birdPos.x - ziDis + douDon1, birdPos.y + douDon2);//左
    else if (direction == 1) return CGPointMake(birdPos.x - xieDis + douDon1, birdPos.y - xieDis + douDon2);//左上
    else if (direction == 2) return CGPointMake(birdPos.x + douDon1, birdPos.y - ziDis + douDon2);//上
    else if (direction == 3) return CGPointMake(birdPos.x + xieDis + douDon1, birdPos.y - xieDis + douDon2);
    else if (direction == 4) return CGPointMake(birdPos.x + ziDis + douDon1, birdPos.y + douDon2);
    else if (direction == 5) return CGPointMake(birdPos.x + xieDis + douDon1, birdPos.y + xieDis + douDon2);
    else if (direction == 6) return CGPointMake(birdPos.x + douDon1, birdPos.y + ziDis + douDon2);
    else if (direction == 7) return CGPointMake(birdPos.x - xieDis + douDon1, birdPos.y + xieDis + douDon2);
    return birdPos;
}

//单击投食
- (void)singleTap:(UITapGestureRecognizer *)tapRecognizer{
    [self clickTap4Food_General:tapRecognizer status:FoodStatus_Eat];
}

//因点击而投食
- (void)clickTap4Food_General:(UITapGestureRecognizer *)tapRecognizer status:(FoodStatus)status{
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
        [self food2Pos:targetPoint caller4RL:nil status:status];
    }
}

//双击投带皮坚果
- (void)doubleTap:(UITapGestureRecognizer *)tapRecognizer{
    [self clickTap4Food_General:tapRecognizer status:FoodStatus_Border];
}

//三击飞行
- (void)threeTap:(UITapGestureRecognizer *)tapRecognizer{
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
    [self food2Pos:[self convertDirection2FoodPos:0] caller4RL:nil status:FoodStatus_Eat];
}
- (IBAction)foodLeftUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-左上");
    [self food2Pos:[self convertDirection2FoodPos:1] caller4RL:nil status:FoodStatus_Eat];
}
- (IBAction)foodUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-上");
    [self food2Pos:[self convertDirection2FoodPos:2] caller4RL:nil status:FoodStatus_Eat];
}
- (IBAction)foodRightUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-右上");
    [self food2Pos:[self convertDirection2FoodPos:3] caller4RL:nil status:FoodStatus_Eat];
}
- (IBAction)foodRightOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-右");
    [self food2Pos:[self convertDirection2FoodPos:4] caller4RL:nil status:FoodStatus_Eat];
}
- (IBAction)foodRightDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-右下");
    [self food2Pos:[self convertDirection2FoodPos:5] caller4RL:nil status:FoodStatus_Eat];
}
- (IBAction)foodDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-下");
    [self food2Pos:[self convertDirection2FoodPos:6] caller4RL:nil status:FoodStatus_Eat];
}
- (IBAction)foodLeftDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"远投-左下");
    [self food2Pos:[self convertDirection2FoodPos:7] caller4RL:nil status:FoodStatus_Eat];
}

/**
 *  MARK:--------------------饥饿是连续的mv输入 (参考28171-todo2)--------------------
 *  @version
 *      2023.06.16: 更饿间隔由5调长成8 (参考30024-修复);
 *      2023.06.26: 支持持续饿感 (参考30042-todo1);
 *      2023.06.26: 支持饿后视觉 (参考30042-todo2);
 */
- (IBAction)hungerBtnOnClick:(id)sender {
    ISTitleLog(@"感官输入");
    //DemoLog(@"马上饿onClick");
    //[theApp.heLogView addDemoLog:@"马上饿onClick"];
    
    //2. 触发饿感 (手动的执行999轮)
    self.birdView.waitEat = true;
    [self hungerSingle:999];
}

- (void) rtHungerBlock {
    ISTitleLog(@"感官输入");
    
    //2. 触发饿感 (强训仅执行3轮)
    self.birdView.waitEat = true;
    [self hungerSingle:3];
    
    //3. 强训工具需要等待第2次更饿后,才能继续训练下轮;
    [theRT appendPauseNames:@[kMainPageSEL]];
    
    //4. 报强训结束标记;
    [theRT invoked:kHungerSEL];
}

-(void) hungerSingle:(int)invokedCount {
    //0. 数据准备;
    if (!self.birdView.waitEat) {
        [theRT clearPauseNames];//吃上坚果后,就不等待持续饿循环了;
        return;
    }
    
    //1. 先感觉到饿: 从0.7饿到0.6 (按0.6计算得迫切度为16);
    [[[DemoHunger alloc] init] commit:0.6 state:UIDeviceBatteryStateUnplugged];
    NSLog(@"触发饿感:%d",invokedCount);
    
    //2. 执行计数 (执行完后,强训工具继续);
    invokedCount--;
    if (invokedCount <= 0) {
        [theRT clearPauseNames];
        return;
    }
    
    //3. 五秒后更饿: 从0.6饿到0.5 (按0.5计算得迫切度为25);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hungerSingle:invokedCount];
    });
    
    //4. 饿后视觉 (参考30042-todo2);
    [self.birdView see:self.view fromObserver:false];
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

//MARK:===============================================================
//MARK:                     < 摸脚按钮 >
//MARK:===============================================================
- (IBAction)touchFootBtnOnClick:(id)sender {
    [self touchFootBlock:nil];
}

- (void)touchFootBlock:(NSNumber*)direction {
    ISTitleLog(@"现实世界");
    DemoLog(@"摸脚onClick");
    //1. 计算random
    long random = arc4random() % 8;
    
    //7. 指定方向参数时;
    if (direction) {
        random = NUMTOOK(direction).longValue;
        NSLog(@"强训kick >> %@",[NVHeUtil getLightStr_Value:random / 8.0f algsType:KICK_RDS dataSource:@""]);
    }
    [self.birdView touchFoot:random];
}
- (IBAction)touchFootLeftOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸脚onClick-左");
    [self.birdView touchFoot:0];
}
- (IBAction)touchFootLeftUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸脚onClick-左上");
    [self.birdView touchFoot:1];
}
- (IBAction)touchFootUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸脚onClick-上");
    [self.birdView touchFoot:2];
}
- (IBAction)touchFootRightUpOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸脚onClick-右上");
    [self.birdView touchFoot:3];
}
- (IBAction)touchFootRightOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸脚onClick-右");
    [self.birdView touchFoot:4];
}
- (IBAction)touchFootRightDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸脚onClick-右下");
    [self.birdView touchFoot:5];
}
- (IBAction)touchFootDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸脚onClick-下");
    [self.birdView touchFoot:6];
}
- (IBAction)touchFootLeftDownOnClick:(id)sender {
    [self animationFlash:sender];
    DemoLog(@"摸脚onClick-左下");
    [self.birdView touchFoot:7];
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
    [self.birdView see:self.woodView fromObserver:false];
    
    //3. 扔前数据准备
    CGFloat allDistance = ScreenWidth - self.woodView.x; //动画扔多远;
    CGFloat allTime = allDistance / ScreenWidth * ThrowTime; //动画总时长
    DemoLog(@"扔木棒 (时:%.2f 距:%.2f)",allTime,allDistance);
    self.waitHiting = true;
    
    //4. 扔出: step动画仅执行一轮 (参考29098-方案3-步骤4);
    [self.woodView throwV5:x time:allTime distance:allDistance invoked:invoked];
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
-(NSArray *)birdView_GetFoodOnHit:(CGRect)birdStart birdEnd:(CGRect)birdEnd status:(FoodStatus)status{
    return [self runCheckHit4BirdFood:birdStart birdEnd:birdEnd status:status];
}

-(UIView*) birdView_GetPageView{
    return self.view;
}

-(CGRect)birdView_GetSeeRect{
    return CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64 - 64);//naviBar和btmBtn
}

//2023.06.04: 废弃_将setFramed换成动画开始,二者是同时触发的,但setFramed有两个问题,1是无法传过来动画时间,2是它会触发两次;
-(void)birdView_SetFramed {
    //[self runCheckHit4WoodBird:@"鸟位置变化"];
}

-(void)birdView_FlyAnimationFinish {
    //[self runCheckHit4WoodBird:0 woodDuration:0 hiterDesc:@"鸟飞结束"];//动画执行完后,要调用下碰撞检测,因为UIView动画后不会立马更新frame (参考29098-追BUG1);
}

-(void) birdView_FlyAnimationBegin:(CGFloat)aniDuration {
    //[self runCheckHit4WoodBird:aniDuration woodDuration:0 hiterDesc:@"鸟飞开始"];
}

-(void) birdView_HungerEnd {
    [[[DemoHunger alloc] init] commit:0.7 state:UIDeviceBatteryStateCharging];
}

/**
 *  MARK:--------------------WoodViewDelegate--------------------
 */

//2023.06.04: 废弃_将setFramed换成动画开始,二者是同时触发的,但setFramed有两个问题,1是无法传过来动画时间,2是它会触发两次;
-(void)woodView_SetFramed {
    [self runCheckHit4WoodBird:0 woodDuration:0 hiterDesc:@"棒扔位置变化"];
    [self runCheckHit4WoodFood];
}

-(void) woodView_WoodAnimationFinish {
    [self runCheckHit4WoodBird:0 woodDuration:0 hiterDesc:@"棒扔结束"];//动画执行完后,要调用下碰撞检测,因为UIView动画后不会立马更新frame (参考29098-追BUG1);
    self.waitHiting = false;//木棒动画结束时,同时碰撞检测也结束;
}

-(void) woodView_FlyAnimationBegin:(CGFloat)aniDuration {
    //[self runCheckHit4WoodBird:0 woodDuration:aniDuration hiterDesc:@"棒扔开始"];
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
 *  @param birdDuration : 当前触发的动画到结束所需动画时长 (用来计算碰撞检测,比如鸟飞的很快,下次触发时却过了很久,不能均匀的认为它飞了这么久);
 *  @callers 检查中状态时,只要木棒或小鸟的位置有变化,就调用:
 *          1. 无论是木棒还是小鸟的frame变化都调用 (参考29098-方案3-步骤1);
 *          2. 无论是木棒还是小鸟的动画结束时,都手动调用下 (因为UIView动画后不会立马更新frame);
 *  @version
 *      2023.06.09: 修复因分母为0,导致分帧rect取到NaN,导致交集全判为撞到的BUG (参考30015);
 *      2023.07.26: 改为每帧木棒变动都进行碰撞检测 & 且改为帧动画后不需要每次调用再分10帧了改为2 (参考30087-todo2);
 */
-(void) runCheckHit4WoodBird:(CGFloat)birdDuration woodDuration:(CGFloat)woodDuration hiterDesc:(NSString*)hiterDesc {
    //1. 非检查中 或 已检测到碰撞 => 返回;
    if (!self.waitHiting || self.isHited) return;
    
    //2. 当前帧model;
    HitItemModel *curHitModel = [[HitItemModel alloc] init];
    curHitModel.woodFrame = self.woodView.showFrame;
    curHitModel.birdFrame = self.birdView.showFrame;
    curHitModel.time = [[NSDate date] timeIntervalSince1970] * 1000;
    curHitModel.birdDuration = birdDuration;
    curHitModel.woodDuration = woodDuration;
    
    //3. 上帧为空时,直接等于当前帧;
    if (self.lastHitModel == nil) {
        self.lastHitModel = curHitModel;
        return;
    }
    
    //4. 分10帧,检查每帧棒鸟是否有碰撞 (参考29098-方案3-步骤3);
    CGFloat totalTime = curHitModel.time - self.lastHitModel.time; //总共过了多久;
    CGFloat woodTime = self.lastHitModel.woodDuration == 0 ? totalTime : self.lastHitModel.woodDuration * 1000; //木棒扔了多久;
    CGFloat birdTime = self.lastHitModel.birdDuration == 0 ? totalTime : self.lastHitModel.birdDuration * 1000; //小鸟飞了多久;
    CGFloat firstCheckTime = MIN(totalTime,MIN(woodTime,birdTime)); //先把检查指定时间的(比如bird动画开始指定了0.15s);
    NSInteger frameCount = 2;
    CGFloat itemTime = firstCheckTime / frameCount; //在下面循环中每份i过了多久;
    for (NSInteger i = 0; i < frameCount; i++) {
        //5. 取上下等份的Rect取并集,避免两等份间距过大,导致错漏检测问题 (参考29098-测BUG2);
        CGFloat wrRadio1 = woodTime == 0 ? 0 : i * itemTime / woodTime, wrRadio2 = woodTime == 0 ? 0 : (i+1) * itemTime / woodTime;
        CGFloat brRadio1 = birdTime == 0 ? 0 : i * itemTime / birdTime, brRadio2 = birdTime == 0 ? 0 : (i+1) * itemTime / birdTime;
        CGRect wr1 = [MathUtils radioRect:self.lastHitModel.woodFrame endRect:curHitModel.woodFrame radio:wrRadio1];
        CGRect br1 = [MathUtils radioRect:self.lastHitModel.birdFrame endRect:curHitModel.birdFrame radio:brRadio1];
        CGRect wr2 = [MathUtils radioRect:self.lastHitModel.woodFrame endRect:curHitModel.woodFrame radio:wrRadio2];
        CGRect br2 = [MathUtils radioRect:self.lastHitModel.birdFrame endRect:curHitModel.birdFrame radio:brRadio2];
        CGRect wrUnion = [MathUtils collectRectA:wr1 rectB:wr2];
        CGRect brUnion = [MathUtils collectRectA:br1 rectB:br2];
        if (CGRectIntersectsRect(wrUnion, brUnion)) {
            self.isHited = true;
            break;
        }
    }
    
    //6. 前段没执行完,后段再执行下检查;
    if (!self.isHited && firstCheckTime != totalTime) {
        //a. wr1br1就是前段的结尾处;
        CGFloat wrRadio1 = woodTime == 0 ? 0 : firstCheckTime / woodTime, brRadio1 = birdTime == 0 ? 0 : firstCheckTime / birdTime;
        CGRect wr1 = [MathUtils radioRect:self.lastHitModel.woodFrame endRect:curHitModel.woodFrame radio:wrRadio1];
        CGRect br1 = [MathUtils radioRect:self.lastHitModel.birdFrame endRect:curHitModel.birdFrame radio:brRadio1];
        //b. wr2br2直接就是最结尾,即curHitModel的位置;
        CGRect wr2 = curHitModel.woodFrame;
        CGRect br2 = curHitModel.birdFrame;
        //c. 后段碰撞检测;
        CGRect wrUnion = [MathUtils collectRectA:wr1 rectB:wr2];
        CGRect brUnion = [MathUtils collectRectA:br1 rectB:br2];
        if (CGRectIntersectsRect(wrUnion, brUnion)) {
            self.isHited = true;
        }
    }
    
    //5. 保留lastHitModel & 撞到时触发痛感 (参考29098-方案3-步骤2);
    if (self.isHited) {
        NSLog(@"碰撞检测: %@ 棒(%.0f -> %.0f) 鸟(%.0f,%.0f -> %.0f,%.0f) from:%@",self.isHited ? @"撞到了" : @"没撞到",
              self.lastHitModel.woodFrame.origin.x,curHitModel.woodFrame.origin.x,
              self.lastHitModel.birdFrame.origin.x,self.lastHitModel.birdFrame.origin.y,
              curHitModel.birdFrame.origin.x,curHitModel.birdFrame.origin.y,hiterDesc);
    }
    self.lastHitModel = curHitModel;
    if (self.isHited) {
        [self.birdView hurt];
    }
}

//木棒与食物碰撞检测
-(void) runCheckHit4WoodFood {
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *foods = [SMGUtils filterArr:[self.view subViews_AllDeepWithClass:FoodView.class] checkValid:^BOOL(FoodView *item) {
        return item.status == FoodStatus_Border;
    }];
    
    //3. 上帧为空时,直接等于当前帧;
    if (CGRectIsNull(self.lastWoodFrame)) {
        self.lastWoodFrame = self.woodView.showFrame;
    }
    
    //4. 分10帧,检查每帧棒鸟是否有碰撞 (参考29098-方案3-步骤3);
    NSInteger frameCount = 3;
    for (NSInteger i = 0; i < frameCount; i++) {
        //5. 取上下等份的Rect取并集,避免两等份间距过大,导致错漏检测问题 (参考29098-测BUG2);
        CGFloat radio1 = i / (float)frameCount, radio2 = (i+1) / (float)frameCount;
        CGRect wr1 = [MathUtils radioRect:self.lastWoodFrame endRect:self.woodView.showFrame radio:radio1];
        CGRect wr2 = [MathUtils radioRect:self.lastWoodFrame endRect:self.woodView.showFrame radio:radio2];
        CGRect wrUnion = [MathUtils collectRectA:wr1 rectB:wr2];
        
        //6. 分别与每个food进行碰撞检测;
        for (FoodView *food in foods) {
            if (CGRectIntersectsRect(wrUnion, food.showFrame)) {
                if (![result containsObject:food]) [result addObject:food];
                continue;
            }
        }
    }
    
    //7. 压到破皮;
    for (FoodView *item in result) {
        item.status = FoodStatus_Eat;
    }
    if (ARRISOK(result)) NSLog(@"碰撞检测,棒压坚果数:%ld 棒(%.0f -> %.0f)",result.count,self.lastWoodFrame.origin.x,self.woodView.showX);
    
    //8. 保留lastWoodFrame
    self.lastWoodFrame = self.woodView.showFrame;
    
    //9. 触发视觉
    if (ARRISOK(result)) {
        [self.birdView see:self.view fromObserver:false];
    }
}

/**
 *  MARK:--------------------坚果碰撞检测算法 (参考30041-记录3-方案)--------------------
 *  @desc 1. 食物不会动,只需要判断鸟飞过的轨迹分帧,有没有路过坚果即可 (每dp一帧);
 *        2. 坐标说明: 不用世界坐标,因为bird,wood,food全在self.view下;
 *  @version
 *      2023.06.23: 初版,解决飞的太快,导致飞过却没吃到的BUG (参考30041-记录3);
 */
-(NSArray*) runCheckHit4BirdFood:(CGRect)birdStart birdEnd:(CGRect)birdEnd status:(FoodStatus)status{
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *foods = ARRTOOK([self.view subViews_AllDeepWithClass:FoodView.class]);
    
    //2. dp距离每点一帧,检查每帧坚果鸟是否有碰撞 (参考30041-记录3-方案);
    float distance = [UIView distance4DP:birdStart.origin pointB:birdEnd.origin];
    for (NSInteger i = 0; i <= distance; i++) {
        CGFloat brRadio = distance == 0 ? 0 : i / distance;
        CGRect birdIFrame = [MathUtils radioRect:birdStart endRect:birdEnd radio:brRadio];
        for (FoodView *food in foods) {
            if (food.status == status && ![result containsObject:food] && CGRectIntersectsRect(birdIFrame, food.frame)) {
                [result addObject:food];
            }
        }
    }
    
    //3. 保留lastHitModel & 撞到时触发痛感 (参考29098-方案3-步骤2);
    NSLog(@"碰撞检测到坚果数: %ld 鸟(%.0f,%.0f -> %.0f,%.0f)",result.count,birdStart.origin.x,birdStart.origin.y,birdEnd.origin.x,birdEnd.origin.y);
    return result;
}

- (void) food2Pos:(CGPoint)targetPoint caller4RL:(NSString*)caller4RL status:(FoodStatus)status{
    FoodView *foodView = [[FoodView alloc] init];
    foodView.status = status;
    [foodView setOrigin:CGPointMake(ScreenWidth * 0.375f, ScreenHeight - 66)];
    [self.view addSubview:foodView];
    [UIView animateWithDuration:0.3f animations:^{
        [foodView setOrigin:targetPoint];
    }completion:^(BOOL finished) {
        //1. 视觉输入
        [self.birdView see:self.view fromObserver:false];
        
        //2. 投食碰撞检测 (参考28172-todo2.2);
        self.birdView.hitFoods = [self birdView_GetFoodOnHit:self.birdView.frame birdEnd:self.birdView.frame status:FoodStatus_Eat];
        if (ARRISOK(self.birdView.hitFoods)) {
            
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
    }else if(theApp.birthPosMode == 3){
        return [self getBirdBirthPos_RandomSafe];
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

/**
 *  MARK:--------------------安全地带随机--------------------
 *  @desc 支持在安全地带出生,以方便训练去皮等,避免动不动疼干扰训练 (参考30145-注1);
 */
-(CGPoint) getBirdBirthPos_RandomSafe{
    //1. 随机x值 (X取值范围: 20 到 ScreenWidth - 50);
    float minX = 20,maxX = ScreenWidth - 50;
    int xDelta = maxX - minX;
    float resultX = (arc4random() % xDelta) + minX;
    
    //2. 随机y值 => 算出最大最小值;
    float minY = 0,maxY = 0;
    if (random() % 2 == 0) {
        //a. 在路上方 (上方时Y取值范围: 64 到 (ScreenHeight - 100) * 0.5f - 30 - 1; //多减1避免撞上);
        minY = 64;
        maxY = (ScreenHeight - 100) * 0.5f - 30 - 1;
    } else {
        //b. 在路下方 (下方时Y取值范围: (ScreenHeight + 100) * 0.5f + 1 到 ScreenHeight - 64 - 30; //多加1避免撞上);
        minY = (ScreenHeight + 100) * 0.5f + 1;
        maxY = ScreenHeight - 64 - 30;
    }
    
    //3. 随机y值 => 算出resultY;
    int yDelta = maxY - minY;
    float resultY = (arc4random() % yDelta) + minY;
    
    //4. 要求返回中心点坐标,所以xy各加15;
    return CGPointMake(resultX + 15, resultY + 15);
}

@end
