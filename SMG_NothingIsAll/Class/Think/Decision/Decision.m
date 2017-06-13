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
    }
    [AILogic ai_searchSingleWithRowId:0];
    
    
    
    
    
    
    
    
    
    
    
}

@end
