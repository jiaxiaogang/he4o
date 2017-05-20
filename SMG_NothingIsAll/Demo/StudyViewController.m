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
#import "DataViewController.h"

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

- (IBAction)dataBtnOnClick:(id)sender {
    DataViewController *page = [[DataViewController alloc] init];
    [self.navigationController pushViewController:page animated:true];
}

- (IBAction)testBtnOnClick:(id)sender {
    
    [self understandA];
    
    //[self understandB];
    
    //[self understandC];

}



/**
 *  MARK:--------------------使用(定义好的对话),来教育SMG--------------------
 */
- (void)understandA {
    if (ARRISOK(self.testArr))
    {
        NSDictionary *dic = self.testArr[0];
        [self.testArr removeObjectAtIndex:0];
        NSMutableArray *commitArr = [[NSMutableArray alloc] init];
        
        //1,doModel
        if ([dic objectForKey:@"doType"]) {
            FeelDoModel *doModel = [[FeelDoModel alloc] init];
            doModel.fromMKId = [dic objectForKey:@"fromMKId"];
            doModel.toMKId = [dic objectForKey:@"toMKId"];
            doModel.doType = [dic objectForKey:@"doType"];
            [commitArr addObject:doModel];
        }
        
        //2,feelTextModel
        if ([dic objectForKey:@"text"]) {
            FeelTextModel *feelTextModel = [[FeelTextModel alloc] init];
            feelTextModel.text = [dic objectForKey:@"text"];
            [commitArr addObject:feelTextModel];
        }
        
        //3,
        if ([dic objectForKey:@"obj"]) {
            FeelObjModel *objModel = [[FeelObjModel alloc] init];
            objModel.name = [dic objectForKey:@"obj"];
            [commitArr addObject:objModel];
        }
        
        //4,commit
        [[SMG sharedInstance].understand commitWithFeelModelArr:commitArr];
    }
    else
    {
        NSLog(@"测试完成....");
    }
}



/**
 *  MARK:--------------------通过(自动生成语言)来教育SMG--------------------
 */
-(void) understandB {
    NSMutableArray *commitArr = [[NSMutableArray alloc] init];
    
    NSMutableArray *personArr = [[NSMutableArray alloc] initWithObjects:@"小赤",@"小臂",@"刚哥", nil];
    NSMutableArray *doArr = [[NSMutableArray alloc] initWithObjects:@"吃",@"给",@"拿着", nil];
    NSMutableArray *targetArr = [[NSMutableArray alloc] initWithObjects:@"苹果",@"桃", nil];
    
    NSString *personStr = personArr[arc4random() % personArr.count];
    NSString *doStr = doArr[arc4random() % doArr.count];
    NSString *targetStr = targetArr[arc4random() % targetArr.count];
    
    //1,doModel
    FeelDoModel *doModel = [[FeelDoModel alloc] init];
    doModel.fromMKId = personStr;
    doModel.toMKId = targetStr;
    doModel.doType = doStr;
    [commitArr addObject:doModel];
    
    //2,feelTextModel
    FeelTextModel *feelTextModel = [[FeelTextModel alloc] init];
    feelTextModel.text = STRFORMAT(@"%@%@%@",personStr,doStr,targetStr);
    [commitArr addObject:feelTextModel];
    
    
    //3,
    FeelObjModel *objModel = [[FeelObjModel alloc] init];
    objModel.name = personStr;
    [commitArr addObject:objModel];
    
    FeelObjModel *objModel2 = [[FeelObjModel alloc] init];
    objModel2.name = targetStr;
    [commitArr addObject:objModel2];
    
    //4,commit
    [[SMG sharedInstance].understand commitWithFeelModelArr:commitArr];
}

/**
 *  MARK:--------------------用(细分解场景数据)来实现更详细的数据分析--------------------
 */
