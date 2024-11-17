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
//@desc3 其实现在的TransferPort存的是似层和抽象层的迁移关联,只是当下用的是I和F来命名的,其中I表示似层,F表示抽象层(抽象层有类比来的交层,也有时序识别后的似层);

@property (strong, nonatomic) NSArray *iCansetContent_ps; //在虚迁移时,iCanset还没生成,此时只能以content_ps来表示;
@property (strong, nonatomic) AIKVPointer *iScene;
@property (strong, nonatomic) AIKVPointer *fCanset;
@property (strong, nonatomic) AIKVPointer *fScene;

@end
