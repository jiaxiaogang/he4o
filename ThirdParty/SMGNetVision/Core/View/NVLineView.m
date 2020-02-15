//
//  NVLineView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/17.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NVLineView.h"
#import "NVConfig.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface NVLineView ()

@property (strong,nonatomic) UIView *lineView;
@property (strong, nonatomic) UILabel *lightLab;

@end

@implementation NVLineView

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
        [self initData];
        [self initDisplay];
    }
    return self;
}

-(void) initView{
    //self
    [self setBackgroundColor:[UIColor clearColor]];
    self.height = 1.0f;//1.0f / UIScreen.mainScreen.scale;
    [self setUserInteractionEnabled:false];
    [self.layer setMasksToBounds:true];
    [self.layer setMasksToBounds:false];
    
    //lineView
    self.lineView = [[UIView alloc] init];
    [self.lineView setBackgroundColor:UIColorWithRGBHex(0xBB5500)];
    [self addSubview:self.lineView];
    [self.lineView setAlpha:0.2f];
    [self.lineView.layer setMasksToBounds:false];
    
    //strongLab
    self.lightLab = [[UILabel alloc] init];
    [self.lightLab setTextColor:UIColorWithRGBHex(0xFF0000)];
    [self addSubview:self.lightLab];
    [self.lightLab setAlpha:0.2f];
    [self.lightLab setFrame:CGRectMake(0, 0, 50, 10)];
    [self.lightLab setFont:[UIFont systemFontOfSize:8]];
    [self.lightLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    
}

-(void) initData{
    _data = [[NSMutableArray alloc] init];
}

-(void) initDisplay{
    
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) light:(NSString*)lightStr{
    [self.lightLab setText:lightStr];
}

-(void) setDataWithDataA:(id)dataA dataB:(id)dataB{
    if (dataA && dataB) {
        [self setDataWithData:@[dataA,dataB]];
    }
}

-(void) setDataWithData:(NSArray*)data{
    if (ARRISOK(data) && data.count == 2) {
        [self.data removeAllObjects];
        [self.data addObjectsFromArray:data];
        [self refreshDisplay];
    }
}

-(void) refreshDisplay{
    
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self.lineView setFrame:CGRectMake(cNodeSize * 0.5f, 0, self.width - cNodeSize, self.height)];
}

@end
