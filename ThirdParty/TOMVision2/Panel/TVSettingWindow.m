//
//  TVSettingWindow.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/10/12.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TVSettingWindow.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface TVSettingWindow ()

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;
@property (weak, nonatomic) IBOutlet UIButton *expiredBtn;
@property (weak, nonatomic) IBOutlet UIButton *actYesBtn;
@property (weak, nonatomic) IBOutlet UIButton *withOutBtn;

@end

@implementation TVSettingWindow

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
    [self setFrame:CGRectMake(ScreenWidth - 100, ScreenHeight - 240, 100, 200)];
    
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
    [self refreshDisplay];
    [self close];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) open{
    [theApp.window addSubview:self];
}

-(void) close{
    [self removeFromSuperview];
}

-(void) refreshDisplay{
    self.finishBtn.backgroundColor = self.finishSwitch ? UIColor.greenColor : UIColor.redColor;
    self.expiredBtn.backgroundColor = self.expiredSwitch ? UIColor.greenColor : UIColor.redColor;
    self.withOutBtn.backgroundColor = self.withOutSwitch ? UIColor.greenColor : UIColor.redColor;
    self.actYesBtn.backgroundColor = self.actYesSwitch ? UIColor.greenColor : UIColor.redColor;
}


//MARK:===============================================================
//MARK:                     < click >
//MARK:===============================================================

- (IBAction)actYesBtnClick:(id)sender {
    self.actYesSwitch = !self.actYesSwitch;
    [self refreshDisplay];
}
- (IBAction)withOutBtnClick:(id)sender {
    self.withOutSwitch = !self.withOutSwitch;
    [self refreshDisplay];
}
- (IBAction)expiredBtnClick:(id)sender {
    self.expiredSwitch = !self.expiredSwitch;
    [self refreshDisplay];
}
- (IBAction)finishBtnClick:(id)sender {
    self.finishSwitch = !self.finishSwitch;
    [self refreshDisplay];
}
- (IBAction)closeBtnClick:(id)sender {
    [self close];
}

@end
