//
//  PreviewViewController.m
//  Pulse
//

#import <Photos/Photos.h>

#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "HomeViewController.h"
#import "PartyViewController.h"
#import "PreviewViewController.h"
#import "SCLAlertView.h"
#import "UIViewControllerAdditions.h"


@interface PreviewViewController () {
    AppDelegate *appDelegate;
}

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    _partyImageField.layer.borderWidth = 4;
    _partyImageField.layer.borderColor = [[UIColor whiteColor] CGColor];
    _partyImageField.layer.cornerRadius = 10;
    _partyImageField.layer.masksToBounds = YES;

    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
    
    if ([_partyType isEqualToString:@"Custom"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"custom_icon"]];
        [_partyImageField setImage:[UIImage imageNamed:@"custom_icon"]];
    }
    else if ([_partyType isEqualToString:@"Social"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"social_icon"]];
        [_partyImageField setImage:[UIImage imageNamed:@"social_icon"]];
    }
    else if ([_partyType isEqualToString:@"Holiday"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"holiday_icon"]];
        [_partyImageField setImage:[UIImage imageNamed:@"holiday_icon"]];
    }
    else if ([_partyType isEqualToString:@"Event"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"event_icon"]];
        [_partyImageField setImage:[UIImage imageNamed:@"event_icon"]];
    }
    else if ([_partyType isEqualToString:@"Rager"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"rager_icon"]];
        [_partyImageField setImage:[UIImage imageNamed:@"rager_icon"]];
    }
    else if ([_partyType isEqualToString:@"Themed"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"themed_icon"]];
        [_partyImageField setImage:[UIImage imageNamed:@"themed_icon"]];
    }
    else if ([_partyType isEqualToString:@"Celebration"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"celebration_icon"]];
        [_partyImageField setImage:[UIImage imageNamed:@"celebration_icon"]];
    }
    
    if ([_partyInvite isEqualToString:@"15"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"open_icon"]];
    }
    else if ([_partyInvite isEqualToString:@"16"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"invite_only_icon"]];
    }
    else if ([_partyInvite isEqualToString:@"17"]) {
        [_inviteIcon setImage:[UIImage imageNamed:@"request_icon"]];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    [super viewWillAppear:YES];
    
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

#pragma mark - Image picker

- (IBAction)addImage:(id)sender {
    [self requestAuthorizationWithRedirectionToSettings];
}

- (void)requestAuthorizationWithRedirectionToSettings {
    dispatch_async(dispatch_get_main_queue(), ^{
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized)
        {
            // We have permission
            [self handleChangingImage];
        }
        else
        {
            // No permission. Trying to normally request it
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status != PHAuthorizationStatusAuthorized)
                {
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Event picture" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *pickFromGallery = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:NULL];
        } else {
            return;
        }
    }];
    
    UIAlertAction *takeAPicture = [UIAlertAction actionWithTitle:@"Choose a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
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
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        // Do something on cancel
    }];
    
    [alertController addAction:pickFromGallery];
    [alertController addAction:takeAPicture];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info {

    [picker dismissViewControllerAnimated:YES completion:nil];
    [_partyImageField setImage:nil];
    [_partyImageField setImage:image];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Functions

- (IBAction)onPrevious:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onProceed:(id)sender {
    checkNetworkReachability();
    [self setBusy:YES];
    
    NSString *myUniqueName = [NSString stringWithFormat:@"%@-%lu", @"event", (unsigned long)([[NSDate date] timeIntervalSince1970]*10.0)];

    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];

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
    
    [_params setObject:_partyInvite forKey:@"invite_type"];
    [_params setObject:_usersInvited forKey:@"invited_user_ids"];
    [_params setObject:_partyName forKey:@"name"];
    [_params setObject:_partyAddress forKey:@"location"];
    [_params setObject:_partyLatitude forKey:@"latitude"];
    [_params setObject:_partyLongitude forKey:@"longitude"];
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm a";
    NSDate *start_time = [dateFormatter dateFromString:_partyStartTime];
    NSDate *end_time = [dateFormatter dateFromString:_partyEndTime];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *start_time_24 = [dateFormatter stringFromDate:start_time];
    NSString *end_time_24 = [dateFormatter stringFromDate:end_time];
    [_params setObject:start_time_24 forKey:@"start_time"];
    [_params setObject:end_time_24 forKey:@"end_time"];

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
    if (imageData && !([[UIImage imageNamed:@"balloons_icon" ] isEqual:_partyImageField.image])){
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
                        // [self.navigationController popToRootViewControllerAnimated:YES];
                        PartyViewController *partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];
                        partyViewController.partyUrl = [JSONValue objectForKey:@"party_url"];
                        partyViewController.popToRoot = YES;
                        [self.navigationController pushViewController:partyViewController animated:YES];
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
