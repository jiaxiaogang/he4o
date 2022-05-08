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

-(void) initView{
    //1. self
    [super initView];
    self.title = @"和";
}

-(void) initData{
    [super initData];
    [theRT regist:kGrowPageSEL target:self selector:@selector(birdGrowBtnOnClick:)];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [theRT invoked:kGrowPageSEL];
    });
}

@end
