//
//  PartyViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "PartyViewController.h"
#import "UIViewControllerAdditions.h"


#define DEFAULT_BTN_TEXT @"Let's go!"
#define ATTENDING_BTN_TEXT @"Going!"


@interface PartyViewController () {
    AppDelegate *appDelegate;
}

@end

@implementation PartyViewController

@synthesize usersAttending;

- (void)viewDidLoad {
    if (_partyUrl){
        [self getPartyDetails];
    }

    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
    
    // Go back when swipe right
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    [super viewWillAppear:YES];
    
    if (!_partyUrl){
        [self showPartyInfo];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
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

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAttend:(id)sender {
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
            
            if ([data length] > 0 && error == nil){
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if (JSONValue != nil){
                    if ([_attendBtn.titleLabel.text isEqual:DEFAULT_BTN_TEXT]){
                        [_attendBtn setTitle:ATTENDING_BTN_TEXT forState:UIControlStateNormal];
                    } else {
                        [_attendBtn setTitle:DEFAULT_BTN_TEXT forState:UIControlStateNormal];
                    }
                }
            } else {
                [self showMessage:SERVER_ERROR];
            }
        }];
        [self setBusy:NO];
    });
}

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
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){

        if ([data length] > 0 && error == nil){
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]]){
                int partyId = [[JSONValue valueForKey:@"id"]intValue];
                _partyId = [NSString stringWithFormat:@"%d", partyId];
                // _partyInvite =
                _partyType = [JSONValue valueForKey:@"party_type"];
                _partyName = [JSONValue valueForKey:@"name"];
                _partyAddress = [JSONValue valueForKey:@"location"];
                _partySize = [JSONValue valueForKey:@"party_size"];
                int partyMonth = [[JSONValue valueForKey:@"party_month"]intValue];
                _partyMonth = [NSString stringWithFormat:@"%d", partyMonth];
                int partyDay = [[JSONValue valueForKey:@"party_day"]intValue];
                _partyDay = [NSString stringWithFormat:@"%d", partyDay];
                _partyStartTime = [JSONValue valueForKey:@"start_time"];
                _partyEndTime = [JSONValue valueForKey:@"end_time"];
                if ([JSONValue valueForKey:@"image"] == [NSNull null]){
                    _partyImage = @"";
                } else {
                    NSString *str = [JSONValue valueForKey:@"image"];
                    _partyImage = [NSString stringWithFormat:@"https://oby.s3.amazonaws.com/media/%@", str];
                }
                _partyDescription = [JSONValue valueForKey:@"description"];
                _partyAttending = [NSString abbreviateNumber:[[JSONValue valueForKey:@"attendees_count"]intValue]];
                _partyRequests = [NSString abbreviateNumber:[[JSONValue valueForKey:@"attendees_count"]intValue]];

                if (!([JSONValue valueForKey:@"get_attendees_info"] == [NSNull null])){
                    NSMutableArray *arrAttendee = [JSONValue valueForKey:@"get_attendees_info"];
                    usersAttending = [[NSMutableArray alloc]init];
                    
                    for(int i = 0; i < arrAttendee.count; i++){
                        NSMutableDictionary *dictAttendeeInfo = [[NSMutableDictionary alloc]init];
                        NSDictionary *dictUserDetail = [arrAttendee objectAtIndex:i];
                        
                        if([dictUserDetail objectForKey:@"profile_pic"] == [NSNull null]){
                            [dictAttendeeInfo setObject:@"" forKey:@"user__profile_pic"];
                        } else {
                            NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"profile_pic"]];
                            [dictAttendeeInfo setValue:proflURL forKey:@"user__profile_pic"];
                        }
                        
                        if([dictUserDetail objectForKey:@"full_name"] == [NSNull null]){
                            [dictAttendeeInfo setObject:@"" forKey:@"user__full_name"];
                        } else {
                            [dictAttendeeInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                        }
                        
                        [usersAttending addObject:dictAttendeeInfo];
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
    [_partyImageField loadImageFromURL:_partyImage withTempImage:@"camera_icon"];
    _partyImageField.layer.borderWidth = 4;
    _partyImageField.layer.borderColor = [[UIColor whiteColor] CGColor];
    _partyImageField.layer.cornerRadius = 10;
    _partyImageField.layer.masksToBounds = YES;
    
    NSInteger monthNumber = [_partyMonth integerValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *monthName = [[dateFormatter monthSymbols] objectAtIndex:(monthNumber-1)];
    _partyDateTimeField.text = [NSString stringWithFormat:@"%@ %@, 2016  %@-%@", monthName, _partyDay, _partyStartTime, _partyEndTime];
    
    _partyNameField.text = _partyName;
    _partyAddressField.text = _partyAddress;
    _partyAttendingField.text = _partyAttending;
    _partyRequestsField.text = _partyRequests;
    _partyDescriptionField.text = _partyDescription;
    
    if ([[usersAttending valueForKey:@"user__full_name"] containsObject:GetUserName]) {
        [_attendBtn setTitle:ATTENDING_BTN_TEXT forState:UIControlStateNormal];
    } else {
        [_attendBtn setTitle:DEFAULT_BTN_TEXT forState:UIControlStateNormal];
    }
}

@end
