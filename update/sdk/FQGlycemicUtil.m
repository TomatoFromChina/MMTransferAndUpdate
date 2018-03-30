//
//  FQGlycemicUtil.m
//  MiaoMiaoBluetoothDemo
//
//  Created by xuliusheng on 2017/10/26.
//  Copyright © 2017年 fanqie. All rights reserved.
//

#import "FQGlycemicUtil.h"
#import "FQApiObject.h"
#import "FQToolsUtil.h"
#import "FQHeaderDefine.h"

#define LEN 100
#define TIM 20880


@implementation FQGlycemicUtil

+ (FQGlycemicUtil *)shared
{
    static FQGlycemicUtil *shared = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        shared = [[FQGlycemicUtil alloc] init];
    });
    return shared;
}

- (NSDictionary *)receiveGlucose:(NSString *)gluPacket{
    
    NSDictionary *paramDict = [NSMutableDictionary dictionary];
    
    NSString *glucose = [gluPacket substringFromIndex:6];
    glucose = [glucose substringToIndex:glucose.length-2];
    NSString *every_min_s = [glucose substringWithRange:NSMakeRange(0, 4)];
    NSString *uid_s = [glucose substringWithRange:NSMakeRange(4, 16)];
    NSString *battery_s =  [glucose substringWithRange:NSMakeRange(20, 2)];
    NSString *firmware_s = [glucose substringWithRange:NSMakeRange(22, 4)];
    /*NSString *hardware_s = [glucose substringWithRange:NSMakeRange(26, 4)];*/
    NSInteger counter = strtol([every_min_s UTF8String],0,16);  //探头每分钟计数
    NSInteger battery = strtol([battery_s UTF8String],0,16);
//    NSInteger firmVer = strtol([firmware_s UTF8String],0,16);  //固件版本号
//   NSString *new_glu_s = [glucose substringFromIndex:30];
    NSString *uid = [self getSensorNum:uid_s];
    
//    NSInteger lastCounter = 0;
//    NSDate   *latestDate = nil;
//    NSDictionary *lastDict = [FQToolsUtil userDefaults:uid];
//    if (lastDict) {
//        lastCounter =  [lastDict[@"count"]integerValue];
//        latestDate = lastDict[@"date"];
//    }
//    NSMutableArray * new_arr = [NSMutableArray arrayWithCapacity:0];
//    BOOL isAllZero = YES;
//    for (NSInteger i = 0; i < 10;i++ ) {
//        NSString *glu = [new_glu_s substringWithRange:NSMakeRange(i*4, 4)];
//        float cli_gly = [FQGlycemicUtil getCaliGly:glu];
//        [new_arr addObject:@(cli_gly)];
//        if (cli_gly > 0) {
//            isAllZero = NO;
//        }
//    }
	
    /*------------检查3种特殊情况------------
    if (isAllZero && counter == 0) {  //探头未启动 直接返回
        [paramDict setValue:@(FQUnStart) forKey:@"type"];
        return paramDict;
    }
    if (counter > TIM) {  //探头已过期 直接返回
        [paramDict setValue:@(FQExpired) forKey:@"type"];
        return paramDict;
    }
	
    if([[NSDate date]timeIntervalSinceDate:latestDate] > 2*60  && latestDate){ //TODO 探头已损坏
        if(lastCounter == counter){
            [paramDict setValue:@(FQDamage) forKey:@"type"];
            return paramDict;
        }
    }
	 */

    /*-------------------------------------
    
    
    
    
    NSString *his_glu_s = [new_glu_s substringFromIndex:40];
    NSMutableArray * history_arr = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = 0; i < his_glu_s.length/4;i++ ) {
        NSString *glu = [his_glu_s substringWithRange:NSMakeRange(i*4, 4)];
        float cli_gly = [FQGlycemicUtil getCaliGly:glu];
        [history_arr addObject:@(cli_gly)];
    }
    
    NSArray *revArr = [[new_arr reverseObjectEnumerator]allObjects];
    NSDictionary *dict = [FQGlycemicUtil calculateAverageGlucose:revArr];
    
    //1min数据
    NSMutableArray *newArr  = [NSMutableArray arrayWithCapacity:10]; //保存10条新数据
    NSMutableArray *rawArr = [NSMutableArray arrayWithCapacity:5];
    NSInteger temp_counter = counter;
    
    for (NSInteger i = 0; i < new_arr.count; i++) {
        CGMObject *cgmObj = [CGMObject new];
        cgmObj.glycemic = [[new_arr objectAtIndex:i]floatValue];
        cgmObj.count = temp_counter;
        cgmObj.uid = uid;
        cgmObj.date = [NSDate dateWithTimeIntervalSinceNow:(temp_counter - counter) * 60];
        [newArr insertObject:cgmObj atIndex:0];
        
        if (temp_counter > lastCounter) { //存数据库传 服务器
            CGMObject *rawObj = [CGMObject new];
            rawObj.rawGlycemic = [new_glu_s substringWithRange:NSMakeRange(i*4, 4)];
            rawObj.count = temp_counter;
            rawObj.uid = uid;
            rawObj.date = cgmObj.date;
            [rawArr addObject:rawObj];
        }
        temp_counter--;
    }
    //15min数据
    NSMutableArray *historyArr  = [NSMutableArray arrayWithCapacity:2];
    NSInteger his_counter = counter;
    NSInteger j = 0;
    while (j < history_arr.count && history_arr.count > 0) {
        if (his_counter % 15 == 0) {  //隔15分钟
            CGMObject *cgmObj = [CGMObject new];
            cgmObj.glycemic = [[history_arr objectAtIndex:j]floatValue];
            cgmObj.count = his_counter;
            cgmObj.uid = uid;
            cgmObj.date = [NSDate dateWithTimeIntervalSinceNow:(his_counter - counter) * 60];
            [historyArr insertObject:cgmObj atIndex:0];
            j++;
        }
        his_counter--;
    }
    
    [self save:uid rawArr:rawArr];
    [FQToolsUtil saveUserDefaults:@{@"count":@(counter),@"date":[NSDate date]} key:uid];
    
    //上传到服务器
    [self uploadRawArr];
    float slope = [dict[@"trend"]floatValue];
    int trend = [self changeArrow:slope];
//    NSString *timeleft = [self timeleft:(int)counter];
	 	 */
    paramDict = @{
                    @"frimVersion":firmware_s,
                    @"battery":@(battery),
                    @"uid":uid,
                    @"counter":@(counter)
                    };
    
    return paramDict;

}

