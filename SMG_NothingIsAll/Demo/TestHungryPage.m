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
@property (weak, nonatomic) IBOutlet UIButton *canceBtn;
@property (weak, nonatomic) IBOutlet UISlider *hungerLevelSlider;
@property (weak, nonatomic) IBOutlet UILabel *hungerLevelLab;
@property (weak, nonatomic) IBOutlet UIButton *thinkStatusBtn;
@property (weak, nonatomic) IBOutlet UIButton *mainThreadStatusBtn;
@property (weak, nonatomic) IBOutlet UITextField *logCountTF;
@property (weak, nonatomic) IBOutlet UILabel *aiOutputLab;

@property (assign, nonatomic) CGFloat lastSliderValue;

@end

@implementation TestHungryPage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    [self initDisplay];
}

-(void) initView{
    //1,tf
    self.tf.delegate = self;
    [self.tf setReturnKeyType:UIReturnKeyGo];
    
    //2,hungerLevelLab
    [self.hungerLevelLab setText:STRFORMAT(@"%.2f",self.hungerLevelSlider.value)];
    [self.hungerLevelLab setTextColor:self.hungerLevelSlider.value > 0.7 ? [UIColor greenColor] : [UIColor redColor]];
    
    //3,mainThreadStatusBtn
    [self.mainThreadStatusBtn.layer setCornerRadius:3];
    [self.mainThreadStatusBtn.layer setMasksToBounds:true];
    [self.mainThreadStatusBtn.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.mainThreadStatusBtn.layer setBorderWidth:1];
    
    //4,thinkStatusBtn
    [self.thinkStatusBtn.layer setCornerRadius:3];
    [self.thinkStatusBtn.layer setMasksToBounds:true];
    [self.thinkStatusBtn.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.thinkStatusBtn.layer setBorderWidth:1];
}

-(void) initData{
    [Output sharedInstance].delegate = self;
}

-(void) initDisplay{
    //2,thinkStatusBtn
    [self.thinkStatusBtn setBackgroundColor:[UIColor greenColor]];
    
    //3,mainThreadStatusBtn
    [self.mainThreadStatusBtn setBackgroundColor:[UIColor greenColor]];
}

-(void) refreshDisplay_HungerLevelLab{
    NSString *value = STRFORMAT(@"%.3f",self.hungerLevelSlider.value);
    [self.hungerLevelLab setText:value];
    [self.hungerLevelLab setTextColor:self.hungerLevelSlider.value > 0.7 ? [UIColor greenColor] : [UIColor redColor]];
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

- (IBAction)canceBtnOnClick:(id)sender {
    [self.tf resignFirstResponder];
    self.tf.text = nil;
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

- (IBAction)mainThreadStatusBtnOnClick:(id)sender {
    
}

- (IBAction)awarenessLogBtnOnClick:(id)sender {
    
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
    NSMutableString *mStr = [[NSMutableString alloc] initWithString:self.aiOutputLab.text];
    [mStr appendFormat:@"%c",c];
    [self.aiOutputLab setText:mStr];
}

@end
