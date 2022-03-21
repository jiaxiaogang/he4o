//
//  TOMVisionAlgView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/18.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionAlgView.h"

@implementation TOMVisionAlgView

-(void) initView{
    //self
    [super initView];
    [self setBackgroundColor:UIColorWithRGBHex(0xAAAAAA)];
}

-(void) refreshDisplay{
    //1. 检查数据;
    [super refreshDisplay];
    TOAlgModel *data = (TOAlgModel*)self.data;
    if (!data) return;
    
    [self.headerBtn setTitle:STRFORMAT(@"A%ld",data.content_p.pointerId) forState:UIControlStateNormal];
}

@end