/*
- (void)uploadRawArr{
    
    NSMutableArray *totalArr = [FQSqliteManager selectObjs];
    if (totalArr.count == 0) {return;} //如果没有新的数据
    NSDate *lastUploadDate = [FQToolsUtil userDefaults:@"lastUploadDate"];
    if ([[NSDate date]timeIntervalSinceDate:lastUploadDate] < 60 * 20   && lastUploadDate) {return;}//20min同步一次数据 
    
    NSMutableArray *glycemic_raw_list = [NSMutableArray arrayWithCapacity:5];
    for (CGMObject *obj in totalArr) {  //一分钟数据
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setObject:obj.rawGlycemic forKey:@"raw_glycemic"];
        [d setObject:@(obj.count) forKey:@"glycemic_index"];
        [d setObject:obj.uid forKey:@"detector_no"]; //探头UID
        [d setObject:[FQGlycemicUtil dateToStr:obj.date format:@"yyyy-MM-dd HH:mm:ss"] forKey:@"glycemic_time"];
        [glycemic_raw_list addObject:d];
    }
    NSInteger userId = [[FQToolsUtil userDefaults:AuthKey]integerValue];
    NSDictionary *dict = @{
                           @"user_id":@(userId),
                           @"glycemic_raw_list":glycemic_raw_list
                           };
    [FQHttpReqest POST:dict service:@"upload" success:^(NSDictionary *dict){
        NSInteger errcode = [dict[@"errcode"]integerValue];
        if (errcode == 0) {
            if(totalArr.count > 0){ [FQSqliteManager deleteObjs];} //删除本地数据
        }
    } failure:^(NSError *error) {
        
    }];
    [FQToolsUtil saveUserDefaults:[NSDate date] key:@"lastUploadDate"];
   
}

- (void)save:(NSString*)uid rawArr:(NSMutableArray *)rawArr{
    if (rawArr.count) {
         [FQSqliteManager saveObjs:rawArr];
    }
}

- (int)changeArrow:(float)num{
    
    if (num > 0.1) {
        return  FQUpward;
    }else if (0.06 <= num  && num <= 0.1){
        return  FQObliqueUpward;
    }else if (-0.06< num && num < 0.06){
        return FQFlat;
    }else if (-0.1 <=num && num <= -0.06){
        return FQObliqueDown;
    }else if (num < -0.1){
        return FQDown;
    }
    return FQFlat;
}


- (NSString *)timeleft:(int)time{

    NSInteger counter = 20880;
    if (time >= counter) {
        return @"已过期";
    }
    if (counter - time <= 720) {
        NSString *s = [self timeFormatted:(TIM - time)];
        return s;
    }
    NSString * s = [NSString stringWithFormat:@"剩余%d天",14 - (time/1440)];
    return s;
}

- (NSString *)timeFormatted:(int)totalSeconds{
    int minutes = (totalSeconds) % 60;
    int hours = totalSeconds / 60;
    return [NSString stringWithFormat:@"剩余：%02d小时%02d分",hours,minutes];
}



//时间转字符串
+ (NSString *)dateToStr:(NSDate *)date format:(NSString *)format{
    
    NSDateFormatter *formaterMD = [[NSDateFormatter alloc] init];
    [formaterMD setDateFormat:format];
    NSString *dateStrForMD = [formaterMD stringFromDate:date];
    return dateStrForMD;
}
//字符串转时间
+ (NSDate *)strToDate:(NSString *)dateStr format:(NSString *)format{
    NSDateFormatter *f =[[NSDateFormatter alloc] init];
    [f setDateFormat:format];
    NSDate *f_date=[f dateFromString:dateStr];
    return f_date;
}

*/

