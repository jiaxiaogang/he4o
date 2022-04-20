//
//  RLTPanel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/4/15.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "RLTPanel.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "TOMVisionItemModel.h"
#import "PINDiskCache.h"
#import "TVideoWindow.h"
#import "TVUtil.h"

@interface RLTPanel () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tv;
@property (weak, nonatomic) IBOutlet UILabel *totalScoreLab;
@property (weak, nonatomic) IBOutlet UILabel *branchScoreLab;
@property (weak, nonatomic) IBOutlet UILabel *totalSPLab;
@property (weak, nonatomic) IBOutlet UILabel *branchSPLab;
@property (weak, nonatomic) IBOutlet UILabel *sulutionLab;
@property (weak, nonatomic) IBOutlet UILabel *progressLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (strong, nonatomic) NSArray *tvDatas;

@end

@implementation RLTPanel

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
        [self initData];
        [self initDisplay];
    }
    return self;
}

-(void) initView{
    //self
    [self setAlpha:0.3f];
    [self setFrame:CGRectMake(ScreenWidth / 3.0f * 2.0f - 20, 64, ScreenWidth / 3.0f, ScreenHeight - 128)];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    [self.containerView.layer setCornerRadius:8.0f];
    [self.containerView.layer setBorderWidth:1.0f];
    [self.containerView.layer setBorderColor:UIColorWithRGBHex(0x000000).CGColor];
    
    //tv
    self.tv.delegate = self;
    self.tv.dataSource = self;
    [self.tv.layer setBorderWidth:1.0f];
    [self.tv.layer setBorderColor:UIColorWithRGBHex(0x0000FF).CGColor];
}

-(void) initData{
    self.playing = false;
}

-(void) initDisplay{
    [self close];
}

-(void) refreshDisplay{
    //1. tv
    self.tvDatas = ARRTOOK([self.delegate rltPanel_getQueues]);
    [self.tv reloadData];
    
    //2. progressLab
    self.progressLab.text = STRFORMAT(@"0 / %ld",self.tvDatas.count);
    
    
    //TODOTOMORROW20220420: 继续别的显示;
    
    
}

//MARK:===============================================================
//MARK:                     < getset >
//MARK:===============================================================
-(void)setPlaying:(BOOL)playing{
    _playing = playing;
    [self.playBtn setTitle: self.playing ? @"暂停" : @"播放" forState:UIControlStateNormal];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) reloadData{
    [self refreshDisplay];
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
-(NSString*) cellStr:(NSString*)queue {
    if ([kGrowPage isEqualToString:queue]) {
        return @"页 - 进入成长页";
    }else if ([kFly isEqualToString:queue]) {
        return @"飞 - 随机";
    }else if ([kWood isEqualToString:queue]) {
        return @"棒 - 扔木棒";
    }
    return @"";
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)playBtnOnClick:(id)sender {
    self.playing = !self.playing;
}

- (IBAction)stopBtnOnClick:(id)sender {
    [self.delegate rltPanel_Stop];
}

- (IBAction)loadBtnOnClick:(id)sender {
    [theRT queue1:kGrowPage];
    [theRT queueN:@[kFly,kWood] count:5];
}

- (IBAction)closeBtnOnClick:(id)sender {
    [self close];
}

//MARK:===============================================================
//MARK:       < UITableViewDataSource &  UITableViewDelegate>
//MARK:===============================================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tvDatas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    NSString *queue = STRTOOK(ARR_INDEX(self.tvDatas, indexPath.row));
    NSString *cellStr = [self cellStr:queue];
    [cell.textLabel setFont:[UIFont systemFontOfSize:8]];
    [cell.textLabel setText:STRFORMAT(@"%ld. %@",indexPath.row+1, cellStr)];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat maskHeight = 10.0f;
    int size = (int)(self.tv.height / maskHeight);
    size = size / 2 * 2 + 1;
    return self.tv.height / size;
}

@end
