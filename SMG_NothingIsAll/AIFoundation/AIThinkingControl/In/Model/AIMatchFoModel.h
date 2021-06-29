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
 *      2021.06.29: 对于认知识别时matchFo而言,匹配cutIndex与已发生actionIndex是一回事;
 *      2021.06.29: 对于反思时matchFo而言,匹配cutIndex与已发生actionIndex并不是一回事 (因为反思是"假设"这么做,会怎么样);
 */
@class AIFoNodeBase;
@interface AIMatchFoModel : NSObject

+(AIMatchFoModel*) newWithMatchFo:(AIFoNodeBase*)matchFo matchFoValue:(CGFloat)matchFoValue cutIndex:(NSInteger)cutIndex;
@property (strong, nonatomic) AIFoNodeBase *matchFo;    //匹配时序
@property (assign, nonatomic) CGFloat matchFoValue;     //时序匹配度
@property (assign, nonatomic) NSInteger cutIndex;       //proto在match中匹配到的最后一位,在match中的下标;
@property (assign, nonatomic) NSInteger actionIndex;    //已发生与预测的截点 (0开始,已发生含cutIndex);
@property (assign, nonatomic) TIModelStatus status;     //状态

@end
