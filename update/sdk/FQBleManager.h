//
//  GTCBLEManager.h
//  BLEOTA
//
//  Created by zyk on 2017/1/24.
//  Copyright © 2017年 zhuyankun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FQApi.h"


@protocol FQBleManagerDelegate <NSObject>

//find peripherals
@required
- (void)fqFoundPeripheral:(CBPeripheral *)peripheral
           centralManager:(CBCentralManager *)centralManager
                     RSSI:(NSNumber *)RSSI
              firmVersion:(NSString *)firmVersion
                      MAC:(NSString*)MAC;

//connect to peripheral
- (void)fqConnectSuccess:(CBPeripheral *)peripheral
		  centralManager:(CBCentralManager *)centralManager;

//connect Failed
- (void)fqConnectFailed;

//disConnected
- (void)fqDisConnected;

//return data
- (void)fqResp:(FQBaseResp*)resp;


@end

@interface FQBleManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (weak ,nonatomic) id<FQBleManagerDelegate> delegate;
@property (copy,nonatomic)NSString *selectMAC;
@property (strong ,nonatomic) CBCentralManager *manager;
@property (strong ,nonatomic) CBPeripheral *peripheral;


//instance
+ (FQBleManager *)shared;

//start scaning
- (void)startScanDevice;

//stop scaning
- (void)stopScanDevice;

//connect device
- (void)connectDevice;
//cancel connect
- (void)cancelConnectDevice;


//get servicies
- (void)disCoverServiceWith:(CBPeripheral *)peripheral;

- (void)writeFileData:(NSData *)data;

- (void)writeControlData:(NSData *)data;

- (void)readValue;

@end
