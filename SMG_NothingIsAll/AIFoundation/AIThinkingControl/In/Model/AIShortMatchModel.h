//
//  ActiveCache.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/15.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------瞬时模型 (单帧)--------------------
 *  @title 即: pFo
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
 *      2022.01.17: 废弃matchRFos,因其主要用于GL已被废弃,且现rLearning再抽象不仅针对rFos也支持pFos (参考25104);
 *      2023.02.25: 废弃matchRFos代码,其早已明存实亡,最近改动了下时序识别算法,正好把它代码注掉 (参考时序识别算法-注释2023.02.24);
 */
@interface AIShortMatchModel : NSObject

//MARK:===============================================================
//MARK:                     < Alg部分 >
//MARK:===============================================================
@property (strong, nonatomic) AIAlgNodeBase *protoAlg;  //原始概念

/**
 *  MARK:--------------------概念识别结果 (元素为AIMatchAlgModel)--------------------
 *  @readme 1. 感: 最终有价值指向; 理: 最终无价值指向;
 *          2. 似: 较具象,所含元素相似但未抛除; 交: 较抽象,所含元素相似度低已在类比中有过抛除 (它的判断标准并非是否抽象具象,而是是否有抛除元素);
 *  @version
 *      2020.10.30前: 一般为全含抽象节点,但在无全含时,就是partAlgs的首个节点;
 *      2020.10.30: 仅为全含抽象节点 (如果v2四测中,发现此处变动有影响,则反过来考虑此改动是否合理);
 *      2020.11.18: 支持多全含识别 (参考21145);
 *  @desc
 *      排序方式: 按照matchCount特征匹配数从大到小排序 (匹配数最多的,一般也最具象);
 */
@property (strong, nonatomic) NSArray *matchAlgs_PS; //概念识别结果 (感似层)
@property (strong, nonatomic) NSArray *matchAlgs_PJ; //概念识别结果 (理交层)
@property (strong, nonatomic) NSArray *matchAlgs_RS; //概念识别结果 (感似层)
@property (strong, nonatomic) NSArray *matchAlgs_RJ; //概念识别结果 (理交层)
@property (strong, nonatomic) AIMatchAlgModel *firstMatchAlg;//默认为matchAlgs首条;
-(NSArray*) matchAlgs_R;    //返回理部分 notnull;
-(NSArray*) matchAlgs_P;    //返回感部分 notnull;
-(NSArray*) matchAlgs_Si;   //返回似层 notnull;
-(NSArray*) matchAlgs_Jiao; //返回交层 notnull;
-(NSArray*) matchAlgs_All;  //返回全部 notnull;

@property (assign, nonatomic) NSTimeInterval inputTime; //原始概念输入时间


//MARK:===============================================================
//MARK:                     < Fo部分 >
//MARK:===============================================================
/**
 *  MARK:--------------------原始时序--------------------
 *  @desc
 *      1. protoFo: 由前几帧AIShortModel.protoAlg组成时序;
 *      2. regroupFo: 由TOFoModel的实际反馈feedbackProtoAlg组成时序 (没反馈的由原matchFo.alg补足);
 *  @version
 *      2020.06.26: 将protoFo拆分为protoFo和matchAFo两部分;
 */
@property (strong, nonatomic) AIFoNodeBase *protoFo;    //识别时赋值
@property (strong, nonatomic) AIFoNodeBase *regroupFo;  //反思时赋值
@property (strong, nonatomic) AIFoNodeBase *protoFo4PInput;//P输出时赋值 (将mv放到protoFo的content末位) (参考30094-todo3);

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
 *      2023.03.15: 打开matchRFos (参考28181-方案3);
 *  @desc
 *      内容说明: 对已发生部分全含匹配的时序;
 *      排序方式: 按照当前matchAlg.refPorts被引用强度有序;
 */
@property (strong, nonatomic) NSMutableArray *matchPFos; //有mv指向匹配时序 (元素为AIMatchFoModel);
@property (strong, nonatomic) NSMutableArray *matchRFos; //无mv指向匹配时序 (元素为AIMatchFoModel);

/**
 *  MARK:--------------------含mv且迫切度最高的一条mFo--------------------
 */
//@property (strong, nonatomic) AIFoNodeBase *matchFo;    //matchFo
//@property (assign, nonatomic) CGFloat matchFoValue;     //时序匹配度
//@property (assign, nonatomic) TIModelStatus status;     //状态


//MARK:===============================================================
//MARK:           < 不同用途时取不同prFos (参考25134-方案2) >
//MARK:===============================================================

//用于学习 (参考:25134-方案2-A学习);
//-(NSArray*) fos4RLearning;
-(NSArray*) fos4PLearning;

//用于预测 (参考:25134-方案2-B预测);
//-(NSArray*) fos4RForecast;
-(NSArray*) fos4PForecast;

//用于预测 (参考:25134-方案2-B预测);
-(NSDictionary*) fos4Demand;

-(void) log4HavXianWuJv_AlgPJ:(NSString*)prefix;
-(void) log4HavXianWuJv_PFos:(NSString*)prefix;

@end
