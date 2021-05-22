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
 */
@interface AIKVPointer : AIPointer

+(AIKVPointer*) newWithPointerId:(NSInteger)pointerId folderName:(NSString*)folderName algsType:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut isMem:(BOOL)isMem;

/**
 *  MARK:--------------------嵌套的baseFoId--------------------
 *  @callers
 *      1. 目前仅用于SP构建时,用来标记当前SP作用于哪个场景下的;
 *  @version
 *      2021.05.22: v1将spBaseId记录到字典中,以对不同场景下的SP经验进行区分 (参考2307b-方案2);
 *  @desc 目前用于sp嵌套的baseFoId,随后可支持:
 *      1. 扩展至hngl&dsPorts等嵌套使用 (目前hnglsp全是使用absPorts来实现的,而dsPorts由fo下独立属性来实现的);
 *      2. 支持路径baseFoIds,如baseGL.baseFo场景 (目前仅支持单条baseFoId);
 *      3. 定义subFoNode子类,专门做嵌套fo的节点 (目前未定义此子类);
 *      4. 定义subIds,与baseId做配合使用 (目前这个由absPorts.sp来表示);
 */
@property (assign, nonatomic) NSInteger baseFoId;

-(NSString*) folderName;    //神经网络根目录 | 索引根目录
-(NSString*) algsType;      //算法类型_分区
-(NSString*) dataSource;    //数据源(AIData的来源:如inputModel中的某属性targetType等)
-(BOOL) isOut;              //是否outPointer(默认false);
-(NSString*) filePath:(NSString*)customFolderName;  //取自定义folderName的filePath;

@end
