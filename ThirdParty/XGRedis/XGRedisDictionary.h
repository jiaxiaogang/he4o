//
//  XGRedisDictionary.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------有序字典--------------------
 *  以key和value两个分别的数组,同步操作;
 *  自定义字典的原因:可以直接根据index下标操作,而不必一一对比key
 */
@interface XGRedisDictionary : NSObject

-(NSArray*) allKeys;//copy keys;
-(NSInteger) count;
-(BOOL) removeObjectAtIndex:(NSInteger)index;
-(BOOL) addObject:(NSObject*)obj forKey:(NSString*)key;
-(BOOL) insertObject:(NSObject*)obj key:(NSString*)key atIndex:(NSInteger)index;
-(NSString*) keyForIndex:(NSInteger)index;
-(NSObject*) valueForIndex:(NSInteger)index;

@end


//MARK:===============================================================
//MARK:                     < 回收模型 >
//MARK:===============================================================
@interface XGRedisGCMark : NSObject

@property (assign, nonatomic) long long time;  //销毁时间
@property (strong, nonatomic) NSString *key;//销毁的key

@end
