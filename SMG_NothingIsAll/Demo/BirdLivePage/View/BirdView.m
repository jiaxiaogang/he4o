//
//  BirdView.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/7.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "BirdView.h"
#import "FoodView.h"
#import "AIReactorControl.h"
#import "NVHeUtil.h"

@interface BirdView ()

@property (strong,nonatomic) IBOutlet UIView *containerView;

@end

@implementation BirdView

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
    [self setBackgroundColor:[UIColor clearColor]];
    [self setFrame:CGRectMake(100, 100, 30, 30)];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView setFrame:CGRectMake(0, 0, 30, 30)];
}

-(void) initData{
}

-(void) initDisplay{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputObserver:) name:kOutputObserver object:nil];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) flyAction:(CGFloat)value{
    //1. 数据检查
    value = MAX(MIN(1, value), 0);
    
    //2. 将从左顺时针: "0至1",转换为: "-1至1";
    CGFloat value_F1_1 = value * 2 - 1;
    
    //3. 将"-1至1",转为: "-180至180度";
    CGFloat angle = value_F1_1 * M_PI;
    CGFloat distance = 30;
    CGFloat time = 0.15f;
    CGFloat xDistance = (cos(angle) * distance);
    CGFloat yDistance = (sin(angle) * distance);
    CGFloat xSpeed = xDistance / time, ySpeed = yDistance / time;
    CGPoint protoPos = self.origin;
    
    //4. 用sin计算对边Y,cos计算邻边X;
    NSLog(@"fly >> %@ angle:%.0f",[NVHeUtil getLightStr_Value:value algsType:FLY_RDS dataSource:@""],value_F1_1 * 180);
    UIDynamicAnimator *dyAnimator = nil;
    
    //5. 自定义力 及 item属性
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
    itemBehavior.allowsRotation = false; //禁止被撞的旋转
    itemBehavior.density = 0; //密度 (默认1,设为0时也能撞到,不知道啥意思);
    itemBehavior.friction = 0; //摩擦力
    itemBehavior.resistance = 0; //线性阻力
    [itemBehavior addLinearVelocity:CGPointMake(xSpeed / 100, ySpeed / 100) forItem:self]; //线性速度
    [dyAnimator addBehavior:itemBehavior];
    
    //6. finish
    __block typeof(itemBehavior) weakItemBehavior = itemBehavior;
    itemBehavior.action = ^{
        
        //7. 距离飞够后移除线性力;
        CGFloat aleardayDistance = [NVViewUtil distancePoint:protoPos second:self.origin];
        if (aleardayDistance > distance) {
            [dyAnimator removeBehavior:weakItemBehavior];
            
            //8. 指定目标位置;
            [self setX:self.x + xDistance];
            [self setY:self.y + yDistance];
            
            //9. 飞后与坚果碰撞检测 (参考28172-todo2.2);
            if ([self.delegate birdView_GetFoodOnMouth]) {
                
                //10. 如果飞到坚果上,则触发吃掉 (参考28172-todo2.1);
                [self touchMouth];
            }
            //11. 强训飞完报告;
            [theRT invoked:kFlySEL];
        }
    };
}
-(void) flyResult:(CGFloat)value{
    //1. 飞后视觉
    [self see:[self.delegate birdView_GetPageView]];
}

-(void) see:(UIView*)view{
    if (self.delegate && [self.delegate respondsToSelector:@selector(birdView_GetSeeRect)]) {
        //1. 将视觉范围下,的视觉信息输入大脑;
        CGRect rect = [self.delegate birdView_GetSeeRect];
        [AIInput commitView:self targetView:view rect:rect];
    }
}

//被动吃
-(void) touchMouth{
    //2. 吃
    [AIReactorControl commitReactor:EAT_RDS];
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)mouchOnClick:(id)sender {
    DemoLog(@"鸟嘴 吸吮反射");
    [self touchMouth];
}

/**
 *  MARK:--------------------摸翅膀--------------------
 *  @param direction 从左顺时针,8个方向,分别为0-7;
 */
-(void) touchWing:(long)direction {
    //1. 飞前视觉
    //[self see:[self.delegate birdView_GetPageView]];
    
    //2. 飞行
    float data = direction / 8.0f;
    [AIReactorControl commitReactor:FLY_RDS datas:@[@(data)]];
}

/**
 *  MARK:--------------------痛--------------------
 *  @version
 *      2021.01.25: 加大痛感,否则不痛不痒的思维没活力 (乌鸦不care);
 */
