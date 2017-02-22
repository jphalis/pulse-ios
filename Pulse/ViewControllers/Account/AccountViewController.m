//
//  AccountViewController.m
//  Pulse
//

#import <Photos/Photos.h>

#import "AccountViewController.h"
#import "AppDelegate.h"
#import "CollectionViewCellImage.h"
#import "defs.h"
#import "EventsViewController.h"
#import "FollowViewController.h"
#import "GlobalFunctions.h"
#import "PartyViewController.h"
#import "PhoneViewController.h"
#import "ProfileClass.h"
#import "SCLAlertView.h"
#import "SettingsViewController.h"
#import "TWMessageBarManager.h"
#import "UIViewControllerAdditions.h"

@interface AccountViewController () <UICollectionViewDelegateFlowLayout, KIImagePagerDelegate, KIImagePagerDataSource>{
    
    AppDelegate *appDelegate;
    NSMutableDictionary *dictProfileInformation;
    NSMutableArray *arrEventImages;
    NSMutableArray *arrUserImages;
    BOOL viewer_can_see;
    NSString *imagePickerLabel;
    UIRefreshControl *refreshControl;
}

@end

@implementation AccountViewController

- (void)viewDidLoad {
    self.definesPresentationContext = YES;
    
    dictProfileInformation = [[NSMutableDictionary alloc]init];
    arrEventImages = [[NSMutableArray alloc]init];
    arrUserImages = [[NSMutableArray alloc]init];
    [self getProfileDetails:NO];
    
    _profilePicture.layer.cornerRadius = _profilePicture.frame.size.width / 2;
    _profilePicture.clipsToBounds = YES;
    _profilePicture.layer.masksToBounds = YES;
    
    _userImageNewBtn.layer.cornerRadius = _userImageNewBtn.frame.size.width / 2;
    _userImageDeleteBtn.layer.cornerRadius = _userImageDeleteBtn.frame.size.width / 2;
    
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    [_scrollView addSubview:refreshControl];
    
    _collectionVW.alwaysBounceVertical = YES;
    
    _profileBio.delegate = self;
    _profileName.delegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _scrollView.contentInset = UIEdgeInsetsZero;
    _scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    _scrollView.contentOffset = CGPointMake(0.0, 0.0);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated {
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Show the tabbar
    appDelegate.tabbar.tabView.hidden = NO;
    
    [super viewWillAppear:YES];
    
    if (_needBack){
        _backBtn.hidden = NO;
        _backBtn2.hidden = NO;
    } else {
        _backBtn.hidden = YES;
        _backBtn2.hidden = YES;
    }
    
    if ([[_userURL lastPathComponent]isEqualToString:[NSString stringWithFormat:@"%ld", (long)GetUserID]]){
        [_settingsBtn setImage:[UIImage imageNamed:@"settings_icon"] forState:UIControlStateNormal];
        _settingsBtn.tag = 1;
    } else {
        [_settingsBtn setImage:[UIImage imageNamed:@"dot_more_icon"] forState:UIControlStateNormal];
        _settingsBtn.tag = 2;
    }
    
    _imagePager.slideshowTimeInterval = 0.0f;
    _imagePager.slideshowShouldCallScrollToDelegate = YES;
    _imagePager.captionBackgroundColor = [UIColor clearColor];
    _imagePager.imageCounterDisabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _imagePager.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:(171/255.0) green:(14/255.0) blue:(27/255.0) alpha:1.0];
    _imagePager.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 800)];
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

-(void)startRefresh{
    [self getProfileDetails:YES];
}

-(void)dismissKeyboard {
    [_profileName resignFirstResponder];
    [_profileBio resignFirstResponder];
}

