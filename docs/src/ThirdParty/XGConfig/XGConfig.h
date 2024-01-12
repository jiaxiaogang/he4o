//
//  XGConfig.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/8/25.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define xgConfigPath @"xgConfig"
#define xgConfigFile @"config.txt"
#define xgConfigKeyZiWuMode @"植物模式"
#define xgConfigKeyTest @"还牛逼不?"
#define xgConfigKeyPauseRLT @"暂停强化训练"

@interface XGConfig : NSObject

+(XGConfig*) instance;

/**
 *  MARK:--------------------初始配置--------------------
 */
-(void) initConfig;

/**
 *  MARK:--------------------响应配置变化到系统--------------------
 */
-(void) responseXGConfig2HE;

//读写配置
-(id) valueForKey:(NSString*)key reloadIden:(NSString*)reloadIden;
-(void) setValue:(id)value forKey:(NSString*)key;

@end
