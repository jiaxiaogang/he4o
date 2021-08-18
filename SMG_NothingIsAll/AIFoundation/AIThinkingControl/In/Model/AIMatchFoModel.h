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
 */
@class AIFoNodeBase;
@interface AIMatchFoModel : NSObject

+(AIMatchFoModel*) newWithMatchFo:(AIFoNodeBase*)matchFo matchFoValue:(CGFloat)matchFoValue lastMatchIndex:(NSInteger)lastMatchIndex cutIndex:(NSInteger)cutIndex;
@property (strong, nonatomic) AIFoNodeBase *matchFo;    //匹配时序
@property (assign, nonatomic) CGFloat matchFoValue;     //时序匹配度
@property (assign, nonatomic) TIModelStatus status;     //状态

/**
 *  MARK:--------------------匹配截点--------------------
 *  @desc 其描述了proto在match中匹配到的最后一位,在match中的下标;
 *  @caller
 *      1. 当为瞬时识别时,lastMatchIndex与已发生cutIndex同值 (因为瞬时时,判断的本来就是当前已经发生的事);
 *      2. 当为反思识别时,lastMatchIndex与已发生cutIndex不同值 (因为反思是一种假设,并判断假设这么做会怎么样);
 */
@property (assign, nonatomic) NSInteger lastMatchIndex;

/**
 *  MARK:--------------------已发生截点--------------------
 *  @desc 已发生与预测的截点 (0开始,已发生含cutIndex);
 */
@property (assign, nonatomic) NSInteger cutIndex2;

@property (assign, nonatomic) NSInteger matchFoStrong;  //时序识别中被引用强度 (目前仅用于调试);

@end
