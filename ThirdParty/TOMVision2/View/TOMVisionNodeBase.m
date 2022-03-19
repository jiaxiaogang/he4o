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
 */
-(BOOL) isEqualByData:(TOModelBase*)checkData{
    BOOL dataEqual = [self.data isEqual:checkData];
    BOOL baseSeemNil = !self.data.baseOrGroup && !checkData.baseOrGroup;
    BOOL baseSeemPit = self.data.baseOrGroup && [self.data.baseOrGroup isEqual:checkData.baseOrGroup];
    BOOL baseEqual = baseSeemNil || baseSeemPit;
    return dataEqual && baseEqual;
}

@end
