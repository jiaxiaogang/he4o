//
//  AIKVPointer.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

@interface AIKVPointer : AIPointer


/**
 *  MARK:--------------------根文件夹--------------------
 */
@property (strong,nonatomic) NSString *folderName;


/**
 *  MARK:--------------------文件路径--------------------
 */
-(NSString*) filePath;


/**
 *  MARK:--------------------文件名--------------------
 */
-(NSString*) fileName;

@end
