//
//  MapModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------规律(同时)--------------------
 */
@interface MapModel : NSObject
+(MapModel*) initWithAC:(Class)aClass aI:(NSInteger)aId bC:(Class)bClass bI:(NSInteger)bId;
@property (assign,nonatomic) Class aClass;
@property (assign, nonatomic) NSInteger aId;
@property (assign,nonatomic) Class bClass;
@property (assign, nonatomic) NSInteger bId;
@property (assign, nonatomic) NSInteger count;      //计数器

@end
