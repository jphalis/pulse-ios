//
//  defs.h
//  Pulse
//

#ifndef Pulse_defs_h

#define Pulse_defs_h

#include "AppDelegate.h"
#import "UIViewControllerAdditions.h"
#import "Message.h"

extern AppDelegate *appDelegate;

#define trim(x) [x stringByTrimmingCharactersInSet:WSset]
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
    #define SetSInt(x) [NSString stringWithFormat:@"%d",x]
    #define SetInt(x) [NSString stringWithFormat:@"%ld",x]
#else
    #define SetSInt(x) [NSString stringWithFormat:@"%d",x]
    #define SetInt(x) SetSInt(x)
#endif

#define DQ_  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#define _DQ });
#define MQ_ dispatch_async( dispatch_get_main_queue(), ^(void) {
#define _MQ });

#define MAIN_FRAME [[UIScreen mainScreen]bounds]
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height

#define EMAIL         @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@-"
#define PASSWORD_CHAR @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890._-*@!"
#define NAME      @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
#define NUMBERS @"0123456789+"

#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

#ifdef DEBUG
    // DEV URLS
    #define LOGINURL @"http://127.0.0.1:8000/"
    #define SIGNUPURL @"http://127.0.0.1:8000/"
    #define HOMEPAGEURL @"http://127.0.0.1:8000/"
#else
    // PROD URLS
    #define LOGINURL @"https://www.domain.com/"
    #define SIGNUPURL @"https://www.domain.com/"
    #define HOMEPAGEURL @"https://www.domain.com/"
#endif

#define    UserDefaults           [NSUserDefaults standardUserDefaults]

#define    SetAppKill(x)         [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"AppKill"]
#define    GetAppKill            [[NSUserDefaults standardUserDefaults] objectForKey:@"AppKill"]

#define    SetUserToken(x)       [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserToken"]
#define    GetUserToken          [[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"]

#define    SetUserID(x)          [[NSUserDefaults standardUserDefaults] setInteger:(x) forKey:@"UserID"]
#define    GetUserID             [[NSUserDefaults standardUserDefaults] integerForKey:@"UserID"]

#define    SetUserEmail(x)         [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserEmail"]
#define    GetUserEmail            [NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"]

#define    SetUserPassword(x)    [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserPassword"]
#define    GetUserPassword       [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"]

#define    SetUserName(x)         [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserName"]
#define    GetUserName            [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]

#define    SetMobileNum(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"MobileNum"]
#define    GetMobileNum           [[NSUserDefaults standardUserDefaults] objectForKey:@"MobileNum"]

#define    SetInitialScreen(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"InitialScreen"]
#define    GetInitialScreen           [[NSUserDefaults standardUserDefaults] objectForKey:@"InitialScreen"]

#endif
