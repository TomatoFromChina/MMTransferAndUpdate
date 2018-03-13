//
//  FQToolsUtil.m
//  MiaoMiaoBluetoothDemo
//
//  Created by xuliusheng on 2017/10/31.
//  Copyright © 2017年 fanqie. All rights reserved.
//

#import "FQToolsUtil.h"

@implementation FQToolsUtil

+(void)saveUserDefaults:(id)obj key:(NSString *)key{
    [[NSUserDefaults standardUserDefaults]setObject:obj forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(id)userDefaults:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults]objectForKey:key];
}

//判断字符串
+ (NSString *)checkNull:(id)aStr{   
    if (aStr == [NSNull null] || aStr == nil || aStr == Nil ||[aStr isEqual:@"(null)"]) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@",aStr];
}

+ (NSString *)dictToJsonStr:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
