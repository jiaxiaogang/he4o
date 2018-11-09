//
//  BirdLivePage.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/10/24.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "BirdLivePage.h"
#import "BirdView.h"
#import "RoadView.h"

@interface BirdLivePage ()

@property (strong,nonatomic) BirdView *birdView;
@property (strong,nonatomic) RoadView *roadView;

@end

@implementation BirdLivePage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void) initView{
    //1. birdView
    self.birdView = [[BirdView alloc] init];
    [self.birdView setOrigin:CGPointMake(100, 100)];
    [self.view addSubview:self.birdView];
    
    //2. roadView
    self.roadView = [[RoadView alloc] init];
    [self.view addSubview:self.roadView];
}

@end
