//
//  StudyViewController.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/14.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "StudyViewController.h"
#import "SMGHeader.h"
#import "UnderstandHeader.h"
#import "InputHeader.h"
#import "FeelHeader.h"

@interface StudyViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextView *inputTV;
@property (weak, nonatomic) IBOutlet UILabel *selectNameLab;
@property (weak, nonatomic) IBOutlet UITextField *doTypeTF;
@property (weak, nonatomic) IBOutlet UITextField *targetTF;
@property (weak, nonatomic) IBOutlet UITableView *doTableView;
@property (weak, nonatomic) IBOutlet UILabel *errorTipsLab;

@end

@implementation StudyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    [self initDisplay];
}

-(void) initView{
    
}

-(void) initData{
    
}

-(void) initDisplay{
    self.doTableView.delegate = self;
    self.doTableView.dataSource = self;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:true];
}


/**
 *  MARK:--------------------UITableViewDelegate,UITableViewDataSource--------------------
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 32;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/**
 *  MARK:--------------------onclick--------------------
 */
- (IBAction)xiaoChiOnClick:(id)sender {
    [self.selectNameLab setText:@"小赤"];
}

- (IBAction)xiaoBiOnClick:(id)sender {
    [self.selectNameLab setText:@"小臂"];
}

- (IBAction)selfOnClick:(id)sender {
    [self.selectNameLab setText:@"自己"];
}

- (IBAction)clearBtnOnClick:(id)sender {
    [self clearAllContent];
}

- (IBAction)commitBtnOnClick:(id)sender {
    if (STRISOK(self.inputTV.text)) {
        if (STRISOK(self.selectNameLab.text)) {
            if (STRISOK(self.doTypeTF.text)) {
                if (STRISOK(self.targetTF.text)) {
                    NSLog(@"行为人:%@___%@_%@",self.selectNameLab.text,self.doTypeTF.text,self.targetTF.text);
                    //1,doModel
                    DoModel *doModel = [[DoModel alloc] init];
                    doModel.fromMKId = self.selectNameLab.text;
                    doModel.toMKId = self.targetTF.text;
                    doModel.doType = self.doTypeTF.text;
                    
                    //2,feelTextModel
                    FeelTextModel *feelTextModel = [[FeelTextModel alloc] init];
                    feelTextModel.text = self.inputTV.text;
                    
                    //3,commit
                    [[SMG sharedInstance].understand commitWithFeelModel:feelTextModel withDoModel:doModel];
                    
                    //4,clear
                    [self clearAllContent];
                }else{
                    [self showErrorTips:@"请输入目标"];
                }
            }else{
                [self showErrorTips:@"请输入行为"];
            }
        }else{
            [self showErrorTips:@"请选择发言人"];
        }
    }else{
        [self showErrorTips:@"请输入原话"];
    }
}


/**
 *  MARK:--------------------method--------------------
 */
-(void) clearAllContent{
    [self.errorTipsLab setText:@""];
    [self.selectNameLab setText:@""];
    [self.targetTF setText:@""];
    [self.doTypeTF setText:@""];
    [self.inputTV setText:@""];
    [self showErrorTips:@""];
}

-(void) showErrorTips:(NSString*)tips{
    [self.errorTipsLab setText:STRTOOK(tips)];
}





@end

