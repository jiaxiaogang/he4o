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
@property (strong,nonatomic) NSString *dataType;
@property (strong,nonatomic) NSString *dataSource;

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
+(AIPort*) newWithNode:(AINode*)node;


@end



/**
 *  MARK:--------------------端口强度--------------------
 *  注:为简化设计;
 *  1. 由AINode.xxxPorts替代了AILineType
 *  2. 由AIPortStrong替代了AILineStrong
 */
@interface AIPortStrong : NSObject <NSCoding>


//MARK:===============================================================
//MARK:                     < property >
//MARK:===============================================================
@property (assign,nonatomic) int value;
@property (assign, nonatomic) double updateTime;  //更新值时间


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) updateValue;//更新衰减值(1,时间衰减; 2,衰减曲线;)(目前先每天减1;)

@end
