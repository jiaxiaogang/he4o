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

@property (strong,nonatomic) AIKVPointer *pointer;
@property (strong,nonatomic) AIPortStrong *strong;

+(AIPort*) newWithNode:(AINode*)node;
-(NSComparisonResult) compare:(AIPort*)port;//类比port:1级强度,2级pointerId;
-(void) strongPlus;

@end



///**
// *  MARK:--------------------抽象端口--------------------
// */
//@interface AIAbsPort : AIPort <NSCoding>
//
//@property (strong, nonatomic) NSMutableArray *refs_p;//抽象端口(知道自身中哪些微信息被抽象了)
//
//@end



/**
 *  MARK:--------------------端口强度--------------------
 *  注:为简化设计;
 *  1. 由AINode.xxxPorts替代了AILineType
 *  2. 由AIPortStrong替代了AILineStrong
 */
@interface AIPortStrong : NSObject <NSCoding>


@property (assign,nonatomic) int value;
@property (assign, nonatomic) double updateTime;  //更新值时间

//(警告!!!强度不能在strong内部自行改变,不然会影响到第二序列的工作,所以应由第二序列读取到内存时,统一调用处理;)
-(void) updateValue;//更新衰减值(1,时间衰减; 2,衰减曲线;)(目前先每天减1;)
-(NSComparisonResult) compare:(AIPortStrong*)strong;

@end
