//
//  MainPage.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/10/24.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "MainPage.h"
#import "TestHungryPage.h"
#import "BirdLivePage.h"
#import "BirdGrowPage.h"

@implementation MainPage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void) initView{
    //1. self
    self.title = @"和";
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)testHungryOnClick:(id)sender {
    TestHungryPage *page = [[TestHungryPage alloc] init];
    [self.navigationController pushViewController:page animated:true];
}

- (IBAction)birdLiveOnClick:(id)sender {
    BirdLivePage *page = [[BirdLivePage alloc] init];
    [self.navigationController pushViewController:page animated:true];
}

- (IBAction)birdGrowBtnOnClick:(id)sender {
    BirdGrowPage *page = [[BirdGrowPage alloc] init];
    [self.navigationController pushViewController:page animated:true];
}

@end
