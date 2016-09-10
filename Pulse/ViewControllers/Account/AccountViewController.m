//
//  AccountViewController.m
//  Pulse
//


#import "AccountViewController.h"
#import "AppDelegate.h"
#import "CollectionViewCellImage.h"
#import "defs.h"
#import "EventsViewController.h"
#import "FollowViewController.h"
#import "GlobalFunctions.h"
#import "PartyViewController.h"
#import "ProfileClass.h"
#import "SCLAlertView.h"
#import "SettingsViewController.h"
#import "TWMessageBarManager.h"
#import "UIViewControllerAdditions.h"


@interface AccountViewController () <UICollectionViewDelegateFlowLayout>{
    AppDelegate *appDelegate;
    UIRefreshControl *refreshControl;
    NSMutableDictionary *dictProfileInformation;
    NSMutableArray *arrEventImages;
    BOOL viewer_can_see;
}

@end

@implementation AccountViewController

- (void)viewDidLoad
{
    dictProfileInformation = [[NSMutableDictionary alloc]init];
    arrEventImages = [[NSMutableArray alloc]init];
    [self getProfileDetails];
    
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    [_collectionVW addSubview:refreshControl];
    
    _collectionVW.alwaysBounceVertical = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Show the tabbar
    appDelegate.tabbar.tabView.hidden = NO;
    
    [super viewWillAppear:YES];
    
    if (_needBack){
        _backBtn.hidden = NO;
    } else {
        _backBtn.hidden = YES;
    }
    
    if([[_userURL lastPathComponent]isEqualToString:[NSString stringWithFormat:@"%ld", (long)GetUserID]]){
        [_settingsBtn setImage:[UIImage imageNamed:@"settings_icon"] forState:UIControlStateNormal];
        _settingsBtn.tag = 1;
        _followBtn.hidden = YES;
    } else {
        [_settingsBtn setImage:[UIImage imageNamed:@"dot_more_icon"] forState:UIControlStateNormal];
        _settingsBtn.tag = 2;
    }
    
    _eventsBtn.layer.borderWidth = 1;
    _eventsBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _eventsBtn.layer.cornerRadius = 3;
    _followBtn.layer.cornerRadius = 3;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startRefresh
{
    [self getProfileDetails];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getProfileDetails
{
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
        
        if ([data length] > 0 && error == nil){
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]]){
                ProfileClass *profileClass = [[ProfileClass alloc]init];
                
                int userId = [[JSONValue objectForKey:@"id"]intValue];
                profileClass.userId = [NSString stringWithFormat:@"%d", userId];
                profileClass.gender = [JSONValue objectForKey:@"gender"];
                profileClass.userName = [JSONValue objectForKey:@"full_name"];
                profileClass.event_count = [JSONValue objectForKey:@"event_count"];
                BOOL isPrivate = [[JSONValue objectForKey:@"viewer_can_see"]boolValue];
                profileClass.isPrivate = isPrivate;
                if([JSONValue objectForKey:@"profile_pic"] == [NSNull null]){
                    profileClass.userProfilePicture = @"";
                } else {
                    NSString *str = [JSONValue objectForKey:@"profile_pic"];
                    profileClass.userProfilePicture = [NSString stringWithFormat:@"https://oby.s3.amazonaws.com/media/%@", str];
                    SetUserProPic(profileClass.userProfilePicture);
                }
                
                // Followers
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
                    
                    for(int i = 0; i < arrFollower.count; i++){
                        NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrFollower objectAtIndex:i];
                        
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
                    for(int j = 0; j < arrFollowing.count; j++){
                        NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrFollowing objectAtIndex:j];
                        
                        if (userId == GetUserID) {
                            if(appDelegate.arrFollowing.count > 0){
                                [appDelegate.arrFollowing removeAllObjects];
                            }
                            if([dictUserDetail objectForKey:@"user__full_name"] == [NSNull null]){
                                [dictFollowerInfo setObject:@"" forKey:@"user__full_name"];
                            } else {
                                [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__full_name"] forKey:@"user__full_name"];
                            }
                            NSString *userName = [dictFollowerInfo objectForKey:@"user__full_name"];
                            [appDelegate.arrFollowing addObject:userName];
                        }
                        
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
                
                // Event images
                if(arrEventImages.count > 0){
                    [arrEventImages removeAllObjects];
                }
                if([JSONValue objectForKey:@"event_images"] == [NSNull null]){

                } else {
                    NSMutableArray *arrEvents = [JSONValue objectForKey:@"event_images"];
                    
                    for(int k = 0; k < arrEvents.count; k++){
                        NSMutableDictionary *dictEventInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictEventDetail = [arrEvents objectAtIndex:k];
                        
                        if ([[dictEventDetail objectForKey:@"image"] isEqualToString:@""]){
                            [dictEventInfo setObject:@"" forKey:@"event__image"];
                        } else {
                            NSString *eventImageURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictEventDetail objectForKey:@"image"]];
                            [dictEventInfo setValue:eventImageURL forKey:@"event__image"];
                        }
                        
                        int partyId = [[dictEventDetail objectForKey:@"id"]intValue];
                        [dictEventInfo setValue:[NSString stringWithFormat:@"%d", partyId] forKey:@"event__id"];

                        [arrEventImages addObject:dictEventInfo];
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

-(void)showProfileInfo
{
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    _profileName.text = profileClass.userName;
//    _eventCount.text = profileClass.event_count;
    _followerCount.text = profileClass.followers_count;
    _followingCount.text = profileClass.following_count;
    [_profilePicture loadImageFromURL:profileClass.userProfilePicture withTempImage:@"avatar_icon"];
    viewer_can_see = profileClass.isPrivate;
    
    if (viewer_can_see == 1){
        _lockIcon.hidden = YES;
        _collectionVW.hidden = NO;
    } else {
        _lockIcon.hidden = NO;
        _collectionVW.hidden = YES;
    }

    if (![appDelegate.arrFollowing containsObject:_profileName.text]){
        [_followBtn setTitle:@"Follow" forState:UIControlStateNormal];
        _followBtn.layer.borderWidth = 1;
        _followBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
        _followBtn.backgroundColor = [UIColor clearColor];
    } else {
        [_followBtn setTitle:@"Following" forState:UIControlStateNormal];
    }
    
    [refreshControl endRefreshing];
    [_collectionVW reloadData];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSettings:(id)sender
{
    if([sender tag] == 1){
        SettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        [self.navigationController pushViewController:settingsViewController animated:YES];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Block User"
                                                        otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure you want to block this user?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        alert.delegate = self;
        alert.tag = 100;
        [alert show];
    } else if(buttonIndex == 1){
        //        NSLog(@"Cancel button clicked");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 && buttonIndex == 1 ) {
        checkNetworkReachability();
        ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *strURL = [NSString stringWithFormat:@"%@%@/", BLOCKURL, profileClass.userId];
            NSURL *url = [NSURL URLWithString:strURL];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setTimeoutInterval:60];
            [urlRequest setHTTPMethod:@"POST"];
            NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
            NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
            NSString *base64String = [plainData base64EncodedStringWithOptions:0];
            NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
            [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
            [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                [self setBusy:NO];
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Success"
                                                               description:BLOCK_USER
                                                                      type:TWMessageBarMessageTypeSuccess
                                                                  duration:3.0];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        });
    }
}

- (IBAction)onProfilePictureChange:(id)sender
{
    if (_profileName.text == GetUserName){
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:@"Change your profile picture here." closeButtonTitle:@"OK" duration:0.0f];
    }
}

- (IBAction)onEvents:(id)sender
{
    if (viewer_can_see == 1){
        EventsViewController *eventsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsViewController"];
        ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
        eventsViewController.userId = profileClass.userId;
        [self.navigationController pushViewController:eventsViewController animated:YES];
    }
}

- (IBAction)onViewList:(id)sender
{
    if (viewer_can_see == 1){
        FollowViewController *followViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowViewController"];
        
        ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
        
        if([sender tag] == 1){
            if([_followerCount.text isEqualToString:@"0"]){
                return;
            }
            followViewController.pageTitle = @"Followers";
            followViewController.arrDetails = profileClass.arrfollowers.mutableCopy;
        } else {
            if([_followingCount.text isEqualToString:@"0"]){
                return;
            }
            followViewController.pageTitle = @"Following";
            followViewController.arrDetails = profileClass.arrfollowings.mutableCopy;
        }
        [self.navigationController pushViewController:followViewController animated:YES];
    }
}

- (IBAction)onFollow:(id)sender {
    checkNetworkReachability();
    [self setBusy:YES];
    
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@/", FOLLOWURL, profileClass.userId];
    NSURL *url = [NSURL URLWithString:strURL];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60];
    [urlRequest setHTTPMethod:@"POST"];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if ([data length] > 0 && error == nil){
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if(JSONValue != nil){
                
                if([[JSONValue allKeys]count] > 1){
                    
                    if ([appDelegate.arrFollowing containsObject:profileClass.userName]){
                        for(int i = 0; i < appDelegate.arrFollowing.count; i++){
                            if([[appDelegate.arrFollowing objectAtIndex:i]isEqualToString:profileClass.userName]){
                                [appDelegate.arrFollowing removeObjectAtIndex:i];
                            }
                        }
                        [_followBtn setTitle:@"Follow" forState:UIControlStateNormal];
                        _followBtn.layer.borderWidth = 1;
                        _followBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
                        _followBtn.backgroundColor = [UIColor clearColor];
                    } else {
                        [appDelegate.arrFollowing addObject:profileClass.userName];
                        [_followBtn setTitle:@"Following" forState:UIControlStateNormal];
                        _followBtn.layer.borderColor = [[UIColor clearColor] CGColor];
                        _followBtn.backgroundColor = [UIColor colorWithRed:59/255.0 green:199/255.0 blue:114/255.0 alpha:1.0];
                    }
                }
            }
        } else {
            showServerError();
        }
        [self setBusy:NO];
    }];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrEventImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCellImage *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PartyImageCell" forIndexPath:indexPath];
    NSString *imageUrl = [[arrEventImages objectAtIndex:indexPath.row] valueForKey:@"event__image"];
    [cell.partyPicture loadImageFromURL:imageUrl withTempImage:@"avatar_icon"];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PartyViewController *partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];
    partyViewController.partyUrl = [NSString stringWithFormat:@"%@%@/", PARTYURL, [[arrEventImages objectAtIndex:indexPath.row] valueForKey:@"event__id"]];
    [self.navigationController pushViewController:partyViewController animated:YES];
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSInteger numberOfColumns = 3;
//    CGFloat itemWidth = (CGRectGetWidth(collectionView.frame) - (numberOfColumns - 1)) / numberOfColumns;
//    return CGSizeMake(itemWidth, itemWidth);
//}

@end
