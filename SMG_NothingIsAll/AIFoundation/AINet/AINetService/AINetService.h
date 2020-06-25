//
//  AINetService.h
//  SMG_NothingIsAll
//
//  Created by air on 2020/5/21.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------网络数据服务类--------------------
 *  1. 用于网络联想的快捷封装方法;
 *  2. 用于类比构建成果的取用封闭方法;
 */
@interface AINetService : NSObject

/**
 *  MARK:--------------------获取HAlg/GLAlg--------------------
 *  @desc 获取概念的内类比结果,比如概念的GLHN
 *  @param alg : 取alg的大小有无;
 *  @param vAT & vDS : 此内类比类型的微信息at&ds (GL时,为变大小稀疏码的at&ds) (HN时,为变有无的概念的at&ds);
 */
+(AIAlgNodeBase*) getInner1Alg:(AIAlgNodeBase*)alg vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type;

@end
