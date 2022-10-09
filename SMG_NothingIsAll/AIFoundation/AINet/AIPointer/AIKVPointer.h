//
//  AIKVPointer.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

/**
 *  MARK:--------------------KV指针--------------------
 *  1. TODO: 将isOut去除,以大小脑网络区分微信息是否输出; (以广播标识符来标识canOut);
 *  2. isMemNet : 是否存到内存网络 (默认false,存硬盘)
 *  @version
 *      2021.09.17: 集成type (参考24018-线索2);
 */
@interface AIKVPointer : AIPointer

+(AIKVPointer*) newWithPointerId:(NSInteger)pointerId folderName:(NSString*)folderName algsType:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut type:(AnalogyType)type;

//MARK:===============================================================
//MARK:                     < 单属性取值 >
//MARK:===============================================================
-(NSString*) folderName;    //神经网络根目录 | 索引根目录
-(NSString*) algsType;      //算法类型_分区
-(NSString*) dataSource;    //数据源(AIData的来源:如inputModel中的某属性targetType等)
-(BOOL) isOut;              //是否outPointer(默认false);
-(NSString*) typeStr;       //节点类型
-(AnalogyType) type;        //节点类型
-(NSString*) filePath:(NSString*)customFolderName;  //取自定义folderName的filePath;

@end
