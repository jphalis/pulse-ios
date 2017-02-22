//
//  PartyViewController.m
//  Pulse
//


#import "AccountViewController.h"
#import "AppDelegate.h"
#import "defs.h"
#import "FollowViewController.h"
#import "GlobalFunctions.h"
#import "PartyViewController.h"
#import "RequestsViewController.h"
#import "SCLAlertView.h"
#import "TWMessageBarManager.h"
#import "UIViewControllerAdditions.h"


#define DEFAULT_BTN_TEXT @"Will you be there?"
#define ATTENDING_BTN_TEXT @"Going!"
#define REQUEST_BTN_TEXT @"Request invite!"
#define REQUESTED_BTN_TEXT @"Requested"
#define INVITE_ONLY_BTN_TEXT @"Invite only event"


@interface PartyViewController () {
    AppDelegate *appDelegate;
}

@end

@implementation PartyViewController

@synthesize usersAttending, usersRequested, usersInvited, usersLiked;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
    
    // Go back when swipe right
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated {
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    if (_partyUrl == NULL || [_partyUrl isEqualToString:@""]) {
        [self showPartyInfo];
    } else {
        [self getPartyDetails];
    }
    
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Functions

-(void)getPartyDetails {
    checkNetworkReachability();

    NSString *urlString = [NSString stringWithFormat:@"%@", _partyUrl];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {

        if ([data length] > 0 && error == nil) {
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]]) {
                int partyId = [[JSONValue valueForKey:@"id"]intValue];
                _partyId = [NSString stringWithFormat:@"%d", partyId];
                _partyCreator = [JSONValue valueForKey:@"user"];
                _creatorUrl = [JSONValue valueForKey:@"user_url"];
                _partyType = [JSONValue valueForKey:@"party_type"];
                _partyInvite = [JSONValue valueForKey:@"invite_type"];
                _partyName = [JSONValue valueForKey:@"name"];
                _partyAddress = [JSONValue valueForKey:@"location"];
                _partySize = [JSONValue valueForKey:@"party_size"];
                int partyMonth = [[JSONValue valueForKey:@"party_month"]intValue];
                _partyMonth = [NSString stringWithFormat:@"%d", partyMonth];
                int partyDay = [[JSONValue valueForKey:@"party_day"]intValue];
                _partyDay = [NSString stringWithFormat:@"%d", partyDay];
                int partyYear = [[JSONValue valueForKey:@"party_year"]intValue];
                _partyYear = [NSString stringWithFormat:@"%d", partyYear];
                _partyStartTime = [JSONValue valueForKey:@"start_time"];
                if ([JSONValue valueForKey:@"end_time"] != [NSNull null]){
                    _partyEndTime = [JSONValue valueForKey:@"end_time"];
                } else {
                    _partyEndTime = @"?";
                }
                if ([JSONValue valueForKey:@"image"] == [NSNull null]) {
                    _partyImage = @"";
                } else {
                    _partyImage = [JSONValue valueForKey:@"image"];
                }
                _partyDescription = [JSONValue valueForKey:@"description"];
                _partyAttending = [NSString abbreviateNumber:[[JSONValue valueForKey:@"attendees_count"]intValue]];
                _partyRequests = [NSString abbreviateNumber:[[JSONValue valueForKey:@"requesters_count"]intValue]];

                if (!([JSONValue valueForKey:@"get_attendees_info"] == [NSNull null])) {
                    NSMutableArray *arrAttendee = [JSONValue valueForKey:@"get_attendees_info"];
                    usersAttending = [[NSMutableArray alloc]init];
                    
                    for(int i = 0; i < arrAttendee.count; i++) {
                        NSMutableDictionary *dictAttendeeInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrAttendee objectAtIndex:i];
                        
                        if([dictUserDetail objectForKey:@"profile_pic"] == [NSNull null]){
                            [dictAttendeeInfo setObject:@"" forKey:@"user__profile_pic"];
                        } else {
                            [dictAttendeeInfo setValue:[dictUserDetail objectForKey:@"profile_pic"] forKey:@"user__profile_pic"];
                        }
                        
                        if([dictUserDetail objectForKey:@"id"] == [NSNull null]) {
                            [dictAttendeeInfo setObject:@"" forKey:@"user__id"];
                        } else {
                            [dictAttendeeInfo setObject:[NSString stringWithFormat:@"%@",[dictUserDetail objectForKey:@"id"]] forKey:@"user__id"];
                        }
                        
                        if([dictUserDetail objectForKey:@"full_name"] == [NSNull null]) {
                            [dictAttendeeInfo setObject:@"" forKey:@"user__full_name"];
                        } else {
                            [dictAttendeeInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                        }
                        
                        [usersAttending addObject:dictAttendeeInfo];
                    }
                }

                if (!([JSONValue valueForKey:@"get_requesters_info"] == [NSNull null])) {
                    NSMutableArray *arrRequester = [JSONValue valueForKey:@"get_requesters_info"];
                    usersRequested = [[NSMutableArray alloc]init];
                    
                    for(int i = 0; i < arrRequester.count; i++) {
                        NSMutableDictionary *dictRequesterInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrRequester objectAtIndex:i];
                        
                        if([dictUserDetail objectForKey:@"profile_pic"] == [NSNull null]) {
                            [dictRequesterInfo setObject:@"" forKey:@"user__profile_pic"];
                        } else {
                            [dictRequesterInfo setValue:[dictUserDetail objectForKey:@"profile_pic"] forKey:@"user__profile_pic"];
                        }
                        
                        if([dictUserDetail objectForKey:@"id"] == [NSNull null]) {
                            [dictRequesterInfo setObject:@"" forKey:@"user__id"];
                        } else {
                            [dictRequesterInfo setObject:[NSString stringWithFormat:@"%@", [dictUserDetail objectForKey:@"id"]] forKey:@"user__id"];
                        }
                        
                        if([dictUserDetail objectForKey:@"full_name"] == [NSNull null]) {
                            [dictRequesterInfo setObject:@"" forKey:@"user__full_name"];
                        } else {
                            [dictRequesterInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                        }
                        
                        [usersRequested addObject:dictRequesterInfo];
                    }
                }
                
                if (!([JSONValue valueForKey:@"get_invited_users_info"] == [NSNull null])) {
                    NSMutableArray *arrInvited = [JSONValue valueForKey:@"get_invited_users_info"];
                    usersInvited = [[NSMutableArray alloc]init];
                    
                    for(int i = 0; i < arrInvited.count; i++) {
                        NSMutableDictionary *dictInvitedInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrInvited objectAtIndex:i];
                        
                        if([dictUserDetail objectForKey:@"profile_pic"] == [NSNull null]) {
                            [dictInvitedInfo setObject:@"" forKey:@"user__profile_pic"];
                        } else {
                            [dictInvitedInfo setValue:[dictUserDetail objectForKey:@"profile_pic"] forKey:@"user__profile_pic"];
                        }
                        
                        if([dictUserDetail objectForKey:@"id"] == [NSNull null]) {
                            [dictInvitedInfo setObject:@"" forKey:@"user__id"];
                        } else {
                            [dictInvitedInfo setObject:[NSString stringWithFormat:@"%@", [dictUserDetail objectForKey:@"id"]] forKey:@"user__id"];
                        }
                        
                        if([dictUserDetail objectForKey:@"full_name"] == [NSNull null]) {
                            [dictInvitedInfo setObject:@"" forKey:@"user__full_name"];
                        } else {
                            [dictInvitedInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                        }
                        
                        [usersInvited addObject:dictInvitedInfo];
                    }
                }
                
                if (!([JSONValue valueForKey:@"get_likers_info"] == [NSNull null])) {
                    NSMutableArray *arrLiked = [JSONValue valueForKey:@"get_likers_info"];
                    usersLiked = [[NSMutableArray alloc]init];
                    
                    for(int i = 0; i < arrLiked.count; i++) {
                        NSMutableDictionary *dictLikerInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrLiked objectAtIndex:i];
                        
                        if([dictUserDetail objectForKey:@"id"] == [NSNull null]) {
                            [dictLikerInfo setObject:@"" forKey:@"user__id"];
                        } else {
                            [dictLikerInfo setObject:[NSString stringWithFormat:@"%@", [dictUserDetail objectForKey:@"id"]] forKey:@"user__id"];
                        }
                        
                        if([dictUserDetail objectForKey:@"full_name"] == [NSNull null]) {
                            [dictLikerInfo setObject:@"" forKey:@"user__full_name"];
                        } else {
                            [dictLikerInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                        }
                        
                        [usersLiked addObject:dictLikerInfo];
                    }
                }

                [self showPartyInfo];
            }
        } else {
            showServerError();
        }
    }];
}

