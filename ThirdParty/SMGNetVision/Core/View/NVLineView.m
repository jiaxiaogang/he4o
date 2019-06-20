//
//  NVLineView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/17.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NVLineView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "NVNodeView.h"
#import "NodeCompareModel.h"

@interface NVLineView ()

@property (strong,nonatomic) IBOutlet UIView *containerView;

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
    self.height = 1;
    
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

@end

