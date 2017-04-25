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
@property (weak, nonatomic) IBOutlet UITextField *doTypeTF;
@property (weak, nonatomic) IBOutlet UITextField *targetTF;
@property (weak, nonatomic) IBOutlet UITableView *doTableView;
@property (weak, nonatomic) IBOutlet UILabel *errorTipsLab;

@property (weak, nonatomic) IBOutlet UIButton *sayChiBtn;
@property (weak, nonatomic) IBOutlet UIButton *sayBiBtn;
@property (weak, nonatomic) IBOutlet UIButton *saySelfBtn;

@property (weak, nonatomic) IBOutlet UIButton *doChiBtn;
@property (weak, nonatomic) IBOutlet UIButton *doBiBtn;
@property (weak, nonatomic) IBOutlet UIButton *doSelfBtn;

@property (strong,nonatomic) NSString *sayPersonName;
@property (strong,nonatomic) NSString *doPersonName;

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
    [self sayOnClick:self.sayChiBtn];
    [self doOnClick:self.doSelfBtn];
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
- (IBAction)sayChiOnClick:(UIButton *)sender {
    [self sayOnClick:sender];
}
- (IBAction)sayBiOnClick:(UIButton *)sender {
    [self sayOnClick:sender];
}
- (IBAction)saySelfOnClick:(UIButton *)sender {
    [self sayOnClick:sender];
}
-(void) sayOnClick:(UIButton*)sender{
    //name
    self.sayPersonName = sender.currentTitle;
    
    //color
    [self.sayChiBtn setBackgroundColor:[UIColor clearColor]];
    [self.sayBiBtn setBackgroundColor:[UIColor clearColor]];
    [self.saySelfBtn setBackgroundColor:[UIColor clearColor]];
    [sender setBackgroundColor:[UIColor greenColor]];
}


- (IBAction)doChiOnClick:(UIButton *)sender {
    [self doOnClick:sender];
}
- (IBAction)doBiOnClick:(UIButton *)sender {
    [self doOnClick:sender];
}
- (IBAction)doSelfOnClick:(UIButton *)sender {
    [self doOnClick:sender];
}
-(void) doOnClick:(UIButton*)sender{
    //name
    self.doPersonName = sender.currentTitle;
    
    //color
    [self.doChiBtn setBackgroundColor:[UIColor clearColor]];
    [self.doBiBtn setBackgroundColor:[UIColor clearColor]];
    [self.doSelfBtn setBackgroundColor:[UIColor clearColor]];
    [sender setBackgroundColor:[UIColor greenColor]];
}

- (IBAction)clearBtnOnClick:(id)sender {
    [self clearAllContent];
}

- (IBAction)commitBtnOnClick:(id)sender {
    if (!STRISOK(self.inputTV.text)) {
        [self showErrorTips:@"请输入原话"];
        return;
    }
    if (!STRISOK(self.sayPersonName)) {
        [self showErrorTips:@"请选择发言人"];
        return;
    }
    if (!STRISOK(self.doPersonName)) {
        [self showErrorTips:@"请选择行为人"];
        return;
    }
    if (!STRISOK(self.doTypeTF.text)) {
        [self showErrorTips:@"请输入行为"];
    }
    
    if (!STRISOK(self.targetTF.text)) {
        [self showErrorTips:@"请输入目标"];
    }
    NSLog(@"------------\n发言人:%@\n%@\n------------\n行为人:%@\n%@_%@\n------------\n",self.sayPersonName,self.inputTV.text,self.doPersonName,self.doTypeTF.text,self.targetTF.text);
    //1,doModel
    FeelDoModel *doModel = [[FeelDoModel alloc] init];
    doModel.fromMKId = self.doPersonName;
    doModel.toMKId = self.targetTF.text;
    doModel.doType = self.doTypeTF.text;
    
    //2,feelTextModel
    FeelTextModel *feelTextModel = [[FeelTextModel alloc] init];
    feelTextModel.text = self.inputTV.text;
    
    //3,objModel
    FeelObjModel *objModel = [[FeelObjModel alloc] init];
    objModel.name = self.targetTF.text;
    
    //3,commit
    [[SMG sharedInstance].understand commitWithFeelModelArr:@[doModel,feelTextModel,objModel]];
    
    //4,clear
    [self clearAllContent];
    
}

- (IBAction)testBtnOnClick:(id)sender {
    //1,doModel
    FeelDoModel *doModel = [[FeelDoModel alloc] init];
    doModel.fromMKId = @"";
    doModel.toMKId = @"";
    doModel.doType = @"";
    
    //2,feelTextModel
    FeelTextModel *feelTextModel = [[FeelTextModel alloc] init];
    feelTextModel.text = @"";
    
    //3,objModel
    FeelObjModel *objModel = [[FeelObjModel alloc] init];
    objModel.name = @"";
    
    //3,commit
    [[SMG sharedInstance].understand commitWithFeelModelArr:@[doModel,feelTextModel,objModel]];
}

/**
 *  MARK:--------------------method--------------------
 */
-(void) clearAllContent{
    [self.errorTipsLab setText:@""];
    self.sayPersonName = @"";
    self.doPersonName = @"";
    [self.targetTF setText:@""];
    [self.doTypeTF setText:@""];
    [self.inputTV setText:@""];
    [self showErrorTips:@""];
}

-(void) showErrorTips:(NSString*)tips{
    [self.errorTipsLab setText:STRTOOK(tips)];
}





@end

