//
//  MKStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MKStore.h"
#import "TMCache.h"
#import "SMGHeader.h"

@interface MKStore ()

@property (strong,nonatomic) NSMutableArray *words;//分词数组

@end

@implementation MKStore




/**
 *  MARK:--------------------分词--------------------
 */
-(NSArray *)words{
    if (_words == nil) {
        _words = [[NSMutableArray alloc] initWithArray:[[TMCache sharedCache] objectForKey:@"MKStore_Words_Key"]];
    }
    return _words;
}

-(BOOL) containerWord:(NSString*)word{
    return [self.words containsObject:STRTOOK(word)];
}

-(void) addWord:(NSString*)word{
    [self.words addObject:STRTOOK(word)];
    [[TMCache sharedCache] setObject:self.words forKey:@"MKStore_Words_Key"];
}

@end
