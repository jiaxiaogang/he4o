//
//  RTQueueModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/2/12.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTQueueModel : NSObject

+(RTQueueModel*) newWithName:(NSString*)name arg0:(id)arg0 arg1:(id)arg1 arg2:(id)arg2;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) id arg0;
@property (strong, nonatomic) id arg1;
@property (strong, nonatomic) id arg2;

@end
