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
@property (strong,nonatomic) NSObject *data;
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


-(void) setData:(NSObject*)data withStoreType:(StoreType)storeType{
    self.data = data;
    self.storeType = storeType;
    [self refreshDisplay];
}

-(void) refreshDisplay{
    if (self.data) {
        if (self.storeType == StoreType_Mem) {
            NSDictionary *dic = (NSDictionary*)self.data;
            NSArray *doArr = [dic objectForKey:@"do"];
            NSArray *objArr = [dic objectForKey:@"obj"];
            NSString *text = [dic objectForKey:@"text"];
            
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
                for (NSDictionary *doItem in doArr) {
                    NSString *itemId = [doItem objectForKey:@"doId"];
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
            NSDictionary *dic = (NSDictionary*)self.data;
            NSMutableString *mStr = [[NSMutableString alloc] init];
            //itemId
            [mStr appendString:@"行为Id:"];
            [mStr appendString:[dic objectForKey:@"itemId"]];
            [mStr appendString:@"\n"];
            
            //itemName
            [mStr appendString:@"行为名字:"];
            [mStr appendString:[dic objectForKey:@"itemName"]];
            [mStr appendString:@"\n"];
            [self.dataLab setText:mStr];
            
        }else if (self.storeType == StoreType_Obj) {
            NSDictionary *dic = (NSDictionary*)self.data;
            NSMutableString *mStr = [[NSMutableString alloc] init];
            //itemId
            [mStr appendString:@"实物Id:"];
            [mStr appendString:[dic objectForKey:@"itemId"]];
            [mStr appendString:@"\n"];
            
            //itemName
            [mStr appendString:@"实物名字:"];
            [mStr appendString:[dic objectForKey:@"itemName"]];
            [mStr appendString:@"\n"];
            [self.dataLab setText:mStr];
        }else if (self.storeType == StoreType_Text) {
            TextModel *model = (TextModel*)self.data;
            NSMutableString *mStr = [[NSMutableString alloc] init];
            //itemId
            [mStr appendString:@"分词Id:"];
            [mStr appendFormat:@"%ld",model.rowid];
            [mStr appendString:@"\n"];
            
            //itemName
            [mStr appendString:@"词汇:"];
            [mStr appendString:model.text];
            [mStr appendString:@"\n"];
            [self.dataLab setText:mStr];
            
            //objId
            [mStr appendString:@"对应实物:"];
            NSInteger objId = [MapStore searchSingle_OtherIdWithClass:TextModel.class withClassId:model.rowid otherClass:ObjModel.class];
            [mStr appendString:STRTOOK([self getObjName:STRFORMAT(@"%ld",objId)])];
            [mStr appendString:@"\n"];
            [self.dataLab setText:mStr];
            
            //doId
            [mStr appendString:@"对应行为:"];
            NSInteger doId = [MapStore searchSingle_OtherIdWithClass:TextModel.class withClassId:model.rowid otherClass:DoModel.class];
            [mStr appendString:STRTOOK([self getDoName:STRFORMAT(@"%ld",doId)])];
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
    NSDictionary *objDic = [[SMG sharedInstance].store.mkStore.objStore getSingleItemWithWhere:[NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(itemId),@"itemId", nil]];
    if (objDic && [objDic objectForKey:@"itemName"]) {
        return STRTOOK([objDic objectForKey:@"itemName"]);
    }
    return nil;
}

-(NSString*) getDoName:(NSString*)itemId{
    NSDictionary *objDic = [[SMG sharedInstance].store.mkStore.doStore getSingleItemWithWhere:[NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(itemId),@"itemId", nil]];
    if (objDic && [objDic objectForKey:@"itemName"]) {
        return STRTOOK([objDic objectForKey:@"itemName"]);
    }
    return nil;
}

-(NSString*) getWordName:(NSString*)itemId{
    TextModel *model = [TextStore getSingleWordWithItemId:[STRTOOK(itemId) integerValue]];
    if (model) {
        return model.text;
    }
    return nil;
}


+ (CGFloat) getCellHeight{
    return 164;
}

@end
