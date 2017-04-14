//
//  StudyViewController.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/14.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "StudyViewController.h"

@interface StudyViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextView *inputTV;
@property (weak, nonatomic) IBOutlet UILabel *selectNameLab;
@property (weak, nonatomic) IBOutlet UITextField *doTypeTF;
@property (weak, nonatomic) IBOutlet UITextField *targetTF;
@property (weak, nonatomic) IBOutlet UITableView *doTableView;

@end

@implementation StudyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self  initData];
    [self initDisplay];
}

-(void) initView{
    
}

-(void) initData{
    
}

-(void) initDisplay{
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:true];
}


/**
 *  MARK:--------------------UITableViewDelegate,UITableViewDataSource--------------------
 */



@end
