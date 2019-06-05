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

+(void) commitText:(NSString*)text{
    //2017.04
    //[theThink commitUnderstandByShallowFromInput:text];//从input常规输入的浅度理解即可;(简单且错误,参考N4P2)
    
    //2017.10.13修正,input->aiNet->funcModel->aiNet->awareness作预测对比(参考n7p6)
    //[theNet commitString:text];
    
    //2017.11.13修正,input->AIAwareness->AIThinkingControl->aiNet->...
    //[theAIAwarenessControl commitInput:text];
    
    //2017.12.15修正,参考Note9SMG软件架构3
    [AIReactorControl commitInput:text];
}

/**
 *  MARK:--------------------提交mvType--------------------
 *  @params from : 0-10
 *  @params to : 0-10
 */
+(void) commitIMV:(MVType)type from:(CGFloat)from to:(CGFloat)to{
    [AIReactorControl commitIMV:type from:from to:to];
}

+(void) commitCustom:(CustomInputType)type value:(NSInteger)value{
    [AIReactorControl commitCustom:type value:value];
}

+(void) commitView:(UIView*)selfView targetView:(UIView*)targetView rect:(CGRect)rect{
    [AIReactorControl commitView:selfView targetView:targetView rect:rect];
}

@end
