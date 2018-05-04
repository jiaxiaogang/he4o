//
//  AIPort.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------网络端口类--------------------
 */
@class AIKVPointer,AIPortStrong,AINode;
@interface AIPort : NSObject <NSCoding>


//MARK:===============================================================
//MARK:                     < property >
//MARK:===============================================================
@property (strong,nonatomic) AIKVPointer *pointer;
@property (strong,nonatomic) AIPortStrong *strong;

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
+(AIPort*) newWithNode:(AINode*)node;
-(NSComparisonResult) compare:(AIPort*)port;

@end



/**
 *  MARK:--------------------端口强度--------------------
 *  注:为简化设计;
 *  1. 由AINode.xxxPorts替代了AILineType
 *  2. 由AIPortStrong替代了AILineStrong
 */
@interface AIPortStrong : NSObject <NSCoding>


@property (assign,nonatomic) int value;
@property (assign, nonatomic) double updateTime;  //更新值时间


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

//(警告!!!强度不能在strong内部自行改变,不然会影响到第二序列的工作,所以应由第二序列读取到内存时,统一调用处理;)
-(void) updateValue;//更新衰减值(1,时间衰减; 2,衰减曲线;)(目前先每天减1;)


-(NSComparisonResult) compare:(AIPortStrong*)strong;


@end
