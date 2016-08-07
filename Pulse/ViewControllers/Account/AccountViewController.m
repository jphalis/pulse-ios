//
//  AccountViewController.m
//  Pulse
//


#import "AccountViewController.h"
#import "AppDelegate.h"
#import "defs.h"
#import "FollowViewController.h"
#import "GlobalFunctions.h"
#import "ProfileClass.h"
#import "SCLAlertView.h"
#import "SettingsViewController.h"
#import "UIViewControllerAdditions.h"


@interface AccountViewController (){
    AppDelegate *appDelegate;
    
    NSMutableDictionary *dictProfileInformation;
}

@end

@implementation AccountViewController

- (void)viewDidLoad {
    dictProfileInformation = [[NSMutableDictionary alloc]init];
    
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
    
    [self getProfileDetails];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Show the tabbar
    appDelegate.tabbar.tabView.hidden = NO;
    
    [super viewWillAppear:YES];
    
    if (GetUserName){
        _profileName.text = GetUserName;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getProfileDetails{
    ProfileClass *profileClass = [[ProfileClass alloc]init];

    profileClass.userId = @"21";
    profileClass.userName = @"John Doe";
    profileClass.accountUrl = @"";
//                if([JSONValue objectForKey:@"profile_picture"] == [NSNull null]){
//                    profileClass.userProfilePicture = @"";
//                } else {
//                    profileClass.userProfilePicture = [JSONValue objectForKey:@"profile_picture"];
//                }
    profileClass.followers_count = @"0";
    profileClass.following_count = @"1924";
    
    profileClass.arrfollowers = [[NSMutableArray alloc]init];
    profileClass.arrfollowings = [[NSMutableArray alloc]init];

    NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];

    [dictFollowerInfo setObject:@"Jane Smith" forKey:@"user__name"];
//    [dictFollowerInfo setObject:@"" forKey:@"user__profile_picture"];

    [profileClass.arrfollowings addObject:dictFollowerInfo];

    [dictProfileInformation setObject:profileClass forKey:@"ProfileInfo"];
    [self showProfileInfo];
}

-(void)showProfileInfo{
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    _profileName.text = profileClass.userName;
    _followerCount.text = profileClass.followers_count;
    _followingCount.text = profileClass.following_count;
    [_profilePicture setImage:[UIImage imageNamed:@"avatar_icon"]];
}

- (IBAction)onSettings:(id)sender {
    SettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (IBAction)onProfilePictureChange:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showNotice:self title:@"Notice" subTitle:@"Change your profile picture here." closeButtonTitle:@"OK" duration:0.0f];
}

- (IBAction)onEvents:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showNotice:self title:@"Notice" subTitle:@"View events here." closeButtonTitle:@"OK" duration:0.0f];
}

- (IBAction)onViewList:(id)sender {
    FollowViewController *followViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowViewController"];
    
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    
    if([sender tag] == 0){
        if([_followerCount.text isEqualToString:@"0"]){
            return;
        }
        followViewController.pageTitle = @"Followers";
        followViewController.arrDetails = profileClass.arrfollowers.copy;
    } else {
        if([_followingCount.text isEqualToString:@"0"]){
            return;
        }
        followViewController.pageTitle = @"Following";
        followViewController.arrDetails = profileClass.arrfollowings.copy;
    }
    [self.navigationController pushViewController:followViewController animated:YES];
}

@end
