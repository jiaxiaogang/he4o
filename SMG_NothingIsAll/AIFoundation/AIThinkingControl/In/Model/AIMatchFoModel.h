//
//  AIMatchFoModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/23.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------单条matchFo模型--------------------
 *  @version
 *      2021.06.29: 将cutIndex拆分为lastMatchIndex和cutIndex两个,即新增cutIndex已发生截点 (参考23152);
 *      2022.09.06: 将匹配度matchFoValue改成单存分子分母两个值,更新时分母+1,分子计算当前的相近度即可 (参考27095-8);
 *      2022.09.15: 因为maskFo(本体为protoFo/regroupFo),它其实在反省推进时会变化的,所以改成realMaskFo (参考27097);
 */
@class AIFoNodeBase;
@interface AIMatchFoModel : NSObject

+(AIMatchFoModel*) newWithMatchFo:(AIKVPointer*)matchFo maskFo:(AIKVPointer*)maskFo sumNear:(CGFloat)sumNear nearCount:(NSInteger)nearCount indexDic:(NSDictionary*)indexDic cutIndex:(NSInteger)cutIndex;
@property (strong, nonatomic) AIKVPointer *matchFo;     //匹配时序

/**
 *  MARK:--------------------识别时为protoFo,反思时为regroupFo--------------------
 *  @desc 状态: 启用,初始化时为maskFo,但后续可随着反省触发器和cutIndex的推进更新;
 *  @desc 元素初始化时为protoFo/regroupFo的content_ps,后续随着更新附加到尾部;
 */
@property (strong, nonatomic) NSMutableArray *realMaskFo;

@property (assign, nonatomic) CGFloat sumNear;          //时序元素相近度总和
@property (assign, nonatomic) NSInteger nearCount;      //时序元素相近数
@property (assign, nonatomic) BOOL isExpired;           //过期状态 (参考n27p09)

//MARK:===============================================================
//MARK:                     < status每帧状态 >
//MARK:===============================================================
@property (strong, nonatomic) NSMutableDictionary *status;//每帧状态 <K:cutIndex, V:TIModelStatus>
-(TIModelStatus) getStatusForCutIndex:(NSInteger)cutIndex;
-(void) setStatus:(TIModelStatus)status forCutIndex:(NSInteger)cutIndex;

/**
 *  MARK:--------------------匹配下标映射--------------------
 *  @desc 其描述了match与mask匹配到的每一位的下标映射 <K:matchFoIndex,V:maskFoIndex>;
 *  @caller
 *      1. 当为瞬时识别时,lastMatchIndex与已发生cutIndex同值 (因为瞬时时,判断的本来就是当前已经发生的事);
 *      2. 当为反思识别时,lastMatchIndex与已发生cutIndex不同值 (因为反思是一种假设,并判断假设这么做会怎么样);
 *  @version
 *      2022.06.11: 将lastMatchIndex迭代成indexDic,即从末位改成记录所有 (参考26232-TODO2);
 */
@property (strong, nonatomic) NSMutableDictionary *indexDic2;

/**
 *  MARK:--------------------已发生截点--------------------
 *  @desc 已发生与预测的截点 (0开始,已发生含cutIndex);
 *          1. 识别时为indexDic的长度-1,即全已发生;
 *          2. 反思时为-1,无效数据 (反思要从foModel.actionIndex随变随取);
 */
@property (assign, nonatomic) NSInteger cutIndex;

@property (assign, nonatomic) NSInteger matchFoStrong;  //时序识别中被引用强度 (目前仅用于调试);

/**
 *  MARK:--------------------AIMatchFoModel的评分(懒加载)缓存--------------------
 *  @desc 初始未计算时 = NSNotFound;
 *  @version
 *      2022.08.19: 初版,因为demand评分常慢(>1s),跑会训练就卡的很,所以加了这个评分缓存 (参考27065);
 */
@property (assign, nonatomic) CGFloat scoreCache;


//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

//当前帧有反馈;
-(void) feedbackFrame:(AIKVPointer*)fbProtoAlg;

//推进至下一帧;
-(void) forwardFrame;

//匹配度计算;
-(CGFloat) matchFoValue;

@end