-(void)getProfileDetails:(BOOL)refreshed {
    checkNetworkReachability();
    [self setBusy:YES];
    
    if ([_userURL isEqualToString:@""] || _userURL == NULL) {
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
        
        if ([data length] > 0 && error == nil) {
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if ([JSONValue isKindOfClass:[NSDictionary class]]) {
                ProfileClass *profileClass = [[ProfileClass alloc]init];
                
                int userId = [[JSONValue objectForKey:@"id"]intValue];
                profileClass.userId = [NSString stringWithFormat:@"%d", userId];
                profileClass.gender = [JSONValue objectForKey:@"gender"];
                profileClass.userName = [JSONValue objectForKey:@"full_name"];
                profileClass.event_count = [JSONValue objectForKey:@"event_count"];
                if ([JSONValue objectForKey:@"bio"] == [NSNull null]) {
                    profileClass.bio = @"";
                } else {
                    profileClass.bio = [JSONValue objectForKey:@"bio"];
                }
                if ([[JSONValue objectForKey:@"phone_number"] isEqualToString:@""]) {
                    profileClass.phoneNumber = @"";
                } else {
                    profileClass.phoneNumber = [JSONValue objectForKey:@"phone_number"];
                    if (userId == GetUserID) {
                        SetUserPhone([JSONValue objectForKey:@"phone_number"]);
                    }
                }
                BOOL isPrivate = [[JSONValue objectForKey:@"viewer_can_see"]boolValue];
                profileClass.isPrivate = isPrivate;
                if ([JSONValue objectForKey:@"profile_pic"] == [NSNull null]) {
                    profileClass.userProfilePicture = @"";
                } else {
                    profileClass.userProfilePicture = [JSONValue objectForKey:@"profile_pic"];
                    if (userId == GetUserID) {
                        SetUserProPic(profileClass.userProfilePicture);
                    }
                }
                
                // Photos
                if (!([JSONValue objectForKey:@"photos"] == [NSNull null])) {
                    if (arrUserImages.count > 0) {
                        [arrUserImages removeAllObjects];
                    }

                    NSMutableArray *arrPhotos = [JSONValue objectForKey:@"photos"];
    
                    for (int i = 0; i < arrPhotos.count; i++) {
                        NSMutableDictionary *dictPhotoInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictPhotoDetail = [arrPhotos objectAtIndex:i];
                        
                        if ([dictPhotoDetail objectForKey:@"id"] == [NSNull null]) {
                            [dictPhotoInfo setObject:@"" forKey:@"photo__id"];
                        } else {
                            [dictPhotoInfo setValue:[dictPhotoDetail objectForKey:@"id"] forKey:@"photo__id"];
                        }
                        
                        if ([dictPhotoDetail objectForKey:@"user"] == [NSNull null]) {
                            [dictPhotoInfo setObject:@"" forKey:@"user__full_name"];
                        } else {
                            [dictPhotoInfo setValue:[dictPhotoDetail objectForKey:@"user"] forKey:@"user__full_name"];
                        }
                        
                        if ([dictPhotoDetail objectForKey:@"user_url"] == [NSNull null]) {
                            [dictPhotoInfo setObject:@"" forKey:@"user__url"];
                        } else {
                            [dictPhotoInfo setValue:[dictPhotoDetail objectForKey:@"user_url"] forKey:@"user__url"];
                        }
                        
                        if ([dictPhotoDetail objectForKey:@"photo"] == [NSNull null]) {
                            [dictPhotoInfo setObject:@"" forKey:@"photo"];
                        } else {
                            [dictPhotoInfo setValue:[dictPhotoDetail objectForKey:@"photo"] forKey:@"photo"];
                        }
                        
                        [arrUserImages addObject:dictPhotoInfo];
                    }
                }
                
                // Event images
                if (arrEventImages.count > 0) {
                    [arrEventImages removeAllObjects];
                }
                if ([JSONValue objectForKey:@"event_images"] != [NSNull null]) {
                    NSMutableArray *arrEvents = [JSONValue objectForKey:@"event_images"];
                    
                    for (int k = 0; k < arrEvents.count; k++) {
                        NSMutableDictionary *dictEventInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictEventDetail = [arrEvents objectAtIndex:k];
                        
                        if ([[dictEventDetail objectForKey:@"image"] isEqualToString:@""]) {
                            [dictEventInfo setObject:@"" forKey:@"event__image"];
                        } else {
                            [dictEventInfo setValue:[dictEventDetail objectForKey:@"image"] forKey:@"event__image"];
                        }
                        
                        int partyId = [[dictEventDetail objectForKey:@"id"]intValue];
                        [dictEventInfo setValue:[NSString stringWithFormat:@"%d", partyId] forKey:@"event__id"];
                        
                        [arrEventImages addObject:dictEventInfo];
                    }
                }
                
                // Followers
                if ([JSONValue objectForKey:@"follower"] == [NSNull null]) {
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
                    
                    for (int i = 0; i < arrFollower.count; i++) {
                        NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrFollower objectAtIndex:i];
                        
                        if ([dictUserDetail objectForKey:@"user__profile_pic"] == [NSNull null]) {
                            [dictFollowerInfo setObject:@"" forKey:@"user__profile_pic"];
                        } else {
                            [dictFollowerInfo setValue:[dictUserDetail objectForKey:@"user__profile_pic"] forKey:@"user__profile_pic"];
                        }
                        
                        if ([dictUserDetail objectForKey:@"user__full_name"] == [NSNull null]) {
                            [dictFollowerInfo setObject:@"" forKey:@"user__full_name"];
                        } else {
                            [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__full_name"] forKey:@"user__full_name"];
                        }
                        
                        if ([dictUserDetail objectForKey:@"user__id"] == [NSNull null]) {
                            [dictFollowerInfo setObject:@"" forKey:@"user__id"];
                        } else {
                            [dictFollowerInfo setObject:[NSString stringWithFormat:@"%@",[dictUserDetail objectForKey:@"user__id"]] forKey:@"user__id"];
                        }
                        
                        [profileClass.arrfollowers addObject:dictFollowerInfo];
                    }
                    if (userId == GetUserID) {
                        if (appDelegate.arrFollowing.count > 0) {
                            [appDelegate.arrFollowing removeAllObjects];
                        }
                    }
                    for (int j = 0; j < arrFollowing.count; j++) {
                        NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrFollowing objectAtIndex:j];
                        
                        if ([dictUserDetail objectForKey:@"user__profile_pic"] == [NSNull null]) {
                            [dictFollowerInfo setObject:@"" forKey:@"user__profile_pic"];
                        } else {
                            [dictFollowerInfo setValue:[dictUserDetail objectForKey:@"user__profile_pic"] forKey:@"user__profile_pic"];
                        }
                        if ([dictUserDetail objectForKey:@"user__full_name"] == [NSNull null]) {
                            [dictFollowerInfo setObject:@"" forKey:@"user__full_name"];
                        } else {
                            [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__full_name"] forKey:@"user__full_name"];
                        }
                        
                        if ([dictUserDetail objectForKey:@"user__id"] == [NSNull null]) {
                            [dictFollowerInfo setObject:@"" forKey:@"user__id"];
                        } else {
                            [dictFollowerInfo setObject:[NSString stringWithFormat:@"%@",[dictUserDetail objectForKey:@"user__id"]] forKey:@"user__id"];
                        }
                        
                        NSString *fullName = [dictFollowerInfo objectForKey:@"user__full_name"];
                        [dictFollowerInfo setValue:fullName forKey:@"user__full_name"];
                        
                        if (userId == GetUserID) {
                            [appDelegate.arrFollowing addObject:dictFollowerInfo];
                        }
                        
                        [profileClass.arrfollowings addObject:dictFollowerInfo];
                    }
                }
                
                [dictProfileInformation setObject:profileClass forKey:@"ProfileInfo"];
                [self showProfileInfo:refreshed];
            }
        } else {
            showServerError();
        }
        [self setBusy:NO];
    }];
}

