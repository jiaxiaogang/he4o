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

-(void) setData:(TOModelBase*)value{
    _mData = value;
}
-(TOModelBase *)data{
    return _mData;
}
-(BOOL) isEqualByData:(TOModelBase*)checkData{
    return [self.data isEqual:checkData];
}

@end
