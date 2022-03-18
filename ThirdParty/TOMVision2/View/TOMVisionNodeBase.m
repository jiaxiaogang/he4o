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
-(BOOL) isEqualByData:(TOModelBase*)checkData{
    BOOL dataEqual = [self.data isEqual:checkData];
    BOOL baseEqual = (!self.data.baseOrGroup && !checkData.baseOrGroup) || [self.data.baseOrGroup isEqual:checkData.baseOrGroup];
    return dataEqual && baseEqual;
}

@end
