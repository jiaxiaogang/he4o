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
    [self setFrame:CGRectMake(0, 50, 5, 5)];
    [self.layer setCornerRadius:2.5f];
    [self.layer setMasksToBounds:true];
    [self.layer setBorderColor:[UIColor grayColor].CGColor];
    [self setBackgroundColor:[UIColor greenColor]];
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
    self.status = FoodStatus_Border;
}

-(void) initDisplay{
    [self refreshDisplay];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) refreshDisplay{
    if (self.status == FoodStatus_Border) {
        [self.layer setBorderWidth:1];
    }else if(self.status == FoodStatus_Eat){
        [self.layer setBorderWidth:0];
    }else if(self.status == FoodStatus_Remove){
        [self removeFromSuperview];
    }
}

-(void) hit{
    self.status ++;
    [self refreshDisplay];
}

@end

