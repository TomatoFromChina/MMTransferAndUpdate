//
//  GTCBLEManager.m
//  BLEOTA
//
//  Created by zyk on 2017/1/24.
//  Copyright © 2017年 zhuyankun. All rights reserved.
//

#import "FQBleManager.h"
#import "FQHeaderDefine.h"
#import "FQApiObject.h"
#import "FQToolsUtil.h"

@interface FQBleManager()
{
	NSDate *_startDate;
}
@property (strong ,nonatomic) CBCharacteristic *writeCharacteristic;
@property (strong ,nonatomic) CBCharacteristic *notifyCharacteristic;

@property (strong,nonatomic)  NSString *firmNumber; //固件版本号
@property (strong ,nonatomic) NSMutableString *bufStr;
@property (assign ,nonatomic) NSInteger bufLen;


@end

@implementation FQBleManager

+ (FQBleManager *)shared
{
    static FQBleManager *shared = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        shared = [[FQBleManager alloc] init];
    });
    return shared;
}

- (void)startScanDevice{
//    FQLog(@"开始找设备>>>(manager)");
    FQLog(@"startScanDevice>>>(manager)");
    self.manager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
    self.bufStr =  [NSMutableString string];
    
}

- (void)connectDevice
{
    [self.manager connectPeripheral:self.peripheral options:nil];
}

- (void)disCoverServiceWith:(CBPeripheral *)peripheral{
    [peripheral discoverServices:nil];
}

- (void)stopScanDevice
{
    [self.manager stopScan];
    FQLog(@"stop Scan");
}


- (BOOL)retrievePeripherals:(CBCentralManager *)central{
    if(self.selectMAC){
        NSString *sUUID = [FQToolsUtil userDefaults:self.selectMAC];
        if (sUUID.length!=0) {
            NSUUID *uuid0 = [[NSUUID UUID] initWithUUIDString:sUUID];
            NSArray *peripheralArr = [central retrievePeripheralsWithIdentifiers:@[uuid0]];
            if (peripheralArr.count>0) {
                self.peripheral = [peripheralArr firstObject];
                self.peripheral.delegate = self;
                [central connectPeripheral:self.peripheral options:nil];
                return YES;
            }
        }
    }
    return NO;
}

#pragma -mark CBCentralManagerDelegate
//打开设备
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {  //开始扫描周围的外设
        BOOL retrieve = [self retrievePeripherals:central];
        if (!retrieve) {
            [self.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
        }
    }else if (central.state == CBCentralManagerStatePoweredOff){ //蓝牙未开启
		NSLog(@"power off");
    }else{
        
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    FQLog(@"peripheral.name %@",peripheral.name);
    if ([peripheral.name hasPrefix:@"miaomiao"]){
        NSData *data = advertisementData[@"kCBAdvDataManufacturerData"];
        NSString *dataStr = [self hexStringFromData:data];
        
        NSString *MAC = @"";
        if (dataStr.length == 16) {
            NSString *firmVersion = [dataStr substringToIndex:4];
            self.firmNumber = [NSString stringWithFormat:@"%lu",strtoul([firmVersion UTF8String],0,16)];

            MAC = [[dataStr substringFromIndex:4]uppercaseString];
            NSString *bindMac = self.selectMAC;
           
            if ([bindMac hasSuffix:MAC]) {   //判断喵喵
                if(peripheral.state == CBPeripheralStateDisconnected ){
                    //|| peripheral.state == CBPeripheralStateDisconnecting
                    FQLog(@"connecting peripheral");
                    self.peripheral = peripheral;
                    [central connectPeripheral:peripheral options:nil];
                    [self.manager stopScan];
                }else{
                     FQLog(@"didConnectPeripheral");
                    [self centralManager:central didConnectPeripheral:peripheral];
                }
            }
        }
        if ([self.delegate respondsToSelector:@selector(fqFoundPeripheral:centralManager:RSSI:firmVersion:MAC:)]) {
            [self.delegate fqFoundPeripheral:peripheral centralManager:self.manager RSSI:RSSI firmVersion:self.firmNumber MAC:MAC];
        }
        
    }
    if ([peripheral.name hasPrefix:@"miaomiaoA"]){
//        FQLog(@"找到了需要升级的设备");
        self.peripheral = peripheral;
        FQLog(@"%@",peripheral);
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
	FQLog(@"connected peripheral name:（%@）MAC: %@",peripheral.name,self.selectMAC);
    self.peripheral = peripheral;
    [self.peripheral setDelegate:self];
	if ([self.delegate respondsToSelector:@selector(fqConnectSuccess:centralManager:)]) {
        [self.delegate fqConnectSuccess:peripheral centralManager:self.manager];
    }
    NSUUID *uuid = peripheral.identifier;
    [FQToolsUtil saveUserDefaults:uuid.UUIDString key:self.selectMAC];
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:FQ_MM_SERVICE_UUID]]];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(fqConnectFailed)]) {
        [self.delegate fqConnectFailed];
    }
    FQLog(@">>> peripheral name:（%@）failed reason:%@",[peripheral name],[error localizedDescription]);
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    if ([self.delegate respondsToSelector:@selector(fqDisConnected)]) {
        [self.delegate fqDisConnected];
    }
    
    FQLog(@">>>peripheral didDisconnect%@: %@\n", [peripheral name], [error localizedDescription]);
    if (self.peripheral) {
        [self.manager connectPeripheral:self.peripheral options:nil];
    }
    
}

