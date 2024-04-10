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
 */
@interface AIRealModel : NSObject


//可以把初始内容也计入其中,然后记一个initCutIndex;

/**
 *  MARK:--------------------识别时为protoFo,反思时为regroupFo--------------------
 *  @title 实际经历;
 *  @desc 状态: 启用,初始化时为maskFo,但后续可随着反省触发器和cutIndex的推进更新;
 *  @desc 元素初始化时为protoFo/regroupFo的content_ps,后续随着更新附加到尾部;
 */
@property (strong, nonatomic) NSMutableArray *realAlgs;

@property (strong, nonatomic) NSMutableArray *realDeltaTimes; //List<deltaTime> (用来完全时序时,构建protoFo时使用);

/**
 *  MARK:--------------------实际与期望之间的映射--------------------
 *  @解释 1. 实际: TI时为:RealMaskFo & TO时为:每一个algModel的feedbackAlg
 *       2. 期望: TO时为:CansetTo
 *  @desc 用于记录实际反馈与cansetTo的映射 (每反馈一帧,记录一帧) <K:期望 V:实际>;
 */
@property (strong, nonatomic) NSDictionary *realHopeIndexDic;

@end
