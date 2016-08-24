//
//  AccountViewController.m
//  Pulse
//


#import "AccountViewController.h"
#import "AppDelegate.h"
#import "defs.h"
#import "EventsViewController.h"
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
    [self getProfileDetails];
    
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
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
    
    if (_needBack){
        _backBtn.hidden = NO;
    } else {
        _backBtn.hidden = YES;
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
    checkNetworkReachability();
    [self setBusy:YES];
    
    if (!_userURL){
        _userURL = [NSString stringWithFormat:@"%@%ld/", PROFILEURL, (long)GetUserID];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@", _userURL];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error != nil){
            [self setBusy:NO];
        }
        
        if ([data length] > 0 && error == nil){
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]]){
                ProfileClass *profileClass = [[ProfileClass alloc]init];
                
                int userId = [[JSONValue objectForKey:@"id"]intValue];
                profileClass.userId = [NSString stringWithFormat:@"%d", userId];
                profileClass.gender = [JSONValue objectForKey:@"gender"];
                profileClass.userName = [JSONValue objectForKey:@"full_name"];
                profileClass.event_count = [JSONValue objectForKey:@"event_count"];
                BOOL isPrivate = [[JSONValue objectForKey:@"is_private"]boolValue];
                profileClass.isPrivate = isPrivate;
                if([JSONValue objectForKey:@"profile_pic"] == [NSNull null]){
                    profileClass.userProfilePicture = @"";
                } else {
                    NSString *str = [JSONValue objectForKey:@"profile_pic"];
                    profileClass.userProfilePicture = [NSString stringWithFormat:@"https://oby.s3.amazonaws.com/media/%@", str];;
                }
                if([JSONValue objectForKey:@"follower"] == [NSNull null]){
                    profileClass.followers_count = @"0";
                    profileClass.following_count = @"0";
                } else {
                    NSDictionary *dictFollower = [JSONValue objectForKey:@"follower"];
                    NSMutableArray *arrFollower = [dictFollower objectForKey:@"get_followers_info"];
                    NSMutableArray *arrFollowing = [dictFollower objectForKey:@"get_following_info"];
                    
                    profileClass.followers_count = [NSString abbreviateNumber:[[dictFollower objectForKey:@"followers_count"]intValue]];
                    profileClass.following_count = [NSString abbreviateNumber:[[dictFollower objectForKey:@"following_count"]intValue]];
                    
                    profileClass.arrfollowers = [[NSMutableArray alloc]init];
                    profileClass.arrfollowings = [[NSMutableArray alloc]init];
                    
                    for(int j = 0; j < arrFollower.count; j++){
                        NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrFollower objectAtIndex:j];
                        
                        if([dictUserDetail objectForKey:@"user__profile_pic"] == [NSNull null]){
                            [dictFollowerInfo setObject:@"" forKey:@"user__profile_pic"];
                        } else {
                            NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"user__profile_pic"]];
                            [dictFollowerInfo setValue:proflURL forKey:@"user__profile_pic"];
                        }
                        
                        if([dictUserDetail objectForKey:@"user__full_name"] == [NSNull null]){
                            [dictFollowerInfo setObject:@"" forKey:@"user__full_name"];
                        } else {
                            [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__full_name"] forKey:@"user__full_name"];
                        }
                        
                        if([dictUserDetail objectForKey:@"user__id"] == [NSNull null]){
                            [dictFollowerInfo setObject:@"" forKey:@"user__id"];
                        } else {
                            [dictFollowerInfo setObject:[NSString stringWithFormat:@"%@",[dictUserDetail objectForKey:@"user__id"]] forKey:@"user__id"];
                        }
                        
                        [profileClass.arrfollowers addObject:dictFollowerInfo];
                    }
                    for(int k = 0; k < arrFollowing.count; k++){
                        NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrFollowing objectAtIndex:k];
                        
                        if([dictUserDetail objectForKey:@"user__profile_pic"] == [NSNull null]){
                            [dictFollowerInfo setObject:@"" forKey:@"user__profile_pic"];
                        } else {
                            NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"user__profile_pic"]];
                            [dictFollowerInfo setValue:proflURL forKey:@"user__profile_pic"];
                        }
                        if([dictUserDetail objectForKey:@"user__full_name"] == [NSNull null]){
                            [dictFollowerInfo setObject:@"" forKey:@"user__full_name"];
                        } else {
                            [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__full_name"] forKey:@"user__full_name"];
                        }
                        
                        if([dictUserDetail objectForKey:@"user__id"] == [NSNull null]){
                            [dictFollowerInfo setObject:@"" forKey:@"user__id"];
                        } else {
                            [dictFollowerInfo setObject:[NSString stringWithFormat:@"%@",[dictUserDetail objectForKey:@"user__id"]] forKey:@"user__id"];
                        }
                        
                        NSString *fullName = [dictFollowerInfo objectForKey:@"user__full_name"];
                        [dictFollowerInfo setValue:fullName forKey:@"user__full_name"];
                        
                        [profileClass.arrfollowings addObject:dictFollowerInfo];
                    }
                }
                
                [dictProfileInformation setObject:profileClass forKey:@"ProfileInfo"];
                [self showProfileInfo];
            } else {

            }
        } else {
            showServerError();
        }
        [self setBusy:NO];
    }];
}

-(void)showProfileInfo{
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    _profileName.text = profileClass.userName;
    _eventCount.text = profileClass.event_count;
    _followerCount.text = profileClass.followers_count;
    _followingCount.text = profileClass.following_count;
    [_profilePicture loadImageFromURL:profileClass.userProfilePicture withTempImage:@"avatar_icon"];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    EventsViewController *eventsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsViewController"];
    [self.navigationController pushViewController:eventsViewController animated:YES];
}

- (IBAction)onViewList:(id)sender {
    FollowViewController *followViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowViewController"];
    
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    
    if([sender tag] == 1){
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
