//
//  StoreHeader.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Store.h"

//Mem
#import "MemStore.h"

//Logic
#import "LogicStore.h"


//MK
#import "MKStore.h"
#import "TextStore.h"
#import "TextStoreUtils.h"
#import "ObjStore.h"
#import "DoStore.h"
#import "TMCache.h"
#import "SMGHeader.h"



/**
 *  MARK:--------------------PropertyKey--------------------
 */
#define AddPKey(a) ([[TMCache sharedCache] setObject:STRTOOK(a) forKey:STRFORMAT(@"PropertyKey_ExtensionKey_%@",a)])
#define GetPKey(a, ...) [NSString stringWithFormat:a, ##__VA_ARGS__]
