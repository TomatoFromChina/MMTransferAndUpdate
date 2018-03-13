//
//  FQToolsUtil.h
//  MiaoMiaoBluetoothDemo
//
//  Created by xuliusheng on 2017/10/31.
//  Copyright © 2017年 fanqie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FQToolsUtil : NSObject

+(void)saveUserDefaults:(id)obj key:(NSString *)key;
+(id) userDefaults:(NSString *)key;
+(NSString *)checkNull:(id)aStr;
+(NSString *)dictToJsonStr:(NSDictionary *)dict;

@end
