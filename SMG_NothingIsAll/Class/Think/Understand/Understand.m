//
//  Understand.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Understand.h"
#import "SMGHeader.h"
#import "StoreHeader.h"
#import "FeelHeader.h"
#import "ThinkHeader.h"

@interface Understand ()

@property (strong,nonatomic) NSMutableDictionary *mDic; //数据;

@end

@implementation Understand


//此处应该收集所有有关物;并理解词的意思;理解是和mind互动的过程;需要经过多次交互;
//两年后加上预测未来的功能;(并以此吸引注意力)_17.06.17
//两年后加上无聊感功能;(并以此吸引注意力)_17.06.17
-(id) commitOutAttention:(id)data{
    NSLog(@"无意分析");//只取obj,char不存;
    //1,字符串时//每次都给予注意力;
    if (STRISOK(data)) {
        //收集charArr
        NSString *str = (NSString*)data;
        NSMutableArray *charArr = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < str.length; i++) {
            AIChar *c = AIMakeChar([str characterAtIndex:i]);
            [charArr addObject:c];
        }
        //记录规律
        AILaw *law = AIMakeLawByArr(charArr);
        //问mind有没意见
        if (self.delegata && [self.delegata respondsToSelector:@selector(understand_GetMindValue:)]) {
            id mindValue = [self.delegata understand_GetMindValue:law.pointer];
            if (mindValue) {
                NSLog(@"");//xxx
            }
        }
        return law.pointer;
        
    }
    return nil;
}

-(void) commitInAttension:(id)data{
    NSLog(@"有意分析");
}

-(void) commitInDream:(id)data{
    NSLog(@"梦境整理分析");
}




@end




/**
 *  MARK:--------------------min想--------------------
 *  冥想是逻辑整理的关键;(人工智能在闲暇时间,冥想;可以整理逻辑,甚至假设逻辑,然后在现实中验证假设)
 */



/**
 *  MARK:--------------------Feel交由Understand处理理解并存MK,Mem,Logic--------------------
 *  1,整理感觉系统传过来的数据;(属性,图像等)
 *  2,找出共同点与逻辑;
 *  3,更新记忆,MK;及逻辑推理记忆;(此方法不更,以后用到那条记忆时,再update)
 *  4,根据Mind来调用OUTPUT;(表达语言,表达表情,下一次注意力采集信息)(这种采集分析采集分析的递归过程,发现和DeepMind/DNC里的架构很像)
 *
 *  1,存MK(存MK,并生成mkId)
 *      1.1,找到MK则存;找不到不存;
 *      1.2,针对doModel:fromMKId和toMKId存MK_ImgStore DoType存到MK_AudioStore;
 *  2,存Logic(根据mkId更深了解逻辑,存Logic并生成LogicId)
 *      2.1,分析出逻辑则存,分析不到不存;
 *      2.2,找出逻辑规律(语言规律,行为规律,语言中字词和行为的对称关系)
 *      2.3,例如:多次出现行为:'我' 吃 '瓜'  对应  textModel:我吃瓜
 *  3,存Mem(并使用MKId和LogicId占位符)
 *
 *
 *  工作流程:
 *      1,根据多次出现找分词;(sumNone>=10||sumOne>=6||sumTwo>=3)
 *      2,分词已知时,与实物或行为对应;(记忆中实物行为和<3,未理解的分词数量与实物行为和差值<2)
 *
 */

//7,Logic逻辑;(MK<->因果)
//a,归纳
//苹果类;及属性特征
//b,类比
//总结规律
//c,纠错机制
//知识进化
//遗忘及记忆加强机制(熟能生巧)
//信息来源(兼听则明)
//穷举共存(全部结果,共存共生)
