//
//  FQAESUitil.h
//  MiaoMiaoBluetoothDemo
//
//  Created by xuliusheng on 2017/11/1.
//  Copyright © 2017年 fanqie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FQAESUitil : NSObject

+ (NSString *)encryptAES:(NSString *)content key:(NSString *)key;
+ (NSString *)decryptAES:(NSString *)content key:(NSString *)key;
+(NSString *)md5DigestWithString:(NSString*)input;

@end