-(void)showProfileInfo:(BOOL)refreshed {
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    _profileName.text = profileClass.userName;
    _eventCount.text = profileClass.event_count;
    _followerCount.text = profileClass.followers_count;
    _followingCount.text = profileClass.following_count;
    _profileBio.text = profileClass.bio;
    
    [_profilePicture loadImageFromURL:profileClass.userProfilePicture withTempImage:@"avatar_icon"];
    viewer_can_see = profileClass.isPrivate;
    
    if ([_profileBio.text isEqualToString:@""]) {
        _profileBio.text = @"Bio";
        _profileBio.textColor = [UIColor grayColor];
    }
    
    if ([profileClass.phoneNumber isEqualToString:@""] || profileClass.phoneNumber == NULL) {
        [_verifyBtn setImage:[UIImage imageNamed:@"unverified_icon"] forState:UIControlStateNormal];
        _verifyLabel.text = @"unverified";
    } else {
        [_verifyBtn setImage:[UIImage imageNamed:@"verified_icon"] forState:UIControlStateNormal];
        _verifyLabel.text = @"verified";
    }
    
    if (viewer_can_see == 1) {
        _lockIcon.hidden = YES;
        _imagePager.hidden = NO;
        _userImageNewBtn.hidden = NO;
        _collectionVW.hidden = YES;
    } else {
        _lockIcon.hidden = NO;
        _imagePager.hidden = YES;
        _userImageNewBtn.hidden = YES;
        _collectionVW.hidden = YES;
    }
    
    if (![[appDelegate.arrFollowing valueForKey:@"user__full_name"] containsObject:_profileName.text]) {
        [_followBtn setImage:[UIImage imageNamed:@"plus_sign_icon"] forState:UIControlStateNormal];
        
        if (![_profileName.text isEqualToString:GetUserName]) {
            _followLabel.text = @"follow";
        }
    } else {
        [_followBtn setImage:[UIImage imageNamed:@"checkmark_icon"] forState:UIControlStateNormal];
        
        if (![_profileName.text isEqualToString:GetUserName]) {
            _followLabel.text = @"following";
        }
    }
    
    if (refreshed == NO) {
        [_userImagesBtn setTitleColor:[UIColor colorWithRed:(171/255.0) green:(14/255.0) blue:(27/255.0) alpha:1.0] forState:UIControlStateNormal];
        CALayer *border = [CALayer layer];
        border.backgroundColor = [[UIColor colorWithRed:(171/255.0) green:(14/255.0) blue:(27/255.0) alpha:1.0] CGColor];
        border.frame = CGRectMake(0, 30, _userImagesBtn.frame.size.width, 2);
        [_userImagesBtn.layer addSublayer:border];
        
        CALayer *border2 = [CALayer layer];
        border2.frame = CGRectMake(0, 0, 0, 0);
        [_eventImagesBtn.layer addSublayer:border2];
    }
    
    [self arrayWithImages:_imagePager];
    [_imagePager reloadData];
    
    if (![_profileName.text isEqualToString:GetUserName]){
        _userImageNewBtn.hidden = YES;
        _userImageDeleteBtn.hidden = YES;
        _followBtn.hidden = NO;
        _followLabel.hidden = NO;
    }

    [refreshControl endRefreshing];
    [_collectionVW reloadData];
    
    if (arrUserImages.count > 0){
        _userImageId = [[arrUserImages objectAtIndex:_imagePager.currentPage] valueForKey:@"photo__id"];
        
        if ([_profileName.text isEqualToString:GetUserName]){
            _userImageDeleteBtn.hidden = NO;
        }
    }
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSettings:(id)sender {
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

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure you want to block this user?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        alert.delegate = self;
        alert.tag = 100;
        [alert show];
    } else if(buttonIndex == 1) {
        // NSLog(@"Cancel button clicked");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
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

#pragma mark - Add Image

- (IBAction)onProfilePictureChange:(id)sender {
    if ([_profileName.text isEqualToString:GetUserName]){
        [self requestAuthorizationWithRedirectionToSettings];
        imagePickerLabel = @"profile_picture";
    }
}

- (void)requestAuthorizationWithRedirectionToSettings {
    dispatch_async(dispatch_get_main_queue(), ^{
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized) {
            // We have permission
            [self handleChangingImage];
        } else {
            // No permission. Trying to normally request it
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status != PHAuthorizationStatusAuthorized) {
                    // User doesn't give us permission. Showing alert with redirection to settings
                    // Getting description string from info.plist file
                    NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:@"To give permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    [alertController addAction:settingsAction];
                    
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
                }
            }];
        }
    });
}

