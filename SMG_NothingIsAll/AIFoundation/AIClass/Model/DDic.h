//
//  DDic.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/5/10.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------嵌套字典--------------------
 */
@interface DDic : NSObject

@property (strong, nonatomic) NSMutableDictionary *v1;

-(id) objectForKey1:(id)k1 k2:(id)k2;

-(void) setObject:(id)v2 forKey1:(id)k1 k2:(id)k2;

@end
