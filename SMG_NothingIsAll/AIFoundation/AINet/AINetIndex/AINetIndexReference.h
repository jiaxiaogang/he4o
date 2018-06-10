//
//  AINetIndexReference.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/4.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < 微信息引用_itemData区(第二序列) >
//MARK:===============================================================
@class AIKVPointer,AIPort;
@interface AINetIndexReference : NSObject


/**
 *  MARK:--------------------存入数据,由Index调用--------------------
 *  @param indexPointer 索引地址
 *  @param port         插入端口
 */
-(void) setReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue;

/**
 *  MARK:--------------------获取强度靠前的limit个地址--------------------
 *  @param indexPointer  索引地址
 *  @result Return NSArray(元素为AIPointer)
 */
-(NSArray*) getReference:(AIKVPointer*)indexPointer limit:(NSInteger)limit;


@end


//MARK:===============================================================
//MARK:                     < itemDataModel (一条数据) >
//MARK:===============================================================
@interface AINetIndexReferenceModel : NSObject <NSCoding>

@property (strong,nonatomic) NSMutableArray *ports;

@end
