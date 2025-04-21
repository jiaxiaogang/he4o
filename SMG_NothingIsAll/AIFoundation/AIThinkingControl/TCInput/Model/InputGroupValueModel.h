//
//  InputDotModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/15.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------装箱后的组特征模型，用于表征除装箱后指针外，外加level粒度层级和xy位置信息--------------------
 */
@interface InputGroupValueModel : NSObject

+(id) new:(AIKVPointer*)groupValue_p rect:(CGRect)rect;

@property (assign, nonatomic) CGRect rect;//转为最小粒度层的范围
@property (strong, nonatomic) AIKVPointer *groupValue_p;//用subDot_ps构建的组码。

@end
