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

// URLs
#define S3_BUCKET         @"https://oby.s3.amazonaws.com/media/"
#ifdef DEBUG
    #define BASEURL       @"http://127.0.0.1:8000/"
#else
    #define BASEURL       @"https://pulse-ios.herokuapp.com/"
#endif
#define TERMSURL          BASEURL "terms/"
#define PRIVACYURL        BASEURL "privacy/"
#define APIURL            BASEURL "hidden/secure/pulse/api/"
#define LOGINURL          APIURL "auth/token/"
#define SIGNUPURL         APIURL "accounts/create/"
#define FEEDURL           APIURL "feed/"
#define PROFILEURL        APIURL "accounts/"
#define FOLLOWURL         APIURL "follow/"
#define BLOCKURL          APIURL "block/"
#define NOTIFURL          APIURL "notifications/"
#define NOTIFAJAXURL      APIURL "notifications/unread/"
#define PARTIESURL        APIURL "parties/"
#define PARTIESOWNURL     APIURL "parties/own/"
#define PARTYURL          APIURL "party/"
#define PARTYATTENDURL    APIURL "party/attend/"
#define PARTYCREATEURL    APIURL "party/create/"
#define PARTYACCEPTURL    APIURL "party/approve/"
#define PARTYDENYURL      APIURL "party/deny/"
#define FLAGURL           APIURL "flag/create/"

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

#define    SetUserProPic(x)   [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserProPic"]
#define    GetUserProPic      [[NSUserDefaults standardUserDefaults] objectForKey:@"UserProPic"]

#define    SetisFullView(x)   [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"FullView"]
#define    GetsFullView       [[NSUserDefaults standardUserDefaults] boolForKey:@"FullView"]

#endif
