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
 *  MARK:--------------------从Alg中获取指定标识稀疏码的值--------------------
 */
+(double) getValueDataFromAlg:(AIKVPointer*)alg_p valueIdentifier:(NSString*)valueIdentifier;
+(double) getValueDataFromFo:(AIKVPointer*)fo_p valueIdentifier:(NSString*)valueIdentifier;
+(AIKVPointer*) getValuePFromFo:(AIKVPointer*)fo_p valueIdentifier:(NSString*)valueIdentifier;

/**
 *  MARK:--------------------获取glConAlg_ps--------------------
 */
//+(NSArray*) getHNGLConAlg_ps:(AnalogyType)type vAT:(NSString*)vAT vDS:(NSString*)vDS;

@end
