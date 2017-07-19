//
//  TestHungryPage.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "TestHungryPage.h"
#import "InputHeader.h"

@interface TestHungryPage ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *subBtn;
@property (weak, nonatomic) IBOutlet UIButton *eatStartBtn;
@property (weak, nonatomic) IBOutlet UIButton *eatStopBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UITextField *tf;
@property (weak, nonatomic) IBOutlet UIButton *canceBtn;
@property (weak, nonatomic) IBOutlet UISlider *hungerLevelSlider;
@property (weak, nonatomic) IBOutlet UILabel *hungerLevelLab;

@end

@implementation TestHungryPage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void) initView{
    //1,tf
    self.tf.delegate = self;
    [self.tf setReturnKeyType:UIReturnKeyGo];
    
    //2,hungerLevelLab
    [self.hungerLevelLab setText:STRFORMAT(@"%.2f",self.hungerLevelSlider.value)];
}

/**
 *  MARK:--------------------onclick--------------------
 */
- (IBAction)addBtnOnClick:(id)sender {
    self.hungerLevelSlider.value += 0.01f;
    [self hungerLevelSliderValueChanged:self.hungerLevelSlider];
    [theHunger tmpTest_Add];
}

- (IBAction)subBtnOnClick:(id)sender {
    self.hungerLevelSlider.value -= 0.01f;
    [self hungerLevelSliderValueChanged:self.hungerLevelSlider];
    [theHunger tmpTest_Sub];
}

- (IBAction)eatStartBtnOnClick:(id)sender {
    [theHunger tmpTest_Start];
}

- (IBAction)eatStopBtnOnClick:(id)sender {
    [theHunger tmpTest_Stop];
}

- (IBAction)confirmBtnOnClick:(id)sender {
    if (STRISOK(self.tf.text)) {
        [[SMG sharedInstance].input commitText:self.tf.text];
        self.tf.text = nil;
    }
}

- (IBAction)canceBtnOnClick:(id)sender {
    [self.tf resignFirstResponder];
    self.tf.text = nil;
}

- (IBAction)hungerLevelSliderValueChanged:(id)sender {
    NSString *value = STRFORMAT(@"%.2f",self.hungerLevelSlider.value);
    [self.hungerLevelLab setText:value];
    theHunger.tmpLevel = self.hungerLevelSlider.value;
}

/**
 *  MARK:--------------------UITextFieldDelegate--------------------
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self confirmBtnOnClick:self.confirmBtn];
    return true;
}

@end
