//
//  ExpModel.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/21.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "ExpModel.h"
#import "AIPointer.h"

@implementation ExpModel

+(ExpModel*) newWithExp_p:(AIPointer*)exp_p{
    ExpModel *expModel = [[ExpModel alloc] init];
    //if (type == MindHappyType_Yes) {
    //    expModel.score = (CGFloat)urgentTo / 2.0f;//v2TODO:此处,暂时这么写score;但这是伪精度;
    //}else if (type == MindHappyType_No){
    //    expModel.score = -(CGFloat)urgentTo / 2.0f;
    //}
    expModel.exp_p = exp_p;
    return expModel;
}


- (NSMutableArray *)exceptExpOut_ps{
    if (_exceptExpOut_ps == nil) {
        _exceptExpOut_ps = [[NSMutableArray alloc] init];
    }
    return _exceptExpOut_ps;
}

- (NSMutableArray *)exceptTryOut_ps{
    if (_exceptTryOut_ps == nil) {
        _exceptTryOut_ps = [[NSMutableArray alloc] init];
    }
    return _exceptTryOut_ps;
}

-(BOOL) isEqual:(ExpModel*)object{
    if (object) {
        return [self.exp_p isEqual:object.exp_p];
    }
    return false;
}

@end
