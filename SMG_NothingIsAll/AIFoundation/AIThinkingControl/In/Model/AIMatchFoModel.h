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
 */
@class AIFoNodeBase;
@interface AIMatchFoModel : NSObject

+(AIMatchFoModel*) newWithMatchFo:(AIFoNodeBase*)matchFo matchFoValue:(CGFloat)matchFoValue cutIndex:(NSInteger)cutIndex;
@property (strong, nonatomic) AIFoNodeBase *matchFo;    //匹配时序
@property (assign, nonatomic) CGFloat matchFoValue;     //时序匹配度
@property (assign, nonatomic) NSInteger cutIndex;       //已发生与预测的截点 (0开始,已发生含cutIndex);
@property (assign, nonatomic) TIModelStatus status;     //状态

@end