//获取服务后回调
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    FQLog(@">>>scanned services：%@",peripheral.services);
    if (error){
        FQLog(@">>>Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    for (CBService *service in peripheral.services) {
        FQLog(@"%@",service.UUID);
        //扫描每个service的Characteristics
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    FQLog(@"discovered characteristics");
    if (error) {
        FQLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics){
        //发送数据
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FQ_MM_WRITE_CHARACTER_UUID]]) {
            self.writeCharacteristic = characteristic;
        }
        //发送指令
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FQ_MM_NOTIFY_CHARACTER_UUID]]) {
            self.notifyCharacteristic = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    FQLog(@"set notifyed");
    if (characteristic.isNotifying == YES) {
        [self reset];
		Byte value[1] = {0xF0};
        NSData * data = [NSData dataWithBytes:&value length:sizeof(value)];
        [self writeFileData:data];
    }
   
    
}

//写文件时候的回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    NSData *data = characteristic.value;
	
    //unread or need change sensor
    if(data.length == 1 || data.length == 2){
        
        FQBaseResp *resp = [[FQBaseResp alloc]init];
        resp.errCode = error.code;
        resp.errStr =  error.localizedDescription;
        NSString *s = [self hexStringFromData:data];
		resp.hexStr = s;
        if ([s isEqualToString:@"32"]) {
            resp.type = FQChange;
        }
        if ([s isEqualToString:@"34"]) {
            resp.type = FQUnRead;
        }
		if ([s isEqualToString:@"D101"]) {
			NSLog(@"change time interval success");
		}
		if ([s isEqualToString:@"D100"]) {
			NSLog(@"change time interval failed");
		}
        [self.delegate fqResp:resp];
        return;
    }
	
    //sensor hex data
    NSString *data_s = [self hexStringFromData:data];
	//	NSLog(@"data_s-->%@",data_s);
    if (data.length) {
        NSString *pre_s = [data_s substringToIndex:2];
        if ([pre_s isEqualToString:@"28"] && self.bufStr.length == 0) {
            NSString *len_s = [data_s substringWithRange:NSMakeRange(2, 4)];
            self.bufLen = strtoul([len_s UTF8String],0,16);
            [self.bufStr appendString:data_s];
			_startDate = [NSDate date];
        }else{
            [self.bufStr appendString:data_s];
        }
    }
    if (self.bufStr.length == self.bufLen * 2) {
		
		FQBaseResp *resp = [[FQBaseResp alloc]init];
		resp.errCode = error.code;
		resp.errStr =  error.localizedDescription;
		resp.type = FQReceived;
		resp.hexStr = self.bufStr;
		
        if ([self.delegate respondsToSelector:@selector(fqResp:)]) {
            [self.delegate fqResp:resp];
        }
		NSTimeInterval timer = [[NSDate date]timeIntervalSinceDate:_startDate];
		NSLog(@"timerinterval-->%f",timer);
        [self reset];
	
    }
}

//写数据回调
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    FQLog(@"%@,%@",peripheral,characteristic);
    if (error) {
        FQLog(@"write error:=======%@",error);
    }else{
        FQLog(@"write success");
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FQ_MM_WRITE_CHARACTER_UUID]]) {
            FQLog(@"characteristic value is:%@",characteristic.value);
        }
    }
}

- (void)writeFileData:(NSData *)data{
	NSLog(@"request data");
    [self.peripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)writeControlData:(NSData *)data{
    [self.peripheral writeValue:data forCharacteristic:self.notifyCharacteristic type:CBCharacteristicWriteWithResponse];
}
- (void)cancelConnectDevice{
    if (self.peripheral.state == CBPeripheralStateConnected) {
         [self.manager cancelPeripheralConnection:self.peripheral];
         self.peripheral = nil;
    }
}


- (void)readValue{
}

- (void)setSelectMAC:(NSString *)selectMAC
{
    _selectMAC = selectMAC;
    
	FQLog(@"set Mac: %@",_selectMAC);
    if ([selectMAC isEqualToString:@""]) {
        return;
    }
    //初始化并扫描连接
    if (!self.manager) {
        FQLog(@"manager is nil create manager and start scanning");
        [self startScanDevice];
		return;
    }
    //如果扫描后停止
    if (!self.peripheral) {
		FQLog(@"self.peripheral is nil  manager:%@ is scanning:%d",self.manager,self.manager.isScanning);
        [self.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];return;
    }
    //切换喵喵设备
    if (self.peripheral.state == CBPeripheralStateConnected) {
        FQLog(@"self.peripheral is Connected");
        [self.manager cancelPeripheralConnection:self.peripheral];
        self.peripheral = nil;
        [self.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    }
}

- (NSString *)hexStringFromData:(NSData *)myD
{
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)  {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length] == 1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
- (void)reset{
    self.bufLen = 0;
    [self.bufStr setString:@""];
}


@end
