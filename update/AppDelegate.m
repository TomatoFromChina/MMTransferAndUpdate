//
//  AppDelegate.m
//  update
//
//  Created by xuliusheng on 2018/3/6.
//  Copyright © 2018年 fanqie. All rights reserved.
//

#import "AppDelegate.h"
#import "FQBleManager.h"
#import "FQApi.h"
#import "ViewController.h"
#import "update-Swift.h"
#import <updateFrameWork/FQHttpReqest.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "Toast+UIView.h"


//#import "UPloadFirmwareVC.swift"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	//you can connected to miaomiao just like this..
	//[FQApi connectWithMAC:@"D4973DFEA21C"];
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma 番茄SDK蓝牙回调函数

/**
 搜索到蓝牙(喵喵)设备后触发
 @param peripheral 喵喵硬件
 @param centralManager 蓝牙centralManager(升级用)
 @param RSSI 信号强度
 @param firmVersion 固件版本号
 @param MAC 喵喵MAC地址
 */
- (void)fqFoundPeripheral:(CBPeripheral *)peripheral
		   centralManager:(CBCentralManager *)centralManager
					 RSSI:(NSNumber *)RSSI
			  firmVersion:(NSString *)firmVersion
					  MAC:(NSString *)MAC{
	
	if ([peripheral.name  isEqualToString:@"miaomiaoA"]) {
		/*
		 接厂商SDK升级
		 */
		NSLog(@"miaomioa is BootLoader Model，you must update before used it");
	}
	
	ViewController *rootVC = (ViewController *)self.window.rootViewController;
	[rootVC.peripheralDict setObject:peripheral forKey:MAC];
	[rootVC.tableView reloadData];
	rootVC.stateLab.text = @"scaning";
}

- (void)fqConnectSuccess:(CBPeripheral *)peripheral
		  centralManager:(CBCentralManager *)centralManager{
	[self.window makeToast:@"connectSuccess" duration:2 position:@"center"];
	NSLog(@"connectSuccess");
}
- (void)fqConnectFailed {
	NSLog(@"connectFailed");
}
- (void)fqDisConnected {
	NSLog(@"disConnected");
}

#pragma 番茄SDK 数据回调
- (void)fqResp:(FQBaseResp*)resp{
	
	enum FQRespType type = resp.type;
	NSString *msg = @"";
	switch (type) {
		case FQUnRead:
			msg = @"unread";
			break;
		case FQChange:{
			msg = @"change sensor？";
			[self ifChange];
		}
			break;
		case FQReceived:{
			msg = @"received";
			
		}
			break;
		default:
			break;
	}
	[self showAlertView:msg];
	NSLog(@"received data hexStr--->\n%@",resp.hexStr);
}


- (void)showAlertView:(NSString *)msg{
	//    FQLog(@">>>%@",msg);
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
	}]];
	[self.window.rootViewController presentViewController:alert animated:YES completion:^{
	}];
}

- (void)ifChange{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"change confirm ?" preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"change" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[FQApi confirmChange]; //确认更换探头 更换成功后会主动获取新探头的数据
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
	}]];
	[self.window.rootViewController presentViewController:alert animated:YES completion:^{
	}];
}

@end