-(void) hurt{
    DemoLog(@"痛感");
    [AIInput commitIMV:MVType_Hurt from:2.0f to:3.0f];
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  MARK:--------------------吃--------------------
 *  @desc 无论是主动吃,还是被动吃,都要观察下吃前的视觉,吃后的视觉,以及价值上的影响;
 *  @version
 *      2020.01.20: 吃前视觉仅由被动吃时有,为解决外层死循环问题 (参考n18p5-BUG9);
 *      2023.03.11: 吃上了,不会立马感觉饱,而是不再继续更饿 (参考28171-todo2);
 */
-(void) eatAction:(CGFloat)value{
    //1. 吃动作
    [UIView animateWithDuration:0.1f animations:^{
        [self.containerView.layer setTransform:CATransform3DMakeRotation(M_PI_4 * 0.5f, 0, 0, 1)];
    }completion:^(BOOL finished) {
        //2. 吃完动作
        [UIView animateWithDuration:0.1f animations:^{
            [self.containerView.layer setTransform:CATransform3DIdentity];
        }completion:^(BOOL finished) {
            [theRT invoked:kEatSEL];
        }];
    }];
}
-(void) eatResult:(CGFloat)value{
    if (self.delegate && [self.delegate respondsToSelector:@selector(birdView_GetFoodOnMouth)]) {
        //1. 嘴附近的食物
        FoodView *foodView = [self.delegate birdView_GetFoodOnMouth];
        
        //2. 吃掉UI (计时器触发,更饿时,发现没坚果吃,并不能解决饥饿问题,参考:18084_todo1);
        if (foodView){
            //3. 吃掉 (让he以吸吮反射的方式,去主动吃;并将out入网,以抽象出"吃"的节点;参考n15p6-QT1)
            if(foodView.status == FoodStatus_Eat){
                [foodView removeFromSuperview];
            }
            
            //4. 吃完视觉 (其实啥也看不到);
            [self see:[self.delegate birdView_GetPageView]];
            
            //5. 价值变化;
            if (foodView.status == FoodStatus_Eat) {
                //a. 吃上了,不会立马感觉饱,而是不再继续更饿 (参考28171-todo2);
                DemoLog(@"吃上坚果了");
                self.waitEat = false;
            }else if(foodView.status == FoodStatus_Border){
                //b. 产生HurtMindValue (坚果带皮时,不仅吃不到,还得嘴疼);
                [AIInput commitIMV:MVType_Hurt from:2.0f to:3.0f];
            }
        }else{
            //3. 没坚果可吃 (计时器触发,更饿时,发现没坚果吃,并不能解决饥饿问题,参考:18084_todo1);
        }
    }
}

//MARK:===============================================================
//MARK:                     < outputObserver >
//MARK:===============================================================
-(void) outputObserver:(NSNotification*)notification{
    if (notification && ISOK(notification.object, OutputModel.class)) {
        //1. 取数据
        OutputModel *model = (OutputModel*)notification.object;
        
        //2. 吸吮反射 / 主动吃
        if ([EAT_RDS isEqualToString:model.identify]) {
            if (OutputObserverType_Front == model.type) {
                //b. 吃前 => 行为动画;
                [self eatAction:[model.data floatValue]];
                model.useTime = 0.2f;
            }else if(OutputObserverType_Back == model.type){
                //b. 吃后 => 世界变化 & 视觉 & 产生mv;
                [self eatResult:[model.data floatValue]];
            }
        }
        //3. 扇翅膀反射
        else if([FLY_RDS isEqualToString:model.identify]){
            if (OutputObserverType_Front == model.type) {
                //a. 飞前 => 行为动画;
                NSLog(@"飞前视觉%p:%@",model,[NVHeUtil fly2Str:model.data.floatValue]);
                [self flyAction:[model.data floatValue]];
                model.useTime = 0.1f;
            }else if(OutputObserverType_Back == model.type){
                //b. 飞后 => 视觉;
                NSLog(@"飞后视觉%p:%@",model,[NVHeUtil fly2Str:model.data.floatValue]);
                [self flyResult:[model.data floatValue]];
            }
        }
        //4. 焦急反射
        else if([ANXIOUS_RDS isEqualToString:model.identify]){
            //1. 小鸟焦急时_扇翅膀;
            //[self see:[self.delegate birdView_GetPageView]];
            //CGFloat data = (arc4random() % 8) / 8.0f;
            //[AIReactorControl commitReactor:FLY_RDS datas:@[@(data)]];
            
            //2. 190731由飞改为叫;
            [theApp setTipLog:@"叽叽喳喳叫一叫"];
        }
    }
}

@end
