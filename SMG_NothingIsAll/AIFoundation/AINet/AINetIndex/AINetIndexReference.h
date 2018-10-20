//
//  AINetIndexReference.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/4.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < 微信息引用_itemData区(第二序列) >
//MARK:===============================================================
@class AIKVPointer,AIPort;
@interface AINetIndexReference : NSObject


/**
 *  MARK:--------------------给target_p建引用序列索引--------------------
 *  @param target_p     :   引用信息的节点地址 (引用者地址(如:xxNode.pointer))
 *  @param index_p      :   被引用的信息地址 (value地址)
 *
 *  注:
 *  1. 分别排了FILENAME_Reference_ByPointer和FILENAME_Reference_ByPort两个序列;
 *  2. 一个按强度排序,一个按指针排序;
 *  3. 目前不需要依output来联想到网络中;helix的整个思维控制器,都依据kv_p来思考,所以此处,无需将后天节点地址传过来;
 *  4. 目前未对小脑做详细设计,没有固化动作的功能,所以此处的引用强度,也仅作为记录,后续可以先以此强度对评分产生影响,再做其它;详参v2计划;
 *  5. 目前此处可作为记录输出,并且作为canOut的依据;
 *  注2:
 *  1. outNode或absOutNode作为target_p时(目前其实就是outputIndex_p);
 */
-(void) setReference:(AIKVPointer*)index_p target_p:(AIKVPointer*)target_p difStrong:(int)difStrong;


/**
 *  MARK:--------------------获取value被引用的node地址;--------------------
 *  @param indexPointer : value_p地址
 *  @param limit : 最多结果个数
 *  @result Return NSArray(元素为AIPort)
 *
 *  @desc : 1.当indexPointer为absValue时,则只有absNode和frontNode会被搜索到;
 *  @desc : 2.当indexPointer为普通value时,则有可能搜索到除absNode之外的所有其它node(如:frontNode或mvNode等)
 */
-(NSArray*) getReference:(AIKVPointer*)indexPointer limit:(NSInteger)limit;


/**
 *  MARK:--------------------获取value被引用的absNode地址;--------------------
 *  @param absValue_p : value_p地址
 *  @param limit : 最多结果个数
 *  @result Return NSArray(元素为AIPort)
 *  @desc : 1.当indexPointer为absValue时,则只有absNode会被搜索到;
 */
-(NSArray*) getReference_JustAbsResult:(AIKVPointer*)absValue_p limit:(NSInteger)limit;


@end
