//
//  Store.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemStore.h"
#import "MKStore.h"

@class LanguageStoreModel;
@interface Store : NSObject


-(id) init;



/**
 *  MARK:--------------------记忆存储--------------------
 */
@property (strong,nonatomic) MemStore *memStore;



/**
 *  MARK:--------------------知识图谱--------------------
 */
@property (strong,nonatomic) MKStore *mkStore;



/**
 *  MARK:--------------------搜索关于文字的记忆--------------------
 *  searchMemStoreWithLanguageText:搜索匹配的记忆
 *  searchMemStoreContainerText:搜索相关的记忆
 */
-(LanguageStoreModel*) searchMemStoreWithLanguageText:(NSString*)text;
-(NSArray*) searchMemStoreContainerText:(NSString*)text;






@end
