//
//  DetailVC.m
//  update
//
//  Created by xuliusheng on 2018/3/26.
//  Copyright © 2018年 fanqie. All rights reserved.
//

#import "DetailVC.h"
#import "FQApi.h"
#import "MBProgressHUD.h"

@interface DetailVC ()

@end

@implementation DetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"device";
	self.view.backgroundColor = [UIColor whiteColor];
	[self createBtn];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	[self show:@"connect..."];
	[FQApi connectWithMAC:self.MAC];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createBtn{
//	UIButton *conBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//	conBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
//	conBtn.titleLabel.font = [UIFont systemFontOfSize:17];
//	conBtn.titleLabel.textColor = [UIColor blackColor];
//	conBtn.frame = CGRectMake(10, 100, self.view.frame.size.width - 20, 44);
//	[conBtn addTarget:self action:@selector(conBtnClick) forControlEvents:UIControlEventTouchUpInside];
//	[conBtn setTitle:[NSString stringWithFormat:@"get data：%@",self.MAC] forState:UIControlStateNormal];
//	[self.view addSubview:conBtn];
	
	
	UIButton *closeUARTBtn = [UIButton buttonWithType:UIButtonTypeSystem];
	closeUARTBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
	closeUARTBtn.titleLabel.font = [UIFont systemFontOfSize:17];
	closeUARTBtn.frame = CGRectMake(10, 100, self.view.frame.size.width - 20, 44);
	[closeUARTBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[closeUARTBtn addTarget:self action:@selector(closeUARTBtn) forControlEvents:UIControlEventTouchUpInside];
	[closeUARTBtn setTitle:[NSString stringWithFormat:@"close UART：%@",self.MAC] forState:UIControlStateNormal];
	[self.view addSubview:closeUARTBtn];
	
}
- (void)conBtnClick{

}

- (void)closeUARTBtn{
	[FQApi closeUART];
}




- (void)stopScan:(id)sender {
	[FQApi stopScaning];
}

- (void)show:(NSString *)msg{
	MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
	progressHUD.label.text = msg;
	[progressHUD hideAnimated:YES afterDelay:10];
}


@end
