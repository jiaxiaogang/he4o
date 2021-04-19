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
 *  MARK:--------------------联想HNGL经验--------------------
 *  @desc 获取概念的内类比结果,比如概念的GLHN
 *  @param maskFo
 *              1. GL时,传入瞬时中匹配MC的matchAlg,所在的protoFo (即: 符合现实世界的当前场景)->向抽象取嵌套;
 *              2. HN时,传入决策短时记忆中的alg.baseFo (即: 当前解决方案中,每次得到的坚果,是哪来的)->向具象取嵌套;
 *  @param vAT & vDS : 此内类比类型的微信息at&ds (GL时,为变大小稀疏码的at&ds) (HN时,为变有无的概念的at&ds);
 */
+(AIKVPointer*) testGL:(AIShortMatchModel*)inModel vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type except_ps:(NSArray*)except_ps;
+(AIKVPointer*) getInnerV3_GL:(AIFoNodeBase*)maskFo vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type except_ps:(NSArray*)except_ps;
+(AIKVPointer*) getInnerV3_HN:(AIAlgNodeBase*)maskAlg vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type except_ps:(NSArray*)except_ps;

/**
 *  MARK:--------------------从Alg中获取指定标识稀疏码的值--------------------
 */
+(double) getValueDataFromAlg:(AIKVPointer*)alg_p valueIdentifier:(NSString*)valueIdentifier;

/**
 *  MARK:--------------------获取glConAlg_ps--------------------
 *  @desc 联想路径说明: (glConAlg_ps = glValue.refPorts->glAlg.conPorts->glConAlgs);
 */
+(NSArray*) getHNGLConAlg_ps:(AnalogyType)type vAT:(NSString*)vAT vDS:(NSString*)vDS;

@end
