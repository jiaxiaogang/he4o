//
//  AINetData.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/3.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < itemData区(第二序列) >
//MARK:===============================================================
@class AIPointer,AINetDataModel;
@interface AINetData : NSObject


/**
 *  MARK:--------------------存入数据,由Index调用--------------------
 */
-(void) setObject:(NSNumber*)value algsType:(NSString*)algsType dataSource:(NSString*)dataSource;
-(NSNumber*) valueForPointerId:(NSInteger)pointerId algsType:(NSString*)algsType dataSource:(NSString*)dataSource;

/**
 *  MARK:--------------------更新强度,由net构建时调用--------------------
 */
-(void) updateObject:(AIPointer*)pointer;

@end


//MARK:===============================================================
//MARK:                     < itemDataModel (一条数据) >
//MARK:===============================================================
@interface AINetDataModel : NSObject <NSCoding>

@property (strong, nonatomic) NSNumber *value;
@property (strong,nonatomic) NSMutableArray *ports;

@end
