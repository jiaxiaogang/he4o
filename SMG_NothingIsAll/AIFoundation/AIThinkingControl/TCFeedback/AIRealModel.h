//
//  AIRealModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2024.04.10.
//  Copyright © 2024 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------实际反馈记录--------------------
 *  @desc 此模型起因: 在TI中,早就有realMaskFo和realDeltaTimes的做法,并且indexDic映射也够用,但在TO中,测出了构建RHCanset时,其indexDic或不准,或为空的问题;
 *                  而写这个RealModel模型,就是为了整理这一流程,将其数据整理过来,使之相关代码看着顺当简洁,也解决TO中indexDic不准等问题;
 *  @desc RealModel分两步:
 *          1. 初始:
 *              1.1 在TI中,时序识别预测后,将预测matchFo和实际发生maskFo中已发生的部分存下来;
 *              1.2 在TO中,cansetFo迁移xv之后(xvModel赋值后),将sceneTo和cansetTo已发生部分的映射存下来;
 *                  TODO: 可以考虑把初始内容记一个initCutIndex;
 *          2. 更新:
 *              1.1 在TI中,每一次feedbackTIR反馈后,再更新之;
 *              1.2 在TO中,后续每次cansetFo有反馈时,再更新之;
 */
@interface AIRealModel : NSObject

/**
 *  MARK:--------------------识别时为protoFo,反思时为regroupFo--------------------
 *  @title 实际经历: 包含真实发生各帧 与 各帧之间的时差;
 *  @作用 用来最后清算构建时序时,构建protoFo时要用;
 *  @desc 状态: 启用,初始化时为maskFo,但后续可随着反省触发器和cutIndex的推进更新;
 *  @desc 元素初始化时为protoFo/regroupFo的content_ps,后续随着更新附加到尾部;
 */
@property (strong, nonatomic) NSMutableArray *realOrders;

/**
 *  MARK:--------------------实际与场景之间的映射--------------------
 *  @解释 1. 实际: TI时为:RealMaskFo & TO时为:每一个algModel的feedbackAlg
 *       2. 场景: TI时为:matchFo(pFo) & TO时为:SceneTo
 *  @desc 用于记录实际反馈与cansetTo的映射 (每反馈一帧,记录一帧) <K:场景 V:实际>;
 */
@property (strong, nonatomic) NSMutableDictionary *realSceneIndexDic;

@end