-(void) understandC {
    NSMutableArray *commitArr = [[NSMutableArray alloc] init];
    //ChatStore (Test)
    NSArray *a = [CharStore insertString:@"我爱你"];
    NSLog(@"");
    NSString *str = [CharStore searchString:a];
    NSLog(@"");
    
    
    
    //MemMode (Test)
    //A看见B,说:你好;
    //1,数据
    ObjModel *aObj = [ObjStore createInstanceModel:@"A"];
    ObjModel *bObj = [ObjStore createInstanceModel:@"B"];
    DoModel *see = [DoStore createInstanceModel:@"看见"];
    DoModel *bySee = [DoStore createInstanceModel:@"被看见"];
    DoModel *say = [DoStore createInstanceModel:@"说"];
    DoModel *hear = [DoStore createInstanceModel:@"听"];
    
    //2,A看见B;
    MemModel *aSeeModel = [[MemModel alloc] init];
    aSeeModel.groupId = [MemStore createGroupId];
    aSeeModel.objRowId = aObj.rowid;
    aSeeModel.doRowId = see.rowid;
    [MemModel insertToDB:aSeeModel];
    
    //2,B被看见;
    MemModel *bBySee = [[MemModel alloc] init];
    bBySee.groupId = aSeeModel.groupId;
    bBySee.objRowId = bObj.rowid;
    bBySee.doRowId = bySee.rowid;
    [MemModel insertToDB:bBySee];
    
    //3,A说
    MemModel *aSayModel = [[MemModel alloc] init];
    aSayModel.groupId = [MemStore createGroupId];
    aSayModel.objRowId = aObj.rowid;
    aSayModel.doRowId = say.rowid;
    [MemModel insertToDB:aSayModel];
    
    //3,A说内容
    NSString *text = @"你好";
    for (NSInteger i = 0; i < text.length; i++) {
        NSString *value = [text substringWithRange:NSMakeRange(i,1)];
        CharModel *charModel = [CharStore createInstanceModel:value];
        
        MemModel *sayItemModel = [[MemModel alloc] init];
        sayItemModel.groupId = aSayModel.groupId;
        sayItemModel.objRowId = aObj.rowid;
        sayItemModel.charRowId = charModel.rowid;
        [MemModel insertToDB:sayItemModel];
    }
    NSLog(@"");
    
    //4,commit
    [[SMG sharedInstance].understand commitWithFeelModelArr:commitArr];
}




-(NSMutableArray *) testArr{
    if (_testArr == nil) {
        _testArr = [NSMutableArray arrayWithObjects:
                    @{@"fromMKId":@"小刚",@"doType":@"给",@"toMKId":@"苹果",@"text":@"小刚给苹果"},
                    @{@"doType":@"吃",@"toMKId":@"桃",@"text":@"吃桃"},
                    @{@"text":@"苹果",@"obj":@"苹果"},
                    @{@"text":@"苹果",@"obj":@"苹果"},
                    @{@"text":@"苹果",@"obj":@"苹果"},
                    @{@"text":@"苹果",@"obj":@"苹果"},
                    @{@"fromMKId":@"小赤",@"doType":@"吃",@"toMKId":@"苹果",@"text":@"小赤吃苹果"},
                    @{@"fromMKId":@"小赤",@"doType":@"给",@"toMKId":@"苹果",@"text":@"小赤给苹果"},
                    @{@"fromMKId":@"小赤",@"doType":@"给",@"toMKId":@"桃",@"text":@"小赤给桃"},
                    @{@"fromMKId":@"小臂",@"doType":@"给",@"toMKId":@"苹果",@"text":@"小臂给苹果"},
                    @{@"fromMKId":@"小生",@"doType":@"取",@"toMKId":@"苹果",@"text":@"小生取苹果"},
                    @{@"fromMKId":@"小贾",@"doType":@"吃",@"toMKId":@"苹果",@"text":@"小贾吃苹果"},
                    @{@"fromMKId":@"小刚",@"doType":@"吃",@"toMKId":@"桃",@"text":@"小刚吃桃"},

                    @{@"fromMKId":@"小赤",@"doType":@"吃",@"toMKId":@"苹果",@"text":@"小赤吃苹果"},
                    @{@"fromMKId":@"小赤",@"doType":@"吃",@"toMKId":@"苹果",@"text":@"小赤吃苹果"},
                    @{@"fromMKId":@"小赤",@"doType":@"吃",@"toMKId":@"苹果",@"text":@"小赤吃苹果"},
                    @{@"fromMKId":@"小赤",@"doType":@"吃",@"toMKId":@"桃",@"text":@"小赤吃桃"},
                    @{@"fromMKId":@"小赤",@"doType":@"吃",@"toMKId":@"桃",@"text":@"小赤吃桃"},
                    @{@"fromMKId":@"小赤",@"doType":@"吃",@"toMKId":@"桃",@"text":@"小赤吃桃"},

                    @{@"doType":@"吃",@"toMKId":@"桃",@"text":@"吃桃"},
                    @{@"doType":@"吃",@"toMKId":@"桃",@"text":@"吃桃"},

                    @{@"doType":@"吃",@"text":@"吃啊"},
                    @{@"doType":@"吃",@"text":@"吃啊"},

                    @{@"doType":@"吃",@"text":@"吃"},
                    @{@"doType":@"吃",@"text":@"吃"},

                    nil];
    }
    return _testArr;
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









