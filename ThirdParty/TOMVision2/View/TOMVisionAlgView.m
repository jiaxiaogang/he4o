//
//  TOMVisionAlgView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/18.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionAlgView.h"
#import "TVUtil.h"

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
    
    //2. 内容;
    NSMutableString *mStr = [[NSMutableString alloc] init];
    [mStr appendFormat:@"A%ld",data.content_p.pointerId];
    [mStr appendFormat:@"\n%@",[TVUtil getLightStr:data.content_p]];
    
    //3. 显示;
    [self.headerLab setText:mStr];
}

-(NSString*) getNodeDesc{
    return Pit2FStr(self.data.content_p);
}

@end
