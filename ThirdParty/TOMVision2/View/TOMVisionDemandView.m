//
//  TOMVisionDemandView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/16.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionDemandView.h"

@interface TOMVisionDemandView ()

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn;
@property (weak, nonatomic) IBOutlet UILabel *mvDescLab;
@property (weak, nonatomic) IBOutlet UILabel *scoreLab;

@end

@implementation TOMVisionDemandView

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
    CGFloat score = [AIScore score4Demand:self.data];
    
    //2. 类型;
    if (ISOK(self.data, ReasonDemandModel.class)) {
        [self.typeBtn setTitle:@"R" forState:UIControlStateNormal];
    }else if (ISOK(self.data, PerceptDemandModel.class)) {
        [self.typeBtn setTitle:@"P" forState:UIControlStateNormal];
    }else if (ISOK(self.data, HDemandModel.class)) {
        [self.typeBtn setTitle:@"H" forState:UIControlStateNormal];
    }
    
    //3. mv描述颜色
    if (score < 0) {
        [self.mvDescLab setTextColor:UIColor.redColor];
        [self.scoreLab setTextColor:UIColor.redColor];
    }else if(score > 0){
        [self.mvDescLab setTextColor:UIColor.greenColor];
        [self.scoreLab setTextColor:UIColor.greenColor];
    }else {
        [self.mvDescLab setTextColor:UIColor.grayColor];
        [self.scoreLab setTextColor:UIColor.grayColor];
    }
    
    //4. 类型text
    [self.mvDescLab setText:Class2Str(NSClassFromString(self.data.algsType))];
    
    //5. 评分
    [self.scoreLab setText:STRFORMAT(@"%.1f",score)];
}

//MARK:===============================================================
//MARK:                     < override >
//MARK:===============================================================
-(void) setData:(DemandModel*)data{
    [super setData:data];
    [self refreshDisplay];
}

-(DemandModel *)data{
    return (DemandModel*)[super data];
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self.containerView setFrame:CGRectMake(0, 0, self.width, self.height)];
}

@end