-(void)showPartyInfo {
    if ([_partyType isEqualToString:@"Custom"]) {
        [_partyImageField loadImageFromURL:_partyImage withTempImage:@"custom_icon"];
    }
    else if ([_partyType isEqualToString:@"Social"]) {
        [_partyImageField loadImageFromURL:_partyImage withTempImage:@"social_icon"];
    }
    else if ([_partyType isEqualToString:@"Holiday"]) {
        [_partyImageField loadImageFromURL:_partyImage withTempImage:@"holiday_icon"];
    }
    else if ([_partyType isEqualToString:@"Event"]) {
        [_partyImageField loadImageFromURL:_partyImage withTempImage:@"event_icon"];
    }
    else if ([_partyType isEqualToString:@"Rager"]) {
        [_partyImageField loadImageFromURL:_partyImage withTempImage:@"rager_icon"];
    }
    else if ([_partyType isEqualToString:@"Themed"]) {
        [_partyImageField loadImageFromURL:_partyImage withTempImage:@"themed_icon"];
    }
    else if ([_partyType isEqualToString:@"Celebration"]) {
        [_partyImageField loadImageFromURL:_partyImage withTempImage:@"celebration_icon"];
    }
    
    _partyImageField.layer.borderWidth = 4;
    _partyImageField.layer.borderColor = [[UIColor whiteColor] CGColor];
    _partyImageField.layer.cornerRadius = 10;
    _partyImageField.layer.masksToBounds = YES;
    
    if ([_partyInvite isEqualToString:@"Open"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"open_icon"]];
    }
    else if ([_partyInvite isEqualToString:@"Invite only"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"invite_only_icon"]];
    }
    else if ([_partyInvite isEqualToString:@"Request + approval"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"request_icon"]];
    }
    
    NSInteger monthNumber = [_partyMonth integerValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *monthName = [[dateFormatter monthSymbols] objectAtIndex:(monthNumber-1)];
    _partyDateTimeField.text = [NSString stringWithFormat:@"%@ %@, %@  %@-%@", monthName, _partyDay, _partyYear, _partyStartTime, _partyEndTime];
    
    _partyNameField.text = _partyName;
    _partyAddressField.text = _partyAddress;
    _partyAttendingField.text = _partyAttending;
    _partyRequestsField.text = _partyRequests;
    _partyDescriptionField.text = _partyDescription;
    
    if ([[usersLiked valueForKey:@"user__full_name"] containsObject:GetUserName]) {
        [_likeImg setImage:[UIImage imageNamed:@"like_icon_active"]];
        _likeCountLabel.textColor = [UIColor whiteColor];
    }
    _likeCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[usersLiked count]];
    
    // compare party end date with today
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"MM-dd-yyyy"];
    NSDate *partyEndDate = [dateFormatter2 dateFromString:[NSString stringWithFormat:@"%@-%@-%@", _partyMonth, _partyDay, _partyYear]];
    NSDate *today = [[NSDate alloc] init];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    NSDateComponents *date1Components = [calendar components:comps
                                                    fromDate: partyEndDate];
    NSDateComponents *date2Components = [calendar components:comps
                                                    fromDate: today];
    partyEndDate = [calendar dateFromComponents:date1Components];
    today = [calendar dateFromComponents:date2Components];
    
    // party has ended
    if ([partyEndDate compare: today] == NSOrderedAscending) {
        [_attendBtn setTitle:@"Event expired" forState:UIControlStateNormal];
        _attendBtn.backgroundColor = [UIColor lightGrayColor];
        _attendBtn.userInteractionEnabled = NO;
    }
    // viewing user is attending party
    else if ([[usersAttending valueForKey:@"user__full_name"] containsObject:GetUserName]) {
        [_attendBtn setTitle:ATTENDING_BTN_TEXT forState:UIControlStateNormal];
        _attendBtn.backgroundColor = [UIColor colorWithRed:59/255.0 green:199/255.0 blue:114/255.0 alpha:1.0];
        _attendBtn.userInteractionEnabled = NO;
    }
    // party is invite only and viewing user is not on list
    else if ([_partyInvite isEqualToString:@"Invite only"] &&
             (!([_partyCreator isEqualToString:GetUserName])) &&
             (!([[usersInvited valueForKey:@"user__full_name"] containsObject:GetUserName]))) {
        [_attendBtn setTitle:INVITE_ONLY_BTN_TEXT forState:UIControlStateNormal];
        _attendBtn.backgroundColor = [UIColor lightGrayColor];
        _attendBtn.userInteractionEnabled = NO;
        _partyNameField.hidden = YES;
        _partyAddressField.hidden = YES;
        
    }
    // party requires a request and viewing user has already requested
    else if ([_partyInvite isEqualToString:@"Request + approval"] &&
             [[usersRequested valueForKey:@"user__full_name"] containsObject:GetUserName] &&
             (!([_partyCreator isEqualToString:GetUserName]))) {
        [_attendBtn setTitle:REQUESTED_BTN_TEXT forState:UIControlStateNormal];
        _attendBtn.backgroundColor = [UIColor lightGrayColor];
        _attendBtn.userInteractionEnabled = NO;
    }
    // party requires a request and viewing user has not already requested
    else if ([_partyInvite isEqualToString:@"Request + approval"] &&
             (![[usersRequested valueForKey:@"user__full_name"] containsObject:GetUserName]) &&
             (!([_partyCreator isEqualToString:GetUserName]))) {
        [_attendBtn setTitle:REQUEST_BTN_TEXT forState:UIControlStateNormal];
    }
    else {
        [_attendBtn setTitle:DEFAULT_BTN_TEXT forState:UIControlStateNormal];
    }   
}

