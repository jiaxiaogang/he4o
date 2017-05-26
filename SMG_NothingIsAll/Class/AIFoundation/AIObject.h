//
//  AIObject.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIObject : NSObject

+(id) initWithContent:(id)content;
@property (strong,nonatomic) AIPointer *pointer; //数据指针
-(void) print;

@end



/**
 *  MARK:--------------------本地存储--------------------
 */
@interface AIObject (Store)

+ (id) ai_searchSingleWithRowId:(NSInteger)rowid;
+ (void) ai_insertToDB:(id)obj;
+ (BOOL) ai_updateToDB:(NSObject *)model where:(id)where;

@end
