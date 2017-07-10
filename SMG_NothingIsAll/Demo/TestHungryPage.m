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

@end

@implementation TestHungryPage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void) initView{
    self.tf.delegate = self;
    [self.tf setReturnKeyType:UIReturnKeyGo];
}

/**
 *  MARK:--------------------onclick--------------------
 */
- (IBAction)addBtnOnClick:(id)sender {
    [[SMG sharedInstance].mindControl tmpTest_Add];//饥饿测试;
}

- (IBAction)subBtnOnClick:(id)sender {
    [[SMG sharedInstance].mindControl tmpTest_Sub];
}

- (IBAction)eatStartBtnOnClick:(id)sender {
    [[SMG sharedInstance].mindControl tmpTest_Start];
}

- (IBAction)eatStopBtnOnClick:(id)sender {
    [[SMG sharedInstance].mindControl tmpTest_Stop];
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

/**
 *  MARK:--------------------UITextFieldDelegate--------------------
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self confirmBtnOnClick:self.confirmBtn];
    return true;
}

@end
