//
//  MapModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/12/26.
//  Copyright © 2023 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------存几个值的模型 (总比用数组方便)--------------------
 */
@interface MapModel : NSObject

+(MapModel*) newWithV1:(id)v1 v2:(id)v2;

@property (strong, nonatomic) id v1;
@property (strong, nonatomic) id v2;

@end
