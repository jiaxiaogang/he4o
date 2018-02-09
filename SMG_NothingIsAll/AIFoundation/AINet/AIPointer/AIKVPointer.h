//
//  AIKVPointer.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

@interface AIKVPointer : AIPointer


+(AIKVPointer*) newWithPointerId:(NSInteger)pointerId folderName:(NSString*)folderName dataType:(NSString*)dataType dataSource:(NSString*)dataSource;


/**
 *  MARK:--------------------根文件夹--------------------
 */
@property (strong,nonatomic) NSString *folderName;
@property (strong,nonatomic) NSString *dataType;    //数据类型(AIData的Type:如AIIntModel,AIIndentifier等)
@property (strong,nonatomic) NSString *dataSource;  //数据源(AIData的来源:如inputModel中的某属性targetType等)


/**
 *  MARK:--------------------文件路径--------------------
 */
-(NSString*) filePath;

@end
