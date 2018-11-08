//
//  BirdLivePage.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/10/24.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "BirdLivePage.h"
#import "BirdView.h"

@interface BirdLivePage ()

@property (strong,nonatomic) BirdView *birdView;

@end

@implementation BirdLivePage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void) initView{
    self.birdView = [[BirdView alloc] init];
    [self.birdView setFrame:CGRectMake(100, 100, 10, 10)];
    [self.view addSubview:self.birdView];
}

@end