#pragma mark - Button functions

- (IBAction)onBack:(id)sender {
    if (_popToRoot) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onMore:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Report Event"
                                                    otherButtonTitles:@"View Host", nil];
    if ([_partyCreator isEqualToString:GetUserName]) {
        [actionSheet addButtonWithTitle:@"Delete Event"];
    }
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure you want to report this event?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        alert.delegate = self;
        alert.tag = 100;
        [alert show];
    }
    else if (buttonIndex == 1) {
        AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
        accountViewController.userURL = _creatorUrl;
        accountViewController.needBack = YES;
        [self.navigationController pushViewController:accountViewController animated:YES];
    }
    else if (buttonIndex == 2){
//        NSLog(@"Cancel button clicked");
    }
    else if (buttonIndex == 3) {
        [self deleteEvent];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100 && buttonIndex == 1 ) {
        checkNetworkReachability();
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *strURL = [NSString stringWithFormat:@"%@%@/", FLAGURL, _partyId];
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
                                                               description:REPORT_EVENT
                                                                      type:TWMessageBarMessageTypeSuccess
                                                                  duration:3.0];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        });
    }
}

- (void)deleteEvent {
    checkNetworkReachability();
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *strURL = [NSString stringWithFormat:@"%@", _partyUrl];
        NSURL *url = [NSURL URLWithString:strURL];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:60];
        [urlRequest setHTTPMethod:@"DELETE"];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
        [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            [self setBusy:NO];
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Success"
                                                           description:@"Your event has been deleted"
                                                                  type:TWMessageBarMessageTypeSuccess
                                                              duration:3.0];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    });
}

