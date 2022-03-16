//
//  TOMVisionNodeBase.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/16.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionNodeBase.h"

@interface TOMVisionNodeBase ()

@property (strong, nonatomic) TOModelBase *data;

@end

@implementation TOMVisionNodeBase

-(void) setData:(TOModelBase*)data{
    _data = data;
}
-(TOModelBase *)data{
    return self.data;
}
-(BOOL) isEqualByData:(DemandModel*)checkData{
    return [self.data isEqual:checkData];
}

@end
