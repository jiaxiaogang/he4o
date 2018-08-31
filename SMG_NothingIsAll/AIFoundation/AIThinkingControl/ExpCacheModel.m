//
//  ExpCacheModel.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/21.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "ExpCacheModel.h"

@implementation ExpCacheModel

+(ExpCacheModel*) newWithExp_p:(AIPointer*)exp_p{
    ExpCacheModel *expModel = [[ExpCacheModel alloc] init];
    //if (type == MindHappyType_Yes) {
    //    expModel.score = (CGFloat)urgentTo / 2.0f;//v2TODO:此处,暂时这么写score;但这是伪精度;
    //}else if (type == MindHappyType_No){
    //    expModel.score = -(CGFloat)urgentTo / 2.0f;
    //}
    expModel.exp_p = exp_p;
    return expModel;
}

- (NSMutableArray *)except_ps{
    if (_except_ps == nil) {
        _except_ps = [[NSMutableArray alloc] init];
    }
    return _except_ps;
}

@end
