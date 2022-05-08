//
//  HEViewController.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/8/15.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "HEViewController.h"

@interface HEViewController ()

@end

@implementation HEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    [self initDisplay];
}

-(void) initView{
    [theRT regist:kMainPageSEL target:self selector:@selector(popToMainPage)];
}

-(void) initData{}
-(void) initDisplay{}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

-(void) popToMainPage{
    [self.navigationController popToRootViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [theRT invoked:kMainPageSEL];
    });
}

@end
