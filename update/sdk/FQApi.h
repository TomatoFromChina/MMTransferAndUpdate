//
//  FQApi.h
//  MiaoMiaoBluetoothDemo
//
//  Created by xuliusheng on 2017/10/24.
//  Copyright © 2017年 fanqie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FQApiObject.h"

@interface FQApi : NSObject


+(void)startScaning;

+(void)stopScaning;

+(void)connectWithMAC:(NSString *)MAC; //you can connect peripheral directly by MAC

+(void)connectAfterUpdateWithMAC:(NSString *)MAC;

+(void)cancelConnectWithMAC:(NSString *)MAC; //cancel your connected peripheral

+(void)confirmChange;	//when miaomiao read new sensor ,your App need confirm change.

@end
