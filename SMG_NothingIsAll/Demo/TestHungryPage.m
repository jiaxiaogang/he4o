//
//  TestHungryPage.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "TestHungryPage.h"

@interface TestHungryPage ()

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *subBtn;
@property (weak, nonatomic) IBOutlet UIButton *eatStartBtn;
@property (weak, nonatomic) IBOutlet UIButton *eatStopBtn;

@end

@implementation TestHungryPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

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


@end
