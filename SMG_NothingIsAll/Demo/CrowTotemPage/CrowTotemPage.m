//
//  CrowTotemPage.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/10/24.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "CrowTotemPage.h"
#import "CrowView.h"

@interface CrowTotemPage ()

@property (strong,nonatomic) CrowView *crowView;

@end

@implementation CrowTotemPage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void) initView{
    self.crowView = [[CrowView alloc] init];
    [self.crowView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.view addSubview:self.crowView];
}

@end