- (void)handleChangingImage {
    NSString *controller_title;
    
    if ([imagePickerLabel isEqualToString:@"profile_picture"]) {
        controller_title = @"Profile Picture";
    } else {
        controller_title = @"User Image";
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:controller_title message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takeAPicture = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:NULL];
        } else {
            return;
        }
    }];
    
    UIAlertAction *pickFromGallery = [UIAlertAction actionWithTitle:@"Choose a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.editing = NO;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:NULL];
        } else {
            return;
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        // Do something on cancel
    }];
    
    [alertController addAction:pickFromGallery];
    [alertController addAction:takeAPicture];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info {
    
    [self setBusy:YES];
    
    if ([imagePickerLabel isEqualToString:@"profile_picture"]) {
        _profilePicture.image = image;
    }
    checkNetworkReachability();
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    
    NSString *myUniqueName = [NSString stringWithFormat:@"%@-%lu", @"image", (unsigned long)([[NSDate date] timeIntervalSince1970]*10.0)];
    
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:_profileName.text forKey:@"full_name"];
    [_params setObject:GetUserEmail forKey:@"email"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString *FileParamConstant;
    if ([imagePickerLabel isEqualToString:@"profile_picture"]) {
        FileParamConstant = @"profile_pic";
    } else {
        FileParamConstant = @"photo";
    }
    
    NSString *webUrl;
    if ([imagePickerLabel isEqualToString:@"profile_picture"]) {
        webUrl = [NSString stringWithFormat:@"%@%@/", PROFILEURL, profileClass.userId];
    } else {
        webUrl = PHOTOUPLOAD;
    }
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSString *urlStr = [NSString stringWithFormat:@"%@", webUrl];
    NSURL *requestURL = [NSURL URLWithString:urlStr];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];

    NSString *method;
    if ([imagePickerLabel isEqualToString:@"profile_picture"]) {
        method = @"PUT";
    } else {
        method = @"POST";
    }
    [request setHTTPMethod:method];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData;
    if ([imagePickerLabel isEqualToString:@"profile_picture"]) {
        imageData = UIImageJPEGRepresentation(_profilePicture.image, 1.0);
    } else {
        imageData = UIImageJPEGRepresentation(image, 1.0);
    }
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", FileParamConstant, myUniqueName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:requestURL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if ([data length] > 0 && error == nil) {
            [self setBusy:NO];
            
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            if ([JSONValue isKindOfClass:[NSDictionary class]]) {
                
                if ([JSONValue objectForKey:@"profile_pic"]) {
                    NSString *profilePic;
                    if([JSONValue objectForKey:@"profile_pic"] == [NSNull null]){
                        profilePic = @"";
                    } else {
                        profilePic = [JSONValue objectForKey:@"profile_pic"];
                    }
                    SetUserProPic(profilePic);
                    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Success"
                                                                   description:@"Your profile picture has been updated."
                                                                          type:TWMessageBarMessageTypeSuccess
                                                                      duration:3.0];
                }
                else if ([JSONValue objectForKey:@"photo"]) {
                    NSMutableDictionary *dictPhotoInfo = [[NSMutableDictionary alloc]init];
                    [dictPhotoInfo setValue:[JSONValue objectForKey:@"photo"] forKey:@"photo"];
                    [arrUserImages addObject:dictPhotoInfo];
                    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Success"
                                                                   description:@"Your photo has been uploaded."
                                                                          type:TWMessageBarMessageTypeSuccess
                                                                      duration:3.0];
                    [_imagePager reloadData];
                }
            }
        } else {
            showServerError();
        }
    }];
    [self setBusy:NO];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Text Field

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    if ([_profileName.text isEqualToString:GetUserName]) {
        return YES;
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField:textField up:NO];
}

