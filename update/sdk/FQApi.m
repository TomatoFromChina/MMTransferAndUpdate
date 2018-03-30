//
//  FQApi.m
//  MiaoMiaoBluetoothDemo
//
//  Created by xuliusheng on 2017/10/24.
//  Copyright © 2017年 fanqie. All rights reserved.
//

#import "FQApi.h"
#import "FQHeaderDefine.h"
#import "FQBleManager.h"
#import "FQToolsUtil.h"
#import <UIKit/UIKit.h>
#import "sys/utsname.h"



@interface FQApi()
@end

@implementation FQApi


+(void)startScaning{
    id d = UIApplication.sharedApplication.delegate;
	FQBleManager *manager = [FQBleManager shared];
	manager.delegate = (id)d;
	[manager startScanDevice];
}

+(void)connectWithMAC:(NSString *)MAC{
    
    [FQApi stopScaning];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id d = UIApplication.sharedApplication.delegate;
		FQBleManager *manager = [FQBleManager shared];
		manager.delegate = (id)d;
		manager.selectMAC = MAC;
    });
  
}

+(void)connectAfterUpdateWithMAC:(NSString *)MAC{
	[FQApi stopScaning];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		id d = UIApplication.sharedApplication.delegate;
		FQBleManager *manager = [FQBleManager shared];
		manager.delegate = (id)d;
		manager.manager = nil;
		manager.peripheral = nil;
		manager.selectMAC = MAC;
	});
	
}

+(void)cancelConnectWithMAC:(NSString *)MAC{
    if (MAC.length > 0) {
        FQBleManager *manager = [FQBleManager shared];
        [manager stopScanDevice];  //停止扫描
        [FQToolsUtil saveUserDefaults:nil key:MAC];
        [manager setSelectMAC:@""]; //清空Mac地址
        [manager cancelConnectDevice]; //断开蓝牙
    }
}



+(void)stopScaning{
	
	FQBleManager *manager = [FQBleManager shared];
	[manager stopScanDevice];
}


+(void)confirmChange{
    dispatch_after(0.2, dispatch_get_main_queue(), ^{
        FQBleManager *manager = [FQBleManager shared];
        Byte byte[2] = {};
        byte[0] = 0xD3;
        byte[1] = 0x01;
        NSData * data = [NSData dataWithBytes:&byte length:sizeof(byte)];
        [manager writeFileData:data];
        
        dispatch_after(0.2, dispatch_get_main_queue(), ^{
            //请求数据
            Byte byte1 = 0xF0;
            NSData * data1 = [NSData dataWithBytes:&byte1 length:sizeof(byte)];
            [manager writeFileData:data1];
        });
    });
}
+ (void)closeUART{
	FQBleManager *manager = [FQBleManager shared];
	Byte byte[1] = {};
	byte[0] = 0x45;
	NSData * data = [NSData dataWithBytes:&byte length:sizeof(byte)];
	[manager writeFileData:data];
}


@end
