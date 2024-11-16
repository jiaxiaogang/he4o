//
//  AITransferPort.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/16.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AITransferPort : NSObject <NSCoding>

+(AITransferPort*) newWithFScene:(AIKVPointer*)fScene fCanset:(AIKVPointer*)fCanset iScene:(AIKVPointer*)iScene iCansetContent_ps:(NSArray*)iCansetContent_ps;

//@desc1 因为迁移port是挂在scene下的,所以此处需要把两个canset都存下来;
//@desc2 scene原本是只需要存targetScene的,但为了方便用,现在先两个scene全写上,随后优化时,再去掉当前scene,即不必要的一个;

@property (strong, nonatomic) NSArray *iCansetContent_ps; //在虚迁移时,iCanset还没生成,此时只能以content_ps来表示;
@property (strong, nonatomic) AIKVPointer *iScene;
@property (strong, nonatomic) AIKVPointer *fCanset;
@property (strong, nonatomic) AIKVPointer *fScene;

@end
