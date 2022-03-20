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
    [self setFrame:CGRectMake(0, 0, 80, 10)];
}

-(void) initData{
}

-(void) initDisplay{
}

-(void) refreshDisplay{
}

-(void) setData:(TOModelBase*)value{
    _mData = value;
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
 */
-(BOOL) isEqualByData:(TOModelBase*)checkData{
    //BOOL dataEqual = [self.data isEqual:checkData];
    //BOOL baseSeemNil = !self.data.baseOrGroup && !checkData.baseOrGroup;
    //BOOL baseSeemPit = self.data.baseOrGroup && [self.data.baseOrGroup isEqual:checkData.baseOrGroup];
    //BOOL baseEqual = baseSeemNil || baseSeemPit;
    //return dataEqual && baseEqual;
    return [STRFORMAT(@"%p",self.data) isEqualToString:STRFORMAT(@"%p",checkData)];
}

-(void) scaleContainer:(CGFloat)scale{
    for (UIView *view in self.subviews) {
        //1. 先拉长;
        view.width = (scale == 0) ? 0 : (self.width / scale);
        view.height = (scale == 0) ? 0 : (self.height / scale);
        
        //2. 缩放是中心缩放的,所以先中心对齐;
        view.center = CGPointMake(self.width / 2, self.height / 2);
        
        //3. 多次缩放导致bounds和frame大小不统一,所以每次缩放时强行重置bounds尺寸;
        view.bounds = CGRectMake(0, 0, view.width, view.height);
        
        //4. 再缩小;
        [view setTransform:CGAffineTransformIdentity];
        [view setTransform:CGAffineTransformMakeScale(scale, scale)];
    }
}

@end
