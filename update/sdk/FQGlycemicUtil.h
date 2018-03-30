//
//  FQGlycemicUtil.h
//  MiaoMiaoBluetoothDemo
//
//  Created by xuliusheng on 2017/10/26.
//  Copyright © 2017年 fanqie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FQGlycemicUtil : NSObject
+ (FQGlycemicUtil *)shared;
+ (float)getCaliGly:(NSString *)aStr;

- (NSDictionary *)receiveGlucose:(NSString *)gluPacket;
- (NSString *)getSensorNum:(NSString *)ori_sen;
- (NSString *)getSensorUid:(NSString *)uid;
//- (void)uploadRawArr;
@end
