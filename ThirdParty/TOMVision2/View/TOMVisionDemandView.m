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
@property (weak, nonatomic) IBOutlet UIButton *headerBtn;

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
    NSMutableString *mStr = [[NSMutableString alloc] init];
    if (ISOK(self.data, ReasonDemandModel.class)) {
        ReasonDemandModel *rData = (ReasonDemandModel*)self.data;
        [mStr appendFormat:@"R%ld",rData.mModel.matchFo.pointer.pointerId];
    }else if (ISOK(self.data, PerceptDemandModel.class)) {
        [mStr appendString:@"P"];
    }else if (ISOK(self.data, HDemandModel.class)) {
        HDemandModel *hData = (HDemandModel*)self.data;
        [mStr appendFormat:@"H%ld",hData.baseOrGroup.content_p.pointerId];
    }
    
    //3. mv描述颜色
    if (score < 0) {
        [self.headerBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    }else if(score > 0){
        [self.headerBtn setTitleColor:UIColor.greenColor forState:UIControlStateNormal];
    }else {
        [self.headerBtn setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    }
    
    //4. 类型text
    [mStr appendString:Class2Str(NSClassFromString(self.data.algsType))];
    
    //5. 评分
    [mStr appendFormat:@"%.1f",score];
    
    //6. 显示
    [self.headerBtn setTitle:mStr forState:UIControlStateNormal];
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
    [self.headerBtn setFrame:CGRectMake(0, 0, self.width, self.height)];
}

@end
