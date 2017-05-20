//
//  MapStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------Map(映射表/规律,同时)--------------------
 */
@interface MapStore : NSObject


+(MapModel*) insertToDB_MapModel:(MapModel*)model;
+(MapModel*) searchSingle_MapModel:(Class)class withClassId:(NSInteger)classId;


@end
