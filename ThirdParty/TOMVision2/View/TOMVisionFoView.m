//
//  TOMVisionFoView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/15.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionFoView.h"

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
    
    [self.headerBtn setTitle:STRFORMAT(@"F%ld",data.content_p.pointerId) forState:UIControlStateNormal];
    
    //2. 刷新UI;
    for (AIKVPointer *alg_p in fo.content_ps) {
        //可以显示一些容易看懂的,比如某方向飞行,或者吃,果,棒,这些;
        
        
    }
}

@end
