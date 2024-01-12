//
//  TCRethink.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/25.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------反省--------------------
 *  @desc 分裂成理性反省 和 感性反省 (参考n24p02);
 *  @desc 四个feedback分别对应四个rethink反省 (参考25031-12);
 */
@interface TCRethink : NSObject

+(void) reasonInRethink:(AIMatchFoModel*)model cutIndex:(NSInteger)cutIndex type:(AnalogyType)type;
+(void) perceptInRethink:(AIMatchFoModel*)model type:(AnalogyType)type;
+(void) reasonOutRethink:(TOFoModel*)model actionIndex:(NSInteger)actionIndex type:(AnalogyType)type;
+(void) perceptOutRethink:(TOFoModel*)model type:(AnalogyType)type;

@end
