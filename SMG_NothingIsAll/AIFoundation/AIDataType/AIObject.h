//
//  AIObject.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AILine,AIPointer;
@interface AIObject : NSObject<NSCoding>


+(id) newWithContent:(id)content;
@property (strong,nonatomic) AIPointer *pointer; //数据指针(自身指针地址)


/**
 *  MARK:--------------------print--------------------
 */
-(void) print;


/**
 *  MARK:--------------------插网线--------------------
 *  每次产生神经网络的时候,要把网线插在网口上;
 */
-(void) connectLine:(AILine*)line;
-(void) connectLine:(AILine*)line save:(BOOL)save;


/**
 *  MARK:--------------------判断是否有效指针--------------------
 */
-(BOOL) pointerValid;


@end



/**
 *  MARK:--------------------本地存储--------------------
 */
@interface AIObject (Store)

+ (id) ai_searchSingleWithRowId:(NSInteger)rowid;
+ (void) ai_insertToDB:(id)obj;
+ (BOOL) ai_updateToDB:(NSObject *)model where:(id)where;

@end



//-(id) alloc_DB;
