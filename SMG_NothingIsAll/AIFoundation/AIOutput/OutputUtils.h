//
//  OutputUtils.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/20.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutputUtils : NSObject

/**
 *  MARK:--------------------转换数据类型为"输出算法标识"--------------------
 *  注:目前仅支持一一对应,随后支持多个后,return改为Array;
 *  注:所有output类型都应由先天反射转后天主动,所以此处写死的方法不应存在;
 *  解: 应该以后天学习映射关系到网络的方式,来解决这个问题;TODO
 */
+(NSString*) convertOutType2dataSource:(NSString*)dataType;


@end
