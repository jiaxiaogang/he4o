//
//  HeLogView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/3/12.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "HeLogView.h"
#import "HeLogModel.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "HeLogUtil.h"

@interface HeLogView () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *startTF;
@property (weak, nonatomic) IBOutlet UITextField *endTF;
@property (weak, nonatomic) IBOutlet UITextField *keywordTF;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;
@property (strong, nonatomic) NSMutableString *str;
@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (strong, nonatomic) HeLogModel *model;
@property (assign, nonatomic) BOOL isOpen;

@end

@implementation HeLogView

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
        [self initData];
    }
    return self;
}

-(void) initView{
    //self
    [self setFrame:CGRectMake(0, StateBarHeight, ScreenWidth, ScreenHeight - StateBarHeight)];
    [self setHidden:true];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    
    //tf
    self.keywordTF.delegate = self;
    self.startTF.delegate = self;
    self.endTF.delegate = self;
}

-(void) initData{
    self.isOpen = false;
    self.stop = !heLogSwitch;
    self.model = [[HeLogModel alloc] init];
    self.str = [[NSMutableString alloc] init];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) addLog:(NSString*)log{
    if (self.stop) {
        return;
    }
    if (log) {
        NSDictionary *addDic = [self.model addLog:log];
        if (self.isOpen) {
            //[self appendData:@[addDic]];(实时加一行的性能问题,现在懒得解决,故先去掉)
        }
    }
}

-(void) addDemoLog:(NSString*)log{
    if (self.stop) {
        return;
    }
    log = STRFORMAT(@"********************************************* %@ *********************************************",log);
    [self.model addLog:log];
}

-(void) open{
    [self setHidden:false];
    self.isOpen = true;
    [self reloadData:false];
}

-(void) close{
    [self setHidden:true];
    self.isOpen = false;
}

-(void) clear{
    [self.model clear];
}

-(NSInteger) count{
    return self.model.count;
}

-(void) reloadData:(BOOL)reloadHd{
    //0. 工作状态
    if (self.stop) {
        return;
    }
    
    //1. 重新加载硬盘;
    if (reloadHd) {
        [self.model reloadData];
    }
    
    //2. UI清空 & 重加载
    [self.str setString:@""];
    [self appendData:self.model.getDatas];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
-(void) appendData:(NSArray*)datas{
    //1. 筛选 (时间 & 关键字)
    NSArray *timeValids = [HeLogUtil filterByTime:self.startTF.text endT:self.endTF.text checkDatas:datas];
    NSArray *keywordValids = [HeLogUtil filterByKeyword:self.keywordTF.text checkDatas:datas];
    
    //2. 有效并集 (用dic去重基于hash,比NSArray要快许多);
    NSMutableArray *valids = [[NSMutableArray alloc] init];
    NSMutableDictionary *timeDic = [[NSMutableDictionary alloc] init];
    for (NSDictionary *timeItem in timeValids)
        [timeDic setObject:timeItem forKey:STRFORMAT(@"%p",timeItem)];
    for (NSDictionary *keywordItem in keywordValids){
        if ([timeDic objectForKey:STRFORMAT(@"%p",keywordItem)]) {
            [valids addObject:keywordItem];
        }
    }
    
    //3. 重拼接赋值
    for (NSDictionary *valid in valids) {
        double time = [NUMTOOK([valid objectForKey:kTime]) doubleValue];
        NSString *log = [valid objectForKey:kLog];
        NSString *timeStr = [SMGUtils date2yyyyMMddHHmmssSSS:[[NSDate alloc] initWithTimeIntervalSince1970:(time / 1000.0f)]];
        [self.str appendFormat:@"%@: %@\n",timeStr,log];
    }
    
    //4. 刷新显示
    [self refreshDisplay];
}

-(void) refreshDisplay{
    //1. textView
    [self.textView setText:self.str];
    
    //2. countLab
    NSString *sep = @"\n";
    [self.countLab setText:STRFORMAT(@"共计:%ld条",STRTOARR(self.str, sep).count - 1)];
}

//MARK:===============================================================
//MARK:                     < onClick >
//MARK:===============================================================
- (IBAction)filterBtnOnClick:(id)sender {
    [self reloadData:false];
}
- (IBAction)closeBtnOnClick:(id)sender {
    [self close];
}

//MARK:===============================================================
//MARK:                     < UITextFieldDelegate >
//MARK:===============================================================
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.startTF) {
        [self.endTF becomeFirstResponder];
    }else if (textField == self.endTF) {
        [self.keywordTF becomeFirstResponder];
    }else if (textField == self.keywordTF) {
        [self reloadData:false];
    }
    return true;
}

@end
