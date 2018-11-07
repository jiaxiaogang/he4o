//
//  CrowView.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/7.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "CrowView.h"

@interface CrowView ()

@property (strong,nonatomic) IBOutlet UIView *containerView;

@end

@implementation CrowView

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
    }
    return self;
}

-(void) initView{
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    
    //self
    [self setBackgroundColor:[UIColor clearColor]];
    [self setFrame:CGRectMake(0, 0, ScreenWidth, 59)];
}

@end

