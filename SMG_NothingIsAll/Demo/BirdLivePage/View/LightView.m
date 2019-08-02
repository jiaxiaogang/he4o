//
//  LightView.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "LightView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface LightView ()

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (strong,nonatomic) NSTimer *timer;            //计时器

@end

@implementation LightView

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
    [self setFrame:CGRectMake(ScreenWidth - 25, 60, 30, 30)];
    [self.layer setCornerRadius:15];
    [self.layer setMasksToBounds:true];
    self.tag = visibleTag;
    
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
    self.curLightIsGreen = true;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
}

-(void) initDisplay{
    [self refreshDisplay];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) refreshDisplay{
    [self setBackgroundColor:self.curLightIsGreen ? [UIColor greenColor] : [UIColor redColor]];
}

- (void)notificationTimer{
    //data
    self.curLightIsGreen = !self.curLightIsGreen;
    
    //ui
    [self refreshDisplay];
    
    //delegate
    if (self.curLightIsGreen && self.delegate && [self.delegate respondsToSelector:@selector(lightView_ChangeToGreen)]) {
        [self.delegate lightView_ChangeToGreen];
    }
    
}

@end

