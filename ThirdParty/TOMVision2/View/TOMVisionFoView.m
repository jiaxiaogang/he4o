//
//  TOMVisionFoView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/15.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionFoView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface TOMVisionFoView ()

@property (strong, nonatomic) IBOutlet UIView *containerView;

@end

@implementation TOMVisionFoView

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
    AIFoNodeBase *fo = [SMGUtils searchNode:self.data.content_p];
    
    //2. 刷新UI;
    for (AIKVPointer *alg_p in fo.content_ps) {
        //可以显示一些容易看懂的,比如某方向飞行,或者吃,果,棒,这些;
        
        
    }
}

//MARK:===============================================================
//MARK:                     < override >
//MARK:===============================================================
-(void) setData:(TOFoModel*)value{
    [super setData:value];
    [self refreshDisplay];
}

-(TOFoModel*) data{
    return (TOFoModel*)[self data];
}

@end
