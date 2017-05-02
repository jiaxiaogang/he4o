//
//  DoStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoStore : NSObject

/**
 *  MARK:--------------------getObj--------------------
 */
//精确匹配某词
-(NSDictionary*) getSingleItemWithItemName:(NSString*)itemName;
//获取where的最近一条;(精确匹配)
-(NSDictionary*) getSingleItemWithWhere:(NSDictionary*)whereDic;
//获取where的所有条
-(NSMutableArray*) getItemArrWithWhere:(NSDictionary*)where;

/**
 *  MARK:--------------------addItem--------------------
 */
-(NSDictionary*) addItem:(NSString*)itemName;
-(NSMutableArray*) addItemNameArr:(NSArray*)itemNameArr;

@end
