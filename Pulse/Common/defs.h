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
    #define SetInt(x)  [NSString stringWithFormat:@"%ld",x]
#else
    #define SetSInt(x) [NSString stringWithFormat:@"%d",x]
    #define SetInt(x)  SetSInt(x)
#endif

#define DQ_  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#define _DQ });
#define MQ_ dispatch_async(dispatch_get_main_queue(), ^(void) {
#define _MQ });

#define MAIN_FRAME    [[UIScreen mainScreen]bounds]
#define SCREEN_WIDTH  [[UIScreen mainScreen]bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height

#define EMAIL          @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@-"
#define PASSWORD_CHAR  @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890._-*@!"
#define NAME           @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
#define NUMBERS        @"0123456789+"

#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

#ifdef DEBUG
    // DEV URLS
    #define TERMSURL       @"http://127.0.0.1:8000/terms/"
    #define PRIVACYURL     @"http://127.0.0.1:8000/privacy/"
    #define LOGINURL       @"http://127.0.0.1:8000/hidden/secure/pulse/api/auth/token/"
    #define SIGNUPURL      @"http://127.0.0.1:8000/hidden/secure/pulse/api/accounts/create/"
    #define FEEDURL        @"http://127.0.0.1:8000/hidden/secure/pulse/api/feed/"
    #define PROFILEURL     @"http://127.0.0.1:8000/hidden/secure/pulse/api/accounts/"
    #define FOLLOWURL      @"http://127.0.0.1:8000/hidden/secure/pulse/api/follow/"
    #define BLOCKURL       @"http://127.0.0.1:8000/hidden/secure/pulse/api/block/"
    #define NOTIFURL       @"http://127.0.0.1:8000/hidden/secure/pulse/api/notifications/"
    #define NOTIFAJAXURL   @"http://127.0.0.1:8000/hidden/secure/pulse/api/notifications/unread/"
    #define PARTIESURL     @"http://127.0.0.1:8000/hidden/secure/pulse/api/parties/"
    #define PARTIESOWNURL  @"http://127.0.0.1:8000/hidden/secure/pulse/api/parties/own/"
    #define PARTYURL       @"http://127.0.0.1:8000/hidden/secure/pulse/api/party/"
    #define PARTYATTENDURL @"http://127.0.0.1:8000/hidden/secure/pulse/api/party/attend/"
    #define PARTYCREATEURL @"http://127.0.0.1:8000/hidden/secure/pulse/api/party/create/"
    #define PARTYACCEPTURL @"http://127.0.0.1:8000/hidden/secure/pulse/api/party/approve/"
    #define PARTYDENYURL   @"http://127.0.0.1:8000/hidden/secure/pulse/api/party/deny/"
    #define FLAGURL        @"http://127.0.0.1:8000/hidden/secure/pulse/api/flag/create/"
#else
    // PROD URLS
    #define TERMSURL       @"https://pulse-ios.herokuapp.com/terms/"
    #define PRIVACYURL     @"https://pulse-ios.herokuapp.com/privacy/"
    #define LOGINURL       @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/auth/token/"
    #define SIGNUPURL      @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/accounts/create/"
    #define FEEDURL        @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/feed/"
    #define PROFILEURL     @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/accounts/"
    #define FOLLOWURL      @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/follow/"
    #define BLOCKURL       @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/block/"
    #define NOTIFURL       @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/notifications/"
    #define NOTIFAJAXURL   @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/notifications/unread/"
    #define PARTIESURL     @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/parties/"
    #define PARTIESOWNURL  @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/parties/own/"
    #define PARTYURL       @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/party/"
    #define PARTYATTENDURL @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/party/attend/"
    #define PARTYCREATEURL @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/party/create/"
    #define PARTYACCEPTURL @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/party/approve/"
    #define PARTYDENYURL   @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/party/deny/"
    #define FLAGURL        @"https://pulse-ios.herokuapp.com/hidden/secure/pulse/api/flag/create/"
#endif

#define    UserDefaults       [NSUserDefaults standardUserDefaults]

#define    SetUserToken(x)    [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserToken"]
#define    GetUserToken       [[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"]

#define    SetUserID(x)       [[NSUserDefaults standardUserDefaults] setInteger:(x) forKey:@"UserID"]
#define    GetUserID          [[NSUserDefaults standardUserDefaults] integerForKey:@"UserID"]

#define    SetUserEmail(x)    [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserEmail"]
#define    GetUserEmail       [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"]

#define    SetUserPassword(x) [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserPassword"]
#define    GetUserPassword    [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"]

#define    SetUserName(x)     [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserName"]
#define    GetUserName        [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]

#define    SetisFullView(x)   [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"FullView"]
#define    GetsFullView       [[NSUserDefaults standardUserDefaults] boolForKey:@"FullView"]

#endif
