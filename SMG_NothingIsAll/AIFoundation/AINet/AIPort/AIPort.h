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
 *  用来替代AILine+AIStrong
 *  @desc:
 *      1. 每一个关联,有两个端口;
 *      2. 每一个端口,都有关联强度;
 *  @version
 *      2022.05.11: 新增targetHavMv标记 (参考26022-1);
 */
@class AIKVPointer,AIPortStrong;
@interface AIPort : NSObject <NSCoding>

@property (strong,nonatomic) AIKVPointer *target_p;   //指向目标的地址
@property (strong,nonatomic) AIPortStrong *strong;
@property (assign, nonatomic) BOOL targetHavMv;       //指向目标有mv指向;

/**
 *  MARK:--------------------指向节点的header--------------------
 *  1. 如algNode.absPorts时,就是抽象节点value_ps的md5值
 *  作用: 用来快速匹配port指向的节点的值:(如指向node.content_ps)
 *  替代方案: 也可以用value_ps的值序列来作有序,然后二分法匹配;
 */
@property (strong,nonatomic) NSString *header;

-(void) strongPlus;

@end


/**
 *  MARK:--------------------端口强度--------------------
 *  注:为简化设计;
 *  1. 由AINode.xxxPorts替代了AILineType
 *  2. 由AIPortStrong替代了AILineStrong
 *  3. 互相关联,不表示强度值一致,所以A与B关联,有可能A的强度为3,B却为100;
 */
@interface AIPortStrong : NSObject <NSCoding>


@property (assign,nonatomic) NSInteger value;

/**
 *  MARK:--------------------上次更新强度时间--------------------
 */
@property (assign, nonatomic) double updateTime;  //更新值时间(18.07.13目前未工作,随后补上)

//(警告!!!强度不能在strong内部自行改变,不然会影响到第二序列的工作,所以应由第二序列读取到内存时,统一调用处理;)
-(void) updateValue;//更新衰减值(1,时间衰减; 2,衰减曲线;)(目前先每天减1;)

@end

/**
 *  MARK:--------------------SP强度--------------------
 *  @version
 *      2021.12.25: 初版,用于Fo下记录某元素的SP强度值 (也可用于mv的SP强度值) (参考25031-5);
 */
@interface AISPStrong : NSObject <NSCoding,NSCopying>

@property (assign,nonatomic) CGFloat sStrong;
@property (assign,nonatomic) CGFloat pStrong;

@end

/**
 *  MARK:--------------------有效强度--------------------
 *  @version
 *      2022.05.22: 初版,用于Fo下记录解决方案的有效性 (参考26094);
 */
@interface AIEffectStrong : NSObject <NSCoding>

+(AIEffectStrong*) newWithSolutionFo:(AIKVPointer*)solutionFo;

@property (strong, nonatomic) AIKVPointer *solutionFo;  //解决方案
@property (assign,nonatomic) NSInteger hStrong; //有效
@property (assign,nonatomic) NSInteger nStrong; //无效

@end

//MARK:===============================================================
//MARK: < 内存记录sp防重(主要用于TOFoModel.outSPRecord和pFo.inSPRecord) >
//MARK:===============================================================
@interface SPMemRecord : NSObject

/**
 *  MARK:--------------------In/OutSP强度值反馈记录--------------------
 *  @说明 用于检查:避免重复&避免冲突 (仅放在内存中,不持久化,避免它重复计SP值,或者计了S又计P的冲突);
 */
@property (strong, nonatomic) NSMutableDictionary *spRecord;

/**
 *  MARK:--------------------防重检查和回滚--------------------
 *  @param spIndex type difStrong : 本次要执行更新sp的几个参数值;
 *  @param backBlock : 发现重复,调用回滚的block
 *  @param runBlock : 本次允许,调用执行的block
 */
-(void) update:(NSInteger)spIndex type:(AnalogyType)type difStrong:(NSInteger)difStrong backBlock:(void(^)(NSInteger mDifStrong,AnalogyType mType))backBlock runBlock:(void(^)())runBlock;

@end
