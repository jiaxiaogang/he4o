//
//  Decision.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Decision.h"
#import "MindHeader.h"


@interface Decision ()

@property (strong,nonatomic) NSMutableDictionary *mDic; //数据;

@end


@implementation Decision


/**
 *  MARK:--------------------Mind引擎的需求 分析 & 决策--------------------
 *  Mind->Decision->FeelOut->Output
 */
-(void) commitDemand:(id)demand withType:(MindType)type{
    NSLog(@"1,提交需求...To...Decision");
    
    
    NSLog(@"2,分析决策 Mind的需求 ");
    NSLog(@"3,分析理解Mind需求,作出下步行为输出");
    
    
    
    if (type == MindType_Angry) {
        NSLog(@"我很生气!");
        NSLog(@"我要:%@",demand);
    }else if (type == MindType_Happy) {
        NSLog(@"我很开心!");
        NSLog(@"我要:%@",demand);
    }
    
    //1,从(记忆,经验习惯和知识)里找到解决方式;
    //  1.1,注:每一步都要受到(Mood,Hobby,Mine)的影响;
    //  1.2,找不到分析(获取注意力|作为火花塞点燃mind)(转2)
    //  1.3,找到则执行(转3)
    //2,decision分析
    //3,执行;
    //  3.1,注:最终决策要交由Mind作最后命令;
    //4,结果;
    //  4.1,反馈给mindControl;
    
    
    //?解决饿的问题
    if (type == MindType_Hunger) {
        //1,找吃的
        //1.1,找到与吃的最相关的东西;(如冰箱)
//        AILaw
        
        
        //分析当前的饥饿状态 & 记到"意识流";
        //找相关记忆,如果找不到则直接表达情绪;
        //xxxx
        
        
        
    }
    [AILogic ai_searchSingleWithRowId:0];
    
    //?:SMG的觉醒
    //1,无法跳过input来实现理解世界(机器已经有了听视文字三觉,只是与人类不同)
    //2,所有的数据有模糊到清晰的过程
    //3,决策无经验,则用原始方式;
    //4,假设SMG面对与人类完全不同的世界;只能通过输出文本和表情符来与世界沟通;而通过输入文本来交流;
    
    
    
    //logic表结构分析:mindType,mindValue,pointerArr;
    //1,单需求时,直接通过先天定义的急哭就可以解决;
    //2,多样需求时,就有了交互;交互是互相试探的过程;(并且试探过程会存为经验logic)
    //3,logic只存有指针;指向memory(长期情景记忆)
    //4,If(a,b=>c); 然后: b!>c; 则:a=>c;
    
    
    
    //数据
    //1,input时输入了一切 & 放到回放池;
    //2,作浅理解;
    //3,获得注意力 & 拍照;
    //4,存深理解内容,存记忆内容,存快照;
    //5,遗忘策略,4小时忘60%,24小时再忘20%;
    
    
    
    
    
    
}

@end
