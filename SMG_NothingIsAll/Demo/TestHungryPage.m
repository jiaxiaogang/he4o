//
//  TestHungryPage.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "TestHungryPage.h"

@interface TestHungryPage ()

@property (weak, nonatomic) IBOutlet UIButton *hungerBtn;
@property (weak, nonatomic) IBOutlet UIButton *chargeBtn;

@end

@implementation TestHungryPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)hungerBtnOnClick:(id)sender {
    [[SMG sharedInstance].mindControl tmpTest];//饥饿测试;
}

- (IBAction)chargeBtnOnClick:(id)sender {
    
}




@end
