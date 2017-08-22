//
//  AIObject.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"
#import "SMGUtils.h"

@interface AIObject ()

@property (strong,nonatomic) NSMutableArray *linePointers;

@end

@implementation AIObject

/**
 *  MARK:--------------------Store--------------------
 */
+(void)initialize{
    //[self removePropertyWithColumnName:@"pointer"];
}

+(BOOL) isContainParent{
    return true;
}

/**
 *  MARK:--------------------method--------------------
 */
+(id) newWithContent:(id)content{
    return [[AIObject alloc] init];
}

-(AIPointer*) pointer{
    if (_pointer == nil) {
        _pointer = [[AIPointer alloc] init];//initWithClass:withId方法里写了去重;所以它方法有冗余,以后有时间改掉;
    }
    _pointer.pClass = NSStringFromClass(self.class);
    _pointer.pId = self.rowid;//初次存入self时,pointer.Pid==0;所以这里重新赋值;保证每次读取pointer地址都是正确的;
    return _pointer;
}

-(NSMutableArray *)linePointers{
    if (_linePointers == nil) {
        _linePointers = [[NSMutableArray alloc] init];
    }
    return _linePointers;
}

-(BOOL) isEqual:(id)obj{
    if (obj && [obj isKindOfClass:[AIObject class]]) {
        return [self.pointer isEqual:((AIObject*)obj).pointer];//对比指针地址
    }
    return false;
}

-(void) print{
    //1,data
    NSMutableString *mStr = [self getAllPropertysString];
    NSMutableString *logStr = [[NSMutableString alloc] init];
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[mStr componentsSeparatedByString:@"\n"]];
    NSInteger maxLength = 0;
    for (NSString *line in lines)
        maxLength = MAX(maxLength, line.length);
    
    //2,top_______
    [logStr appendString:@"\n"];
    for (NSInteger i = 0; i < maxLength; i++) {
        [logStr appendString:@"_"];
    }
    [logStr appendString:@"_\n"];
    
    //3,content    |
    for (NSString *line in lines) {
        [logStr appendString:line];
        for (NSInteger i = line.length; i < maxLength; i++) {
            [logStr appendString:@" "];
        }
        [logStr appendString:@"|\n"];
    }
    
    //4,bottom_____
    for (NSInteger i = 0; i < maxLength; i++) {
        [logStr appendString:@"_"];
    }
    [logStr appendString:@"|\n\n\n"];
    
    //5,print
    NSLog(@"%@",logStr);
}

/**
 *  MARK:--------------------插网线--------------------
 *  每次产生神经网络的时候,要把网线插在网口上;
 */
-(void) connectLine:(AILine*)line{
    [self connectLine:line save:false];
}

-(void) connectLine:(AILine*)line save:(BOOL)save{
    if (LINEISOK(line) && POINTERISOK(line.pointer) && ![self containsLine:line]) {
        [self.linePointers addObject:line.pointer];
        if (save)
            [SMGUtils store_Insert:self awareness:false];
    }
}

/**
 *  MARK:--------------------判断是否插了某网线--------------------
 */
-(BOOL) containsLine:(AILine*)line{
    if (LINEISOK(line)) {
        for (AIPointer *pointer in self.linePointers) {
            if (POINTERISOK(pointer)) {
                if ([pointer isEqual:line.pointer]) {
                    return true;
                }
            }
        }
    }
    return false;
}

@end


/**
 *  MARK:--------------------本地存储--------------------
 */
@implementation AIObject (Store)

+ (id) ai_searchSingleWithRowId:(NSInteger)rowid {
    return [self.class searchSingleWithWhere:[DBUtils sqlWhere_RowId:rowid] orderBy:nil];
}

+ (void) ai_insertToDB:(id)obj{
    [self.class insertToDB:obj];
}

+ (BOOL) ai_updateToDB:(NSObject *)model where:(id)where {
    return [self.class updateToDB:model where:where];
}

@end
