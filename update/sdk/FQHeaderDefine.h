
//
//  FQHeaderDefine.h
//  MiaoMiaoBluetoothDemo
//
//  Created by xuliusheng on 2017/10/24.
//  Copyright © 2017年 fanqie. All rights reserved.
//

#ifndef FQHeaderDefine_h
#define FQHeaderDefine_h


#define FQ_SDK_OSTYPE                         @"iOS"
#define FQ_SDK_VERSION                        @"1.0.0"

#define FQ_MM_SERVICE_UUID                    @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define FQ_MM_WRITE_CHARACTER_UUID            @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define FQ_MM_NOTIFY_CHARACTER_UUID           @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"


#endif /* FQHeaderDefine_h */

// NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#ifdef DEBUG
#define FQLog( s, ... ) NSLog( @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define FQLog( s, ... )
#endif