- (IBAction)onAttend:(id)sender {
    if ([[usersRequested valueForKey:@"user__full_name"] containsObject:GetUserName]) {
        return;
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *strURL = [NSString stringWithFormat:@"%@%@/", PARTYATTENDURL, _partyId];
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
                
                if ([data length] > 0 && error == nil) {
                    NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

                    if (JSONValue != nil) {
                        
                        // user not attending and anyone can attend
                        if ([_attendBtn.titleLabel.text isEqual:DEFAULT_BTN_TEXT]) {
                            [_attendBtn setTitle:ATTENDING_BTN_TEXT forState:UIControlStateNormal];
                            _attendBtn.backgroundColor = [UIColor colorWithRed:59/255.0 green:199/255.0 blue:114/255.0 alpha:1.0];
                            _attendBtn.userInteractionEnabled = NO;
                        }
                        // user not attending and can request an invite
                        else if ([_attendBtn.titleLabel.text isEqual:REQUEST_BTN_TEXT]) {
                            [_attendBtn setTitle:REQUESTED_BTN_TEXT forState:UIControlStateNormal];
                            _attendBtn.backgroundColor = [UIColor lightGrayColor];
                            _attendBtn.userInteractionEnabled = NO;
                            _attendBtn.userInteractionEnabled = NO;
                            [usersRequested addObject:GetUserName];
                        }
                        // user not attending and invite only event
                        else if ([_attendBtn.titleLabel.text isEqual:INVITE_ONLY_BTN_TEXT]) {
                            _attendBtn.userInteractionEnabled = NO;
                            return;
                        }
                        else {
                            [_attendBtn setTitle:DEFAULT_BTN_TEXT forState:UIControlStateNormal];
                            _attendBtn.backgroundColor = [UIColor colorWithRed:244/255.0 green:72/255.0 blue:73/255.0 alpha:1.0];
                            _attendBtn.userInteractionEnabled = NO;
                        }
                    }
                } else {
                    [self showMessage:SERVER_ERROR];
                }
            }];
            [self setBusy:NO];
        });
    }
}

