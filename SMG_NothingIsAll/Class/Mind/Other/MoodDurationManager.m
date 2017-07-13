//
//  MoodDurationManager.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/11.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MoodDurationManager.h"

@interface MoodDurationManager ()

@property (strong,nonatomic) Mood *mood;
@property (strong,nonatomic) NSMutableArray *models;

@end

@implementation MoodDurationManager

+ (MoodDurationManager *)sharedInstance
{
    static MoodDurationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MoodDurationManager alloc] init];
    });
    return manager;
}

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.models = [[NSMutableArray alloc] init];
}

-(void) checkAddMood:(Mood*)mood rateBlock:(void(^)(Mood *mood))rateBlock{
    if (mood) {
        MoodDurationManagerModel *model = [[MoodDurationManagerModel alloc] init];
        model.rateBlock = rateBlock;
        model.mood = mood;
        [self.models addObject:model];
        [self run:model];
    }
}

-(void) checkRemoveMood:(Mood*)mood {
    for (NSInteger i = 0 , max = self.models.count; i < max; i++) {
        if ([self.models[i] isEqual:mood]) {
            [self.models removeObjectAtIndex:i];
            i--;
            max--;
        }
    }
}

-(void) run:(MoodDurationManagerModel*)model{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (model && [self.models containsObject:model]) {
            if (model.mood.type == MoodType_Irritably2Calm) {//急躁恢复平静
                if (model.mood.value < 0) {
                    model.mood.value++;
                    if (model.rateBlock) model.rateBlock(model.mood);
                    [self run:model];
                }
            }
        }
    });
}

@end



@interface MoodDurationManagerModel ()
@end

@implementation MoodDurationManagerModel
@end
