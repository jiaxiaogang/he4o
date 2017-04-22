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
#import "TextHeader.h"

@interface MKStore ()

@property (strong,nonatomic) Text *text;

@end

@implementation MKStore




/**
 *  MARK:--------------------Text--------------------
 *  调用转到Text;
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
