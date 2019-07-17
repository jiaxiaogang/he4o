//
//  NVLineView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/17.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NVLineView.h"

@interface NVLineView ()

@property (strong,nonatomic) UIView *containerView;

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
    
    //containerView
    self.containerView = [[UIView alloc] init];
    [self.containerView setBackgroundColor:[UIColor redColor]];
    [self addSubview:self.containerView];
    [self.containerView setAlpha:0.3f];
}

-(void) initData{
    _data = [[NSMutableArray alloc] init];
}

-(void) initDisplay{
    
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
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
    [self.containerView setFrame:CGRectMake(10, 0, self.width - 20, self.height)];
}

@end

