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

@interface RLTPanel ()

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *totalScoreLab;
@property (weak, nonatomic) IBOutlet UILabel *branchScoreLab;
@property (weak, nonatomic) IBOutlet UILabel *totalSPLab;
@property (weak, nonatomic) IBOutlet UILabel *branchSPLab;
@property (weak, nonatomic) IBOutlet UILabel *sulutionLab;
@property (weak, nonatomic) IBOutlet UILabel *descProgressLab;
@property (weak, nonatomic) IBOutlet UILabel *traningProgressLab;

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
    
    //scrollView
    //加上边框显示 & delegate;
    
    
    
}

-(void) initData{
    
}

-(void) initDisplay{
}

-(void) refreshDisplay{
    
}

@end
