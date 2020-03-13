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

@interface HeLogView ()

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
}

-(void) initData{
    self.model = [[HeLogModel alloc] init];
    self.str = [[NSMutableString alloc] init];
    [self reloadData:self.model.getDatas];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) addLog:(NSString*)log{
    if (log) {
        NSDictionary *addDic = [self.model addLog:log];
        [self reloadData:@[addDic]];
    }
}

-(void) open{
    [self setHidden:false];
}

-(void) close{
    [self setHidden:true];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
-(void) reloadData:(NSArray*)datas{
    //1. 筛选 (时间 & 关键字)
    NSArray *timeValids = [HeLogUtil filterByTime:self.startTF.text endT:self.endTF.text checkDatas:datas];
    NSArray *keywordValids = [HeLogUtil filterByKeyword:self.keywordTF.text checkDatas:datas];
    
    //2. 有效并集
    NSMutableArray *valids = [[NSMutableArray alloc] init];
    for (id timeItem in timeValids) {
        if ([keywordValids containsObject:timeItem]) {
            [valids addObject:timeItem];
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
    //清空 & 重加载
    [self.str setString:@""];
    [self reloadData:self.model.getDatas];
}
- (IBAction)closeBtnOnClick:(id)sender {
    [self close];
}

@end
