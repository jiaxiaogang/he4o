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
    
    //1,从(记忆,经验和知识)里找到解决方式;
    //2,每一步都要受到(Mood,Hobby,Mine)的影响;
    //3,最终决策再交由Mind作最后命令;
    
    
    
    //难点:当我在办公室想吃东西时;首先想到零食柜;
    //当我在家想吃东西时;首先想到厨房和冰箱;或者从超市购回来的那个袋子里;,,,,如果是饭点,还会想到问媳妇何时作好饭;
    //我怎么快速实现按地域搜索;还是其实这一切只是经验里取的;我习惯性从冰箱找;而不是地域搜索;
    
    
    
    
}

@end
