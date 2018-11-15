//
//  TestHungryPage.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "TestHungryPage.h"
#import "DemoHunger.h"
#import "DemoCharge.h"
#import "AIInput.h"
#import "Output.h"

@interface TestHungryPage ()<UITextFieldDelegate,OutputDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *subBtn;
@property (weak, nonatomic) IBOutlet UIButton *eatStartBtn;
@property (weak, nonatomic) IBOutlet UIButton *eatStopBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UITextField *tf;
@property (weak, nonatomic) IBOutlet UISlider *hungerLevelSlider;
@property (weak, nonatomic) IBOutlet UILabel *hungerLevelLab;
@property (weak, nonatomic) IBOutlet UIButton *thinkStatusBtn;
@property (weak, nonatomic) IBOutlet UILabel *aiOutputLab;

@property (assign, nonatomic) CGFloat lastSliderValue;
@property (strong,nonatomic) NSTimer *timer;            //计时器
@property (strong, nonatomic) NSMutableString *outputMStr;

@end

@implementation TestHungryPage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    [self initDisplay];
}

-(void) initView{
    //1. self
    self.title = @"充电演示";
    
    //2. tf
    self.tf.delegate = self;
    [self.tf setReturnKeyType:UIReturnKeyGo];
    
    //3. hungerLevelLab
    [self.hungerLevelLab setText:STRFORMAT(@"%.2f",self.hungerLevelSlider.value)];
    [self.hungerLevelLab setTextColor:self.hungerLevelSlider.value > 0.7 ? [UIColor greenColor] : [UIColor redColor]];
    
    //4. thinkStatusBtn
    [self.thinkStatusBtn.layer setCornerRadius:5];
    [self.thinkStatusBtn.layer setMasksToBounds:true];
}

-(void) initData{
    [Output sharedInstance].delegate = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
    self.outputMStr = [[NSMutableString alloc] init];
}

-(void) initDisplay{
    //2,thinkStatusBtn
    [self.thinkStatusBtn setBackgroundColor:[UIColor greenColor]];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) refreshDisplay_HungerLevelLab{
    NSString *value = STRFORMAT(@"%.3f",self.hungerLevelSlider.value);
    [self.hungerLevelLab setText:value];
    [self.hungerLevelLab setTextColor:self.hungerLevelSlider.value > 0.7 ? [UIColor greenColor] : [UIColor redColor]];
}

- (void)notificationTimer{
    NSString *oldText = self.aiOutputLab.text;
    if (oldText.length < self.outputMStr.length) {
        [self.aiOutputLab setText:[self.outputMStr substringToIndex:oldText.length + 1]];
    }else{
        [self.aiOutputLab setText:self.outputMStr];
    }
}

/**
 *  MARK:--------------------onclick--------------------
 */
- (IBAction)addBtnOnClick:(id)sender {
    [[[DemoHunger alloc] init] commit:0.9 state:UIDeviceBatteryStateCharging];
}

- (IBAction)subBtnOnClick:(id)sender {
    [[[DemoHunger alloc] init] commit:0.7 state:UIDeviceBatteryStateUnplugged];
}

- (IBAction)eatStartBtnOnClick:(id)sender {
    [[[DemoCharge alloc] init] commit:HungerState_Charging];
}

- (IBAction)eatStopBtnOnClick:(id)sender {
    [[[DemoCharge alloc] init] commit:HungerState_Unplugged];
}

- (IBAction)confirmBtnOnClick:(id)sender {
    if (STRISOK(self.tf.text)) {
        [theInput commitText:self.tf.text];
        self.tf.text = nil;
    }
}

- (IBAction)hungerLevelSliderValueChanged:(id)sender {
    //1. 数据
    CGFloat curValue = self.hungerLevelSlider.value;
    UIDeviceBatteryState state = self.lastSliderValue > curValue ? UIDeviceBatteryStateUnplugged : UIDeviceBatteryStateCharging;
    
    //2. 提交变化
    [[[DemoHunger alloc] init] commit:curValue state:state];
    
    //3. 记录当前值
    self.lastSliderValue = curValue;
}

- (IBAction)thinkBtnOnClick:(id)sender {
    
}

/**
 *  MARK:--------------------UITextFieldDelegate--------------------
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self confirmBtnOnClick:self.confirmBtn];
    return true;
}

/**
 *  MARK:--------------------OutputDelegate--------------------
 */
-(void)output_Text:(char)c{
    [self.outputMStr appendFormat:@"%c",c];
    if (self.outputMStr.length > 100) {
        NSString *subStr = [self.outputMStr substringFromIndex:self.outputMStr.length - 100];
        self.outputMStr = [[NSMutableString alloc] initWithString:subStr];
    }
}

@end
