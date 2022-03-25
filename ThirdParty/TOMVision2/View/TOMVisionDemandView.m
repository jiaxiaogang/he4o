//
//  TOMVisionDemandView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/16.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionDemandView.h"

@implementation TOMVisionDemandView

-(void) initView{
    //self
    [super initView];
    [self setBackgroundColor:UIColorWithRGBHex(0xFFA08D)];
}

-(void) refreshDisplay{
    //1. 检查数据;
    [super refreshDisplay];
    DemandModel *data = (DemandModel*)self.data;
    if (!data) return;
    CGFloat score = [AIScore score4Demand:data];
    
    //2. 类型;
    NSMutableString *mStr = [[NSMutableString alloc] init];
    if (ISOK(data, ReasonDemandModel.class)) {
        ReasonDemandModel *rData = (ReasonDemandModel*)data;
        [mStr appendFormat:@"R%ld",rData.mModel.matchFo.pointerId];
    }else if (ISOK(data, PerceptDemandModel.class)) {
        [mStr appendString:@"P"];
    }else if (ISOK(data, HDemandModel.class)) {
        HDemandModel *hData = (HDemandModel*)data;
        [mStr appendFormat:@"H%ld",hData.baseOrGroup.content_p.pointerId];
    }
    
    //3. mv描述颜色
    if (score < 0) {
        [self.headerBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    }else if(score > 0){
        [self.headerBtn setTitleColor:UIColor.greenColor forState:UIControlStateNormal];
    }else {
        [self.headerBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
    
    //4. 类型text
    [mStr appendString:Class2Str(NSClassFromString(data.algsType))];
    
    //5. 评分
    [mStr appendFormat:@"%.1f",score];
    
    //6. 显示
    [self.headerBtn setTitle:mStr forState:UIControlStateNormal];
}

@end