- (IBAction)onRequests:(id)sender {
    if ([_partyCreator isEqualToString:GetUserName]) {
        RequestsViewController *requestsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RequestsViewController"];
        requestsViewController.arrDetails = usersRequested.mutableCopy;
        requestsViewController.partyId = _partyId;
        [self.navigationController pushViewController:requestsViewController animated:YES];
    } else {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:@"You must be the event creator to view this" closeButtonTitle:@"OK" duration:0.0f];
    }
}

- (IBAction)onAttendees:(id)sender {
    FollowViewController *followViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowViewController"];
    followViewController.pageTitle = @"Attendees";
    followViewController.arrDetails = usersAttending.mutableCopy;
    [self.navigationController pushViewController:followViewController animated:YES];
}

- (IBAction)onLike:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *strURL = [NSString stringWithFormat:@"%@%@/", PARTYLIKEURL, _partyId];
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
            
            if ([data length] > 0 && error == nil) {
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                if (JSONValue != nil) {
                    int likecount = (int)[usersLiked count];

                    if ([[usersLiked valueForKey:@"user__full_name"] containsObject:GetUserName]) {
                        for(int i = 0; i < [usersLiked count]; i++){
                            NSMutableDictionary *dict = [usersLiked objectAtIndex:i];
                            
                            if ([[dict objectForKey:@"user__full_name"]isEqualToString:GetUserName]) {
                                [usersLiked removeObjectAtIndex:i];
                            }
                        }

                        [_likeImg setImage:[UIImage imageNamed:@"like_icon_default"]];
                        _likeCountLabel.textColor = [UIColor colorWithRed:165/255.0 green:169/255.0 blue:171/255.0 alpha:1.0];
                        likecount--;
                    }
                    else {
                        NSMutableDictionary *dictUser = [[NSMutableDictionary alloc]init];
                        [dictUser setValue:GetUserName forKey:@"user__full_name"];
                        [usersLiked addObject:dictUser];

                        [_likeImg setImage:[UIImage imageNamed:@"like_icon_active"]];
                        _likeCountLabel.textColor = [UIColor whiteColor];
                        likecount++;
                    }
                    _likeCountLabel.text = [NSString stringWithFormat:@"%d", likecount];
                }
            } else {
                [self showMessage:SERVER_ERROR];
            }
        }];
        [self setBusy:NO];
    });
}

@end
