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
-(BOOL) containerWord:(NSString*)word{
    return [self.text getSingleWordWithText:STRTOOK(word)];
}

-(void) addWord:(NSString*)word{
    [self.text addWord:[NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(word),@"word", nil]];
}

@end