- (void)animateTextField:(UITextField*)textField up: (BOOL)up {
    float val;
    
    if (self.view.frame.size.height == 480) {
        val = 0.50;
    } else {
        val = 0.50;
    }
    
    const int movementDistance = val * textField.frame.origin.y;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_profileBio resignFirstResponder];
    [_profileName resignFirstResponder];
    [self updateBio];
    return YES;
}

#pragma mark - Text View

- (void)animateTextView:(UITextView*)textView up: (BOOL) up{
    float val;
    
    if (self.view.frame.size.height == 480) {
        val = 0.50;
    } else {
        val = 0.50;
    }
    
    const int movementDistance = val * textView.frame.origin.y;
    
    // tweak as needed
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}

-(BOOL)textViewShouldBeginEditing:(UITextView*)textView {
    if ([_profileName.text isEqualToString:GetUserName]) {
        return YES;
    }
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        [_profileName resignFirstResponder];
        [self updateBio];
        return NO;
    }
    
    NSUInteger length = [textView.text length] - range.length + [text length];
    if(textView == _profileBio){
        return length <= 200 ;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [self animateTextView:textView up: YES];
    
    if ([_profileBio.text isEqualToString:@"Bio"]) {
        _profileBio.text = @"";
        _profileBio.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self animateTextView:textView up: NO];
    
    if ([_profileBio.text isEqualToString:@""]) {
        _profileBio.text = @"Bio";
        _profileBio.textColor = [UIColor grayColor];
    }
}

