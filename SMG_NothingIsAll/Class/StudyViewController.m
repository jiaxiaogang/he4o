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

@property (strong,nonatomic) NSMutableArray  *testArr;//测试数据;

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

-(NSMutableArray *) testArr{
    if (_testArr == nil) {
        NSDictionary *dic1 = @{@"fromMKId":@"小赤",
                              @"doType":@"给",
                              @"toMKId":@"苹果",
                              @"text":@"小赤给我苹果",
                              @"name":@"苹果"};
        
        NSDictionary *dic2 = @{@"fromMKId":@"我",
                              @"doType":@"吃",
                              @"toMKId":@"苹果",
                              @"text":@"我吃苹果",
                              @"name":@"苹果"};
        
        NSDictionary *dic3 = @{@"fromMKId":@"我",
                               @"doType":@"感觉",
                               @"toMKId":@"甜",
                               @"text":@"我感觉甜",
                               @"name":@"甜"};
        
        NSDictionary *dic4 = @{@"fromMKId":@"苹果",
                               @"doType":@"是",
                               @"toMKId":@"甜",
                               @"text":@"苹果很甜",
                               @"name":@"甜"};
        
        NSDictionary *dic5 = @{@"fromMKId":@"小赤",
                               @"doType":@"给",
                               @"toMKId":@"苹果",
                               @"text":@"小赤给我苹果",
                               @"name":@"苹果"};
        
        NSDictionary *dic6 = @{@"fromMKId":@"我",
                               @"doType":@"吃",
                               @"toMKId":@"苹果",
                               @"text":@"我吃苹果",
                               @"name":@"苹果"};
        
        NSDictionary *dic7 = @{@"fromMKId":@"我",
                               @"doType":@"感觉",
                               @"toMKId":@"甜",
                               @"text":@"我感觉甜",
                               @"name":@"甜"};
        
        NSDictionary *dic8 = @{@"fromMKId":@"苹果",
                               @"doType":@"是",
                               @"toMKId":@"甜",
                               @"text":@"苹果很甜",
                               @"name":@"甜"};
        
        _testArr = [NSMutableArray arrayWithObjects:dic1,dic2,dic3,dic4,dic5,dic6,dic7,dic8, nil];
    }
    return _testArr;
}

- (IBAction)testBtnOnClick:(id)sender {
    if (ARRISOK(self.testArr))
    {
        NSDictionary *dic = self.testArr[0];
        [self.testArr removeObjectAtIndex:0];
        
        //1,doModel
        FeelDoModel *doModel = [[FeelDoModel alloc] init];
        doModel.fromMKId = [dic objectForKey:@"fromMKId"];
        doModel.toMKId = [dic objectForKey:@"toMKId"];
        doModel.doType = [dic objectForKey:@"doType"];
        
        //2,feelTextModel
        FeelTextModel *feelTextModel = [[FeelTextModel alloc] init];
        feelTextModel.text = [dic objectForKey:@"text"];
        
        //3,objModel
        FeelObjModel *objModel = [[FeelObjModel alloc] init];
        objModel.name = [dic objectForKey:@"name"];
        
        //4,commit
        [[SMG sharedInstance].understand commitWithFeelModelArr:@[doModel,feelTextModel,objModel]];
    }
    else
    {
        NSLog(@"测试完成....");
    }
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

