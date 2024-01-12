//
//  RTQueueModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/2/12.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTQueueModel : NSObject

+(RTQueueModel*) newWithName:(NSString*)name arg0:(id)arg0;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) id arg0;

@end
