//
//  FrontIndexDicModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/30.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------前段条件满足算法结果模型--------------------
 */
@interface FrontIndexDicModel : NSObject

+(FrontIndexDicModel*) newWithProtoIndex:(NSInteger)protoIndex cansetIndex:(NSInteger)cansetIndex transferAlg:(AIKVPointer*)transferAlg_p;

@property (assign, nonatomic) NSInteger protoIndex;//映射到的proto下标
@property (assign, nonatomic) NSInteger cansetIndex;//映射到的canset下标
@property (strong, nonatomic) AIKVPointer *transferAlg_p;//cansetAlg迁移后的transferAlg;

@end
