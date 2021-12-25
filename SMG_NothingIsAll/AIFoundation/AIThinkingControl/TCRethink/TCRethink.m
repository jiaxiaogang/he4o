//
//  TCRethink.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/25.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCRethink.h"

@implementation TCRethink

//理性IRT反省;
+(void) reasonInRethink:(AIMatchFoModel*)model type:(AnalogyType)type{
    [model.matchFo updateSPStrong:model.cutIndex2 + 1 type:type];
}

+(void) perceptInRethink:(AIMatchFoModel*)model type:(AnalogyType)type{
    [model.matchFo updateSPStrong:-1 type:type];
}

+(void) reasonOutRethink:(AIMatchFoModel*)model type:(AnalogyType)type{
    
}

+(void) perceptOutRethink:(AIMatchFoModel*)model type:(AnalogyType)type{
    
}

@end
