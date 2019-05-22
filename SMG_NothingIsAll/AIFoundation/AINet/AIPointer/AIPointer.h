//
//  AIPointer.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------"数据指针"--------------------
 *  1. 可以指向任何表的任一项;
 *  2. 指针的字段,是为指针的使用者而设的;例如A有B的指针,则需要B指针描述B的确切位置;
 */
@interface AIPointer : NSObject <NSCoding,NSCopying>

@property (assign, nonatomic) NSInteger pointerId;          //指针地址(Id)
@property (assign, nonatomic) BOOL isMem;                   //是否存内存网络(默认false);
@property (strong, nonatomic) NSMutableDictionary *params;  //用于分区(在二分查巨量队列,params越细分,越有利性能)
-(NSString*) filePath;                                      //文件路径(可以是key,或者path,或者sql表和行号等)
-(NSString*) identifier;    //一般由 "algsType" + "dataSource/Source" 组成;
-(id) paramForKey:(NSString*)key;

@end
