//
//  PreviewViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "PreviewViewController.h"
#import "SCLAlertView.h"
#import "UIViewControllerAdditions.h"


@interface PreviewViewController () {
    AppDelegate *appDelegate;
}

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    [super viewWillAppear:YES];
    
    _partyImageField.layer.borderWidth = 4;
    _partyImageField.layer.borderColor = [[UIColor whiteColor] CGColor];
    _partyImageField.layer.cornerRadius = 10;
    _partyImageField.layer.masksToBounds = YES;
    
    _partyNameField.text = _partyName;
    
    NSInteger monthNumber = [_partyMonth integerValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *monthName = [[dateFormatter monthSymbols] objectAtIndex:(monthNumber-1)];
    _partyDateTimeField.text = [NSString stringWithFormat:@"%@ %@, %@  %@-%@", monthName, _partyDay, _partyYear, _partyStartTime, _partyEndTime];
    
    _partyAddressField.text = _partyAddress;
    
    _partyDescriptionField.text = _partyDescription;
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

#pragma mark - Functions

- (IBAction)addImage:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showInfo:self title:@"Notice" subTitle:@"Add image here." closeButtonTitle:@"OK" duration:0.0f];
}

- (IBAction)onPrevious:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onProceed:(id)sender {
    checkNetworkReachability();
    [self setBusy:YES];
    
    NSString *myUniqueName = [NSString stringWithFormat:@"%@-%lu", @"event", (unsigned long)([[NSDate date] timeIntervalSince1970]*10.0)];

    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    // [_params setObject:_partyInvite forKey:@"invite_type"];
    NSString *serverPartyType;
    if ([_partyType isEqualToString:@"Custom"]){
        serverPartyType = @"0";
    }
    else if ([_partyType isEqualToString:@"Social"]) {
        serverPartyType = @"1";
    }
    else if ([_partyType isEqualToString:@"Holiday"]) {
        serverPartyType = @"2";
    }
    else if ([_partyType isEqualToString:@"Event"]) {
        serverPartyType = @"3";
    }
    else if ([_partyType isEqualToString:@"Rager"]) {
        serverPartyType = @"4";
    }
    else if ([_partyType isEqualToString:@"Themed"]) {
        serverPartyType = @"5";
    }
    else if ([_partyType isEqualToString:@"Celebration"]) {
        serverPartyType = @"6";
    }
    [_params setObject:serverPartyType forKey:@"party_type"];
    
    [_params setObject:_partyName forKey:@"name"];
    [_params setObject:_partyAddress forKey:@"location"];
    NSString *serverPartySize;
    if ([_partySize isEqualToString:@"1-25"]){
        serverPartySize = @"10";
    }
    else if ([_partySize isEqualToString:@"25-100"]) {
        serverPartySize = @"11";
    }
    else if ([_partySize isEqualToString:@"100+"]) {
        serverPartySize = @"12";
    }
    [_params setObject:serverPartySize forKey:@"party_size"];
    [_params setObject:_partyMonth forKey:@"party_month"];
    [_params setObject:_partyDay forKey:@"party_day"];
    [_params setObject:_partyYear forKey:@"party_year"];
    [_params setObject:_partyStartTime forKey:@"start_time"];
    [_params setObject:_partyEndTime forKey:@"end_time"];
    [_params setObject:_partyDescription forKey:@"description"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'image'
    NSString *FileParamConstant = @"image";
    
    // the server url to which the image (or the media) is uploaded
    NSURL *requestURL = [NSURL URLWithString:PARTYCREATEURL];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(_partyImageField.image, 1.0);
    if (imageData && !([[UIImage imageNamed:@"camera_icon" ] isEqual:_partyImageField.image])){
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", FileParamConstant,myUniqueName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the request
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
        
        if ([data length] > 0 && error == nil){
            [self setBusy:NO];
            
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]]){
                if([JSONValue objectForKey:@"id"]){
                    SCLAlertView *alert = [[SCLAlertView alloc] init];
                    alert.showAnimationType = SlideInFromLeft;
                    alert.hideAnimationType = SlideOutToBottom;
                    [alert showInfo:self title:@"Notice" subTitle:PARTY_CREATED closeButtonTitle:@"OK" duration:0.0f];
                    [alert alertIsDismissed:^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }];
                }
            }
        } else {
            showServerError();
        }
        [self setBusy:NO];
    }];
}

@end
