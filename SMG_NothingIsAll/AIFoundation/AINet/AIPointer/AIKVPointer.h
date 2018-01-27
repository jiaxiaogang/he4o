//
//  AIKVPointer.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

@interface AIKVPointer : AIPointer


+(AIKVPointer*) newWithPointerId:(NSInteger)pointerId folderName:(NSString*)folderName;


/**
 *  MARK:--------------------根文件夹--------------------
 */
@property (strong,nonatomic) NSString *folderName;


/**
 *  MARK:--------------------文件路径--------------------
 */
-(NSString*) filePath;

@end
