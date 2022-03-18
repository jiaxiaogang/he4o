//
//  TVPanelView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/18.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TVPanelView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface TVPanelView ()

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *speedSegment;
@property (weak, nonatomic) IBOutlet UIButton *frameBtn;
@property (weak, nonatomic) IBOutlet UIButton *timeBtn;
@property (weak, nonatomic) IBOutlet UIButton *loopBtn;
@property (weak, nonatomic) IBOutlet UIStepper *shotStep;

@end

@implementation TVPanelView

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
    [self setFrame:CGRectMake(0, ScreenHeight - 40, ScreenWidth, 40)];
    
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
}

-(void) initDisplay{
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)loopBtnClicked:(id)sender {
}

- (IBAction)timeBtnClicked:(id)sender {
}

- (IBAction)frameBtnClicked:(id)sender {
}

- (IBAction)speedSegmentChanged:(id)sender {
}

- (IBAction)playBtnClicked:(id)sender {
}

- (IBAction)shotStepChanged:(id)sender {
}

@end
