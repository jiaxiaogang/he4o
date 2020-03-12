//
//  HeLogView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/3/12.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "HeLogView.h"
#import "HeLog.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface HeLogView ()

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *startTF;
@property (weak, nonatomic) IBOutlet UITextField *endTF;
@property (weak, nonatomic) IBOutlet UITextField *keywordTF;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;
@property (strong, nonatomic) NSMutableString *str;

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
    self.str = [[NSMutableString alloc] init];
    [self reloadData];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) addLog:(NSString*)log{
    [[HeLog sharedInstance] addLog:log];
    [self reloadData];
}
-(void) reloadData{
    //1. 清空
    [self.str setString:@""];
    
    //2. 筛选 (时间 & 关键字)
    NSArray *timeValids = [[HeLog sharedInstance] filterByTime:self.startTF.text endT:self.endTF.text];
    NSArray *keywordValids = [[HeLog sharedInstance] filterByKeyword:self.keywordTF.text];
    
    //3. 有效并集
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    for (id timeItem in timeValids) {
        if ([keywordValids containsObject:timeItem]) {
            [datas addObject:timeItem];
        }
    }
    
    //4. 重拼接赋值
    for (NSDictionary *data in datas) {
        long long time = [NUMTOOK([data objectForKey:kTime]) longLongValue];
        NSString *log = [data objectForKey:kLog];
        NSString *timeStr = [SMGUtils date2yyyyMMddHHmmssSSS:[[NSDate alloc] initWithTimeIntervalSince1970:time]];
        [self.str appendFormat:@"%@: %@\n",timeStr,log];
    }
    
    //5. 刷新显示
    [self refreshDisplay];
}

-(void) refreshDisplay{
    [self.textView setText:self.str];
}

-(void) open{
    [self setHidden:false];
}

-(void) close{
    [self setHidden:true];
}

//MARK:===============================================================
//MARK:                     < onClick >
//MARK:===============================================================
- (IBAction)filterBtnOnClick:(id)sender {
    [self reloadData];
}
- (IBAction)closeBtnOnClick:(id)sender {
    [self close];
}

@end
