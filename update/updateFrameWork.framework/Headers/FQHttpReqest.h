//
//  FQHttpReqest.h
//  MiaoMiaoBluetoothDemo
//
//  Created by xuliusheng on 2017/10/24.
//  Copyright © 2017年 fanqie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FQHttpReqest : NSObject

+ (void)downFileWithMAC:(NSString *)MAC
				success:(void (^)(id responseObject))success
				  errorBlock:(void (^)( NSError *))error;

@end
