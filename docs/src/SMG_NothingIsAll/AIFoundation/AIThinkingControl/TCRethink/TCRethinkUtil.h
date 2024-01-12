//
//  TCRethinkUtil.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/20.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCRethinkUtil : NSObject

+(void) spEff4Abs:(AIFoNodeBase*)curFo curFoIndex:(NSInteger)curFoIndex itemRunBlock:(void(^)(AIFoNodeBase *absFo,NSInteger absIndex))itemRunBlock;

@end
