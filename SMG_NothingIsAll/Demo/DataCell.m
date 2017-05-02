//
//  DataCell.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/28.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "DataCell.h"
#import "StoreHeader.h"

@interface DataCell ()

@property (weak, nonatomic) IBOutlet UILabel *dataLab;
@property (strong,nonatomic) NSDictionary *dic;
@property (assign, nonatomic) StoreType storeType;

@end

@implementation DataCell


+ (NSString*)reuseIdentifier{
    return @"DataCell";
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

-(void) initView{
    
}


-(void) setData:(NSDictionary*)dic withStoreType:(StoreType)storeType{
    self.dic = dic;
    self.storeType = storeType;
    [self refreshDisplay];
}

-(void) refreshDisplay{
    if (self.dic) {
        if (self.storeType == StoreType_Mem) {
            NSArray *doArr = [self.dic objectForKey:@"do"];
            NSArray *objArr = [self.dic objectForKey:@"obj"];
            NSString *text = [self.dic objectForKey:@"text"];
            
            NSMutableString *mStr = [[NSMutableString alloc] init];
            //Text
            [mStr appendString:@"记忆:"];
            if (STRISOK(text)) {
                [mStr appendString:text];
            }
            [mStr appendString:@"\n"];
            
            //Obj
            if (ARRISOK(objArr)) {
                [mStr appendString:@"实物:"];
                for (NSString *itemId in objArr) {
                    NSString *itemName = [self getObjName:itemId];
                    if (STRISOK(itemName)) {
                        [mStr appendString:itemName];
                        [mStr appendString:@" "];
                    }
                    [mStr appendString:@"\n"];
                }
            }
            
            //Do
            if (ARRISOK(doArr)) {
                [mStr appendString:@"行为:"];
                for (NSString *itemId in doArr) {
                    NSString *itemName = [self getDoName:itemId];
                    if (STRISOK(itemName)) {
                        [mStr appendString:itemName];
                        [mStr appendString:@" "];
                    }
                    [mStr appendString:@"\n"];
                }
            }
            
            [self.dataLab setText:mStr];
        }else if (self.storeType == StoreType_Do) {
            
            NSMutableString *mStr = [[NSMutableString alloc] init];
            //itemId
            [mStr appendString:@"行为Id:"];
            [mStr appendString:[self.dic objectForKey:@"itemId"]];
            [mStr appendString:@"\n"];
            
            //itemName
            [mStr appendString:@"行为名字:"];
            [mStr appendString:[self.dic objectForKey:@"itemName"]];
            [mStr appendString:@"\n"];
            [self.dataLab setText:mStr];
            
        }else if (self.storeType == StoreType_Obj) {
            NSMutableString *mStr = [[NSMutableString alloc] init];
            //itemId
            [mStr appendString:@"实物Id:"];
            [mStr appendString:[self.dic objectForKey:@"itemId"]];
            [mStr appendString:@"\n"];
            
            //itemName
            [mStr appendString:@"实物名字:"];
            [mStr appendString:[self.dic objectForKey:@"itemName"]];
            [mStr appendString:@"\n"];
            [self.dataLab setText:mStr];
        }else if (self.storeType == StoreType_Text) {
            NSMutableString *mStr = [[NSMutableString alloc] init];
            //itemId
            [mStr appendString:@"分词Id:"];
            [mStr appendString:[self.dic objectForKey:@"itemId"]];
            [mStr appendString:@"\n"];
            
            //itemName
            [mStr appendString:@"分词名字:"];
            [mStr appendString:[self.dic objectForKey:@"itemName"]];
            [mStr appendString:@"\n"];
            [self.dataLab setText:mStr];
        }else if (self.storeType == StoreType_Logic) {
            [self.dataLab setText:@"逻辑"];
        }
    }
}

/**
 *  MARK:--------------------method--------------------
 */
-(NSString*) getObjName:(NSString*)itemId{
    NSDictionary *objDic = [[SMG sharedInstance].store.mkStore getObjWithWhere:[NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(itemId),@"itemId", nil]];
    if (objDic && [objDic objectForKey:@"itemName"]) {
        return STRTOOK([objDic objectForKey:@"itemName"]);
    }
    return nil;
}

-(NSString*) getDoName:(NSString*)itemId{
    NSDictionary *objDic = [[SMG sharedInstance].store.mkStore getDoWithWhere:[NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(itemId),@"itemId", nil]];
    if (objDic && [objDic objectForKey:@"itemName"]) {
        return STRTOOK([objDic objectForKey:@"itemName"]);
    }
    return nil;
}

-(NSString*) getWordName:(NSString*)itemId{
    NSDictionary *objDic = [[SMG sharedInstance].store.mkStore getWordWithWhere:[NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(itemId),@"itemId", nil]];
    if (objDic && [objDic objectForKey:@"word"]) {
        return STRTOOK([objDic objectForKey:@"word"]);
    }
    return nil;
}


+ (CGFloat) getCellHeight{
    return 164;
}

@end
