//
//  AITransferPort.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/16.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AITransferPort : NSObject <NSCoding>

+(AITransferPort*) newWithFScene:(AIKVPointer*)fScene fCanset:(AIFoNodeBase*)fCanset iScene:(AIKVPointer*)iScene iCansetContent_ps:(NSArray*)iCansetContent_ps;

//@desc1 因为迁移port是挂在scene下的,所以此处需要把两个canset都存下来;
//@desc2 scene原本是只需要存targetScene的,但为了方便用,现在先两个scene全写上,随后优化时,再去掉当前scene,即不必要的一个;
//@desc3 其实现在的TransferPort存的是似层和抽象层的迁移关联,只是当下用的是I和F来命名的,其中I表示似层,F表示抽象层(抽象层有类比来的交层,也有时序识别后的似层);

/**
 *  MARK:--------------------iCanset--------------------
 *  @version
 *      2024.11.xx: 在虚迁移时,iCanset还没生成,此时只能以content_ps来表示;
 *      2024.11.29: 这里不需要存全部的content_ps,因为只需要判断指向,改为存content_ps的md5值即可,这样改:即省空间,判断匹配时性能还更好;
 */
@property (strong, nonatomic) NSString *iCansetHeader;
@property (strong, nonatomic) AIKVPointer *iScene;

/**
 *  MARK:--------------------fCansetHeader--------------------
 *  @version
 *      2024.11.xx: 存fCanset;
 *      2024.11.30: 父非子时,需要根据fCanset的key,取fScene下的itemOutSPDic,这里存上header,避免取fCansetNode性能差;
 *  @todo
 *      2024.11.30: 其实fCanset应该可以去掉了,它用来防重,或复用取itemOutSPDic,都可以直接用md5Header来实现,先不删,随后再删吧,一年后它还是没用,再删;
 */
@property (strong, nonatomic) AIKVPointer *fCanset;
@property (strong, nonatomic) NSString *fCansetHeader;
@property (strong, nonatomic) AIKVPointer *fScene;

@end
