//
//  AppDelegate.m
//  Pulse
//

@import GooglePlaces;

#import "AppDelegate.h"
//#import "AuthViewController.h"
#import "defs.h"
#import "MBProgressHUD.h"
#import "SignInViewController.h"
#import "UIViewControllerAdditions.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


MBProgressHUD *hud;

@interface AppDelegate ()<UIAlertViewDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // Override point for customization after application launch.
    
    // Show status bar after splash page
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if(GetUserEmail == nil){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"NavigationControllerPulse"];
        SignInViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SignInViewController"];
        navController.viewControllers = @[vc];
        [self.window setRootViewController:navController];
    }
    
    // Dark keyboard
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    _arrFollowing = [[NSMutableArray alloc]init];
    
    [GMSPlacesClient provideAPIKey:@"AIzaSyBkOYnlH6Ht1T4_Z6uM0IF9HCxBSkByNcc"];
    
    // Push notification settings
    [self registerForRemoteNotifications];
    
    // Launched via URL
    NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (url) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
    return YES;
}

#pragma mark - Remote Notification Delegate // <= iOS 9.x

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *tokenAsString = [[NSString alloc]initWithFormat:@"%@", [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
//    NSLog(@"udid: %@", uniqueIdentifier);
//    NSLog(@"device token: %@", tokenAsString);
    
    [[NSUserDefaults standardUserDefaults] setObject:uniqueIdentifier forKey:@"deviceUDID"];
    [[NSUserDefaults standardUserDefaults] setObject:tokenAsString forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    NSLog(@"Push Notification Information : %@", userInfo);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    NSLog(@"%@ = %@", NSStringFromSelector(_cmd), error);
//    NSLog(@"Error = %@", error);
}

#pragma mark - UNUserNotificationCenter Delegate // >= iOS 10

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
//    NSLog(@"User Info = %@", notification.request.content.userInfo);
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
    
//    NSLog(@"User Info 2 = %@", response.notification.request.content.userInfo);
    completionHandler();
}

#pragma mark - Class Methods

/* Notification Registration */
- (void)registerForRemoteNotifications {
    
    if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) ) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
             if( !error ) {
                 [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
//                 NSLog( @"Push registration success." );
             } else {
//                 NSLog( @"Push registration FAILED" );
//                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
//                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );  
             }  
         }];  
    }
}

#pragma mark - Static Methods

+(AppDelegate*)getDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+(void)showMessage:(NSString *)message{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Message"
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
    [myAlertView show];
}

# pragma mark - Open page from URL

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if (!url) { return NO; }
    
    NSString *party_url = [NSString stringWithFormat:@"%@%@/", PARTYURL, url.lastPathComponent];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"URLSCHEMEACTIVATEDNOTIFICATION"
                                                        object:party_url
                                                      userInfo:nil];
    return YES;
}

-(BOOL) application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (!url) { return NO; }
    
    NSString *party_url = [NSString stringWithFormat:@"%@%@/", PARTYURL, url.lastPathComponent];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"URLSCHEMEACTIVATEDNOTIFICATION"
                                                        object:party_url
                                                      userInfo:nil];
    return YES;
}

#pragma mark - ActivityIndicator methods

-(void)hideHUDForView:(UIView *)view {
    HideNetworkActivityIndicator();
    [MBProgressHUD hideHUDForView:self.window animated:YES];    //view
}

-(void)showHUDAddedTo:(UIView *)view {
    ShowNetworkActivityIndicator();
    hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];  //view
    hud.labelText = @"";
}

-(void)showHUDAddedToView:(UIView *)view message:(NSString *)message {
    [self hideHUDForView:view];
    ShowNetworkActivityIndicator();
    hud = [MBProgressHUD showHUDAddedTo:view animated:YES];  //view
    hud.labelText = message;
}

-(void)showHUDAddedToView2:(UIView *)view message:(NSString *)message {
    [self hideHUDForView:view];
    ShowNetworkActivityIndicator();
    hud = [MBProgressHUD showHUDAddedTo:view animated:YES];  //view
    hud.labelText = message;
}

-(void)showHUDAddedTo:(UIView *)view message:(NSString *)message {
    [self hideHUDForView:view];
    ShowNetworkActivityIndicator();
    hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];  //view
    hud.labelText = message;
}

-(void)hideHUDForView2:(UIView *)view {
    HideNetworkActivityIndicator();
    [MBProgressHUD hideHUDForView:view animated:YES];    //view
}

-(void)UpdateMessage:(NSString *)message {
    if(hud != nil && hud.labelText != nil)
        hud.labelText = message;
}

#pragma mark - Validation Methods

+(BOOL)validateEmail:(NSString *)email{
    email = [email lowercaseString];
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:email];
    return myStringMatchesRegEx;
}

+(BOOL)isValidCharacter:(NSString*)string filterCharSet:(NSString*)set {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:set] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

-(NSInteger)getLength:(NSString*)mobileNumber {
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSInteger length = [mobileNumber length];
    return length;
}

-(void)userLogout {
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserID"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserToken"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserName"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserEmail"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserPassword"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserProPic"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserPhone"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"Party_Url_From_Web"];
    [self.arrFollowing removeAllObjects];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"NavigationControllerPulse"];
    SignInViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SignInViewController"];
    navController.viewControllers = @[vc];
    [self.window setRootViewController:navController];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
}

@end
