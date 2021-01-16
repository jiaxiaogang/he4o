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

-(void) fly:(CGFloat)value{
    //1. 数据检查
    value = MAX(MIN(1, value), 0);
    
    //2. 将从左顺时针: "0至1",转换为: "-1至1";
    CGFloat value_F1_1 = value * 2 - 1;
    
    //3. 将"-1至1",转为: "-180至180度";
    CGFloat angle = value_F1_1 * M_PI;
    
    //4. 用sin计算对边Y,cos计算邻边X;
    NSLog(@"fly >> %@ angle:%f",[NVHeUtil getLightStr_Value:value algsType:FLY_RDS dataSource:@""],value_F1_1 * 180);
    [UIView animateWithDuration:0.1f animations:^{
        [self setX:self.x + (cos(angle) * 30.0f)];
        [self setY:self.y + (sin(angle) * 30.0f)];
    }completion:^(BOOL finished) {
        //5. 飞后视觉
        [self see:[self.delegate birdView_GetPageView]];
    }];
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
-(void) touchWing:(int)direction{
    //1. 飞前视觉
    //[self see:[self.delegate birdView_GetPageView]];
    
    //2. 飞行
    float data = direction / 8.0f;
    [AIReactorControl commitReactor:FLY_RDS datas:@[@(data)]];
}

/**
 *  MARK:--------------------痛--------------------
 */
-(void) hurt{
    DemoLog(@"痛感");
    [AIInput commitIMV:MVType_Hurt from:0.0f to:1.0f];
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  MARK:--------------------吃--------------------
 *  @desc 无论是主动吃,还是被动吃,都要观察下吃前的视觉,吃后的视觉,以及价值上的影响;
 *  @desc 20200120 吃前视觉仅由被动吃时有,为解决外层死循环问题 (参考n18p5-BUG9)
 */
-(void) eat:(CGFloat)value{
    if (self.delegate && [self.delegate respondsToSelector:@selector(birdView_GetFoodOnMouth)]) {
        //1. 嘴附近的食物
        FoodView *foodView = [self.delegate birdView_GetFoodOnMouth];
        
        //2. 吃动作
        [UIView animateWithDuration:0.1f animations:^{
            [self.containerView.layer setTransform:CATransform3DMakeRotation(M_PI_4 * 0.5f, 0, 0, 1)];
        }completion:^(BOOL finished) {
            //3. 没坚果可吃 (计时器触发,更饿时,发现没坚果吃,并不能解决饥饿问题,参考:18084_todo1);
            if (!foodView){
            }else{
                //4. 吃掉 (让he以吸吮反射的方式,去主动吃;并将out入网,以抽象出"吃"的节点;参考n15p6-QT1)
                if(foodView.status == FoodStatus_Eat){
                    [foodView removeFromSuperview];
                }
            }
            
            //5. 吃完动作
            [UIView animateWithDuration:0.1f animations:^{
                [self.containerView.layer setTransform:CATransform3DIdentity];
            }completion:^(BOOL finished) {
                if (foodView) {
                    //6. 吃完视觉
                    [self see:[self.delegate birdView_GetPageView]];
                    if (foodView.status == FoodStatus_Eat) {
                        //7. 产生HungerMindValue;
                        [self sendHunger:1.0f];
                    }else if(foodView.status == FoodStatus_Border){
                        //8. 产生HurtMindValue (坚果带皮时,不仅吃不到,还得嘴疼);
                        [AIInput commitIMV:MVType_Hurt from:9.0f to:1.0f];
                    }
                }
            }];
        }];
    }
}

//MARK:===============================================================
//MARK:                     < outputObserver >
//MARK:===============================================================
-(void) outputObserver:(NSNotification*)notification{
    if (notification) {
        //1. 取数据
        NSDictionary *obj = DICTOOK(notification.object);
        NSString *identify = STRTOOK([obj objectForKey:kOOIdentify]);
        NSNumber *paramNum = NUMTOOK([obj objectForKey:kOOParam]);
        NSInteger type = [NUMTOOK([obj objectForKey:kOOType]) integerValue];
        
        //2. 吸吮反射 / 主动吃
        if ([EAT_RDS isEqualToString:identify]) {
            if (OutputObserverType_Front == type) {
            }else if(OutputObserverType_Back == type){
                //b. 吃后 => UI处理 & 视觉 & 产生mv;
                [self eat:[paramNum floatValue]];
            }
        }
        //3. 扇翅膀反射
        else if([FLY_RDS isEqualToString:identify]){
            if (OutputObserverType_Front == type) {
            }else if(OutputObserverType_Back == type){
                [self fly:[paramNum floatValue]];
            }
        }
        //4. 焦急反射
        else if([ANXIOUS_RDS isEqualToString:identify]){
            //1. 小鸟焦急时_扇翅膀;
            //[self see:[self.delegate birdView_GetPageView]];
            //CGFloat data = (arc4random() % 8) / 8.0f;
            //[AIReactorControl commitReactor:FLY_RDS datas:@[@(data)]];
            
            //2. 190731由飞改为叫;
            [theApp setTipLog:@"叽叽喳喳叫一叫"];
        }
    }
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------发送饥饿信号--------------------
 *  @desc 饥饿感 (0-10) (值越大越饿);
 */
-(void) sendHunger:(CGFloat)hungerDelta{
    DemoLog(@"饥饿感 %f",hungerDelta);
    [AIInput commitIMV:MVType_Hunger from:5.0f to:5.0 + hungerDelta];
}

@end
