//
//  AIThinkOutMvModel.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/21.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIThinkOutMvModel.h"
#import "AIPointer.h"

@implementation AIThinkOutMvModel

+(AIThinkOutMvModel*) newWithExp_p:(AIPointer*)mvNode_p{
    AIThinkOutMvModel *expModel = [[AIThinkOutMvModel alloc] init];
    //if (type == MindHappyType_Yes) {
    //    expModel.score = (CGFloat)urgentTo / 2.0f;//v2TODO:此处,暂时这么写score;但这是伪精度;
    //}else if (type == MindHappyType_No){
    //    expModel.score = -(CGFloat)urgentTo / 2.0f;
    //}
    expModel.mvNode_p = mvNode_p;
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

-(BOOL) isEqual:(AIThinkOutMvModel*)object{
    if (object) {
        return [self.mvNode_p isEqual:object.mvNode_p];
    }
    return false;
}

@end
