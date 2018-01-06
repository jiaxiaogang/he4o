//
//  SMGRange.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMGRange : NSObject<NSCoding>


+(SMGRange*) rangeWithLocation:(NSInteger)location length:(NSInteger)length;
@property (assign, nonatomic) NSInteger location;
@property (assign, nonatomic) NSInteger length;


@end
