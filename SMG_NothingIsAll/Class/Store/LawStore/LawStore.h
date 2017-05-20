//
//  LawStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------Map(映射表/规律,同时)--------------------
 */
@interface LawStore : NSObject


+(LawModel*) insertToDB_LawModel:(LawModel*)model;
+(LawModel*) searchSingle_LawModel:(Class)class withClassId:(NSInteger)classId;
+(LawModel*) searchSingle_LawModel:(Class)class withClassId:(NSInteger)classId otherClass:(Class)otherClass;
+(NSInteger) searchSingle_OtherIdWithClass:(Class)class withClassId:(NSInteger)classId otherClass:(Class)otherClass;
+(LawModel*) searchSingle_LawModel:(NSDictionary*)where;

@end
