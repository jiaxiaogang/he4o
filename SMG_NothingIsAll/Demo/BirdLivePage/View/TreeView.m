//
//  TreeView.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "TreeView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface TreeView ()

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (strong,nonatomic) NSTimer *timer;            //计时器

@end

@implementation TreeView

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
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
}

-(void) initDisplay{
    [self refreshDisplay];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) refreshDisplay{
    
}

- (void)notificationTimer{
    //掉落果实
    //1. 3s掉一个,汽车压一次消皮,压三次全消
    //2. 30%掉路边
    //3. 70%掉路中
    //4. 10%落地破皮
}

@end

