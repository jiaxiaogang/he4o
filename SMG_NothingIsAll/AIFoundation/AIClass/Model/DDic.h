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

@property (strong, nonatomic) NSMutableDictionary *data;

-(id) objectForKey:(id)key;
-(id) objectV2ForKey1:(id)k1 k2:(id)k2;
-(id) objectV3ForKey1:(id)k1 k2:(id)k2 k3:(id)k3;
-(void) setObject:(id)value forKey:(id)key;
-(void) setObjectV2:(id)v2 k1:(id)k1 k2:(id)k2;
-(void) setObjectV3:(id)v3 k1:(id)k1 k2:(id)k2 k3:(id)k3;

@end
