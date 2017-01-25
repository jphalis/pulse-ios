//
//  GuestsCreateViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "DateCreateViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "GuestsCreateViewController.h"
#import "SCLAlertView.h"
#import "UIViewControllerAdditions.h"

#import <GooglePlaces/GooglePlaces.h>


@interface GuestsCreateViewController () <CLLocationManagerDelegate, UIActionSheetDelegate, GMSAutocompleteViewControllerDelegate> {
    AppDelegate *appDelegate;
}

- (IBAction)onClick:(id)sender;

enum{
    BTNSMALL = 0,
    BTNMED,
    BTNLARGE,
};

@end

@implementation GuestsCreateViewController {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
    
    _partyNameField.delegate = self;

    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    [super viewWillAppear:YES];
    
    // partyNameField attributes
    _partyNameField.layer.cornerRadius = 7;
    
    // partyAddressField attributes
    _partyAddressField.layer.cornerRadius = 7;
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

#pragma mark - Google Functions

// Present the autocomplete view controller when the button is pressed.
- (IBAction)onLaunchClicked:(id)sender {
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [[UINavigationBar appearance] setBarTintColor:[UIColor darkGrayColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor lightGrayColor]];
    acController.tableCellBackgroundColor = [UIColor darkGrayColor];
    acController.primaryTextHighlightColor = [UIColor whiteColor];
    acController.primaryTextColor = [UIColor lightGrayColor];
    acController.secondaryTextColor = [UIColor lightGrayColor];
    acController.tableCellSeparatorColor = [UIColor whiteColor];
    [self presentViewController:acController animated:YES completion:nil];
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
//    NSLog(@"Place name %@", place.name);
//    NSLog(@"Place attributions %@", place.attributions.string);
    _partyAddressField.text = place.formattedAddress;
    _partyLatitude = [NSString stringWithFormat:@"%.8f", place.coordinate.latitude];
    _partyLongitude = [NSString stringWithFormat:@"%.8f", place.coordinate.longitude];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
//    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Functions

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self animateTextField: textField up: NO];
}

- (void)animateTextField:(UITextField*)textField up: (BOOL) up{
    float val;
    
    if(self.view.frame.size.height == 480){
        val = 0.75;
    } else {
        val = 0.65;
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
    if (textField.tag == 0){
        [_partyNameField resignFirstResponder];
    }
    return YES;
}

- (BOOL)checkParty{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([_partyNameField.text isEqualToString:@""]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PARTY_NAME closeButtonTitle:@"OK" duration:0.0f];
        [alert alertIsDismissed:^{
            [_partyNameField becomeFirstResponder];
        }];
        return NO;
    }
    else if ([_partyAddressField.text isEqualToString:@""]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PARTY_ADDRESS closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    else if ([_partySize isEqualToString:@""] || _partySize == nil){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PARTY_SIZE closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    return YES;
}

#pragma mark - Current Location

- (IBAction)onLocation:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    [locationManager requestWhenInUseAuthorization];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    // NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        _partyLatitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        _partyLongitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
    // NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        // NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            _partyAddressField.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                       placemark.subThoroughfare, placemark.thoroughfare,
                                       placemark.postalCode, placemark.locality,
                                       placemark.administrativeArea,
                                       placemark.country];
        } else {
            // NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}

#pragma mark - Party Size

- (IBAction)onClick:(id)sender {
    switch ([sender tag]) {
        case BTNSMALL:{
            _smallPartyIcon.layer.borderWidth = 3;
            _smallPartyIcon.layer.borderColor = [[UIColor greenColor] CGColor];
            _smallPartyIcon.layer.cornerRadius = _smallPartyIcon.frame.size.width / 2;
            _partySize = @"1-25";
            
            _mediumPartyIcon.layer.borderWidth = 0;
            _largePartyIcon.layer.borderWidth = 0;
            break;
        }
        case BTNMED:{
            _mediumPartyIcon.layer.borderWidth = 3;
            _mediumPartyIcon.layer.borderColor = [[UIColor greenColor] CGColor];
            _mediumPartyIcon.layer.cornerRadius = _mediumPartyIcon.frame.size.width / 2;
            _partySize = @"25-100";
            
            _smallPartyIcon.layer.borderWidth = 0;
            _largePartyIcon.layer.borderWidth = 0;
            break;
        }
        case BTNLARGE:{
            _largePartyIcon.layer.borderWidth = 3;
            _largePartyIcon.layer.borderColor = [[UIColor greenColor] CGColor];
            _largePartyIcon.layer.cornerRadius = _largePartyIcon.frame.size.width / 2;
            _partySize = @"100+";
            
            _smallPartyIcon.layer.borderWidth = 0;
            _mediumPartyIcon.layer.borderWidth = 0;
            break;
        }
        default: {
            break;
        }
    }
}

- (IBAction)onPrevious:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onScratch:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Are you sure you want to scratch this party?"
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Yes", @"No", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        return;
    }
}

- (IBAction)onProceed:(id)sender {
    if ([self checkParty]){
        DateCreateViewController *dateCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DateCreateViewController"];
        dateCreateViewController.partyInvite = _partyInvite;
        dateCreateViewController.usersInvited = _usersInvited;
        dateCreateViewController.partyType = _partyType;
        dateCreateViewController.partyName = _partyNameField.text;
        dateCreateViewController.partyAddress = _partyAddressField.text;
        dateCreateViewController.partyLatitude = _partyLatitude;
        dateCreateViewController.partyLongitude = _partyLongitude;
        dateCreateViewController.partySize = _partySize;
        [self.navigationController pushViewController:dateCreateViewController animated:YES];
    }
}

@end
