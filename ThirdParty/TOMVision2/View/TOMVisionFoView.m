//
//  TOMVisionFoView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/15.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionFoView.h"
#import "TVUtil.h"

@implementation TOMVisionFoView

-(void) initView{
    //self
    [super initView];
    [self setBackgroundColor:UIColorWithRGBHex(0xDDBD08)];
}

-(void) refreshDisplay{
    //1. 检查数据;
    TOFoModel *data = (TOFoModel*)self.data;
    [super refreshDisplay];
    if (!data) return;
    AIFoNodeBase *fo = [SMGUtils searchNode:data.content_p];
    
    //2. SP计数求和;
    NSInteger sumSP = 0;
    for (AISPStrong *sp in fo.spDic.allValues) {
        sumSP += sp.sStrong + sp.pStrong;
    }
    
    //2. 收集要展示的文本;
    NSMutableString *mStr = [[NSMutableString alloc] init];
    [mStr appendFormat:@"F%ld",data.content_p.pointerId];
    if (ISOK(data.baseOrGroup, ReasonDemandModel.class)) {
        //CGFloat spScore = [TOUtils getSPScore:fo startSPIndex:0 endSPIndex:fo.count];
        [mStr appendFormat:@" SP:%ld",sumSP];
    }else if(ISOK(data.baseOrGroup, HDemandModel.class)){
        //CGFloat spScore = [TOUtils getSPScore:fo startSPIndex:0 endSPIndex:data.targetIndex];
        [mStr appendFormat:@" SP:%ld",sumSP];
    }
    
    //2. 内容;
    [mStr appendFormat:@"\n%@",[TVUtil getLightStr:data.content_p]];
    
    //3. 刷新UI;
    [self.headerLab setText:mStr];
    for (AIKVPointer *alg_p in fo.content_ps) {
        //可以显示一些容易看懂的,比如某方向飞行,或者吃,果,棒,这些;
        
        
    }
}

-(NSString*) getNodeDesc{
    return Pit2FStr(self.data.content_p);
}

@end
