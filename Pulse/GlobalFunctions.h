//
//  GlobalFunctions.h
//  Pulse
//

void checkNetworkReachability();
void showServerError();

@interface NSString(MyNSStringCategoryName)
+ (NSString *)abbreviateNumber:(int)num;
+ (NSString *)floatToString:(float)val;
@end
