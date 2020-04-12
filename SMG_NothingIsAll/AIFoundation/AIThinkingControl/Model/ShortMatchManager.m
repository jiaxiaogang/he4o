//
//  ShortMatchManager.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/12.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "ShortMatchManager.h"

@interface ShortMatchManager ()

@property (strong, nonatomic) NSMutableArray *models;

@end

@implementation ShortMatchManager

-(NSMutableArray*)models{
    if (_models == nil) _models = [[NSMutableArray alloc] init];
    return _models;
}
-(void) add:(AIShortMatchModel*)model{
    if (model)
        [self.models addObject:model];
    if (self.models.count > 4)
        self.models = [[NSMutableArray alloc] initWithArray:ARR_SUB(self.models, self.models.count - 4, 4)];
}

@end
