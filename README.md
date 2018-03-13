# MMTransferAndUpdate
a demo for miaomiao bluetooth transfer and firmware update
## install
```pod  'iOSDFULibrary'
 pod   'MBProgressHUD'
```
## something about miaomiao
1. APP in the development process must first call ``` +(void)startScaning ``` to get the MAC address, . after   you can connect  directly by MAC ```+(void)connectWithMAC:(NSString *)MAC ``` .

2. SDK package Bluetooth reconnection mechanism, Bluetooth due to power outages, signal strength and other reasons will disconnect automatically reconnect, the corresponding state will callback in the APPDelegate.

3. When recieved data  func```- (void)fqResp:(BaseResp*)resp ``` call back.

4. When the user changes the sensor, the APP needs to give the change confirm . Call to``` +(void)confirmChangeconfirm``` replacement, do not confirm will always receive the FQChange status. After replacement will return to the new probe data.

5. The miaomiao transefer date every 5 minutes.

6. When the searched device name is "miaomiaoA", it is in BootLoader mode, at this moment, miaomiao needs to be forcibly upgraded before you can use it.

## update firmware
1. you should install   ```pod   'MBProgressHUD'```  for detail [IOS-nRF-Toolbox] (https://github.com/NordicSemiconductor/IOS-nRF-Toolbox)
2. the main code just link this,
```
@objc func upload() -> Void {
print("bgin")
if (selectedPeripheral) {
	let initiator = DFUServiceInitiator(centralManager: centralManager!, target: selectedPeripheral!)
		initiator.forceDfu = false //UserDefaults.standard.bool(forKey: "dfu_force_dfu")
		initiator.packetReceiptNotificationParameter = 20//UInt16(UserDefaults.standard.integer(forKey: "dfu_number_of_packets"))
		initiator.logger = self
		initiator.delegate = self
		initiator.progressDelegate = self
		initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
		dfuController = initiator.with(firmware: selectedFirmware!).start()
	}else{
		print("selectedPeripheral == nil || selectedFirmware == nil");
	}
}
```
3. when finished you can connect to your miaomiao by  this function ``` +(void)connectAfterUpdateWithMAC:(NSString *)MAC;```

## last
if you get something wrong ,please let me know.  our email is support@fanqies.com



