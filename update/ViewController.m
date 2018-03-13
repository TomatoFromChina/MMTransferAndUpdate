//
//  ViewController.m
//  update
//
//  Created by xuliusheng on 2018/3/6.
//  Copyright © 2018年 fanqie. All rights reserved.
//

#import "ViewController.h"
#import "FQApi.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "MBProgressHUD.h"

#import "update-Swift.h"
#import "PeripheralCell.h"
#import <updateFrameWork/FQHttpReqest.h>
#import "FQBleManager.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.peripheralDict = [NSMutableDictionary dictionaryWithCapacity:2];
	
	//开始扫描
	
}
- (IBAction)starScan:(id)sender {

	[self.peripheralDict removeAllObjects];
	[self.tableView reloadData];
	
	[FQApi startScaning];

	[self show:@"search peripherals..."];
	[self performSelector:@selector(stopScan:) withObject:nil afterDelay:2];
}
- (void)stopScan:(id)sender {
	[FQApi stopScaning];
}

- (void)show:(NSString *)msg{
	MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
	progressHUD.label.text = msg;
	[progressHUD hideAnimated:YES afterDelay:2];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark -tableView dataSource/Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.peripheralDict.allKeys.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *cellId = @"PeripheralCell";
	PeripheralCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (!cell) {
		cell = [[NSBundle mainBundle]loadNibNamed:@"PeripheralCell" owner:self options:nil][0];
	}
	NSString *UUIDString = [self.peripheralDict.allKeys objectAtIndex:indexPath.row];
	cell.title.text = [NSString stringWithFormat:@"connect miaomiao:%@",UUIDString];
	[cell.updateBtn addTarget:self action:@selector(updateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	NSString *MAC = [self.peripheralDict.allKeys objectAtIndex:indexPath.row];
	//连接选择的设备
	[FQApi connectWithMAC:MAC];
	

	
}

- (UITableViewCell *)getSuperCell:(UIView *)view{
	UIView *superView = view;
	while (![superView isKindOfClass:[UITableViewCell class]]) {
		superView = superView.superview;
	}
	return (UITableViewCell *)superView;
}

- (void)updateBtnClick:(UIButton *)btn{
	UITableViewCell *cell = [self getSuperCell:btn];
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	NSString *MAC = [self.peripheralDict.allKeys objectAtIndex:indexPath.row];
	
	[FQHttpReqest downFileWithMAC:MAC success:^(id responseObject) {
		CBPeripheral *peripheral =  self.peripheralDict[MAC];
		[self uploadFirmware:peripheral MAC:MAC];
	}errorBlock:^(NSError *error) {
		
	}];
}

- (void)uploadFirmware:(CBPeripheral *)peripheral MAC:(NSString *)MAC{
	UPloadFirmwareVC *fVC = [[UPloadFirmwareVC alloc]init];
	fVC.selectedPeripheral = peripheral; //your peripheral
	fVC.successBlock = ^{
		[FQApi connectAfterUpdateWithMAC:MAC];
	};
	fVC.view.backgroundColor = [UIColor clearColor];
	fVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
	[self presentViewController:fVC animated:NO completion:^{}];
	
}


@end