- (NSString *)getSensorNum:(NSString *)ori_sen
{
    NSMutableString *s = [NSMutableString string];
    if (ori_sen.length == 16) {
        for (NSInteger i = 7; i >= 0; i--) {
            NSString *sub_s= [ori_sen substringWithRange:NSMakeRange(i*2, 2)];
            [s appendString:sub_s];
        }
    }
    NSString *uid = [self getSensorUid:s];
    return uid;
}

__int64_t changeToInt( char *a) {
    
    for(int i = 0; i < strlen(a); i++){
        a[i] = toupper(a[i]);
    }
    __int64_t sum = 0;
    for (int i =0 ; i < strlen(a); i++) {
        char b_s = a[i];
        int count = (int)b_s;
        sum = sum * 16 + count - 48;
        if (count >= 65) {
            sum -= 7;
        }
    }
    return sum;
}

- (NSString *)getSensorUid:(NSString *)uid{
    NSArray *lookupTable = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"C",@"D",@"E",@"F",@"G",@"H",@"J",@"K",@"L",@"M",@"N",@"P",@"Q",@"R",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    NSString *uidString = [uid substringFromIndex:4];
    NSMutableString *serialNumber = [NSMutableString string];
    
    const char * expr =[uidString UTF8String];
    char buf[strlen(expr + 1)];
    strcpy(buf, expr);
    __int64_t aValue = changeToInt(buf);
    NSString *str = [NSString stringWithFormat:@"%lld",aValue];
    NSString *uidAsBinaryString = [self toBinarySystemWithDecimalSystem:str];
    uidAsBinaryString = [NSString stringWithFormat:@"%@00",uidAsBinaryString];
    for (NSInteger i = 0; i< uidAsBinaryString.length; i += 5) {
        NSString *fiveBits = [uidAsBinaryString substringWithRange:NSMakeRange(i, 5)];
        NSInteger theInt = strtoul([fiveBits UTF8String],0,2);
        if(0 <= theInt && theInt < lookupTable.count){
            [serialNumber appendString:lookupTable[theInt]];
        }
    }
    serialNumber = [[NSMutableString alloc]initWithFormat:@"0%@",serialNumber];
    return serialNumber;
}