#pragma mark - Bio Update

- (void)updateBio {
    checkNetworkReachability();
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    
    NSString *params = [NSString stringWithFormat:@"full_name=%@&email=%@&bio=%@", _profileName.text, GetUserEmail, _profileBio.text];
    
    NSMutableData *bodyData = [[NSMutableData alloc] initWithData:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@/", PROFILEURL, profileClass.userId];
    NSURL *requestURL = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:requestURL];
    [urlRequest setTimeoutInterval:60];
    [urlRequest setHTTPMethod:@"PUT"];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [urlRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
    [urlRequest setHTTPBody:bodyData];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if ([data length] > 0 && error == nil) {
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if (JSONValue != nil) {
                SetUserName(_profileName.text);
                alert.showAnimationType = SlideInFromLeft;
                alert.hideAnimationType = SlideOutToBottom;
                [alert showNotice:self title:@"Notice" subTitle:@"Your profile has been updated." closeButtonTitle:@"OK" duration:0.0f];
            }
        } else {
            showServerError();
        }
        [self setBusy:NO];
    }];
}

- (IBAction)onEvents:(id)sender {
    if (viewer_can_see == 1) {
        EventsViewController *eventsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsViewController"];
        ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
        eventsViewController.userId = profileClass.userId;
        [self.navigationController pushViewController:eventsViewController animated:YES];
    }
}

- (IBAction)onViewList:(id)sender {
    if (viewer_can_see == 1) {
        FollowViewController *followViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowViewController"];
        
        ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
        
        if ([sender tag] == 1) {
            if ([_followerCount.text isEqualToString:@"0"]) {
                return;
            }
            followViewController.pageTitle = @"Followers";
            followViewController.arrDetails = profileClass.arrfollowers.mutableCopy;
        } else {
            if ([_followingCount.text isEqualToString:@"0"]) {
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
    
    [appDelegate showHUDAddedToView:self.view message:@""];
    
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
            
            if (JSONValue != nil) {
                
                if ([[JSONValue allKeys]count] > 1) {
                    
                    if ([[appDelegate.arrFollowing valueForKey:@"user__full_name"] containsObject:profileClass.userName]) {
                        
                        for (int i = 0; i < appDelegate.arrFollowing.count; i++) {
                            
                            if ([[[appDelegate.arrFollowing objectAtIndex:i] valueForKey:@"user__full_name"] isEqualToString:profileClass.userName]) {
                                [appDelegate.arrFollowing removeObjectAtIndex:i];
                            }
                        }
                        [_followBtn setImage:[UIImage imageNamed:@"plus_sign_icon"] forState:UIControlStateNormal];
                        _followLabel.text = @"follow";
                    } else {
                        NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                        [dictFollowerInfo setObject:profileClass.userName forKey:@"user__full_name"];
                        [dictFollowerInfo setObject:profileClass.userId forKey:@"user__id"];
                        [dictFollowerInfo setObject:profileClass.userProfilePicture forKey:@"user__profile_pic"];
                        [appDelegate.arrFollowing addObject:dictFollowerInfo];
                        [_followBtn setImage:[UIImage imageNamed:@"checkmark_icon"] forState:UIControlStateNormal];
                        _followLabel.text = @"following";
                    }
                }
            }
        } else {
            showServerError();
        }
        [appDelegate hideHUDForView2:self.view];
        [self setBusy:NO];
    }];
}

