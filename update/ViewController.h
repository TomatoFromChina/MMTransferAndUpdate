//
//  ViewController.h
//  update
//
//  Created by xuliusheng on 2018/3/6.
//  Copyright © 2018年 fanqie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property(nonatomic,strong)NSMutableDictionary *peripheralDict;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *stateLab;
@property (weak, nonatomic) IBOutlet UILabel *rssiLab;

@end

