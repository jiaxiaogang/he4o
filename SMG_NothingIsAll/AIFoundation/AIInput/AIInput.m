//
//  Input.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIInput.h"
#import "AINet.h"
#import "AIReactorControl.h"

@implementation AIInput

static AIInput *_instance;
+(AIInput*) sharedInstance{
    if (_instance == nil) {
        _instance = [[AIInput alloc] init];
    }
    return _instance;
}

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    
}

-(void) commitText:(NSString*)text{
    //2017.04
    //[theThink commitUnderstandByShallowFromInput:text];//从input常规输入的浅度理解即可;(简单且错误,参考N4P2)
    
    //2017.10.13修正,input->aiNet->funcModel->aiNet->awareness作预测对比(参考n7p6)
    //[theNet commitString:text];
    
    //2017.11.13修正,input->AIAwareness->AIThinkingControl->aiNet->...
    //[theAIAwarenessControl commitInput:text];
    
    //2017.12.15修正,参考Note9SMG软件架构3
    [[AIReactorControl shareInstance] commitInput:text];
}

-(void) commitIMV:(MVType)type from:(CGFloat)from to:(CGFloat)to{
    [[AIReactorControl shareInstance] commitIMV:type from:from to:to];
}

-(void) commitCustom:(CustomInputType)type value:(NSInteger)value{
    [[AIReactorControl shareInstance] commitCustom:type value:value];
}

-(void) commitView:(UIView*)selfView targetView:(UIView*)targetView{
    [[AIReactorControl shareInstance] commitView:selfView targetView:targetView];
}

@end
