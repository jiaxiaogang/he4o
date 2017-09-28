//
//  AIKVPointer.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIKVPointer.h"

@implementation AIKVPointer


-(NSString*) filePath{
    NSString *pIdStr = STRFORMAT(@"%ld",self.pointerId);
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableString *fileRootPath = [[NSMutableString alloc] initWithFormat:@"%@/KVPath",cachePath];
    for (NSInteger j = 0; j < pIdStr.length - 1; j++) {
        [fileRootPath appendFormat:@"/%@",[pIdStr substringWithRange:NSMakeRange(j, 1)]];
    }
    return fileRootPath;
}

-(NSString*) fileName{
    NSString *pIdStr = STRFORMAT(@"%ld",self.pointerId);
    return [pIdStr substringFromIndex:pIdStr.length - 1];
}


@end
