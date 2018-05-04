//
//  AIKVPointer.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

@interface AIKVPointer : AIPointer


+(AIKVPointer*) newWithPointerId:(NSInteger)pointerId folderName:(NSString*)folderName algsType:(NSString*)algsType dataSource:(NSString*)dataSource;


-(NSString*) folderName;    //神经网络根目录 | 索引根目录
-(NSString*) algsType;      //算法类型_分区
-(NSString*) dataSource;    //数据源(AIData的来源:如inputModel中的某属性targetType等)
-(NSString*) filePath:(NSString*)customFolderName;  //取自定义folderName的filePath;

@end
