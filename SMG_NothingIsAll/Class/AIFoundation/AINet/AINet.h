//
//  AINet.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIModel,AINetModel;
@interface AINet : NSObject

+(AINet*) sharedInstance;

//MARK:===============================================================
//MARK:                     < insert >
//MARK:===============================================================
-(void) insertProperty:(id)data rootPointer:(AIPointer*)rootPointer;
-(void) insertModel:(AIModel*)model;


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNetModel:(AINetModel*)model;


//MARK:===============================================================
//MARK:                     < search >
//MARK:===============================================================
-(AINetModel*) searchWithModel:(id)model;

@end
