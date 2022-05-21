//
//  TOMVisionDemandView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/16.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionDemandView.h"
#import "TVUtil.h"

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
        AIMatchFoModel *firstPFo = ARR_INDEX(rData.pFos, 0);
        [mStr appendFormat:@"R%ld",firstPFo.matchFo.pointerId];
    }else if (ISOK(data, PerceptDemandModel.class)) {
        [mStr appendString:@"P"];
    }else if (ISOK(data, HDemandModel.class)) {
        HDemandModel *hData = (HDemandModel*)data;
        [mStr appendFormat:@"H%ld",hData.baseOrGroup.content_p.pointerId];
    }
    
    //3. mv描述颜色
    if (score < 0) {
        [self.headerLab setTextColor:UIColor.redColor];
    }else if(score > 0){
        [self.headerLab setTextColor:UIColor.greenColor];
    }else {
        [self.headerLab setTextColor:UIColor.whiteColor];
    }
    
    //4. 类型text
    if (!ISOK(data, HDemandModel.class)) {
        [mStr appendString:Class2Str(NSClassFromString(data.algsType))];
    }
    
    //5. 评分
    if (!ISOK(data, HDemandModel.class)) {
        [mStr appendFormat:@"%.1f",score];
    }
    
    //5. 内容;
    if (ISOK(data, ReasonDemandModel.class)) {
        ReasonDemandModel *rData = (ReasonDemandModel*)data;
        AIMatchFoModel *firstPFo = ARR_INDEX(rData.pFos, 0);
        [mStr appendFormat:@"\n%@",[TVUtil getLightStr:firstPFo.matchFo]];
    }else if (ISOK(data, HDemandModel.class)) {
        HDemandModel *hData = (HDemandModel*)data;
        [mStr appendFormat:@"\n%@",[TVUtil getLightStr:hData.baseOrGroup.content_p]];
    }
    
    //6. 显示
    [self.headerLab setText:mStr];
}

-(NSString*) getNodeDesc{
    if (ISOK(self.data, ReasonDemandModel.class)) {
        ReasonDemandModel *rData = (ReasonDemandModel*)self.data;
        AIMatchFoModel *firstPFo = ARR_INDEX(rData.pFos, 0);
        return Pit2FStr(firstPFo.matchFo);
    }else if (ISOK(self.data, HDemandModel.class)) {
        HDemandModel *hData = (HDemandModel*)self.data;
        return Pit2FStr(hData.baseOrGroup.content_p);
    }
    return @"";
}

@end
