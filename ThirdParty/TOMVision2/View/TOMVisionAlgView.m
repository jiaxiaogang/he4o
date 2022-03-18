//
//  TOMVisionAlgView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/18.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionAlgView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface TOMVisionAlgView ()

@property (strong, nonatomic) IBOutlet UIView *containerView;

@end

@implementation TOMVisionAlgView

-(void) initView{
    //self
    [self setFrame:CGRectMake(0, 0, 40, 10)];
    
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

-(void) refreshDisplay{
    //1. 检查数据;
    if (!self.data) return;
    
    
    
}

//MARK:===============================================================
//MARK:                     < override >
//MARK:===============================================================
-(void) setData:(TOAlgModel*)data{
    [super setData:data];
    [self refreshDisplay];
}

-(TOAlgModel *)data{
    return (DemandModel*)[super data];
}

@end
