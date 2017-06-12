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
    
    //xxx
    
    //代码:定义不同时期的输出决策;开心就笑和不开心就哭;这是先天决定的;
    //不会说话明:笑和哭
    //学会说话后,用语言和动作等表达;
    
    //难点:当我在办公室想吃东西时;首先想到零食柜;
    //当我在家想吃东西时;首先想到厨房和冰箱;或者从超市购回来的那个袋子里;,,,,如果是饭点,还会想到问媳妇何时作好饭;
    //这一切只是经验里取的;我习惯性从冰箱找;
    
    
    
    
}

@end