- (IBAction)onVerify:(id)sender {
    if ((GetUserPhone) || !([GetUserName isEqualToString:_profileName.text])) {
        return;
    } else {
        PhoneViewController *phoneViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhoneViewController"];
        ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
        phoneViewController.profileName = _profileName.text;
        phoneViewController.profileId = profileClass.userId;
        [self.navigationController pushViewController:phoneViewController animated:YES];
    }
}

- (IBAction)onEventImages:(id)sender {
    [_eventImagesBtn setTitleColor:[UIColor colorWithRed:(171/255.0) green:(14/255.0) blue:(27/255.0) alpha:1.0] forState:UIControlStateNormal];
    [_userImagesBtn setTitleColor:[UIColor colorWithRed:(41/255.0) green:(46/255.0) blue:(50/255.0) alpha:1.0] forState:UIControlStateNormal];

    if ([_eventImagesBtn.layer.sublayers count] > 1) {
        [[_eventImagesBtn.layer.sublayers objectAtIndex:1] removeFromSuperlayer];
        CALayer *border = [CALayer layer];
        border.backgroundColor = [[UIColor colorWithRed:(171/255.0) green:(14/255.0) blue:(27/255.0) alpha:1.0] CGColor];
        border.frame = CGRectMake(0, 30, _eventImagesBtn.frame.size.width, 2);
        [_eventImagesBtn.layer addSublayer:border];
    }
    if ([_userImagesBtn.layer.sublayers count] > 1) {
        [[_userImagesBtn.layer.sublayers objectAtIndex:1] removeFromSuperlayer];
        CALayer *border2 = [CALayer layer];
        border2.frame = CGRectMake(0, 0, 0, 0);
        [_userImagesBtn.layer addSublayer:border2];
    }
    _imagePager.hidden = YES;
    _userImageNewBtn.hidden = YES;
    _userImageDeleteBtn.hidden = YES;
    _collectionVW.hidden = NO;
}

- (IBAction)onUserImages:(id)sender {
    [_userImagesBtn setTitleColor:[UIColor colorWithRed:(171/255.0) green:(14/255.0) blue:(27/255.0) alpha:1.0] forState:UIControlStateNormal];
    [_eventImagesBtn setTitleColor:[UIColor colorWithRed:(41/255.0) green:(46/255.0) blue:(50/255.0) alpha:1.0] forState:UIControlStateNormal];
    
    if ([_userImagesBtn.layer.sublayers count] > 1) {
        [[_userImagesBtn.layer.sublayers objectAtIndex:1] removeFromSuperlayer];
        CALayer *border = [CALayer layer];
        border.backgroundColor = [[UIColor colorWithRed:(171/255.0) green:(14/255.0) blue:(27/255.0) alpha:1.0] CGColor];
        border.frame = CGRectMake(0, 30, _userImagesBtn.frame.size.width, 2);
        [_userImagesBtn.layer addSublayer:border];
    }
    if ([_eventImagesBtn.layer.sublayers count] > 1) {
        [[_eventImagesBtn.layer.sublayers objectAtIndex:1] removeFromSuperlayer];
        CALayer *border2 = [CALayer layer];
        border2.frame = CGRectMake(0, 0, 0, 0);
        [_eventImagesBtn.layer addSublayer:border2];
    }
    _imagePager.hidden = NO;
    if ([_profileName.text isEqualToString:GetUserName]) {
        _userImageNewBtn.hidden = NO;
        _userImageDeleteBtn.hidden = NO;
    } else {
        _userImageNewBtn.hidden = YES;
        _userImageDeleteBtn.hidden = YES;
    }
    _collectionVW.hidden = YES;
}

