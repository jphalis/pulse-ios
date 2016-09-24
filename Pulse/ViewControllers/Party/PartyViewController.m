//
//  PartyViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "defs.h"
#import "FollowViewController.h"
#import "GlobalFunctions.h"
#import "PartyViewController.h"
#import "RequestsViewController.h"
#import "TWMessageBarManager.h"
#import "UIViewControllerAdditions.h"


#define DEFAULT_BTN_TEXT @"Let's go!"
#define ATTENDING_BTN_TEXT @"Going!"
#define REQUEST_BTN_TEXT @"Request invite!"
#define REQUESTED_BTN_TEXT @"Requested"
#define INVITE_ONLY_BTN_TEXT @"Invite only event"


@interface PartyViewController ()
{
    AppDelegate *appDelegate;
}

@end

@implementation PartyViewController

@synthesize usersAttending, usersRequested, usersInvited;

- (void)viewDidLoad
{

    if (_partyUrl)
    {
        [self getPartyDetails];
    }

    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
    
    // Go back when swipe right
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated
{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    [super viewWillAppear:YES];
    
    if (!_partyUrl)
    {
        [self showPartyInfo];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
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

-(void)getPartyDetails
{
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

        if ([data length] > 0 && error == nil)
        {
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]])
            {
                int partyId = [[JSONValue valueForKey:@"id"]intValue];
                _partyId = [NSString stringWithFormat:@"%d", partyId];
                _partyCreator = [JSONValue valueForKey:@"user"];
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
                _partyEndTime = [JSONValue valueForKey:@"end_time"];
                if ([JSONValue valueForKey:@"image"] == [NSNull null])
                {
                    _partyImage = @"";
                }
                else
                {
                    _partyImage = [JSONValue valueForKey:@"image"];
                }
                _partyDescription = [JSONValue valueForKey:@"description"];
                _partyAttending = [NSString abbreviateNumber:[[JSONValue valueForKey:@"attendees_count"]intValue]];
                _partyRequests = [NSString abbreviateNumber:[[JSONValue valueForKey:@"requesters_count"]intValue]];

                if (!([JSONValue valueForKey:@"get_attendees_info"] == [NSNull null]))
                {
                    NSMutableArray *arrAttendee = [JSONValue valueForKey:@"get_attendees_info"];
                    usersAttending = [[NSMutableArray alloc]init];
                    
                    for(int i = 0; i < arrAttendee.count; i++)
                    {
                        NSMutableDictionary *dictAttendeeInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrAttendee objectAtIndex:i];
                        
                        if([dictUserDetail objectForKey:@"profile_pic"] == [NSNull null])
                        {
                            [dictAttendeeInfo setObject:@"" forKey:@"user__profile_pic"];
                        }
                        else
                        {
                            [dictAttendeeInfo setValue:[dictUserDetail objectForKey:@"profile_pic"] forKey:@"user__profile_pic"];
                        }
                        
                        if([dictUserDetail objectForKey:@"id"] == [NSNull null])
                        {
                            [dictAttendeeInfo setObject:@"" forKey:@"user__id"];
                        }
                        else
                        {
                            [dictAttendeeInfo setObject:[NSString stringWithFormat:@"%@",[dictUserDetail objectForKey:@"id"]] forKey:@"user__id"];
                        }
                        
                        if([dictUserDetail objectForKey:@"full_name"] == [NSNull null])
                        {
                            [dictAttendeeInfo setObject:@"" forKey:@"user__full_name"];
                        }
                        else
                        {
                            [dictAttendeeInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                        }
                        
                        [usersAttending addObject:dictAttendeeInfo];
                    }
                }

                if (!([JSONValue valueForKey:@"get_requesters_info"] == [NSNull null]))
                {
                    NSMutableArray *arrRequester = [JSONValue valueForKey:@"get_requesters_info"];
                    usersRequested = [[NSMutableArray alloc]init];
                    
                    for(int i = 0; i < arrRequester.count; i++)
                    {
                        NSMutableDictionary *dictRequesterInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrRequester objectAtIndex:i];
                        
                        if([dictUserDetail objectForKey:@"profile_pic"] == [NSNull null])
                        {
                            [dictRequesterInfo setObject:@"" forKey:@"user__profile_pic"];
                        }
                        else
                        {
                            [dictRequesterInfo setValue:[dictUserDetail objectForKey:@"profile_pic"] forKey:@"user__profile_pic"];
                        }
                        
                        if([dictUserDetail objectForKey:@"id"] == [NSNull null])
                        {
                            [dictRequesterInfo setObject:@"" forKey:@"user__id"];
                        }
                        else
                        {
                            [dictRequesterInfo setObject:[NSString stringWithFormat:@"%@", [dictUserDetail objectForKey:@"id"]] forKey:@"user__id"];
                        }
                        
                        if([dictUserDetail objectForKey:@"full_name"] == [NSNull null])
                        {
                            [dictRequesterInfo setObject:@"" forKey:@"user__full_name"];
                        }
                        else
                        {
                            [dictRequesterInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                        }
                        
                        [usersRequested addObject:dictRequesterInfo];
                    }
                }
                
                if (!([JSONValue valueForKey:@"get_invited_users_info"] == [NSNull null]))
                {
                    NSMutableArray *arrInvited = [JSONValue valueForKey:@"get_invited_users_info"];
                    usersInvited = [[NSMutableArray alloc]init];
                    
                    for(int i = 0; i < arrInvited.count; i++)
                    {
                        NSMutableDictionary *dictInvitedInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrInvited objectAtIndex:i];
                        
                        if([dictUserDetail objectForKey:@"profile_pic"] == [NSNull null])
                        {
                            [dictInvitedInfo setObject:@"" forKey:@"user__profile_pic"];
                        }
                        else
                        {
                            [dictInvitedInfo setValue:[dictUserDetail objectForKey:@"profile_pic"] forKey:@"user__profile_pic"];
                        }
                        
                        if([dictUserDetail objectForKey:@"id"] == [NSNull null])
                        {
                            [dictInvitedInfo setObject:@"" forKey:@"user__id"];
                        }
                        else
                        {
                            [dictInvitedInfo setObject:[NSString stringWithFormat:@"%@", [dictUserDetail objectForKey:@"id"]] forKey:@"user__id"];
                        }
                        
                        if([dictUserDetail objectForKey:@"full_name"] == [NSNull null])
                        {
                            [dictInvitedInfo setObject:@"" forKey:@"user__full_name"];
                        }
                        else
                        {
                            [dictInvitedInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                        }
                        
                        [usersInvited addObject:dictInvitedInfo];
                    }
                }

                [self showPartyInfo];
            }
        }
        else
        {
            showServerError();
        }
    }];
}

