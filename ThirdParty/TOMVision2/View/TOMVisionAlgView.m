//
//  TOMVisionAlgView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/18.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionAlgView.h"

@interface TOMVisionAlgView ()

@property (strong, nonatomic) IBOutlet UIView *containerView;

@end

@implementation TOMVisionAlgView

-(void) initView{
    //self
    [super initView];
    [self setFrame:CGRectMake(0, 0, 40, 10)];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
}

-(void) refreshDisplay{
    //1. 检查数据;
    [super refreshDisplay];
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
    return (TOAlgModel*)[super data];
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self.containerView setFrame:CGRectMake(0, 0, self.width, self.height)];
}

@end