- (IBAction)onAddNewPhoto:(id)sender {
    [self requestAuthorizationWithRedirectionToSettings];
    imagePickerLabel = @"user_image";
}

#pragma mark - KIImagePager DataSource

- (NSArray *)arrayWithImages:(KIImagePager*)pager {
    return [arrUserImages valueForKey:@"photo"];
}

- (UIViewContentMode)contentModeForImage:(NSUInteger)image inPager:(KIImagePager *)pager {
    return UIViewContentModeScaleAspectFill;
}

#pragma mark - KIImagePager Delegate

- (void)imagePager:(KIImagePager *)imagePager didScrollToIndex:(NSUInteger)index {
    // NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
    _userImageId = [[arrUserImages objectAtIndex:index] valueForKey:@"photo__id"];
}

- (void)imagePager:(KIImagePager *)imagePager didSelectImageAtIndex:(NSUInteger)index {
    // NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
}

- (IBAction)onDeleteUserImage:(id)sender {
    if ([_profileName.text isEqualToString:GetUserName]) {
       SCLAlertView *alert = [[SCLAlertView alloc] init];

        [alert addButton:@"Delete" actionBlock:^(void) {
            checkNetworkReachability();
            [self.view endEditing:YES];
            [self setBusy:YES];

            SCLAlertView *alert2 = [[SCLAlertView alloc] init];

            NSString *params = [NSString stringWithFormat:@"full_name=%@&email=%@", _profileName.text, GetUserEmail];

            NSMutableData *bodyData = [[NSMutableData alloc] initWithData:[params dataUsingEncoding:NSUTF8StringEncoding]];
            NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
            NSString *urlStr = [NSString stringWithFormat:@"%@%@/", PHOTODELETE, _userImageId];
            NSURL *requestURL = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:requestURL];
            [urlRequest setTimeoutInterval:60];
            [urlRequest setHTTPMethod:@"DELETE"];
            NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
            NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
            NSString *base64String = [plainData base64EncodedStringWithOptions:0];
            NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
            [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
            [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            [urlRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
            [urlRequest setHTTPBody:bodyData];

            [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){

                if ([data length] > 0 && error == nil) {
                    NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

                    if (JSONValue != nil) {
                        alert2.showAnimationType = SlideInFromLeft;
                        alert2.hideAnimationType = SlideOutToBottom;
                        [alert2 showNotice:self title:@"Notice" subTitle:@"Your photo has been deleted." closeButtonTitle:@"OK" duration:0.0f];

                        [arrUserImages removeObjectAtIndex:_imagePager.currentPage];
                        [_imagePager reloadData];
                    }
                } else {
                    showServerError();
                }
                [self setBusy:NO];
            }];
        }];
        [alert showWarning:self title:@"Delete Photo" subTitle:@"Are you sure you want to delete this photo?" closeButtonTitle:@"Cancel" duration:0.0f];
    }
}

#pragma mark - CollectionView

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [arrEventImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCellImage *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PartyImageCell" forIndexPath:indexPath];
    NSString *imageUrl = [[arrEventImages objectAtIndex:indexPath.row] valueForKey:@"event__image"];
    [cell.partyPicture loadImageFromURL:imageUrl withTempImage:@"balloons_icon"];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PartyViewController *partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];
    partyViewController.partyUrl = [NSString stringWithFormat:@"%@%@/", PARTYURL, [[arrEventImages objectAtIndex:indexPath.row] valueForKey:@"event__id"]];
    [self.navigationController pushViewController:partyViewController animated:YES];
}

@end
