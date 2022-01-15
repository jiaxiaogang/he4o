//
//  ActiveCache.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/15.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------理性的,瞬时匹配模型--------------------
 *  说明:
 *      1. AIShortMatchModel是TOR理性思维的model结果;
 *      2. 在瞬时ShortMemory整合到短时ShortMatchModel中来后,短时中的protoAlg即表示原瞬时;
 *  @desc 191104 : 将activeCache更名为shortMatch,并传递给TOR使用;
 *  @desc 模型说明:
 *      1. 供TOR使用的模型一共有三种: 瞬时,短时,长时;
 *      2. 瞬时由模型承载,而短时和长时由Net承载;
 *      3. 此AIShortMatchModel是瞬时的模型;
 *  @todo
 *      1. 支持多条matchAlg,多条matchFo,将fuzzys独立列出;
 *      2. 在多条matchFo.mv价值预测下,可以相应的跑多个正向反馈类比,和反向反馈类比;
 *  @version
 *      2020.10.30: 将seemAlg改成partAlgs,即将所有相似返回 (参考21113-步骤1);
 */
@interface AIShortMatchModel : NSObject

//MARK:===============================================================
//MARK:                     < Alg部分 >
//MARK:===============================================================
@property (strong, nonatomic) AIAlgNodeBase *protoAlg;  //原始概念

/**
 *  MARK:--------------------匹配概念--------------------
 *  @version
 *      2020.10.30前: 一般为全含抽象节点,但在无全含时,就是partAlgs的首个节点;
 *      2020.10.30: 仅为全含抽象节点 (如果v2四测中,发现此处变动有影响,则反过来考虑此改动是否合理);
 *      2020.11.18: 支持多全含识别 (参考21145);
 *  @desc
 *      排序方式: 按照matchCount特征匹配数从大到小排序 (匹配数最多的,一般也最具象);
 */
@property (strong, nonatomic) NSArray *matchAlgs;
@property (strong, nonatomic) AIAlgNodeBase *matchAlg;//默认为matchAlgs首条;

/**
 *  MARK:--------------------局部匹配概念--------------------
 *  @desc 排序方式: 仅按照matchCount排序 (不含全含部分);
 *  @todo
 *      2020.11.18: 随后可考虑,将是否"全含"作为第一排序标准,matchCount作为第二排序标准 (转至下条);
 *      2020.11.18: 随后可考虑,是否将"全含"部分移出去,此处仅保留partAlgs即可 T;
 */
@property (strong, nonatomic) NSArray *partAlgs;
@property (assign, nonatomic) NSTimeInterval inputTime; //原始概念输入时间


//MARK:===============================================================
//MARK:                     < Fo部分 >
//MARK:===============================================================
/**
 *  MARK:--------------------原始时序--------------------
 *  @desc
 *      1. 不可轻易改为由protoAlg构建,因为matchAlg对红色或距离的认识才是几个标志性值(比如5,8,13,21,57);
 *          a. 内类比成果因此而,这对以后决策时进行匹配有用,如果改成protoAlg构建,这个值会非常多,使决策循环也非常多才能找到有用的经验;
 *          b. 反向反馈类比成果也同理,对MC中MC是否有效可行为化的判定非常有用,因为一旦无法MC匹配到mIsC,那么将进入下轮决策循环;
 *  @version
 *      2020.06.26: 将protoFo拆分为protoFo和matchAFo两部分;
 */
@property (strong, nonatomic) AIFoNodeBase *protoFo;

/**
 *  MARK:--------------------由matchAlg构建的时序--------------------
 *  @desc
 *      1. 将原先protoFo,拆分为:protoFo和matchAFo两部分实现;
 *      2. 由前几桢瞬时中的(优先matchAlg,matchAlg为空时填充protoAlg)来构建 (完整而尽量抽象);
 */
@property (strong, nonatomic) AIFoNodeBase *matchAFo;

/**
 *  MARK:--------------------时序识别--------------------
 *  @version
 *      2021.01.23: 支持时序多识别 (参考22073);
 *      2021.01.24: 默认取首条mFo,改为默认取含mv且迫切度最高的一条 (参考22073-todo7);
 *      2021.04.15: 支持matchRFos (参考23014-分析1&23016);
 *  @desc
 *      内容说明: 对已发生部分全含匹配的时序;
 *      排序方式: 按照当前matchAlg.refPorts被引用强度有序;
 */
@property (strong, nonatomic) NSMutableArray *matchPFos; //有mv指向匹配时序 (元素为AIMatchFoModel);
@property (strong, nonatomic) NSMutableArray *matchRFos; //无mv指向匹配时序 (元素为AIMatchFoModel);

/**
 *  MARK:--------------------时序抽象--------------------
 *  @desc
 *      内容说明: 在时序识别后,由matchRFos与protoFo类比抽象而成 (元素为AIFoNodeBase) (参考23041-示图absFo);
 *      用途说明: 作为RFo抽具象的"激活期",用于加强RFo的抽具象关联,从而解决GL嵌套在抽具象通路上打通的问题;
 *  @callers
 *      1. 在内中外类比中,会将抽象gl嵌套到对应的absRFo下;
 *      2. 在getInnerGL中,会尝试从absRFos下取GL经验;
 *  @version
 *      2021.04.22: 初版 (参考23041);
 */
@property (strong, nonatomic) NSMutableArray *absRFos;

/**
 *  MARK:--------------------含mv且迫切度最高的一条mFo--------------------
 */
//@property (strong, nonatomic) AIFoNodeBase *matchFo;    //matchFo
//@property (assign, nonatomic) CGFloat matchFoValue;     //时序匹配度
//@property (assign, nonatomic) TIModelStatus status;     //状态

@end
