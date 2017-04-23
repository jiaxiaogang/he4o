//
//  ObjStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjStore : NSObject

/**
 *  MARK:--------------------getObj--------------------
 */
//精确匹配某词
-(NSDictionary*) getSingleItemWithItemName:(NSString*)itemName;
//获取where的最近一条;(精确匹配)
-(NSDictionary*) getSingleItemWithWhere:(NSDictionary*)whereDic;


/**
 *  MARK:--------------------addItem--------------------
 */
-(NSDictionary*) addItem:(NSString*)itemName;
-(NSMutableArray*) addItemNameArr:(NSArray*)itemNameArr;


@end
