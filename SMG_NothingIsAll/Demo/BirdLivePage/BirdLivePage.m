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
#import "TreeView.h"
#import "FoodView.h"
#import "UIView+Extension.h"

@interface BirdLivePage ()<RoadViewDelegate>

@property (strong,nonatomic) BirdView *birdView;
@property (strong,nonatomic) RoadView *roadView;
@property (strong,nonatomic) TreeView *treeView;

@end

@implementation BirdLivePage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void) initView{
    //1. self
    self.title = @"小鸟生存演示";
    
    //2. birdView
    self.birdView = [[BirdView alloc] init];
    [self.view addSubview:self.birdView];
    
    //3. roadView
    self.roadView = [[RoadView alloc] init];
    [self.view addSubview:self.roadView];
    self.roadView.delegate = self;
    
    //4. treeView
    self.treeView = [[TreeView alloc] init];
    [self.view addSubview:self.treeView];
}

/**
 *  MARK:--------------------RoadViewDelegate--------------------
 */
-(NSArray *)roadView_GetFoodInLoad{
    return [self.treeView subViews_AllDeepWithClass:FoodView.class];
}

@end
