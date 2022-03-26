//
//  TOMVisionNodeBase.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/16.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionNodeBase.h"

@interface TOMVisionNodeBase ()

@property (strong, nonatomic) TOModelBase *mData;

@end

@implementation TOMVisionNodeBase

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
    //[self.layer setMasksToBounds:true];
    [self setFrame:CGRectMake(0, 0, 40, 10)];
    
    //containerView
    self.containerView = [[UIView alloc] init];
    [self addSubview:self.containerView];
    
    //headerBtn
    self.headerBtn = [[UIButton alloc] init];
    [self.containerView addSubview:self.headerBtn];
    [self.headerBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
    [self.headerBtn setOrigin:CGPointZero];
}

-(void) initData{
}

-(void) initDisplay{
}

-(void) refreshDisplay{
}

-(void) setData:(TOModelBase*)value{
    _mData = value;
    [self refreshDisplay];
}
-(TOModelBase *)data{
    return _mData;
}

/**
 *  MARK:--------------------判断一致--------------------
 *  @desc 用于复用view
 *      1. 现在判断data.Equal而不是content_p的Equal,因为同一content_p也有可能不能复用;
 *      2. 比如: 多帧matchFo都生成了RDemand,但cutIndex等细节有差异,是不能复用的;
 *  @version
 *      2022.03.20: 用内存地址是否匹配来判断equal,因为树上可能同时出现多处同节点,且它们的base也一样 (导致过度复用);
 *      2022.03.23: 改用selfIden替代内存地址 (参考25185-方案1-优点);
 */
-(BOOL) isEqualByData:(TOModelBase*)checkData{
    //BOOL dataEqual = [self.data isEqual:checkData];
    //BOOL baseSeemNil = !self.data.baseOrGroup && !checkData.baseOrGroup;
    //BOOL baseSeemPit = self.data.baseOrGroup && [self.data.baseOrGroup isEqual:checkData.baseOrGroup];
    //BOOL baseEqual = baseSeemNil || baseSeemPit;
    //return dataEqual && baseEqual;
    return [self.data isEqual:checkData];
}

-(void) scaleContainer:(CGFloat)scale{
    //1. 先拉长;
    self.containerView.width = (scale == 0) ? 0 : (self.width / scale);
    self.containerView.height = (scale == 0) ? 0 : (self.height / scale);
    [self.headerBtn setSize:self.containerView.size];
    
    //2. 缩放是中心缩放的,所以先中心对齐;
    self.containerView.center = CGPointMake(self.width / 2, self.height / 2);
    
    //3. 多次缩放导致bounds和frame大小不统一,所以每次缩放时强行重置bounds尺寸;
    self.containerView.bounds = CGRectMake(0, 0, self.containerView.width, self.containerView.height);
    
    //4. 再缩小;
    [self.containerView setTransform:CGAffineTransformIdentity];
    [self.containerView setTransform:CGAffineTransformMakeScale(scale, scale)];
}

@end
