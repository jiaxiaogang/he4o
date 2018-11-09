//
//  FoodView.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "FoodView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface FoodView ()

@property (strong,nonatomic) IBOutlet UIView *containerView;

@end

@implementation FoodView

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
    [self.containerView.layer setBorderWidth:2];
    [self.containerView.layer setBorderColor:[UIColor redColor].CGColor];
}

-(void) initData{
    
}

-(void) initDisplay{
    [self refreshDisplay];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) refreshDisplay{
    
}

-(void) removePeel{
    [self.containerView.layer setBorderColor:[UIColor clearColor].CGColor];
}

@end