-(void)showPartyInfo
{
    [_partyImageField loadImageFromURL:_partyImage withTempImage:@"camera_icon"];
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
    
    // viewing user is attending party
    if ([[usersAttending valueForKey:@"user__full_name"] containsObject:GetUserName])
    {
        [_attendBtn setTitle:ATTENDING_BTN_TEXT forState:UIControlStateNormal];
    }
    // party is invite only and viewing user is not on list
    else if ([_partyInvite isEqualToString:@"Invite only"] &&
             (!([_partyCreator isEqualToString:GetUserName])) &&
             (!([[usersInvited valueForKey:@"user__full_name"] containsObject:GetUserName])))
    {
        [_attendBtn setTitle:INVITE_ONLY_BTN_TEXT forState:UIControlStateNormal];
        _attendBtn.backgroundColor = [UIColor lightGrayColor];
        _attendBtn.userInteractionEnabled = NO;
    }
    // party requires a request and viewing user has already requested
    else if ([_partyInvite isEqualToString:@"Request + approval"] &&
             [[usersRequested valueForKey:@"user__full_name"] containsObject:GetUserName] &&
             (!([_partyCreator isEqualToString:GetUserName])))
    {
        [_attendBtn setTitle:REQUESTED_BTN_TEXT forState:UIControlStateNormal];
        _attendBtn.backgroundColor = [UIColor lightGrayColor];
    }
    // party requires a request and viewing user has not already requested
    else if ([_partyInvite isEqualToString:@"Request + approval"] &&
             (![[usersRequested valueForKey:@"user__full_name"] containsObject:GetUserName]) &&
             (!([_partyCreator isEqualToString:GetUserName])))
    {
        [_attendBtn setTitle:REQUEST_BTN_TEXT forState:UIControlStateNormal];
    }
    else
    {
        [_attendBtn setTitle:DEFAULT_BTN_TEXT forState:UIControlStateNormal];
    }   
}

#pragma mark - Button functions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onMore:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Report Event"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure you want to report this event?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        alert.delegate = self;
        alert.tag = 100;
        [alert show];
    }
    else if(buttonIndex == 1)
    {
        // NSLog(@"Cancel button clicked");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 && buttonIndex == 1 )
    {
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

- (IBAction)onAttend:(id)sender
{
    if ([[usersRequested valueForKey:@"user__full_name"] containsObject:GetUserName])
    {
        return;
    }
    else
    {
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
                
                if ([data length] > 0 && error == nil)
                {
                    NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

                    if (JSONValue != nil)
                    {
                        if ([_attendBtn.titleLabel.text isEqual:DEFAULT_BTN_TEXT])
                        {
                            [_attendBtn setTitle:ATTENDING_BTN_TEXT forState:UIControlStateNormal];
                        }
                        else if ([_attendBtn.titleLabel.text isEqual:REQUEST_BTN_TEXT])
                        {
                            [_attendBtn setTitle:REQUESTED_BTN_TEXT forState:UIControlStateNormal];
                            _attendBtn.backgroundColor = [UIColor lightGrayColor];
                            [usersRequested addObject:GetUserName];
                        }
                        else if ([_attendBtn.titleLabel.text isEqual:INVITE_ONLY_BTN_TEXT])
                        {
                            return;
                        }
                        else
                        {
                            [_attendBtn setTitle:DEFAULT_BTN_TEXT forState:UIControlStateNormal];
                        }
                    }
                }
                else
                {
                    [self showMessage:SERVER_ERROR];
                }
            }];
            [self setBusy:NO];
        });
    }
}

- (IBAction)onRequests:(id)sender
{
    if ([_partyCreator isEqualToString:GetUserName])
    {
        RequestsViewController *requestsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RequestsViewController"];
        requestsViewController.arrDetails = usersRequested.mutableCopy;
        requestsViewController.partyId = _partyId;
        [self.navigationController pushViewController:requestsViewController animated:YES];
    }
}

- (IBAction)onAttendees:(id)sender
{
    FollowViewController *followViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowViewController"];
    followViewController.pageTitle = @"Attendees";
    followViewController.arrDetails = usersAttending.mutableCopy;
    [self.navigationController pushViewController:followViewController animated:YES];
}

@end