- (NSString *)toBinarySystemWithDecimalSystem:(NSString *)decimal{
    long long  num = [decimal longLongValue];
    long long remainder = 0;      //余数
    long long divisor = 0;        //除数
    NSString * prepare = @"";
    while (true){
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%lld",remainder];
        
        if (divisor == 0)
        {
            break;
        }
    }
    NSString * result = @"";
    for (long long i = prepare.length - 1; i >= 0; i --)
    {
        result = [result stringByAppendingFormat:@"%@",[prepare substringWithRange:NSMakeRange((int)i , 1)]];
    }
    
    return result;
}






NSInteger customSort(id obj1, id obj2,void* context){
    if ([obj1 floatValue] > [obj2 floatValue]) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    if ([obj1 floatValue] < [obj2 floatValue]) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
}
NSInteger gCount = 12;

/*
 原始值     arr1 = [4.3,4.5,5.5,1.0,7.9,4.6]...
 排序后     arr2 = [1.0,4.3,4.5,4.6,5.5,7.9]  因为 (7.9- 1.0) > 2.2 所以这两个值均去掉
 掐头去尾后  arr3 = [4.3,4.5,4.6,5.5]
 再判断要写数据库的值是否在 arr3里面 在的话则插入
 例如 4.3插  1.0 不插
 */

static float filter = 2.2;
//+ (NSDictionary *)calculateAverageGlucose:(NSArray *)newArr{
//
//    NSMutableArray *array =  [NSMutableArray arrayWithArray:[newArr sortedArrayUsingFunction:customSort context:nil]];
//    NSMutableArray *filterArr = [self removeAbnormal:array];
//    NSDictionary *fd = [self caluculateTrend:filterArr ori_arr:newArr];
//    float average = [[filterArr valueForKeyPath:@"@avg.floatValue"]floatValue];
//
//    float trend = [fd[@"trend"]floatValue];
//    float newValue = [fd[@"newValue"]floatValue];
//    NSDictionary *d = @{
//                        @"currentTime":[NSDate date],
//                        @"newValue":@(newValue), //
//                        @"trend":@(trend),
//                        @"rate":@(trend), //rate
//                        @"average":@(average), //
//                        @"filterArr":filterArr
//                        };
//    return d;
//
//
//
//}

+ (NSDictionary *)caluculateTrend:(NSArray *)filterArr ori_arr:(NSArray *)news_arr {
    
    Data.len = 0;
    //遍历后面最新的5个数据做线性拟合
    float newValue = 0.0;
    for(NSInteger i = (news_arr.count - 1), j = 5; i > 0; i--) {
        NSNumber *num = news_arr[i];
        if ([filterArr containsObject:num]) {
            float g_v =  [num floatValue];    // [filterArr[i] floatValue];
//            FQLog(@"index-->%ld-->%f",i,g_v); // float date2 = (0.13 * g_v * 180 -20)/18.0;
            if (j == 5) {
                newValue = g_v;
            }
            j--;
            push(i,g_v);
            if (j == 0)
                break;
        }
    }
//    printf("5分钟后血糖值预计为 %fmmol/l\n",calc([news_arr count]+5));
    float trend = calcSlope();
    NSDictionary *d = @{
                        @"newValue":@(newValue),
                        @"trend":@(trend)
                        };
    
    return d;
}



