//
//  AppDelegate.h
//  Pulse
//

#import <UIKit/UIKit.h>
#import "CustomTabViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

+(AppDelegate*) getDelegate;
+(void)showMessage:(NSString *)message;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *arrFollowing;
@property (strong, nonatomic) NSMutableDictionary *dicAllKeys;
@property (strong, nonatomic) NSMutableDictionary *dictProfileInfo;
@property (strong, nonatomic) NSMutableArray *arrViewControllers;
@property (strong, nonatomic) CustomTabViewController *tabbar;
@property (assign, nonatomic) NSInteger currentTab;
@property (assign, nonatomic) NSInteger notificationCount;
@property (strong, nonatomic) UINavigationController *navController;

//Activity Methods
-(void)showHUDAddedToView2:(UIView *)view message:(NSString *)message;
-(void)showHUDAddedToView:(UIView *)view message:(NSString *)message;
-(void)hideHUDForView2:(UIView *)view;
-(void)hideHUDForView:(UIView *)view;
-(void)showHUDAddedTo:(UIView *)view ;
-(void)showHUDAddedTo:(UIView *)view message:(NSString *)message ;
-(void)UpdateMessage:(NSString *)message;

//Validation Methods
+(BOOL)validateEmail:(NSString *)email ;
+(BOOL)isValidCharacter:(NSString*)string filterCharSet:(NSString*)set;
-(NSString*)formatNumber:(NSString*)mobileNumber;
-(NSInteger)getLength:(NSString*)mobileNumber;

-(void)userLogout;

@end