+ (NSMutableArray *)removeAbnormal:(NSMutableArray *)array {
    NSMutableArray *arr ;
    float l_v = [[array lastObject]floatValue];
    float f_v = [[array firstObject] floatValue];
    if ((l_v -  f_v ) > filter) {
        [array removeLastObject];
        [array removeObjectAtIndex:0];
        arr = [self removeAbnormal:array];
    }else{
        arr = array;
    }
    return arr;
}


//获取血糖值
+ (float)getGlycemic:(NSString*)aStr
{
    //字符串高低位换算
    if(aStr.length == 4){
        NSString *sub0 = [aStr substringWithRange:NSMakeRange(0, 2)];
        NSString *sub1 = [aStr substringWithRange:NSMakeRange(2, 2)];
        NSString *sub10 = [NSString stringWithFormat:@"%@%@",sub1,sub0];
        NSData *d = [self hexToBytes:sub10];
        Byte * myByte = (Byte *)[d bytes];
        float data1 = (256 * (myByte[0] & 0xFF) + (myByte[1] & 0xFF)) & 0x3FFF;
        float newGlycemic = data1 /10.0/18.0; //mmol/L
        
        return newGlycemic;
    }
    return 0.0;
}


+ (float)getCaliGly:(NSString *)aStr{
    float oriValue = [self getGlycemic:aStr];
    float calValue =  1 * oriValue + 0;
    return calValue;
}



+ (NSData *)hexToBytes:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}


/*最小二乘法*/
struct _Data_Unit{
    float x;
    float y;
};

struct _Data{
    struct _Data_Unit data[LEN];
    int len;
};

struct _Data Data ={
    .len = 0
};


void push(float x,float y){
    
    int i = 0;
    if (Data.len < LEN){
        Data.data[Data.len].x = x;
        Data.data[Data.len++].y = y;
        return;
    }
    
    //数据移动,去掉最后一个数据
    for (i = 0;i < LEN - 1;i++){
        Data.data[i].x = Data.data[i + 1].x;
        Data.data[i].y = Data.data[i + 1].y;
    }
    Data.data[LEN].x = x;
    Data.data[LEN].y = y;
    Data.len = LEN;
}

float calcSlope(){
    int i = 0;
    float mean_x = 0;
    float mean_y = 0;
    float num1 = 0;
    float num2 = 0;
    float a = 0;
    float b = 0;
    
    //求t,y的均值
    for (i = 0;i < Data.len;i++) {
        mean_x += Data.data[i].x;
        mean_y += Data.data[i].y;
    }
    mean_x /= Data.len;
    mean_y /= Data.len;
    
    //    printf("mean_x = %f,mean_y = %f\n",mean_x,mean_y);
    for (i = 0;i < Data.len;i++) {
        num1 += (Data.data[i].x - mean_x) * (Data.data[i].y - mean_y);
        num2 += (Data.data[i].x - mean_x) * (Data.data[i].x - mean_x);
    }
    b = num1 / num2;
    a = mean_y - b * mean_x;
    return  b;
}

float calc(float x) {
    
    int i = 0;
    float mean_x = 0;
    float mean_y = 0;
    float num1 = 0;
    float num2 = 0;
    float a = 0;
    float b = 0;
    
    //求t,y的均值
    for (i = 0;i < Data.len;i++) {
        mean_x += Data.data[i].x;
        mean_y += Data.data[i].y;
    }
    mean_x /= Data.len;
    mean_y /= Data.len;
    
//    printf("mean_x = %f,mean_y = %f\n",mean_x,mean_y);
    for (i = 0;i < Data.len;i++) {
        num1 += (Data.data[i].x - mean_x) * (Data.data[i].y - mean_y);
        num2 += (Data.data[i].x - mean_x) * (Data.data[i].x - mean_x);
    }
    b = num1 / num2;
    a = mean_y - b * mean_x;
//    printf("a = %f,b = %f\n",a,b);
    return  (a + b * x);
}
@end
